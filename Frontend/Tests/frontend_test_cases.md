# Frontend Test Cases -- Flutter Mobile App

## Category: UI Tests

### TC-001: Login Screen Renders Correctly
- **Precondition**: App launched, user not authenticated
- **Steps**: Open the app
- **Expected Result**: Login screen shows app icon, "Welcome Back" title, email field, password field, "Sign In" button, "Forgot Password?" link, and "Sign Up" link
- **Priority**: P0

### TC-002: Register Screen Renders Correctly
- **Precondition**: On login screen
- **Steps**: Tap "Sign Up" link
- **Expected Result**: Register screen shows name, email, password, confirm password fields and "Create Account" button
- **Priority**: P0

### TC-003: Dashboard Stats Cards Display
- **Precondition**: User is authenticated
- **Steps**: Navigate to Dashboard tab
- **Expected Result**: Three stat cards (To Do, In Progress, Done) render with correct counts and status colors
- **Priority**: P0

### TC-004: Project List Renders
- **Precondition**: User is authenticated, projects exist
- **Steps**: Navigate to Projects tab
- **Expected Result**: Project cards display name, description, member count, task count, and avatar letter
- **Priority**: P0

### TC-005: Kanban Board Columns Display
- **Precondition**: User opened a project
- **Steps**: Navigate to project board
- **Expected Result**: PageView shows 4 status columns (To Do, In Progress, Under Review, Done) with correct headers, colors, and task counts
- **Priority**: P0

### TC-006: Task Card Elements
- **Precondition**: Tasks exist in a project
- **Steps**: View task cards on board or dashboard
- **Expected Result**: Each card shows title, priority badge, due date (if set), sub-task count (if any), and assignee avatars
- **Priority**: P0

### TC-007: Task Detail Screen Layout
- **Precondition**: Task exists
- **Steps**: Tap a task card
- **Expected Result**: Detail screen shows title, status badge, priority badge, due date, status changer chips, description, checklist, and tabs (Comments/Activity/Details)
- **Priority**: P0

### TC-008: Notification List Renders
- **Precondition**: Notifications exist
- **Steps**: Navigate to Notifications tab
- **Expected Result**: Notification tiles show type icon, title, body, timestamp, and unread indicator (blue dot)
- **Priority**: P1

### TC-009: Settings Screen Profile Section
- **Precondition**: User authenticated
- **Steps**: Navigate to Settings tab
- **Expected Result**: Shows avatar, email, name field, bio field, "Save Profile" button, password change section, and logout button
- **Priority**: P1

### TC-010: Bottom Navigation Bar
- **Precondition**: User authenticated
- **Steps**: Observe bottom nav
- **Expected Result**: Four tabs visible (Dashboard, Projects, Notifications, Settings) with correct icons. Notification tab shows unread badge count
- **Priority**: P0

---

## Category: Interaction Tests

### TC-011: Login Form Validation
- **Precondition**: On login screen
- **Steps**: Tap "Sign In" with empty fields
- **Expected Result**: Inline validation errors: "Email is required" and "Password is required"
- **Priority**: P0

### TC-012: Login Success Flow
- **Precondition**: On login screen
- **Steps**: Enter valid email and password (8+ chars), tap "Sign In"
- **Expected Result**: Loading spinner shows on button, then navigates to Dashboard with bottom nav
- **Priority**: P0

### TC-013: Registration Validation
- **Precondition**: On register screen
- **Steps**: Enter password without uppercase letter, tap "Create Account"
- **Expected Result**: Validation error: "Must contain an uppercase letter"
- **Priority**: P0

### TC-014: Password Mismatch Validation
- **Precondition**: On register screen
- **Steps**: Enter different values in password and confirm password fields
- **Expected Result**: Validation error: "Passwords do not match"
- **Priority**: P1

### TC-015: Create Project Flow
- **Precondition**: On Projects screen
- **Steps**: Tap FAB "New Project", fill name, tap "Create Project"
- **Expected Result**: Bottom sheet closes, navigates to project board, project appears in list
- **Priority**: P0

### TC-016: Create Task Flow
- **Precondition**: On project board
- **Steps**: Tap FAB (+), fill title, select status and priority, tap "Create Task"
- **Expected Result**: Success SnackBar, navigates back, task appears in correct column
- **Priority**: P0

### TC-017: Change Task Status
- **Precondition**: On task detail screen
- **Steps**: Tap a different status chip
- **Expected Result**: Status badge updates immediately, status chip highlights change
- **Priority**: P0

### TC-018: Toggle Sub-task Completion
- **Precondition**: On task detail with sub-tasks
- **Steps**: Tap a sub-task checkbox
- **Expected Result**: Checkbox toggles, progress bar updates, completed count changes, done items show strikethrough
- **Priority**: P1

### TC-019: Add Comment
- **Precondition**: On task detail screen
- **Steps**: Type in comment field, tap send icon
- **Expected Result**: Comment appears in list with author name and "just now" timestamp, input clears
- **Priority**: P1

### TC-020: Delete Task
- **Precondition**: On task detail screen
- **Steps**: Tap overflow menu, tap "Delete Task", confirm in dialog
- **Expected Result**: Confirmation dialog shown, task removed, navigates back, error-colored SnackBar shown
- **Priority**: P1

### TC-021: Mark Notification as Read
- **Precondition**: Unread notifications exist
- **Steps**: Tap an unread notification
- **Expected Result**: Blue dot disappears, background changes to transparent, badge count decrements
- **Priority**: P1

### TC-022: Mark All Notifications Read
- **Precondition**: Unread notifications exist
- **Steps**: Tap "Mark all read" in AppBar
- **Expected Result**: All blue dots disappear, badge count becomes 0, button hides
- **Priority**: P1

### TC-023: Search Tasks
- **Precondition**: On project board with tasks
- **Steps**: Tap search icon, type a keyword
- **Expected Result**: Board filters to show only tasks matching the search query in title or description
- **Priority**: P1

### TC-024: Filter Tasks by Status
- **Precondition**: On project board
- **Steps**: Tap filter icon, select a status chip
- **Expected Result**: Filter sheet closes, active filter bar appears, only matching tasks shown
- **Priority**: P1

### TC-025: Clear All Filters
- **Precondition**: Filters applied on project board
- **Steps**: Tap "Clear all" in filter bar
- **Expected Result**: All filters removed, all tasks visible again, filter bar disappears
- **Priority**: P2

### TC-026: Dashboard Quick Filter
- **Precondition**: On dashboard with tasks
- **Steps**: Tap "In Progress" filter chip
- **Expected Result**: Only tasks with In Progress status shown in My Tasks section
- **Priority**: P1

### TC-027: Logout Flow
- **Precondition**: On settings screen, authenticated
- **Steps**: Tap "Log Out" button
- **Expected Result**: Returns to login screen, stored tokens cleared
- **Priority**: P0

### TC-028: Update Profile
- **Precondition**: On settings screen
- **Steps**: Edit name field, tap "Save Profile"
- **Expected Result**: Success SnackBar "Profile updated" shown
- **Priority**: P1

---

## Category: Edge Cases

### TC-029: Empty Project List
- **Precondition**: User has no projects
- **Steps**: Navigate to Projects tab
- **Expected Result**: Empty state widget shown with folder icon, "No projects yet" text, and "Create Project" action button
- **Priority**: P1

### TC-030: Empty Task Column
- **Precondition**: Kanban column has no tasks
- **Steps**: View empty column on board
- **Expected Result**: Column shows "No tasks" text in center, column still has proper header with count "0"
- **Priority**: P2

### TC-031: Overdue Task Highlighting
- **Precondition**: Task exists with past due date, status not Done
- **Steps**: View task on dashboard or board
- **Expected Result**: Due date text and icon display in red (errorColor), task appears in "Overdue" section on dashboard
- **Priority**: P1

### TC-032: Long Task Title Overflow
- **Precondition**: Task with 200+ character title
- **Steps**: View task card
- **Expected Result**: Title truncates with ellipsis after 2 lines, card layout not broken
- **Priority**: P2

### TC-033: Empty Notifications
- **Precondition**: User has no notifications
- **Steps**: Navigate to Notifications tab
- **Expected Result**: Empty state with "No notifications" and "You're all caught up!" subtitle
- **Priority**: P2

### TC-034: Project Name Max Length
- **Precondition**: Creating a new project
- **Steps**: Try entering 101+ characters in name field
- **Expected Result**: TextField enforces maxLength: 100, character counter shown
- **Priority**: P2

### TC-035: Empty Comment Submission
- **Precondition**: On task detail, comment field empty
- **Steps**: Tap send button with empty/whitespace input
- **Expected Result**: Nothing happens, no comment added, no error
- **Priority**: P2

### TC-036: Pull-to-Refresh on Dashboard
- **Precondition**: On dashboard
- **Steps**: Pull down to trigger RefreshIndicator
- **Expected Result**: Refresh indicator shows, data reloads, list updates
- **Priority**: P2

### TC-037: Password Change Mismatch
- **Precondition**: On settings screen
- **Steps**: Enter different values in new password and confirm password
- **Expected Result**: Error SnackBar "Passwords do not match" shown
- **Priority**: P1

### TC-038: Multiple Assignee Avatars
- **Precondition**: Task assigned to 3+ users
- **Steps**: View task card
- **Expected Result**: Overlapping avatar circles shown (max 3), no layout overflow
- **Priority**: P2

### TC-039: Tab Switching on Task Detail
- **Precondition**: On task detail screen
- **Steps**: Switch between Comments, Activity, and Details tabs
- **Expected Result**: Each tab renders its content correctly, no state loss
- **Priority**: P1

### TC-040: Navigation State Preservation
- **Precondition**: On dashboard with filter applied
- **Steps**: Switch to Projects tab, then back to Dashboard
- **Expected Result**: Dashboard retains its filter state via IndexedStack
- **Priority**: P2
