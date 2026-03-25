# Software Requirements Specification (SRS)
# Task Management App

**Version:** 2.0.0
**Date:** 2026-03-25
**Status:** Final

---

## Table of Contents

1. [Project Overview & Objectives](#1-project-overview--objectives)
2. [Functional Requirements](#2-functional-requirements)
3. [Non-Functional Requirements](#3-non-functional-requirements)
4. [System Architecture Overview](#4-system-architecture-overview)
5. [Data Models / Entity Descriptions](#5-data-models--entity-descriptions)
6. [API Endpoints Overview](#6-api-endpoints-overview)
7. [User Roles and Permissions](#7-user-roles-and-permissions)
8. [Constraints and Assumptions](#8-constraints-and-assumptions)
9. [Acceptance Criteria](#9-acceptance-criteria)

---

## 1. Project Overview & Objectives

### 1.1 Overview

The Task Management App is a full-stack web application that enables individuals and teams to organize, track, and collaborate on tasks and projects. Users can create tasks, assign them to team members, set deadlines, track progress, and gain insights through dashboards.

### 1.2 Objectives

- Provide a clean, intuitive interface for creating and managing tasks
- Enable team collaboration with role-based access control
- Support project-level organization of tasks
- Deliver real-time status updates and notifications
- Offer reporting and analytics for productivity insights
- Ensure secure, scalable, and highly available service

### 1.3 Scope

The application covers:
- User registration, authentication, and profile management
- Project creation and team management
- Full task lifecycle management (create, assign, update, complete, archive)
- Comments and activity logs on tasks
- Labels, priorities, and due date management
- Dashboard with summary and analytics
- Notification system (in-app)
- Dark mode / theme switching
- Drag-and-drop Kanban board
- Global search across tasks and projects
- File attachments on tasks
- AI voice assistant for task creation
- Network connectivity status indicators
- Animated empty states

---

## 2. Functional Requirements

### 2.1 Authentication & User Management

**FR-01** The system shall allow new users to register with email and password.
**FR-02** The system shall validate email uniqueness during registration.
**FR-03** The system shall allow users to log in using email and password.
**FR-04** The system shall issue JWT access tokens upon successful authentication.
**FR-05** The system shall support JWT refresh token rotation.
**FR-06** The system shall allow users to log out and invalidate their session.
**FR-07** The system shall allow users to update their profile (name, avatar, bio).
**FR-08** The system shall allow users to change their password after verifying their current password.
**FR-09** The system shall support password reset via email link.

### 2.2 Project Management

**FR-10** The system shall allow authenticated users to create a new project with a name and description.
**FR-11** The system shall allow the project owner to invite members via email.
**FR-12** The system shall allow the project owner to assign roles (Admin, Member, Viewer) to project members.
**FR-13** The system shall allow project owners and admins to update project details.
**FR-14** The system shall allow project owners to delete a project (with cascading task deletion).
**FR-15** The system shall list all projects a user is a member of.
**FR-16** The system shall support project archiving without deletion.

### 2.3 Task Management

**FR-17** The system shall allow project members (Admin/Member) to create tasks within a project.
**FR-18** Each task shall have a title, description, status, priority, due date, and assignee.
**FR-19** Task status shall support: To Do, In Progress, Under Review, Done, Archived.
**FR-20** Task priority shall support: Low, Medium, High, Critical.
**FR-21** The system shall allow tasks to be assigned to one or more project members.
**FR-22** The system shall allow tasks to be updated by project Admins and Members.
**FR-23** The system shall allow tasks to be deleted by Admins and the task creator.
**FR-24** The system shall support task filtering by status, priority, assignee, and due date.
**FR-25** The system shall support task sorting by due date, priority, and creation date.
**FR-26** The system shall support full-text search on task titles and descriptions within a project.
**FR-27** The system shall allow tasks to be organized into customizable lists/columns (Kanban board view).
**FR-28** The system shall support sub-tasks (checklist items) within a task.

### 2.4 Labels & Tags

**FR-29** The system shall allow project Admins to create custom labels for a project.
**FR-30** The system shall allow members to attach one or more labels to a task.
**FR-31** The system shall allow filtering tasks by label.

### 2.5 Comments & Activity

**FR-32** The system shall allow project members to add comments to a task.
**FR-33** The system shall allow comment authors to edit or delete their own comments.
**FR-34** The system shall record an activity log for every task change (who changed what and when).
**FR-35** The system shall display the activity log in chronological order on the task detail view.

### 2.6 Notifications

**FR-36** The system shall generate in-app notifications when a task is assigned to a user.
**FR-37** The system shall generate in-app notifications when a task's due date is approaching (24 hours prior).
**FR-38** The system shall generate in-app notifications when a comment is added to a task the user is watching.
**FR-39** The system shall allow users to mark notifications as read.
**FR-40** The system shall display an unread notification count badge.

### 2.7 Dashboard & Analytics

**FR-41** The system shall display a personal dashboard showing tasks assigned to the current user across all projects.
**FR-42** The system shall display project-level analytics: total tasks, tasks by status, tasks by assignee.
**FR-43** The system shall display a task completion trend chart (last 30 days).
**FR-44** The system shall display overdue task counts per project.

### 2.8 Global Search

**FR-45** The system shall provide a global search endpoint that searches across all tasks and projects the user has access to.
**FR-46** Global search shall support full-text matching on task titles, descriptions, project names, and descriptions.
**FR-47** Global search shall support filtering by status, priority, assignee, and due date range.
**FR-48** Global search results shall be grouped by type (tasks, projects) and limited to 50 tasks and 20 projects.

### 2.9 File Attachments

**FR-49** The system shall allow project members (Admin/Member) to upload file attachments to a task.
**FR-50** Supported file types shall include: images (JPEG, PNG, GIF, WebP), documents (PDF, DOC, DOCX, XLS, XLSX), and text files (TXT, CSV).
**FR-51** Maximum file size per attachment shall be 10MB.
**FR-52** The system shall store attachments on local disk with unique filenames.
**FR-53** The system shall allow users to list, download, and delete attachments.
**FR-54** Only the attachment uploader, project Admin, or Owner may delete an attachment.
**FR-55** Attachment uploads shall be recorded in the task activity log.

### 2.10 Drag-and-Drop Kanban

**FR-56** The system shall support drag-and-drop reordering of tasks within and across Kanban columns.
**FR-57** The system shall maintain a position field on tasks to preserve ordering within columns.
**FR-58** The system shall support bulk status updates for multiple tasks in a single request.
**FR-59** Task reordering shall shift positions of other tasks in the target column automatically.

### 2.11 Dashboard Analytics (Enhanced)

**FR-60** The system shall provide an analytics endpoint returning: completion rate, priority distribution, average completion time, team workload, and weekly created vs completed stats.
**FR-61** Team workload shall show task counts (total, done, in-progress) per project member.
**FR-62** Weekly stats shall cover the last 4 weeks of created vs completed tasks.

### 2.12 AI Voice Assistant

**FR-63** The system shall accept a voice transcript and project ID, and return parsed task fields using AI (OpenAI GPT).
**FR-64** Parsed fields shall include: title, description, priority, due date, and assignee names.
**FR-65** The system shall resolve assignee names to user IDs by fuzzy-matching against project members.
**FR-66** The AI parse endpoint shall require authentication and project membership.

### 2.13 Dark Mode

**FR-67** The application shall support light, dark, and system-default theme modes.
**FR-68** Theme preference shall persist across sessions using local storage.
**FR-69** All UI components shall render correctly in both light and dark modes.

### 2.14 Network Connectivity

**FR-70** The application shall monitor network connectivity status in real-time.
**FR-71** The application shall display an animated banner when connectivity is lost, reconnecting, or restored.
**FR-72** The application shall show a full-screen offline overlay during prolonged disconnection.

### 2.15 Empty States

**FR-73** The application shall display animated empty state illustrations for: no tasks, no projects, no notifications, no search results, no attachments, and empty Kanban columns.
**FR-74** Empty states shall include contextual action buttons (e.g., "Create Task", "New Project").

### 2.16 Haptic Feedback

**FR-75** The application shall provide haptic feedback (light impact) on all interactive elements including buttons, navigation items, filter chips, and card taps.
**FR-76** Haptic feedback intensity shall vary by action type: light for navigation, medium for selections, heavy for confirmations.

### 2.17 Creative Loading Animations

**FR-77** The application shall display creative animated loaders (rocket launch, pencil drawing, typing dots) instead of shimmer placeholders during data loading.
**FR-78** Loading animations shall randomly rotate between available styles for variety.

### 2.18 AI Voice Task UX Enhancement

**FR-79** After creating a task via voice AI, the application shall display an animated success celebration (checkmark animation) before dismissing.
**FR-80** After voice task creation, the task list shall refresh automatically without requiring manual pull-to-refresh.

### 2.19 Mini Game (Space Shooter)

**FR-81** The application shall include a space shooter mini-game accessible from Settings.
**FR-82** The game shall track and persist high scores locally using device storage.
**FR-83** Game mechanics shall include: player ship movement, tap-to-shoot, descending enemies, collision detection, lives system, and score tracking.

### 2.20 AI Chat (Conversational)

**FR-84** The application shall provide a conversational AI chat feature accessible from Settings.
**FR-85** The AI chat shall support any language the user writes in.
**FR-86** The chat shall maintain conversation context by sending recent message history with each request.
**FR-87** The system shall provide a chat API endpoint (`POST /api/ai/chat`) accepting a message and conversation history, returning an AI-generated reply.

### 2.21 Voice Chat with AI

**FR-88** The AI chat feature shall support voice input via speech-to-text, allowing users to speak instead of typing.
**FR-89** The AI chat shall support voice output via text-to-speech, reading AI replies aloud.
**FR-90** Voice output language shall be auto-detected based on the text content (supporting English, Arabic, Chinese, Japanese, Korean, Hindi, Tamil, and more).
**FR-91** Users shall be able to toggle voice output on/off via a mute button.
**FR-92** Tapping any AI message bubble shall replay it via text-to-speech.

---

## 3. Non-Functional Requirements

### 3.1 Performance

**NFR-01** API response time shall be under 300ms for 95% of requests under normal load.
**NFR-02** The system shall support at least 1,000 concurrent users without performance degradation.
**NFR-03** Database queries shall be optimized with appropriate indexes to ensure sub-100ms query times.
**NFR-04** Frontend initial load time (LCP) shall be under 2.5 seconds on a standard broadband connection.
**NFR-05** Frontend bundle size shall not exceed 500KB gzipped.

### 3.2 Security

**NFR-06** All API endpoints (except auth) shall require a valid JWT token.
**NFR-07** Passwords shall be hashed using bcrypt with a minimum cost factor of 12.
**NFR-08** All HTTP traffic shall be served over HTTPS in production.
**NFR-09** The system shall implement rate limiting on authentication endpoints (max 10 requests/minute per IP).
**NFR-10** The system shall sanitize all user inputs to prevent XSS and SQL injection.
**NFR-11** CORS policy shall restrict origins to known frontend domains.
**NFR-12** JWT tokens shall have an expiry of 15 minutes; refresh tokens shall expire in 7 days.

### 3.3 Scalability

**NFR-13** The backend shall be stateless to allow horizontal scaling.
**NFR-14** Database connections shall be managed via a connection pool.
**NFR-15** The architecture shall support deployment on containerized infrastructure (Docker/Kubernetes).

### 3.4 Reliability & Availability

**NFR-16** The system shall target 99.9% uptime (SLA).
**NFR-17** The system shall implement graceful error handling and return meaningful HTTP error codes.
**NFR-18** The system shall implement request logging for all API calls.

### 3.5 Usability

**NFR-19** The UI shall be fully responsive, supporting screen widths from 320px to 2560px.
**NFR-20** The application shall meet WCAG 2.1 AA accessibility standards.
**NFR-21** The UI shall provide loading indicators for all async operations.
**NFR-22** The application shall support keyboard navigation throughout.

---

## 4. System Architecture Overview

### 4.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Client Layer                      │
│              React SPA (Vite + TypeScript)               │
│        React Query + Zustand + React Router v6          │
└────────────────────────┬────────────────────────────────┘
                         │ HTTPS / REST API
┌────────────────────────▼────────────────────────────────┐
│                      API Layer                           │
│              Node.js + Express + TypeScript              │
│          JWT Auth Middleware + Rate Limiting             │
└──────────┬─────────────────────────────┬────────────────┘
           │                             │
┌──────────▼──────────┐     ┌───────────▼────────────────┐
│    Database Layer   │     │       Cache Layer            │
│   PostgreSQL (primary│     │   Redis (sessions/cache)   │
│   + read replica)  │     └────────────────────────────┘
└─────────────────────┘
```

### 4.2 Technology Stack

| Layer       | Technology                         |
|-------------|-------------------------------------|
| Frontend    | React 18, TypeScript, Vite          |
| State       | Zustand, React Query (TanStack)     |
| Routing     | React Router v6                     |
| Styling     | Tailwind CSS                        |
| Backend     | Node.js, Express, TypeScript        |
| Database    | PostgreSQL 15                       |
| ORM         | Prisma                              |
| Cache       | Redis                               |
| Auth        | JWT (jsonwebtoken), bcrypt          |
| Testing     | Vitest, React Testing Library, Jest |
| Deployment  | Docker, Docker Compose              |

---

## 5. Data Models / Entity Descriptions

### 5.1 User

| Field       | Type      | Constraints                          |
|-------------|-----------|--------------------------------------|
| id          | UUID      | PK, auto-generated                   |
| email       | String    | Unique, not null                     |
| password    | String    | Hashed, not null                     |
| name        | String    | Not null                             |
| avatar_url  | String    | Nullable                             |
| bio         | String    | Nullable, max 300 chars              |
| created_at  | Timestamp | Default now()                        |
| updated_at  | Timestamp | Auto-updated                         |

### 5.2 Project

| Field       | Type      | Constraints                          |
|-------------|-----------|--------------------------------------|
| id          | UUID      | PK, auto-generated                   |
| name        | String    | Not null, max 100 chars              |
| description | String    | Nullable, max 500 chars              |
| owner_id    | UUID      | FK -> User, not null                 |
| is_archived | Boolean   | Default false                        |
| created_at  | Timestamp | Default now()                        |
| updated_at  | Timestamp | Auto-updated                         |

### 5.3 ProjectMember

| Field       | Type      | Constraints                          |
|-------------|-----------|--------------------------------------|
| id          | UUID      | PK                                   |
| project_id  | UUID      | FK -> Project                        |
| user_id     | UUID      | FK -> User                           |
| role        | Enum      | ADMIN, MEMBER, VIEWER                |
| joined_at   | Timestamp | Default now()                        |

### 5.4 Task

| Field        | Type      | Constraints                         |
|--------------|-----------|-------------------------------------|
| id           | UUID      | PK, auto-generated                  |
| project_id   | UUID      | FK -> Project, not null             |
| title        | String    | Not null, max 255 chars             |
| description  | Text      | Nullable                            |
| status       | Enum      | TODO, IN_PROGRESS, UNDER_REVIEW, DONE, ARCHIVED |
| priority     | Enum      | LOW, MEDIUM, HIGH, CRITICAL         |
| position     | Integer   | Default 0 (ordering within column)  |
| due_date     | Timestamp | Nullable                            |
| creator_id   | UUID      | FK -> User                          |
| created_at   | Timestamp | Default now()                       |
| updated_at   | Timestamp | Auto-updated                        |

### 5.5 TaskAssignee

| Field     | Type | Constraints         |
|-----------|------|---------------------|
| task_id   | UUID | FK -> Task          |
| user_id   | UUID | FK -> User          |
| assigned_at | Timestamp | Default now()  |

### 5.6 SubTask (Checklist)

| Field       | Type      | Constraints              |
|-------------|-----------|--------------------------|
| id          | UUID      | PK                       |
| task_id     | UUID      | FK -> Task               |
| title       | String    | Not null, max 200 chars  |
| is_done     | Boolean   | Default false            |
| created_at  | Timestamp | Default now()            |

### 5.7 Label

| Field      | Type   | Constraints              |
|------------|--------|--------------------------|
| id         | UUID   | PK                       |
| project_id | UUID   | FK -> Project            |
| name       | String | Not null, max 50 chars   |
| color      | String | Hex color code           |

### 5.8 Comment

| Field      | Type      | Constraints              |
|------------|-----------|--------------------------|
| id         | UUID      | PK                       |
| task_id    | UUID      | FK -> Task               |
| author_id  | UUID      | FK -> User               |
| body       | Text      | Not null                 |
| created_at | Timestamp | Default now()            |
| updated_at | Timestamp | Auto-updated             |

### 5.9 ActivityLog

| Field      | Type      | Constraints              |
|------------|-----------|--------------------------|
| id         | UUID      | PK                       |
| task_id    | UUID      | FK -> Task               |
| actor_id   | UUID      | FK -> User               |
| action     | String    | e.g. "changed status"    |
| meta       | JSONB     | Before/after values      |
| created_at | Timestamp | Default now()            |

### 5.10 Notification

| Field      | Type      | Constraints              |
|------------|-----------|--------------------------|
| id         | UUID      | PK                       |
| user_id    | UUID      | FK -> User               |
| type       | Enum      | TASK_ASSIGNED, DUE_SOON, COMMENT_ADDED |
| title      | String    | Not null                 |
| body       | String    | Not null                 |
| link       | String    | Deep-link URL            |
| is_read    | Boolean   | Default false            |
| created_at | Timestamp | Default now()            |

### 5.11 Attachment

| Field       | Type      | Constraints              |
|-------------|-----------|--------------------------|
| id          | UUID      | PK                       |
| task_id     | UUID      | FK -> Task               |
| uploader_id | UUID      | FK -> User               |
| file_name   | String    | Original file name       |
| file_url    | String    | Server path to file      |
| mime_type   | String    | e.g. "image/png"         |
| file_size   | Integer   | Size in bytes            |
| created_at  | Timestamp | Default now()            |

---

## 6. API Endpoints Overview

### 6.1 Auth

| Method | Endpoint                  | Description                    |
|--------|---------------------------|--------------------------------|
| POST   | /api/auth/register        | Register a new user            |
| POST   | /api/auth/login           | Login and receive tokens       |
| POST   | /api/auth/logout          | Invalidate refresh token       |
| POST   | /api/auth/refresh         | Rotate access token            |
| POST   | /api/auth/forgot-password | Request password reset email   |
| POST   | /api/auth/reset-password  | Reset password with token      |

### 6.2 Users

| Method | Endpoint           | Description              |
|--------|--------------------|--------------------------|
| GET    | /api/users/me      | Get current user profile |
| PUT    | /api/users/me      | Update current user      |
| PUT    | /api/users/me/password | Change password      |

### 6.3 Projects

| Method | Endpoint                         | Description                  |
|--------|----------------------------------|------------------------------|
| GET    | /api/projects                    | List user's projects         |
| POST   | /api/projects                    | Create a project             |
| GET    | /api/projects/:id                | Get project details          |
| PUT    | /api/projects/:id                | Update project               |
| DELETE | /api/projects/:id                | Delete project               |
| POST   | /api/projects/:id/members        | Invite member                |
| GET    | /api/projects/:id/members        | List project members         |
| PUT    | /api/projects/:id/members/:uid   | Update member role           |
| DELETE | /api/projects/:id/members/:uid   | Remove member                |

### 6.4 Tasks

| Method | Endpoint                         | Description                  |
|--------|----------------------------------|------------------------------|
| GET    | /api/projects/:pid/tasks         | List tasks (with filters)    |
| POST   | /api/projects/:pid/tasks         | Create a task                |
| GET    | /api/tasks/:id                   | Get task details             |
| PUT    | /api/tasks/:id                   | Update a task                |
| DELETE | /api/tasks/:id                   | Delete a task                |
| POST   | /api/tasks/:id/assignees         | Add assignees                |
| DELETE | /api/tasks/:id/assignees/:uid    | Remove assignee              |
| GET    | /api/tasks/:id/subtasks          | List sub-tasks               |
| POST   | /api/tasks/:id/subtasks          | Create sub-task              |
| PUT    | /api/tasks/:id/subtasks/:sid     | Update sub-task              |
| DELETE | /api/tasks/:id/subtasks/:sid     | Delete sub-task              |

### 6.5 Comments & Activity

| Method | Endpoint                         | Description                  |
|--------|----------------------------------|------------------------------|
| GET    | /api/tasks/:id/comments          | List task comments           |
| POST   | /api/tasks/:id/comments          | Add comment                  |
| PUT    | /api/comments/:id                | Edit comment                 |
| DELETE | /api/comments/:id                | Delete comment               |
| GET    | /api/tasks/:id/activity          | Get task activity log        |

### 6.6 Labels

| Method | Endpoint                         | Description                  |
|--------|----------------------------------|------------------------------|
| GET    | /api/projects/:pid/labels        | List project labels          |
| POST   | /api/projects/:pid/labels        | Create label                 |
| PUT    | /api/labels/:id                  | Update label                 |
| DELETE | /api/labels/:id                  | Delete label                 |
| POST   | /api/tasks/:id/labels            | Attach labels to task        |
| DELETE | /api/tasks/:id/labels/:lid       | Remove label from task       |

### 6.7 Notifications

| Method | Endpoint                         | Description                   |
|--------|----------------------------------|-------------------------------|
| GET    | /api/notifications               | Get user notifications        |
| PUT    | /api/notifications/:id/read      | Mark notification as read     |
| PUT    | /api/notifications/read-all      | Mark all notifications read   |

### 6.8 Dashboard

| Method | Endpoint                         | Description                   |
|--------|----------------------------------|-------------------------------|
| GET    | /api/dashboard/my-tasks          | Current user's tasks          |
| GET    | /api/dashboard/projects/:pid     | Project analytics             |
| GET    | /api/dashboard/trends            | Task completion trend (30d)   |
| GET    | /api/dashboard/analytics         | Full analytics (completion rate, workload, etc.) |

### 6.9 Search

| Method | Endpoint                         | Description                   |
|--------|----------------------------------|-------------------------------|
| GET    | /api/search                      | Global search (tasks & projects) |

### 6.10 Attachments

| Method | Endpoint                         | Description                   |
|--------|----------------------------------|-------------------------------|
| POST   | /api/tasks/:id/attachments       | Upload file attachment        |
| GET    | /api/tasks/:id/attachments       | List task attachments         |
| DELETE | /api/attachments/:aid            | Delete attachment             |
| GET    | /api/attachments/:aid/download   | Download attachment file      |

### 6.11 Kanban (Task Reordering)

| Method | Endpoint                         | Description                   |
|--------|----------------------------------|-------------------------------|
| PUT    | /api/tasks/bulk-status           | Batch update task statuses    |
| PUT    | /api/tasks/reorder               | Reorder task (status + position) |

### 6.12 AI Voice Assistant

| Method | Endpoint                         | Description                   |
|--------|----------------------------------|-------------------------------|
| POST   | /api/ai/parse-task               | Parse voice transcript into task fields |
| POST   | /api/ai/chat                     | Conversational AI chat (any language)   |

---

## 7. User Roles and Permissions

| Permission                  | Owner | Admin | Member | Viewer |
|-----------------------------|-------|-------|--------|--------|
| View project                | Y     | Y     | Y      | Y      |
| Update project details      | Y     | Y     | N      | N      |
| Delete project              | Y     | N     | N      | N      |
| Invite / remove members     | Y     | Y     | N      | N      |
| Change member roles         | Y     | N     | N      | N      |
| Create tasks                | Y     | Y     | Y      | N      |
| Update any task             | Y     | Y     | Y      | N      |
| Delete task (own)           | Y     | Y     | Y      | N      |
| Delete any task             | Y     | Y     | N      | N      |
| Add comments                | Y     | Y     | Y      | N      |
| Edit/delete own comments    | Y     | Y     | Y      | N      |
| Manage labels               | Y     | Y     | N      | N      |
| View analytics              | Y     | Y     | Y      | Y      |

---

## 8. Constraints and Assumptions

### 8.1 Constraints

- **C-01:** The application must run on Node.js 20+ and PostgreSQL 15+.
- **C-02:** The frontend must support the latest two versions of Chrome, Firefox, Safari, and Edge.
- **C-03:** ~~File attachments are out of scope for v1.0.~~ (Added in v2.0 — local disk storage, 10MB limit)
- **C-04:** Email delivery in v1.0 is limited to password reset (no email notifications).
- **C-05:** The application is English-only for v1.0 (no i18n).
- **C-06:** Mobile native apps are out of scope; the web app must be mobile-responsive.

### 8.2 Assumptions

- **A-01:** All users have a valid email address.
- **A-02:** The deployment environment provides a managed PostgreSQL instance.
- **A-03:** A Redis instance is available for caching and session management.
- **A-04:** SMTP credentials will be provided for transactional email.
- **A-05:** Users will access the application over a broadband connection (>=10 Mbps).

---

## 9. Acceptance Criteria

### 9.1 Authentication

- **AC-01:** A user can register, receive a success response, and immediately log in.
- **AC-02:** Login with incorrect credentials returns HTTP 401 with a descriptive error.
- **AC-03:** An expired access token returns HTTP 401; the client can refresh using the refresh token.

### 9.2 Projects

- **AC-04:** A user can create a project and see it listed in their project list.
- **AC-05:** Inviting a user by email adds them to the project with the specified role.
- **AC-06:** A Viewer cannot create, update, or delete tasks (returns HTTP 403).

### 9.3 Tasks

- **AC-07:** A task created within a project appears in the project task list.
- **AC-08:** Filtering tasks by status returns only tasks matching that status.
- **AC-09:** Searching by keyword returns tasks where the title or description matches.
- **AC-10:** Sub-tasks can be marked as done independently of the parent task.

### 9.4 Comments & Activity

- **AC-11:** A comment added to a task is visible to all project members.
- **AC-12:** Only the comment author can edit or delete their comment (others receive HTTP 403).
- **AC-13:** Every task update is recorded in the activity log with actor, action, and timestamp.

### 9.5 Notifications

- **AC-14:** A user assigned to a task receives an in-app notification.
- **AC-15:** Marking a notification as read updates the unread badge count.

### 9.6 Dashboard

- **AC-16:** The personal dashboard shows all tasks assigned to the user across all projects.
- **AC-17:** The project analytics page shows correct task counts by status.
