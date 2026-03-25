# Frontend Code Review
# Task Management App — React + TypeScript + Vite

**Reviewer:** AI Product Builder
**Date:** 2026-03-24
**Scope:** `Frontend/Code/src/` — all components, hooks, pages, stores, utilities

---

## Overall Assessment

The frontend is well-structured for a simple test app. It follows modern React patterns (functional components, hooks, React Query for server state, Zustand for UI state) and has a clean separation of concerns. The items below are ordered by severity so the most impactful fixes are addressed first.

---

## 1. Code Quality & Best Practices

### 1.1 `useUpdateTask` receives a stale `taskId`
**File:** `src/hooks/useTasks.ts`
**Severity:** High — causes silent no-ops on status change from the Kanban board.

```ts
// Current — taskId is '' when called from KanbanBoard
const { mutate: updateTask } = useUpdateTask('', projectId);

// Fix — pass the real taskId at call time, not hook init time
// Option A: make updateTask accept taskId as part of the payload
export function useUpdateTask(projectId?: string) {
  return useMutation({
    mutationFn: ({ taskId, data }: { taskId: string; data: ... }) =>
      tasksApi.update(taskId, data),
    onSuccess: () => {
      if (projectId) queryClient.invalidateQueries({ queryKey: taskKeys.list(projectId) });
    },
  });
}
```

### 1.2 Prisma `TaskWhereInput` filter construction is fragile
**File:** `src/api/tasks.ts` is fine; the issue is in `tasks.controller.ts` on the backend, but the frontend compounds it by passing `status` as a comma-separated string without type-safety.
**Recommendation:** Pass `status[]` as repeated query params (`?status=TODO&status=IN_PROGRESS`) and use `URLSearchParams` in the API client so Axios serialises arrays correctly.

```ts
// api/tasks.ts
list: (projectId: string, filters?: TaskFilters) =>
  apiClient.get<Task[]>(`/projects/${projectId}/tasks`, {
    params: filters,
    paramsSerializer: (p) => new URLSearchParams(
      Object.entries(p).flatMap(([k, v]) =>
        Array.isArray(v) ? v.map((i) => [k, i]) : [[k, String(v)]]
      )
    ).toString(),
  }),
```

### 1.3 `formatTask` in the backend has a broken TypeScript signature
**File:** `Backend/Code/src/controllers/tasks.controller.ts`
**Severity:** Medium — the `Parameters<typeof formatTask>[0]` cast is an unsafe workaround and will break if Prisma types change.
**Recommendation:** Derive the type explicitly from the `findMany` include shape or use a plain Prisma result type alias.

### 1.4 Inline state in `ProjectsPage` reset is missing from `CreateProjectModal`
**File:** `src/pages/ProjectsPage.tsx`
The `name` and `description` state inside `CreateProjectModal` are local to the function component but the function is defined _inside_ `ProjectsPage`, so it re-creates on every render.
**Recommendation:** Move `CreateProjectModal` outside the parent component or memoize it.

### 1.5 `KanbanBoard` — `updateTask` called with empty `taskId`
**File:** `src/components/tasks/KanbanBoard.tsx`
```ts
// Current
const { mutate: updateTask } = useUpdateTask('', projectId);
// ...
updateTask({ status: newStatus }); // taskId is ''
```
The correct fix is to call `tasksApi.update(taskId, { status: newStatus })` directly inside `handleDragEnd` or restructure the hook as described in 1.1.

### 1.6 `DashboardPage` shows raw project IDs instead of names
**File:** `src/pages/DashboardPage.tsx`
```tsx
// Shows "Project ID: proj-abc123" — not user-friendly
<h2>Project ID: {projectId}</h2>
```
**Recommendation:** Join against the projects list query (already fetched in `useProjects`) to resolve the name client-side, or include `projectName` in the task payload from the API.

### 1.7 Missing `key` prop stability — `uuid` on render
No instances found in this codebase, but the mock handlers in `src/test/mocks/handlers.ts` generate random trend data on every call (`Math.random()`), which causes non-deterministic test snapshots. Use seeded data in tests.

---

## 2. Component Architecture

### 2.1 `AppLayout` uses a hard-coded pixel offset for sidebar width
**File:** `src/components/layout/AppLayout.tsx`
```tsx
// Hard-coded — breaks if sidebar width changes
className={cn('...', sidebarOpen ? 'ml-64' : 'ml-16')}
```
The sidebar width is also hard-coded in `Sidebar.tsx` (`w-64`, `w-16`). These should share a single source of truth — either a Tailwind theme extension or a CSS custom property.

### 2.2 `Header` imports `NotificationPanel` and renders it unconditionally
**File:** `src/components/layout/Header.tsx`
The `NotificationPanel` component renders a backdrop `div` that is always in the DOM (returning `null` when closed). Using a `null` return is fine, but the `useNotifications` query is always subscribed regardless of whether the panel is open. For a test app this is acceptable; in production, consider lazy-loading the panel.

### 2.3 `TaskDetailPage` is too large (350+ lines)
It handles task display, status/priority editing, sub-task toggling, comments, activity, and deletion in one file. For maintainability, extract `TaskComments`, `TaskSubTasks`, and `TaskActivityLog` into `src/components/tasks/`.

### 2.4 `ProjectsPage` embeds `CreateProjectModal` as an inner function
Inner function components lose React reconciliation identity across renders. This is a known source of subtle bugs (focus loss, unmounting on re-render).

```tsx
// Move outside ProjectsPage
function CreateProjectModal({ isOpen, onClose }: ...) { ... }

export default function ProjectsPage() { ... }
```

### 2.5 `Sidebar` project list shows raw project `id` in the URL but the label is just the name
This is correct, just noting the slice `projects.slice(0, 5)` silently drops projects beyond 5 without any "show more" affordance.

---

## 3. Performance Considerations

### 3.1 No memoization on expensive derived values in `DashboardPage`
```ts
// Recomputed on every render
const overdueTasks = tasks.filter(...);
const doneTasks = tasks.filter(...);
```
Wrap with `useMemo` keyed on `tasks` and `statusFilter`.

### 3.2 `useNotifications` polls every 30 seconds unconditionally
**File:** `src/hooks/useNotifications.ts`
Polling starts even on the login/register pages because `useUnreadCount` is called in `Header` which is inside `AppLayout`. This is fine since `AppLayout` only renders for authenticated users, but confirm the query is enabled only when `isAuthenticated`.

```ts
refetchInterval: isAuthenticated ? 30_000 : false,
```

### 3.3 Each task card triggers a separate `subTaskDoneCount` query in `listTasks`
**Backend:** `tasks.controller.ts` runs one `prisma.subTask.count` per task in `Promise.all`, which is an N+1 query.
**Recommendation:** Use a Prisma `groupBy` to count done sub-tasks for all tasks in one query.

```ts
const doneCounts = await prisma.subTask.groupBy({
  by: ['taskId'],
  where: { taskId: { in: tasks.map(t => t.id) }, isDone: true },
  _count: { _all: true },
});
const doneMap = Object.fromEntries(doneCounts.map(r => [r.taskId, r._count._all]));
```

### 3.4 `recharts` is imported at the top level of `AnalyticsPage`
Since `AnalyticsPage` is already lazy-loaded via `React.lazy`, the Recharts bundle is code-split correctly. No action needed.

---

## 4. Security Issues

### 4.1 Access token stored in `sessionStorage` via Zustand persist
**File:** `src/store/authStore.ts`
`sessionStorage` is accessible to any JavaScript running in the same origin. For a test app this is fine. For production, use `httpOnly` cookies exclusively and remove the `persist` middleware — the server should validate the cookie on every request.

### 4.2 No CSRF protection for cookie-based auth
If the app moves to `httpOnly` cookies, CSRF tokens or `SameSite=Strict` cookie attribute must be added. Currently not an issue because credentials travel in the `Authorization` header.

### 4.3 `formatTask` in the backend returns `creatorId` and `projectId` in the task payload
These are internal IDs. They are needed by the frontend for some operations, but ensure they are not surfaced to users who are not project members. The existing `requireMember` check in `getTask` handles this correctly.

### 4.4 Missing input length validation on `updateMe`
**File:** `Backend/Code/src/controllers/users.controller.ts`
The `bio` field is validated to max 300 chars in the SRS but there is no Zod schema on the `PUT /api/users/me` route. Add validation middleware identical to the register schema.

---

## 5. Accessibility

### 5.1 `TaskCard` uses `role="button"` on a `div` — good, but missing `aria-label`
**File:** `src/components/tasks/TaskCard.tsx`
Screen readers will read the full card text, which may be verbose. Add an `aria-label` with just the task title.

```tsx
<div
  role="button"
  tabIndex={0}
  aria-label={`Open task: ${task.title}`}
  ...
>
```

### 5.2 Kanban drag-and-drop is not keyboard accessible
`@dnd-kit` supports keyboard navigation natively, but it requires the `KeyboardSensor` to be added alongside `PointerSensor`.

```ts
import { KeyboardSensor } from '@dnd-kit/core';
import { sortableKeyboardCoordinates } from '@dnd-kit/sortable';

const sensors = useSensors(
  useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
  useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }),
);
```

### 5.3 Colour contrast on `gray-400` placeholder text
Tailwind's `gray-400` (#9ca3af) on a white background has a contrast ratio of ~3.4:1, which fails WCAG AA (4.5:1 required for normal text). Use `gray-500` (#6b7280, ~4.6:1) for placeholder and helper text.

### 5.4 `Modal` sets `aria-modal` and `role="dialog"` correctly — good
Focus is not trapped inside the modal. For production, add a focus trap (e.g., `focus-trap-react` or a custom hook) so keyboard users cannot tab outside the modal while it is open.

---

## 6. Test Coverage Assessment

| Area | Files | Coverage Notes |
|---|---|---|
| Utility functions | `format.test.ts` | Good — all branches covered |
| UI components | `Badge.test.tsx`, `Modal.test.tsx`, `TaskCard.test.tsx` | Good for key components |
| API hooks | None | Missing — hooks that call `apiClient` are not tested |
| Pages | None | Missing — no integration tests for page-level flows |
| Store (Zustand) | None | Missing |
| Auth flow | None | Missing — no test for login/register page rendering |

**Priority additions:**
1. `useAuth.test.ts` — test login mutation error/success states using MSW
2. `ProjectsPage.test.tsx` — test empty state and project creation flow
3. `authStore.test.ts` — test login/logout state transitions

---

## 7. Recommendations Summary

| # | Issue | Severity | Effort |
|---|---|---|---|
| 1 | Fix `useUpdateTask` empty `taskId` in KanbanBoard | High | Low |
| 2 | Move inner `CreateProjectModal` outside parent component | Medium | Low |
| 3 | Add `useMemo` for derived task arrays in DashboardPage | Medium | Low |
| 4 | Add `KeyboardSensor` to DnD for keyboard accessibility | Medium | Low |
| 5 | Fix placeholder text contrast (gray-400 → gray-500) | Medium | Low |
| 6 | Add Zod validation to `PUT /api/users/me` route | Medium | Low |
| 7 | Resolve project name in dashboard (not raw ID) | Medium | Medium |
| 8 | Add focus trap to Modal component | Low | Medium |
| 9 | Add hook and page-level tests | Low | High |
| 10 | Move access token to httpOnly cookie for production | Low | High |
