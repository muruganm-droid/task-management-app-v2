# Figma UI Mapping -- Flutter Mobile

## Design System Tokens (Flutter Implementation)

| Token | Value | Flutter Constant |
|-------|-------|-----------------|
| Primary | #6366F1 | `AppTheme.primaryColor` |
| Primary Dark | #4F46E5 | `AppTheme.primaryDark` |
| Secondary | #8B5CF6 | `AppTheme.secondaryColor` |
| Error | #EF4444 | `AppTheme.errorColor` |
| Success | #10B981 | `AppTheme.successColor` |
| Warning | #F59E0B | `AppTheme.warningColor` |
| Surface | #F9FAFB | `AppTheme.surfaceColor` |
| Text Primary | #111827 | `AppTheme.textPrimary` |
| Text Secondary | #6B7280 | `AppTheme.textSecondary` |
| Border | #E5E7EB | `AppTheme.borderColor` |

---

## Screen: LoginScreen (`views/auth/login_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| App Icon | Icon | `Icons.task_alt_rounded`, size: 64, color: primaryColor | Centered at top |
| Title | Text | fontSize: 28, fontWeight: bold | "Welcome Back" |
| Subtitle | Text | fontSize: 16, color: textSecondary | "Sign in to manage your tasks" |
| Error Banner | Container | errorColor bg at 10% opacity, rounded 10 | Conditionally shown |
| Email Field | TextFormField | email keyboard, prefixIcon: email_outlined | Validates email format |
| Password Field | TextFormField | obscureText, toggle visibility suffix icon | Min 8 chars validation |
| Forgot Password | TextButton | aligned right | Shows SnackBar |
| Sign In Button | ElevatedButton | full width, primaryColor bg | Shows CircularProgressIndicator when loading |
| Register Link | Row + TextButton | centered, textSecondary + primaryColor | Navigates to RegisterScreen |

**States:** Default, Loading (button disabled + spinner), Error (banner visible)

---

## Screen: RegisterScreen (`views/auth/register_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Title | Text | fontSize: 28, bold | "Get Started" |
| Name Field | TextFormField | prefixIcon: person_outlined | Required |
| Email Field | TextFormField | prefixIcon: email_outlined | Email validation |
| Password Field | TextFormField | obscureText, toggle icon | 8+ chars, uppercase, number |
| Confirm Password Field | TextFormField | obscureText | Must match password |
| Create Account Button | ElevatedButton | full width | Loading state |
| Sign In Link | Row + TextButton | centered | Navigator.pop |

---

## Screen: DashboardScreen (`views/dashboard/dashboard_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Stats Row | Row of 3 Containers | white bg, rounded 12, border | To Do / In Progress / Done counts |
| Stat Number | Text | fontSize: 24, bold, status color | Count value |
| Stat Label | Text | fontSize: 12, textSecondary | Status name |
| Section Header | Row | 4px color bar + title + subtitle | Overdue / My Tasks |
| Quick Filters | SingleChildScrollView + FilterChips | horizontal scroll | All / To Do / In Progress / Under Review / Done |
| Task Cards | TaskCard widget | Card with InkWell | Tappable, navigates to detail |
| Empty State | EmptyState widget | icon, title, subtitle | Shown when no tasks |

---

## Screen: ProjectsScreen (`views/projects/projects_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Show Archived Toggle | TextButton.icon | in AppBar actions | Toggles archived visibility |
| New Project FAB | FloatingActionButton.extended | icon: add, label: "New Project" | Opens bottom sheet |
| Project Card | Card + InkWell | rounded 12, border | Shows name, description, stats |
| Project Avatar | Container 40x40 | primaryColor bg at 10%, rounded 10 | First letter of name |
| Member Count | Row | people_outline icon + text | "X members" |
| Task Count | Row | task_outlined icon + text | "X tasks" |
| Create Project Sheet | ModalBottomSheet | rounded top 20 | Name (100 chars) + Description (500 chars) |
| Empty State | EmptyState widget | folder_open icon | "No projects yet" with action button |

---

## Screen: ProjectBoardScreen (`views/projects/project_board_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Search Toggle | IconButton | search / close icon | Toggles search TextField in AppBar |
| Filter Button | IconButton | filter_list icon | Opens filter bottom sheet |
| New Task FAB | FloatingActionButton | add icon | Navigates to CreateTaskScreen |
| Active Filters Bar | Container | primaryColor bg at 5% | Shows filter chips with remove |
| Kanban Board | PageView | viewportFraction: 0.85 | 4 columns: To Do, In Progress, Under Review, Done |
| Column Header | Container | status color bg at 10%, top border 3px | Status name + count badge |
| Task Cards | TaskCard widget | inside ListView | Scrollable per column |
| Filter Sheet | ModalBottomSheet | rounded top 20 | Status + Priority choice chips |

---

## Screen: CreateTaskScreen (`views/tasks/create_task_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Title Field | TextFormField | maxLength: 255, required | "What needs to be done?" |
| Description Field | TextFormField | maxLines: 4, optional | "Add details about this task" |
| Status Chips | Wrap of ChoiceChips | status color at 20% when selected | 4 statuses |
| Priority Chips | Wrap of ChoiceChips | priority color at 20% when selected | 4 priorities |
| Due Date Picker | ListTile + DatePicker | calendar icon, clearable | Shows selected date or "Set due date" |
| Create Button | ElevatedButton | full width | Also in AppBar as TextButton |

---

## Screen: TaskDetailScreen (`views/tasks/task_detail_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Title | Text | fontSize: 22, bold | Task title |
| Status Badge | StatusBadge widget | status color bg at 10% | Current status |
| Priority Badge | PriorityBadge widget | priority color, border | Current priority |
| Due Date | Row with icon + text | red if overdue | "MMM d, yyyy" format |
| Status Changer | ChoiceChips row | horizontal scroll | Change status inline |
| Description | Container | white bg, rounded 10, border | Read-only text block |
| Checklist Progress | LinearProgressIndicator | successColor, 6px height | "X/Y completed" label |
| Sub-task Items | CheckboxListTile | strikethrough when done | Toggle via ViewModel |
| Tabs | TabBar + TabBarView | 3 tabs, 300px height | Comments / Activity / Details |
| Comment Input | TextField + Send IconButton | bottom bar, white bg, top border | Adds comment to local list |
| Delete Action | PopupMenuButton | errorColor text | Confirmation dialog |

---

## Screen: NotificationsScreen (`views/notifications/notifications_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Mark All Read | TextButton | in AppBar | Visible when unread > 0 |
| Notification Tile | ListTile | leading icon container, trailing dot | Colored by type |
| Unread Indicator | Container 8x8 | primaryColor circle | Trailing widget |
| Unread Background | Container | primaryColor at 4% | Distinguishes unread |
| Type Icons | Icon in Container 40x40 | assignment_ind / access_time / comment | Color matches type |
| Empty State | EmptyState widget | notifications_none icon | "You're all caught up!" |

---

## Screen: SettingsScreen (`views/settings/settings_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Avatar | CircleAvatar radius 40 | primaryColor bg at 15% | First letter of name |
| Email | Text | fontSize: 14, textSecondary | Below avatar |
| Name Field | TextField | person_outlined prefix icon | Pre-filled |
| Bio Field | TextField | info_outlined prefix, maxLength: 300 | 2 lines |
| Save Profile Button | ElevatedButton | full width | Success SnackBar |
| Current Password | TextField | obscureText | lock_outlined icon |
| New Password | TextField | obscureText | lock_outline icon |
| Confirm Password | TextField | obscureText | Must match new password |
| Change Password Button | ElevatedButton | full width | Validates match |
| Logout Button | OutlinedButton.icon | errorColor border and text | logout icon |

---

## Shared Widgets

### TaskCard (`views/widgets/task_card.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Card Container | Card + InkWell | margin: 4, rounded 12 | Tappable |
| Title | Text | fontSize: 14, w600 | Max 2 lines, ellipsis |
| Priority Badge | PriorityBadge | compact mode | Top-right |
| Description | Text | fontSize: 12, textSecondary | Max 2 lines if present |
| Due Date | Icon + Text | red if overdue | calendar_today icon, 12px |
| Sub-task Count | Icon + Text | check_circle_outline, 12px | "X/Y" format |
| Assignee Avatars | Stack of CircleAvatars | radius: 11, offset 14px | Max 3 shown |

### PriorityBadge (`views/widgets/priority_badge.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Container | Container | priority color bg 10%, border 30% | Rounded 6 |
| Label | Text | priority color, w600 | Compact: 10px, Normal: 12px |

### StatusBadge (`views/widgets/status_badge.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Container | Container | status color bg 10% | Rounded 6 |
| Label | Text | status color, w600, 12px | Status display name |

### EmptyState (`views/widgets/empty_state.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Icon | Icon | size: 64, textSecondary at 40% | Centered |
| Title | Text | fontSize: 18, w600 | Centered |
| Subtitle | Text | fontSize: 14, textSecondary | Optional |
| Action Button | ElevatedButton | standard style | Optional |

---

## Navigation

| Component | Type | Notes |
|-----------|------|-------|
| AppShell | BottomNavigationBar | 4 tabs: Dashboard, Projects, Notifications, Settings |
| Notification Badge | Badge widget | Shows unread count on bell icon |
| Screen Navigation | Navigator.push | MaterialPageRoute for detail screens |

---

## Enhancement Screens (v2.0)

### Screen: SearchScreen (`views/search/search_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Search Input | TextField | autofocus, prefixIcon: search, border: primaryColor | Full-width with cancel button |
| Filter Chips | SingleChildScrollView + FilterChip | horizontal scroll | All, Status, Priority, Assignee, Due Date |
| Results Section | ListView | grouped by type | Section headers: "Tasks (N results)", "Projects (N results)" |
| Task Result Card | Card | shows project name, status dot, priority badge | Highlights matching text |
| Project Result Card | Card | icon + name + member/task count | Chevron right indicator |
| Empty Search | EmptyState | search_off icon, Lottie animation | "No results found" |

Mockups: `search.html`, `search-filters.html`

### Screen: AnalyticsScreen (`views/dashboard/analytics_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| KPI Cards | Grid 2x2 | icon + value + label | Completion rate %, Overdue count, Avg completion, Total tasks |
| Status Donut Chart | fl_chart PieChart | status colors, center hole | Shows total in center |
| Weekly Trend Chart | fl_chart BarChart | paired bars per week | Created (primary) vs Completed (success) |
| Team Workload | ListView | avatar + name + progress bar + count | Horizontal bar per member |

Mockups: `analytics.html`

### Screen: VoiceTaskScreen (`views/tasks/voice_task_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Voice Sheet | ModalBottomSheet | rounded top 24 | Overlay on current screen |
| Mic Button | Container 72x72 | primaryColor, pulsing animation | Start/stop recording |
| Waveform | Custom AnimatedWidget | 15 bars, primaryColor | Animated wave bars |
| Transcript Box | Container | grey bg, rounded 12 | Live updating text with cursor |
| Cancel Button | ElevatedButton | grey bg | Dismisses sheet |
| Process Button | ElevatedButton | primaryColor bg | Sends to AI API |

Mockups: `voice-assistant.html`, `voice-task-preview.html`

### Widget: AttachmentPicker (`views/widgets/attachment_picker.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Picker Sheet | ModalBottomSheet | rounded top 24 | Camera, Gallery, Document, Cloud |
| Option Icons | Container 60x60 | colored bg, white icon | Blue/purple/indigo/green |
| Cancel Button | TextButton | full width, grey | Dismisses sheet |

Mockups: `attachment-picker.html`, `attachment-preview.html`

### Widget: ConnectivityBanner (`views/widgets/connectivity_banner.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Offline Banner | AnimatedContainer | red bg, wifi_off icon | Slides down when offline |
| Reconnecting Banner | AnimatedContainer | amber bg, sync icon | Pulsing dots animation |
| Restored Banner | AnimatedContainer | green bg, check_circle icon | Auto-dismisses after 3s |
| Full Offline Screen | Scaffold | cloud_off icon, retry button | Shown after prolonged disconnect |

Mockups: `connectivity-states.html`

### Widget: EmptyState (Enhanced) (`views/widgets/empty_state.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Animation | Lottie.asset | 100x100, float animation | Replaces static icon |
| Variants | Per-screen | Different icons/colors per context | Tasks, Projects, Notifications, Search, Attachments, Kanban Column |

Mockups: `empty-states.html`

### Kanban Drag-and-Drop (`views/projects/project_board_screen.dart`)

| Element | Type | Properties | Notes |
|---------|------|------------|-------|
| Drag Handle | Icon grip_indicator | D1D5DB color, left of card | Indicates draggability |
| Dragged Card | LongPressDraggable | rotated -2deg, shadow, primaryColor border | Feedback widget |
| Ghost Card | Container | dashed border, 40% opacity | Placeholder at original position |
| Drop Zone | DragTarget | dashed primaryColor border, 5% bg | "Drop here" text |

Mockups: `kanban-drag-state.html`

---

## Dark Mode

All screens have dark mode variants (suffix `-dark.html`). Dark mode tokens:

| Light Token | Dark Token | Usage |
|-------------|-----------|-------|
| #F9FAFB (surface) | #121212 | Background |
| #FFFFFF (card) | #1E1E1E | Card/surface |
| #E5E7EB (border) | #2A2A2A | Borders |
| #111827 (text primary) | #F3F4F6 | Primary text |
| #6B7280 (text secondary) | #9CA3AF | Secondary text |
| #6366F1 (primary) | #818CF8 | Primary accent |

Dark mockups: `login-dark.html`, `register-dark.html`, `dashboard-dark.html`, `projects-dark.html`, `kanban-dark.html`, `notifications-dark.html`, `settings-dark.html`, `task-detail-dark.html`, `create-task-dark.html`
