# Backend Code Review
# Task Management App — Node.js + Express + TypeScript

**Reviewer:** AI Product Builder
**Date:** 2026-03-24
**Scope:** `Backend/Code/src/` — all routes, controllers, middleware, utilities

---

## Overall Assessment

The backend is clean and minimal — appropriate for a test app. The layered structure (routes → controllers → Prisma) is correct, auth is handled with proper JWT rotation and bcrypt, and errors are centralised. The items below are ordered by severity.

---

## 1. API Design & RESTful Conventions

### 1.1 `routes/projects.ts` mixes two concerns — project routes and label routes in one file
Labels are a separate resource. Inline functions at the bottom of `projects.ts` handle them, making the file grow unpredictably.
**Recommendation:** Extract to `routes/labels.ts` and `controllers/labels.controller.ts`, even if it is small.

### 1.2 `PUT /api/notifications/read-all` should come before `PUT /api/notifications/:id/read`
**File:** `src/routes/notifications.ts`
Express route matching is top-down. If `:id/read` is registered first, a request to `/read-all` would match `:id` = `"read-all"` and call `markRead` instead of `markAllRead`.

```ts
// Current — WRONG order, read-all will never be reached
router.put('/:id/read', ...);
router.put('/read-all', ...);

// Correct — specific route before parameterised route
router.put('/read-all', ...);
router.put('/:id/read', ...);
```
**Severity:** High — `markAllRead` is effectively unreachable in the current code.

### 1.3 Missing `DELETE /api/labels/:id` and `PUT /api/labels/:id` routes
These are specified in the SRS (Section 6.6) but were not implemented. Add them to `routes/labels.ts` once extracted.

### 1.4 `router.use(authenticate)` pattern causes TypeScript cast boilerplate
Every route handler casts `req as AuthRequest`. A cleaner approach is to declare a module augmentation so `Request` always has `userId` after the middleware runs:

```ts
// src/types/express.d.ts
declare global {
  namespace Express {
    interface Request {
      userId: string;
      userEmail: string;
    }
  }
}
```
This eliminates all `req as AuthRequest` casts and makes the code safer.

---

## 2. Security Vulnerabilities

### 2.1 Rate limiter is applied only to auth routes
**File:** `src/routes/auth.ts`
All other routes (task creation, comment posting, notification polling) have no rate limiting. A malicious user can enumerate projects or flood activity logs without restriction.
**Recommendation:** Add a global rate limiter in `app.ts` for all `/api/` routes, with a higher limit than the auth limiter.

```ts
// app.ts
import rateLimit from 'express-rate-limit';
const globalLimiter = rateLimit({ windowMs: 60_000, max: 300 });
app.use('/api/', globalLimiter);
```

### 2.2 `refreshToken` body field is sent in plain JSON
**File:** `src/controllers/auth.controller.ts`
The refresh token is sent in the request body, which means it is stored in browser memory/localStorage if the frontend persists it. For production, store and transmit it via `httpOnly` cookie so JavaScript cannot read it.

```ts
// auth.controller.ts — set as cookie on login/register
res.cookie('refreshToken', tokens.refreshToken, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000,
});
// Read from req.cookies.refreshToken instead of req.body
```

### 2.3 `forgotPassword` logs the reset token to console
**File:** `src/controllers/auth.controller.ts`
```ts
console.log(`[DEV] Password reset token for ${email}: ${resetToken}`);
```
This is acceptable for development but must be removed before any shared or staging deployment. The comment `// In production: ...` is present but there is no guard on `NODE_ENV`.

```ts
if (process.env.NODE_ENV === 'development') {
  console.log(`[DEV] Reset token: ${resetToken}`);
}
```

### 2.4 No `helmet` `contentSecurityPolicy` configured explicitly
`helmet()` is called with defaults, which includes a restrictive default CSP. Verify the default CSP does not break any frontend assets served from the same origin (e.g., inline scripts in `index.html`).

### 2.5 `prisma` instance is a singleton imported directly — safe, but note test implications
The singleton is mocked in tests with `jest.mock`, which is correct. Just ensure `prisma.$disconnect()` is called in a `afterAll` hook in integration tests to avoid open handles.

---

## 3. Error Handling

### 3.1 `tasks.controller.ts` — `formatTask` can return `null` and callers don't guard it
```ts
function formatTask(...): { ... } | null
// ...
res.json(formatTask(task as ...)!); // Non-null assertion on every call
```
If `task` is somehow `null` (race condition, deleted between fetch and format), the `!` suppresses the TypeScript error and a runtime crash follows.
**Recommendation:** Add an explicit null check and throw `notFoundError` before calling `formatTask`.

```ts
const formatted = formatTask(task);
if (!formatted) throw notFoundError('Task');
res.json(formatted);
```

### 3.2 Unhandled promise rejection in `dashboard.controller.ts` — `date-fns` import
`date-fns` is listed as a frontend dependency only (in `Frontend/Code/package.json`). The backend `dashboard.controller.ts` imports `subDays`, `startOfDay`, and `format` from `date-fns` but `date-fns` is not in `Backend/Code/package.json`.
**Severity:** High — the backend will crash at startup with `Cannot find module 'date-fns'`.
**Fix:** Add `date-fns` to `Backend/Code/package.json` dependencies.

```json
"date-fns": "^3.3.1"
```

### 3.3 `errorHandler` swallows the original error object on Zod failures
**File:** `src/middleware/errorHandler.ts`
The Zod branch returns `err.flatten().fieldErrors` which is good. The catch-all branch does `console.error(err)` which logs to stdout in production — use a structured logger (e.g., `pino`) instead.

### 3.4 No validation on `PUT /api/tasks/:id`
Task updates accept any JSON body. A client can send `{ "status": "INVALID_VALUE" }` and Prisma will throw a cryptic error rather than a clean 400. Add a Zod schema:

```ts
const updateTaskSchema = z.object({
  title: z.string().min(1).max(255).optional(),
  description: z.string().optional(),
  status: z.enum(['TODO','IN_PROGRESS','UNDER_REVIEW','DONE','ARCHIVED']).optional(),
  priority: z.enum(['LOW','MEDIUM','HIGH','CRITICAL']).optional(),
  dueDate: z.string().nullable().optional(),
});
```

### 3.5 `createTask` notification uses `createMany` which silently ignores failures
If a notification insert fails for one user, the others succeed and the failure is swallowed. For a test app this is acceptable; note it for production.

---

## 4. Database Query Efficiency

### 4.1 N+1 query in `listTasks` — one `subTask.count` per task
**File:** `src/controllers/tasks.controller.ts`
```ts
const enriched = await Promise.all(
  tasks.map(async (t) => {
    const doneCount = await prisma.subTask.count({ where: { taskId: t.id, isDone: true } });
    ...
  })
);
```
With 50 tasks this fires 51 queries. Fix with `groupBy`:

```ts
const doneCounts = await prisma.subTask.groupBy({
  by: ['taskId'],
  where: { taskId: { in: tasks.map(t => t.id) }, isDone: true },
  _count: { _all: true },
});
const doneByTask = Object.fromEntries(doneCounts.map(r => [r.taskId, r._count._all]));
const enriched = tasks.map(t => ({
  ...formatTask(t)!,
  subTaskDoneCount: doneByTask[t.id] ?? 0,
}));
```

### 4.2 `listProjects` does not paginate
All user projects are returned in a single query. Add `take`/`skip` pagination for users with many projects.

### 4.3 Missing database indexes beyond Prisma defaults
The `ActivityLog` table will grow large. Add an index on `(taskId, createdAt)` for the `listActivity` query. Add this to the Prisma schema:

```prisma
model ActivityLog {
  // ...
  @@index([taskId, createdAt])
}
```

Similarly, `Notification` should have `@@index([userId, createdAt])`.

### 4.4 `myTasks` in `dashboard.controller.ts` fetches all non-archived tasks assigned to a user with no limit
A user with thousands of assigned tasks will receive them all. Add `take: 100` as a reasonable default and support cursor pagination.

---

## 5. Authentication & Authorisation

### 5.1 `requireMember` throws `notFoundError` for both "project doesn't exist" and "user not a member"
This leaks information: a non-member can determine whether a project ID exists by the error message. Both cases should return the same 404 with the same message. The current implementation actually does this correctly (`notFoundError('Project')` in both cases) — just noting it is the right approach.

### 5.2 `removeMember` allows an Admin to remove the project Owner
**File:** `src/controllers/projects.controller.ts`
```ts
// The check only prevents the actor from removing themselves
if (req.params.uid === req.userId) throw badRequestError(...);
```
An Admin could call `DELETE /api/projects/:id/members/:ownerId` and successfully remove the owner.
**Fix:** Also check whether the target user is the project owner.

```ts
const targetMember = await prisma.projectMember.findUnique({
  where: { projectId_userId: { projectId: req.params.id, userId: req.params.uid } },
});
if (targetMember?.role === 'OWNER') throw forbiddenError('Cannot remove the project owner.');
```

### 5.3 Refresh token rotation is correct — good
The existing implementation deletes the old refresh token before issuing a new one, which prevents token reuse. This is the correct pattern.

### 5.4 No cleanup of expired refresh tokens
Expired `RefreshToken` rows accumulate in the database forever. Add a periodic cleanup (cron job or Prisma scheduled query) to delete rows where `expiresAt < now()`.

---

## 6. Test Coverage Assessment

| Area | Files | Coverage Notes |
|---|---|---|
| Error utilities | `errors.test.ts` | Excellent — all factory functions tested |
| JWT utilities | `jwt.test.ts` | Good — sign/verify and tamper cases covered |
| Auth middleware | `middleware.test.ts` | Good — valid/invalid/missing token cases |
| Auth routes | `auth.test.ts` | Good — register, login, logout, health, 404 |
| Project routes | None | Missing |
| Task routes | None | Missing |
| Notification routes | None | Missing |
| Dashboard routes | None | Missing |
| Comments controller | None | Missing |

**Priority additions:**
1. `projects.test.ts` — test create, list, invite member, forbidden cases
2. `tasks.test.ts` — test create, update status, delete permission checks
3. `comments.test.ts` — test author-only edit/delete enforcement
4. Add `afterAll(() => prisma.$disconnect())` to all test files that import Prisma

---

## 7. Recommendations Summary

| # | Issue | Severity | Effort |
|---|---|---|---|
| 1 | Fix route order: `read-all` must be before `/:id/read` | High | Low |
| 2 | Add `date-fns` to backend `package.json` | High | Low |
| 3 | Fix N+1 `subTask.count` using `groupBy` | High | Low |
| 4 | Add global rate limiter to all `/api/` routes | Medium | Low |
| 5 | Prevent Admin from removing the project Owner | Medium | Low |
| 6 | Add Zod validation to `PUT /api/tasks/:id` | Medium | Low |
| 7 | Add null guard before `formatTask` calls | Medium | Low |
| 8 | Guard reset-token console.log behind `NODE_ENV` check | Medium | Low |
| 9 | Add DB indexes on `ActivityLog` and `Notification` | Medium | Low |
| 10 | Move refresh token to `httpOnly` cookie | Low | Medium |
| 11 | Add pagination to `listProjects` and `myTasks` | Low | Medium |
| 12 | Add periodic cleanup of expired refresh tokens | Low | Medium |
| 13 | Add project, task, and comment route tests | Low | High |
| 14 | Add Express type augmentation to remove `AuthRequest` casts | Low | Low |
