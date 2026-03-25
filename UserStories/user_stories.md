# User Stories
# Task Management App

**Version:** 2.0.0
**Date:** 2026-03-25
**Based on:** SRS v2.0.0

---

## Table of Contents

- [Epic 1: Authentication & User Management](#epic-1-authentication--user-management)
- [Epic 2: Project Management](#epic-2-project-management)
- [Epic 3: Task Management](#epic-3-task-management)
- [Epic 4: Labels & Tags](#epic-4-labels--tags)
- [Epic 5: Comments & Activity Log](#epic-5-comments--activity-log)
- [Epic 6: Notifications](#epic-6-notifications)
- [Epic 7: Dashboard & Analytics](#epic-7-dashboard--analytics)
- [Epic 8: Global Search](#epic-8-global-search)
- [Epic 9: File Attachments](#epic-9-file-attachments)
- [Epic 10: Drag-and-Drop Kanban](#epic-10-drag-and-drop-kanban)
- [Epic 11: AI Voice Assistant](#epic-11-ai-voice-assistant)
- [Epic 12: Dark Mode](#epic-12-dark-mode)
- [Epic 13: Network Connectivity & Empty States](#epic-13-network-connectivity--empty-states)
- [Epic 14: Haptic Feedback & UX Polish](#epic-14-haptic-feedback--ux-polish)
- [Epic 15: Mini Game](#epic-15-mini-game)
- [Epic 16: AI Chat](#epic-16-ai-chat)

---

## Epic 1: Authentication & User Management

### US-001 — User Registration

**Story:**
As a new visitor, I want to register an account using my email and password, so that I can access the Task Management App.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Registration form requires name, email, and password fields.
- [ ] Password must be at least 8 characters with at least one uppercase letter and one number.
- [ ] If the email already exists, display an error: "An account with this email already exists."
- [ ] On successful registration, the user is automatically logged in and redirected to the dashboard.
- [ ] A success toast notification is shown after registration.

---

### US-002 — User Login

**Story:**
As a registered user, I want to log in with my email and password, so that I can access my tasks and projects.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] Login form accepts email and password.
- [ ] On incorrect credentials, display: "Invalid email or password."
- [ ] After 5 failed attempts, display a notice about rate limiting.
- [ ] On successful login, the user is redirected to their personal dashboard.
- [ ] JWT access token is stored securely (httpOnly cookie or memory).

---

### US-003 — User Logout

**Story:**
As a logged-in user, I want to log out of the application, so that my session is terminated and my account is secure.

**Priority:** High
**Story Points:** 1

**Acceptance Criteria:**
- [ ] A logout option is visible in the user profile menu.
- [ ] On logout, the access and refresh tokens are invalidated server-side.
- [ ] The user is redirected to the login page.
- [ ] Attempting to use an invalidated token returns HTTP 401.

---

### US-004 — Token Refresh

**Story:**
As a logged-in user, I want my session to be silently refreshed before my access token expires, so that I am not interrupted while working.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] The client automatically calls `/api/auth/refresh` when the access token is near expiry.
- [ ] If the refresh token is still valid, a new access token is issued.
- [ ] If the refresh token has expired, the user is redirected to the login page.
- [ ] No visible interruption occurs during a successful token refresh.

---

### US-005 — Password Reset

**Story:**
As a user who forgot their password, I want to receive a password reset link via email, so that I can regain access to my account.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A "Forgot Password" link is visible on the login page.
- [ ] Entering a registered email triggers a password reset email.
- [ ] The reset link expires after 1 hour.
- [ ] On following the link, the user can set a new password (min 8 chars).
- [ ] After successful reset, the user is redirected to login.
- [ ] If the email is not registered, show a generic message (no user enumeration).

---

### US-006 — Edit Profile

**Story:**
As a logged-in user, I want to update my name, bio, and avatar, so that my profile reflects accurate information.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] Profile settings page allows editing name, bio (max 300 chars), and avatar URL.
- [ ] Changes are saved immediately on form submission.
- [ ] A success message is displayed after a successful update.
- [ ] Invalid data (e.g., empty name) shows inline validation errors.

---

### US-007 — Change Password

**Story:**
As a logged-in user, I want to change my password, so that I can maintain account security.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A "Change Password" section in profile settings requires current password, new password, and confirmation.
- [ ] If the current password is incorrect, display: "Current password is incorrect."
- [ ] New password must meet the same complexity rules as registration.
- [ ] If new password and confirmation do not match, display an inline error.
- [ ] On success, display a confirmation message.

---

## Epic 2: Project Management

### US-008 — Create Project

**Story:**
As a logged-in user, I want to create a new project with a name and description, so that I can organize my tasks under distinct initiatives.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A "New Project" button is visible on the projects list page.
- [ ] Project name is required (max 100 chars); description is optional (max 500 chars).
- [ ] On success, the user is navigated to the new project's board view.
- [ ] The creating user is automatically assigned the Owner role.
- [ ] The new project appears in the user's project list immediately.

---

### US-009 — View Projects List

**Story:**
As a logged-in user, I want to see all projects I belong to (as owner or member), so that I can navigate between my work contexts.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] The projects list shows project name, description, member count, and owner.
- [ ] Projects are sorted by most recently updated by default.
- [ ] Archived projects are hidden by default but accessible via a toggle.
- [ ] An empty state is shown if the user has no projects.

---

### US-010 — Invite Project Member

**Story:**
As a project Owner or Admin, I want to invite users to my project by email, so that they can collaborate on tasks.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] An "Invite Member" option is available in the project settings.
- [ ] Entering a registered email and selecting a role (Admin / Member / Viewer) sends an invitation.
- [ ] If the email is not registered, display: "No user found with this email."
- [ ] If the user is already a member, display: "User is already a member of this project."
- [ ] On success, the invited user appears in the members list immediately.

---

### US-011 — Manage Member Roles

**Story:**
As a project Owner, I want to change the role of a project member, so that their access level matches their responsibilities.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] The members list shows each member's name, email, and current role.
- [ ] The Owner can change roles via a dropdown next to each member.
- [ ] The Owner's own role cannot be changed.
- [ ] Role changes take effect immediately.
- [ ] A confirmation dialog is shown before changing a role.

---

### US-012 — Remove Project Member

**Story:**
As a project Owner or Admin, I want to remove a member from the project, so that they no longer have access.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A "Remove" action is available next to each member (for owners/admins).
- [ ] A confirmation dialog is shown before removal.
- [ ] Removed members immediately lose access to the project and its tasks.
- [ ] The project owner cannot remove themselves.

---

### US-013 — Archive / Delete Project

**Story:**
As a project Owner, I want to archive or delete a project, so that I can manage my project list without losing historical data unnecessarily.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] Archive option marks the project as archived; it is hidden from the default project list.
- [ ] Delete option shows a confirmation dialog warning about permanent data loss.
- [ ] Deleting a project deletes all associated tasks, comments, and labels.
- [ ] Only the project Owner can delete a project; attempting otherwise returns HTTP 403.

---

## Epic 3: Task Management

### US-014 — Create Task

**Story:**
As a project Admin or Member, I want to create a task within a project, so that I can track a unit of work.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A "New Task" button is visible on the project board and list views.
- [ ] Task title is required (max 255 chars); description is optional.
- [ ] User can set status, priority, due date, and assignees at creation time.
- [ ] On success, the task appears in the correct status column/list.
- [ ] The task creator is recorded automatically.

---

### US-015 — View Task Detail

**Story:**
As a project member, I want to open a task and see its full details, so that I understand what needs to be done.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] Clicking a task opens a detail panel or modal.
- [ ] Detail view shows title, description, status, priority, due date, assignees, labels, sub-tasks, comments, and activity log.
- [ ] All sections are visually separated and easy to scan.
- [ ] The view is accessible by direct URL (deep link).

---

### US-016 — Update Task

**Story:**
As a project Admin or Member, I want to edit a task's details, so that the task reflects the latest state of the work.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] All task fields are editable inline on the task detail view.
- [ ] Changes are auto-saved or saved via a clear "Save" action.
- [ ] Every change is recorded in the activity log.
- [ ] Viewers cannot edit tasks; attempting to do so hides/disables edit controls.

---

### US-017 — Change Task Status

**Story:**
As a project Admin or Member, I want to drag a task between status columns or use a dropdown to change status, so that the board reflects current progress.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Status columns on the Kanban board: To Do, In Progress, Under Review, Done.
- [ ] Dragging a task card to another column updates its status immediately (optimistic update).
- [ ] A status dropdown is also available in the task detail view.
- [ ] A status change is reflected in the activity log.

---

### US-018 — Filter & Sort Tasks

**Story:**
As a project member, I want to filter and sort tasks by status, priority, assignee, and due date, so that I can focus on what matters most.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A filter bar is visible above the task list/board.
- [ ] Multiple filters can be applied simultaneously.
- [ ] Active filters are shown as removable chips/tags.
- [ ] Sorting options include: due date (asc/desc), priority (desc), created date (desc).
- [ ] Filters and sort state persist for the duration of the session.

---

### US-019 — Search Tasks

**Story:**
As a project member, I want to search for tasks by keyword within a project, so that I can quickly locate specific work items.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A search bar is available on the project task view.
- [ ] Search matches against task title and description (case-insensitive).
- [ ] Results update as the user types (debounced, 300ms).
- [ ] If no results are found, an empty state message is displayed.

---

### US-020 — Assign Task

**Story:**
As a project Admin or Member, I want to assign a task to one or more project members, so that ownership is clear.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] An assignee picker shows all project members with their avatars.
- [ ] Multiple members can be selected.
- [ ] Assigned members receive an in-app notification.
- [ ] Assigned members are shown as avatar icons on the task card.

---

### US-021 — Set Task Due Date

**Story:**
As a project Admin or Member, I want to set a due date on a task, so that deadlines are visible to the team.

**Priority:** High
**Story Points:** 1

**Acceptance Criteria:**
- [ ] A date picker is available in the task detail view.
- [ ] Due dates are displayed on task cards.
- [ ] Overdue tasks have their due date displayed in red.
- [ ] Due date can be cleared (set to null).

---

### US-022 — Manage Sub-Tasks

**Story:**
As a project member, I want to add a checklist of sub-tasks to a task, so that I can break down complex work into steps.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A "Checklist" section is available in the task detail view.
- [ ] Sub-tasks can be added, renamed, checked, and deleted.
- [ ] A progress indicator (e.g., "2/5 completed") is shown on the task card.
- [ ] Checking/unchecking a sub-task is recorded in the activity log.

---

### US-023 — Delete Task

**Story:**
As a project Admin or the task creator, I want to delete a task, so that obsolete tasks are removed from the board.

**Priority:** Medium
**Story Points:** 1

**Acceptance Criteria:**
- [ ] A "Delete" option is available in the task detail view's action menu.
- [ ] A confirmation dialog is shown before deletion.
- [ ] Deleted tasks and their comments/sub-tasks are permanently removed.
- [ ] Members without delete permission do not see the delete option.

---

### US-024 — Kanban Board View

**Story:**
As a project member, I want to view all tasks as a Kanban board organized by status, so that I can see workflow progress at a glance.

**Priority:** High
**Story Points:** 5

**Acceptance Criteria:**
- [ ] Board shows columns for each status: To Do, In Progress, Under Review, Done.
- [ ] Each card shows title, priority badge, due date, assignee avatars, and label chips.
- [ ] Cards are draggable between columns.
- [ ] Column headers show the count of tasks in that column.
- [ ] Board is responsive and scrolls horizontally on smaller screens.

---

## Epic 4: Labels & Tags

### US-025 — Create Label

**Story:**
As a project Admin, I want to create custom labels with names and colors for a project, so that tasks can be categorized consistently.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A "Manage Labels" page is accessible from project settings.
- [ ] Label name (max 50 chars) and hex color are required.
- [ ] Created labels are immediately available for use on tasks.
- [ ] Duplicate label names within a project are rejected.

---

### US-026 — Apply Labels to Tasks

**Story:**
As a project Admin or Member, I want to attach one or more labels to a task, so that the task is categorized and filterable.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A label picker is available in the task detail view.
- [ ] Multiple labels can be applied to a single task.
- [ ] Applied labels are shown as colored chips on the task card.
- [ ] Labels can be removed from a task.
- [ ] Task list/board can be filtered by label.

---

## Epic 5: Comments & Activity Log

### US-027 — Add Comment

**Story:**
As a project member, I want to add a comment to a task, so that I can communicate updates and context with my team.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A comment input field is visible at the bottom of the task detail view.
- [ ] Comments support plain text (max 2000 chars).
- [ ] On submission, the comment appears immediately in the thread.
- [ ] Each comment shows the author's avatar, name, and timestamp.

---

### US-028 — Edit & Delete Comment

**Story:**
As a comment author, I want to edit or delete my own comments, so that I can correct mistakes or remove outdated information.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] An "Edit" and "Delete" option appear on hover for the comment author.
- [ ] Editing opens an inline text editor with the existing comment pre-filled.
- [ ] An "Edited" badge appears after the comment is modified.
- [ ] A confirmation dialog is shown before deletion.
- [ ] Other users do not see edit/delete options for comments they did not write.

---

### US-029 — View Activity Log

**Story:**
As a project member, I want to see a chronological log of all changes made to a task, so that I have full visibility into its history.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] An "Activity" tab or section is visible in the task detail view.
- [ ] Each entry shows: actor avatar, action description, and timestamp.
- [ ] Events tracked: status changes, priority changes, assignee changes, due date changes, sub-task completion, label changes.
- [ ] Log is sorted newest-first by default.

---

## Epic 6: Notifications

### US-030 — Task Assignment Notification

**Story:**
As a user, I want to receive an in-app notification when I am assigned to a task, so that I am immediately aware of new responsibilities.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A notification appears in the notification center when a task is assigned to the user.
- [ ] The notification includes the task title and project name.
- [ ] Clicking the notification navigates to the task detail view.
- [ ] The unread badge count increments.

---

### US-031 — Due Date Reminder Notification

**Story:**
As a task assignee, I want to receive an in-app reminder when a task's due date is 24 hours away, so that I can prioritize accordingly.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A notification is generated 24 hours before the due date for each assignee.
- [ ] The notification includes the task title, due date, and a link.
- [ ] The notification is only sent once per task per due date.
- [ ] If the task is already Done, no reminder is sent.

---

### US-032 — Comment Notification

**Story:**
As a task assignee or creator, I want to be notified when a new comment is added to a task I'm watching, so that I stay informed of discussions.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A notification is sent to all task assignees and the task creator when a new comment is posted.
- [ ] The comment author does not receive a notification for their own comment.
- [ ] The notification includes the commenter's name and a preview of the comment.
- [ ] Clicking the notification navigates to the task and highlights the new comment.

---

### US-033 — Notification Center

**Story:**
As a logged-in user, I want to view all my notifications in one place and mark them as read, so that I can manage my attention effectively.

**Priority:** High
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A notification bell icon in the header shows the unread count badge.
- [ ] Clicking the bell opens a notification panel/drawer.
- [ ] Each notification shows type, title, body, and time.
- [ ] Unread notifications are visually distinguished.
- [ ] "Mark all as read" clears the badge and marks all notifications read.
- [ ] Individual notifications can be marked as read on click.

---

## Epic 7: Dashboard & Analytics

### US-034 — Personal Task Dashboard

**Story:**
As a logged-in user, I want a personal dashboard that shows all tasks assigned to me across all projects, so that I have a unified view of my workload.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Dashboard is the default landing page after login.
- [ ] Tasks are grouped by project.
- [ ] Each task card shows title, project, status, priority, and due date.
- [ ] Overdue tasks are highlighted at the top.
- [ ] A quick-filter bar allows filtering by status or priority.

---

### US-035 — Project Analytics Overview

**Story:**
As a project Owner or Admin, I want to see a project analytics overview, so that I can assess the team's progress.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] An "Analytics" tab is available on the project page.
- [ ] Summary cards show: Total Tasks, Completed, In Progress, Overdue counts.
- [ ] A donut or bar chart shows task distribution by status.
- [ ] A table shows tasks per assignee with completion rates.

---

### US-036 — Task Completion Trend

**Story:**
As a project Owner, I want to view a chart of tasks completed over the last 30 days, so that I can spot productivity trends and blockers.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A line chart on the project analytics page shows tasks moved to "Done" per day.
- [ ] X-axis spans the last 30 calendar days.
- [ ] Y-axis shows task count.
- [ ] Hovering on a data point shows the exact count and date.
- [ ] The chart updates to reflect newly completed tasks within the current session.

---

## Epic 8: Global Search

### US-037 — Global Search

**Story:**
As a logged-in user, I want to search across all my tasks and projects from a single search bar, so that I can quickly find any work item regardless of which project it belongs to.

**Priority:** High
**Story Points:** 5

**Acceptance Criteria:**
- [ ] A global search screen is accessible from the dashboard.
- [ ] Search queries match against task titles, descriptions, project names, and descriptions (case-insensitive).
- [ ] Results are grouped by type: Tasks and Projects.
- [ ] Matching text is highlighted in search results.
- [ ] Search supports filtering by status, priority, assignee, and due date range.
- [ ] Results update with debounced input (300ms).
- [ ] An animated empty state is shown when no results are found.

---

### US-038 — Search Filters

**Story:**
As a user searching for tasks, I want to apply filters to narrow down results, so that I can find exactly what I need.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A filter bottom sheet is accessible from the search screen.
- [ ] Filters include: Status (multi-select), Priority (multi-select), Assignee (select from project members), Due Date range.
- [ ] Active filters are shown as chips that can be removed.
- [ ] "Reset all" clears all active filters.
- [ ] Filter count is shown on the Apply button.

---

## Epic 9: File Attachments

### US-039 — Upload File Attachment

**Story:**
As a project member, I want to attach files to a task, so that relevant documents and images are kept with the task they belong to.

**Priority:** High
**Story Points:** 5

**Acceptance Criteria:**
- [ ] A "Files" tab is available on the task detail screen.
- [ ] Users can upload files via Camera, Gallery, Document picker, or Cloud.
- [ ] Supported types: images (JPEG, PNG, GIF, WebP), documents (PDF, DOC, DOCX, XLS, XLSX), text (TXT, CSV).
- [ ] Maximum file size is 10MB; oversized files show a clear error.
- [ ] Upload progress is shown with a progress indicator.
- [ ] Uploaded files appear in the attachment list with filename, size, uploader, and timestamp.
- [ ] Attachment upload is recorded in the activity log.

---

### US-040 — View & Download Attachment

**Story:**
As a project member, I want to preview and download file attachments, so that I can review shared documents without leaving the app.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Tapping an image attachment opens a full-screen preview with zoom.
- [ ] Tapping a document attachment opens it in the system viewer or downloads it.
- [ ] File metadata is shown: name, type, size, uploader.
- [ ] Share and download buttons are available in the preview.

---

### US-041 — Delete Attachment

**Story:**
As the attachment uploader or a project Admin/Owner, I want to delete an attachment, so that outdated or incorrect files can be removed.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A delete option is available on each attachment.
- [ ] A confirmation dialog is shown before deletion.
- [ ] Only the uploader, project Admin, or Owner can delete attachments.
- [ ] The physical file is removed from storage on deletion.

---

## Epic 10: Drag-and-Drop Kanban

### US-042 — Drag Task Between Columns

**Story:**
As a project member, I want to drag a task card from one Kanban column to another, so that I can quickly update task status without opening the detail view.

**Priority:** High
**Story Points:** 5

**Acceptance Criteria:**
- [ ] All 4 Kanban columns are visible simultaneously (horizontal scroll).
- [ ] Long-pressing a task card initiates drag mode with a visual feedback card.
- [ ] A ghost placeholder remains at the original position during drag.
- [ ] Drop zones are highlighted when a card is dragged over a valid column.
- [ ] Dropping updates the task status optimistically with server confirmation.
- [ ] If the server update fails, the task rolls back to its original position.
- [ ] Task cards show a grip handle icon to indicate draggability.

---

### US-043 — Reorder Tasks Within Column

**Story:**
As a project member, I want to reorder tasks within a Kanban column, so that I can prioritize tasks visually.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Tasks within a column can be dragged to change their order.
- [ ] Position changes persist across page refreshes.
- [ ] Reordering shifts other tasks' positions automatically.

---

## Epic 11: AI Voice Assistant

### US-044 — Voice Task Creation

**Story:**
As a project member, I want to create a task by speaking into my phone's microphone, so that I can quickly capture tasks hands-free.

**Priority:** High
**Story Points:** 8

**Acceptance Criteria:**
- [ ] A microphone button is available on the Kanban board screen.
- [ ] Tapping the mic opens a voice recording overlay with animated waveform.
- [ ] Live transcript is displayed as the user speaks.
- [ ] Tapping "Process with AI" sends the transcript to the AI parsing endpoint.
- [ ] The parsed task preview shows: title, description, priority, due date, and resolved assignees.
- [ ] User can Edit, Confirm (create task), or Cancel.
- [ ] If an assignee name cannot be resolved, it's shown as unresolved with the original name.
- [ ] Microphone permission is requested on first use with clear explanation.

---

### US-045 — AI Task Preview & Edit

**Story:**
As a user who created a task via voice, I want to review and edit the AI-parsed fields before creating the task, so that I can correct any misinterpretations.

**Priority:** High
**Story Points:** 3

**Acceptance Criteria:**
- [ ] A preview card shows all parsed fields with icons and labels.
- [ ] Tapping "Edit" navigates to the Create Task screen pre-filled with parsed data.
- [ ] Tapping "Create Task" creates the task directly from the preview.
- [ ] Tapping "Cancel" dismisses the preview and returns to the board.

---

## Epic 12: Dark Mode

### US-046 — Theme Switching

**Story:**
As a user, I want to switch between light, dark, and system-default themes, so that the app is comfortable to use in any lighting condition.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] A theme section is available in Settings with 3 options: System, Light, Dark.
- [ ] Theme change applies immediately with a smooth transition animation.
- [ ] Theme preference persists across app restarts.
- [ ] All screens and components render correctly in both modes.

---

## Epic 13: Network Connectivity & Empty States

### US-047 — Network Connectivity Indicator

**Story:**
As a user, I want to see a visual indicator when my internet connection is lost or restored, so that I understand why actions might fail.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] When offline, a red banner slides down: "No internet connection".
- [ ] When reconnecting, an amber banner shows with pulsing dots: "Reconnecting..."
- [ ] When restored, a green banner shows "Back online" and auto-dismisses after 3 seconds.
- [ ] During prolonged offline (>30s), a full-screen overlay with retry button is shown.

---

### US-048 — Animated Empty States

**Story:**
As a user, I want to see friendly animated illustrations when a screen has no data, so that the app feels polished and I understand what action to take.

**Priority:** Low
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Empty tasks screen shows an animated inbox illustration with "Create Task" button.
- [ ] Empty projects screen shows an animated folder with "New Project" button.
- [ ] Empty notifications screen shows a sleeping bell animation.
- [ ] Empty search results shows a magnifying glass animation.
- [ ] Empty attachments shows a paperclip animation with "Upload File" button.
- [ ] Empty Kanban columns show a column illustration.
- [ ] All animations use Lottie and have a subtle floating effect.

---

## Epic 14: Haptic Feedback & UX Polish

### US-049 — Haptic Feedback on Interactions

**Story:**
As a user, I want to feel a subtle haptic vibration when I tap buttons and interactive elements, so that the app feels more responsive and tactile.

**Priority:** Medium
**Story Points:** 3

**Acceptance Criteria:**
- [ ] All buttons, FABs, and navigation items trigger light haptic feedback on tap.
- [ ] Filter chips and card taps trigger light haptic feedback.
- [ ] Task creation confirmation triggers heavy haptic feedback.
- [ ] Haptic intensity varies by action type (light for nav, heavy for confirmations).

---

### US-050 — Creative Loading Animations

**Story:**
As a user, I want to see fun animated loaders instead of plain shimmer placeholders, so that waiting feels more engaging.

**Priority:** Low
**Story Points:** 3

**Acceptance Criteria:**
- [ ] Loading states show one of 3 animations: rocket launch, pencil drawing, or typing dots.
- [ ] Animation selection is random for variety.
- [ ] Animations support both light and dark themes.
- [ ] "Loading..." text is displayed below the animation.

---

### US-051 — Voice Task Success Animation

**Story:**
As a user creating a task via voice AI, I want to see a success celebration animation after the task is created, so that I get clear confirmation it worked.

**Priority:** Medium
**Story Points:** 2

**Acceptance Criteria:**
- [ ] After task creation, a green checkmark animation plays with "Task Created!" text.
- [ ] Heavy haptic feedback fires on success.
- [ ] The task list refreshes automatically in the background.
- [ ] The voice sheet auto-dismisses after 1.5 seconds.

---

## Epic 15: Mini Game

### US-052 — Space Shooter Game

**Story:**
As a user, I want to play a quick space shooter game from the Settings screen, so that I can take a fun break while using the app.

**Priority:** Low
**Story Points:** 8

**Acceptance Criteria:**
- [ ] A "Fun Zone" section appears in Settings with a "Space Shooter" option.
- [ ] The game features a player ship that can be moved by dragging.
- [ ] Tapping anywhere fires a bullet from the player ship.
- [ ] Enemy ships spawn at the top and descend at varying speeds.
- [ ] Destroying an enemy awards +10 points.
- [ ] Player starts with 3 lives; loses one when an enemy reaches the bottom.
- [ ] Game Over screen shows score and high score with a "Play Again" button.
- [ ] High score persists across app sessions.
- [ ] Stars scroll in the background for a space atmosphere.

---

## Epic 16: AI Chat

### US-053 — Conversational AI Chat

**Story:**
As a user, I want to chat with an AI assistant about anything in any language, so that I can have fun conversations or get quick help without leaving the app.

**Priority:** Medium
**Story Points:** 5

**Acceptance Criteria:**
- [ ] A "Chat with AI" option appears in Settings → Fun Zone.
- [ ] Chat UI shows message bubbles: user on right (primary color), AI on left (grey).
- [ ] Each message shows a timestamp.
- [ ] A typing indicator (animated dots) appears while AI is responding.
- [ ] The AI responds in whatever language the user writes in.
- [ ] Conversation context is maintained (last 10 messages sent with each request).
- [ ] A clear chat button in the app bar resets the conversation with confirmation.
- [ ] Empty state shows suggestion chips for conversation starters.
- [ ] Errors display as a distinct red-tinted bubble.
- [ ] Chat auto-scrolls to the latest message.

---

### US-054 — Voice Chat with AI

**Story:**
As a user, I want to speak to the AI assistant and hear its replies read aloud, so that I can have hands-free conversations in any language.

**Priority:** High
**Story Points:** 5

**Acceptance Criteria:**
- [ ] A mic button appears next to the text input in the AI chat screen.
- [ ] Tapping the mic starts speech recognition with a live waveform and transcript display.
- [ ] When the user stops speaking, the message is sent automatically.
- [ ] AI replies are read aloud via text-to-speech when voice input was used.
- [ ] TTS language is auto-detected based on reply text (English, Arabic, Chinese, Japanese, Korean, Hindi, Tamil).
- [ ] A volume toggle in the app bar enables/disables voice output.
- [ ] Tapping any AI message bubble replays it via TTS.
- [ ] A "Stop" button appears during listening to cancel voice input.
- [ ] Voice messages show a small mic icon next to the timestamp.

---

## Story Point Summary

| Epic                              | Total Story Points |
|-----------------------------------|--------------------|
| Epic 1: Auth & User Management    | 15                 |
| Epic 2: Project Management        | 14                 |
| Epic 3: Task Management           | 25                 |
| Epic 4: Labels & Tags             | 4                  |
| Epic 5: Comments & Activity       | 6                  |
| Epic 6: Notifications             | 9                  |
| Epic 7: Dashboard & Analytics     | 9                  |
| Epic 8: Global Search             | 8                  |
| Epic 9: File Attachments          | 10                 |
| Epic 10: Drag-and-Drop Kanban     | 8                  |
| Epic 11: AI Voice Assistant       | 11                 |
| Epic 12: Dark Mode                | 2                  |
| Epic 13: Connectivity & Empty States | 6               |
| Epic 14: Haptic & UX Polish       | 8                  |
| Epic 15: Mini Game                 | 8                  |
| Epic 16: AI Chat                   | 5                  |
| Epic 16 (Voice Chat addition)    | +5                 |
| **Total**                         | **153**            |

---

## Priority Distribution

| Priority | Count |
|----------|-------|
| High     | 27    |
| Medium   | 22    |
| Low      | 5     |
