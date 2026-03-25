# Task Management App — Enhancement Plan v2.0

**Date:** 2026-03-25
**Status:** In Progress

---

## Overview

Enhancing the Task Management App with 8 new features across backend, frontend, and design.

## Project Structure

```
task-management-app-task/
├── SRS/                  # Software Requirements Specification
├── UserStories/          # User stories by epic
├── Frontend/
│   ├── Code/             # Flutter app (Dart)
│   ├── Figma/            # Design mapping docs
│   └── Tests/            # Frontend test files
├── Backend/
│   ├── Code/             # Node.js + Express + TypeScript + Prisma
│   └── Tests/            # Backend test files
├── CodeReview/           # Code review reports
└── plan.md               # This file
```

---

## Enhancement List

| # | Enhancement | Complexity | Status |
|---|------------|-----------|--------|
| 1 | Dark Mode / Theme Switching | Low (already exists) | ✅ Backend N/A · ✅ Figma Done |
| 2 | Drag-and-Drop Kanban Board | Medium | ✅ Backend Done · ✅ Figma Done |
| 3 | Global Search & Filter | Medium | ✅ Backend Done · ✅ Figma Done |
| 4 | Dashboard Analytics | Medium | ✅ Backend Done · ✅ Figma Done |
| 5 | File Attachments | High | ✅ Backend Done · ✅ Figma Done |
| 6 | AI Voice Assistant (Voice-to-Task) | Very High | ✅ Backend Done · ✅ Figma Done |
| 7 | Network Connectivity Animation | Low | ⬜ Backend N/A · ✅ Figma Done |
| 8 | No Data / Empty Screen Animations | Low | ⬜ Backend N/A · ✅ Figma Done |

---

## Phase Breakdown

### Phase 1: Backend (✅ COMPLETE)

All backend changes implemented and tested:

**Schema Changes (Prisma):**
- Added `position Int @default(0)` to Task model (for Kanban ordering)
- Added `Attachment` model with relations to Task and User
- Migration applied: `20260325031830_add_enhancements`

**New API Endpoints:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tasks/bulk-status` | PUT | Batch update task statuses |
| `/api/tasks/reorder` | PUT | Reorder task within/across columns |
| `/api/search` | GET | Global search across tasks & projects |
| `/api/dashboard/analytics` | GET | Completion rate, priority dist, workload, trends |
| `/api/tasks/:id/attachments` | POST/GET | Upload and list file attachments |
| `/api/attachments/:aid` | DELETE | Delete attachment |
| `/api/attachments/:aid/download` | GET | Download attachment |
| `/api/ai/parse-task` | POST | AI-powered voice transcript → task parsing |

**New Files:**
- `src/controllers/search.controller.ts`
- `src/controllers/attachments.controller.ts`
- `src/controllers/ai.controller.ts`
- `src/routes/search.ts`
- `src/routes/attachments.ts`
- `src/routes/ai.ts`
- `src/services/ai.service.ts` (OpenAI integration)
- `src/middleware/upload.ts` (Multer file upload)

**Dependencies Added:** `multer`, `@types/multer`, `openai`

**Tests:** 5 test files in `Backend/Tests/`

---

### Phase 2: Figma Design (✅ COMPLETE)

28 mockup HTML files created/updated at `Frontend/Code/figma-mockups/`:

**New Screens (10):**
- `search.html` — Global search with results
- `search-filters.html` — Filter bottom sheet
- `analytics.html` — Dashboard analytics with charts
- `voice-assistant.html` — Voice recording overlay with waveform
- `voice-task-preview.html` — AI parsed task preview
- `connectivity-states.html` — Offline/reconnecting/restored banners
- `empty-states.html` — All empty state variations
- `attachment-picker.html` — File picker bottom sheet
- `attachment-preview.html` — Full-screen file viewer
- `kanban-drag-state.html` — Drag-and-drop interaction state

**Updated Screens (3):**
- `dashboard.html` — Added analytics entry card
- `task-detail.html` — Added Files tab
- `kanban.html` — Added mic button for voice assistant

**Dark Mode Variants (9):**
- All existing screens have `-dark.html` variants

**Figma Upload:** Pushed to Figma file `nS6sMWBiXv2Ld3mO9WDtee`

---

### Phase 3: Frontend Implementation (⬜ PENDING — Awaiting User Approval)

**Waiting for user to review Figma designs before proceeding.**

Planned frontend work:

#### 3a. Empty State Animations
- Upgrade `EmptyState` widget with Lottie animations
- Add animation assets to `assets/animations/`
- New dependency: `lottie: ^3.1.3`

#### 3b. Network Connectivity
- New `ConnectivityBanner` widget with animated states
- Global overlay integration in `AppShell`
- New dependency: `connectivity_plus: ^6.1.0`

#### 3c. Global Search & Filter
- New `SearchScreen` with debounced search
- `SearchFilterSheet` bottom sheet
- Search service, repository, viewmodel (Riverpod)

#### 3d. Drag-and-Drop Kanban
- Replace `PageView` with horizontal `ScrollView` showing all columns
- `LongPressDraggable` + `DragTarget` on task cards
- Optimistic status update with rollback

#### 3e. Dashboard Analytics
- New `AnalyticsScreen` with `fl_chart` widgets
- Pie chart (status), bar chart (workload), line chart (trends)
- New dependency: `fl_chart: ^0.69.0`

#### 3f. File Attachments
- New `AttachmentService` with Dio multipart upload
- Files tab in `TaskDetailScreen`
- `AttachmentPicker` and `AttachmentPreview` widgets
- New dependencies: `image_picker`, `file_picker`, `open_filex`, `cached_network_image`

#### 3g. AI Voice Assistant
- New `VoiceTaskScreen` with speech-to-text
- Waveform animation widget
- AI service integration for transcript parsing
- New dependencies: `speech_to_text`, `permission_handler`, `audio_waveforms`
- Platform permissions: iOS `Info.plist`, Android `AndroidManifest.xml`

#### 3h. Dark Mode Polish
- Add `AnimatedTheme` transition to `MaterialApp`

---

### Phase 4: Code Review (⬜ OPTIONAL)

After frontend implementation, optionally run code review covering:
- Code quality and best practices
- Component architecture
- Performance considerations
- Security issues
- Test coverage

---

## Environment Setup

**Backend:**
```bash
cd Backend/Code
cp .env.example .env  # Set OPENAI_API_KEY
npm install
npx prisma migrate dev
npm run dev  # Runs on port 8000
```

**Frontend:**
```bash
cd Frontend/Code
flutter pub get
flutter run
```

---

## Key Decisions

1. **File Storage:** Local disk (`uploads/` directory) for v2.0. Can migrate to S3 later.
2. **AI Provider:** OpenAI GPT-4o-mini for voice transcript parsing (cost-effective).
3. **Charts:** `fl_chart` package for Flutter analytics charts.
4. **Speech-to-Text:** `speech_to_text` package (uses platform native APIs).
5. **Animations:** Lottie for empty states, CSS/Flutter animations for connectivity.
