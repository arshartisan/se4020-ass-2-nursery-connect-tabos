# Part A — iPadOS App Development Plan (NurseryConnect)

**Course:** SE4020 — Mobile Application Design and Development (Semester 1, 2026)
**Student:** IT22346322 — MJM ARSHAQ
**Weight:** 10% (100 marks rubric)
**Deadline:** 3 June 2026 · **Viva:** 6–7 June 2026
**Goal:** Extend the Assignment 1 NurseryConnect iOS app (Keyworker — Daily Diary + Incident Reporting) into a fully functional **iPadOS** application using SwiftUI, integrating at least one approved advanced Apple framework and at least one iPadOS-native feature.

> **Path chosen:** Part A = **iPadOS** · Part B = **visionOS** (see `Phase_Plan_visionOS.md`). The watchOS plan is **not selected**.

---

## 0. LOCKED DECISIONS  *(these are committed — every phase below assumes them)*

| Decision | **Locked choice** | Why |
|---|---|---|
| Target platform | **iPadOS** (min iPadOS 17) | Keyworkers are mobile, on-the-floor staff; iPad suits Pencil + split-view. SwiftData/`@Observable` from A1 need iOS/iPadOS 17+. |
| User role | **Keyworker** — carried forward from Assignment 1 | Keeps continuity with the A1 codebase and data model; lowest risk in a 4-day build. |
| **Carried forward** (re-implemented for iPad) | Child Roster, Child Detail, Daily Diary logging, Incident Reporting | Reuse A1 `Child` / `DiaryEntry` / `IncidentReport` models + `DiaryService` / `IncidentService`. |
| **New / extended feature** | **Development & Wellbeing Insights** dashboard + **Daily/Weekly PDF Report** that the keyworker signs and shares with parents | Natural next step after logging — turns existing diary data into trends + a parent-facing artefact. |
| Advanced framework (criterion 4) | **Swift Charts** (primary) — wellbeing-mood / nap-duration / meal trends from diary data. *(Stretch: PDFKit for the report export.)* | Adds genuine value to the new feature; fast, low-risk win in the time available. |
| iPadOS-native feature (criterion 3) | **Multi-column `NavigationSplitView`** (sidebar → child list → detail) **+ PencilKit** (handwritten observation / signature on the report). *(Bonus: ⌘-key shortcuts.)* | Two distinct, demoable iPad-defining capabilities. |
| Architecture | **MVVM + Services** (same layering as A1) | Required by criterion 5; already proven in A1. |

> **Rule from brief:** Do **not** add login / authentication / access control — the app must launch straight into its main functionality.

### One-sentence pitch (Phase 1 exit criteria — already satisfied)
*"This app helps the **Keyworker** turn their daily diary logs into **development & wellbeing insights and a signed parent report**, using **Swift Charts + PencilKit/PDFKit** on **iPadOS**."*

---

## 0b. Pre-Flight Decisions (reference — kept for the report's rationale section)

| Decision | Options considered | Notes |
|---|---|---|
| Target platform | iPadOS **or** macOS | Chose iPadOS (see locked table). macOS suits Setting Managers (multi-window dashboards) — not our role. |
| User role focus | Keyworker · Parent · Setting Manager · Catering Staff | Kept Keyworker for continuity; report must clearly mark "new vs carried-forward". |
| Advanced framework | One from the approved list | Chose Swift Charts. Approved list excludes MapKit / Core Data / Localisation. |
| Native platform feature | PencilKit / Drag & Drop / multi-column nav / keyboard shortcuts | Chose NavigationSplitView + PencilKit. |

---

## Phase 1 — Requirements & Scope Lock-In  *(Day 1 morning — ~3 hrs)*

**Objective:** Convert the brief into a concrete feature spec.

**Activities** *(decisions already locked in §0 — this phase is about writing them up)*
- Write the one-page **"What's new vs Assignment 1" diff** for the report:
  - *Carried forward:* Roster, Child Detail, Diary logging, Incident reporting (re-platformed to iPad split-view).
  - *New:* Development & Wellbeing Insights (Swift Charts), signed Daily/Weekly report (PencilKit + PDFKit), iPad multi-column navigation.
- Map every rubric criterion (1–8) to its phase (see the traceability table at the foot of this file).
- Sketch the iPad navigation map (sidebar → list → detail).
- Note persistence stays **SwiftData** (re-used from A1; does not count as the advanced library).

**Deliverables**
- `docs/scope.md` — role, new-vs-carried, rubric mapping.
- Navigation diagram (hand-drawn or Figma).
- Data model ERD (Child → DiaryEntry / IncidentReport).

**Exit criteria** — already met (see the one-sentence pitch in §0).

---

## Phase 2 — AI-Driven UI Mockup Generation  *(Day 1 afternoon — ~4 hrs)*

**Objective:** Satisfy the **AI-Driven UI Design Process** requirement (rubric criterion 2 = 20 marks).

**Activities**
- Choose at least **one** AI design tool (e.g., v0 by Vercel, Galileo AI, Figma AI, Midjourney, ChatGPT image-gen, Claude Artifacts).
- Write a single tool-justification paragraph: *why this tool for this role/platform*.
- Generate **at least 3 distinct mockup variations** of the primary screen(s) — vary layout, color, density, navigation style.
- Save full-resolution screenshots of each mockup with filenames `mockup_v1.png`, `mockup_v2.png`, `mockup_v3.png`.
- Capture and save **every prompt and AI response** verbatim (rubric criterion 8 = 5 marks for AI usage documentation).
- Critically evaluate each variation against: target user role, NurseryConnect context, platform HIG (iPadOS or macOS).
- Pick a final design (or synthesise) and write the rationale.

**Deliverables**
- `docs/ui-mockups/` folder with 3+ images.
- `docs/ai-mockup-log.md` containing prompts, responses, tool justification, evaluation table, final-design rationale.

**Exit criteria**
- You can defend the design choice with reference to HIG and the user role.

---

## Phase 3 — Project Setup & Architecture Skeleton  *(Day 1 evening — ~2 hrs)*

**Objective:** Stand up a clean SwiftUI project with the right structure before any feature code.

**Activities**
- New Xcode project — SwiftUI App lifecycle, iPadOS *or* macOS target. Min deployment: iPadOS 17 / macOS 14 (Sonoma) or newer to match your framework choice.
- Folder layout: `Models/`, `Views/`, `ViewModels/`, `Services/`, `Persistence/`, `Resources/`.
- Add MVVM scaffolding (one example `ViewModel` with `@Observable` or `ObservableObject`).
- Set up Core Data / SwiftData stack (persistence is required by rubric — but not counted as the advanced library).
- Initialise the GitHub repo, push the skeleton, add `.gitignore`, `README.md`.
- Configure app icon, accent color, launch screen, basic info.plist entries.

**Deliverables**
- Compiling, runnable skeleton on the device/simulator.
- Initial commit pushed to GitHub.

**Exit criteria**
- `⌘R` opens an empty NurseryConnect window/screen with the chosen navigation chrome.

---

## Phase 4 — Migrate / Re-implement Assignment 1 Core  *(Day 2 morning — ~4 hrs)*

**Objective:** Bring forward the Assignment 1 features that the new work builds on.

**Activities**
- Bring across the A1 source: `Child`, `DiaryEntry`, `IncidentReport` models; `DiaryService`, `IncidentService`, `MockDispatchService`, `ChildRosterService`; `ModelContainerProvider` (production + in-memory); `SeedDataService`; the design-system layer (`AppColors`, `AppTypography`, `AppSpacing`, `CardStyle`, `PrimaryButtonStyle`).
- Replace the A1 iPhone `TabView` shell with an iPad **`NavigationSplitView`** (sidebar: Children / Insights / Incidents → child list → detail). Do **not** copy the phone layout verbatim.
- Re-present the diary timeline and incident flows in the detail column; keep the diary sheet + incident `fullScreenCover`.
- Confirm `SeedDataService` populates the roster so every screen is non-empty at launch.

**Deliverables**
- Working A1 baseline (roster, diary, incidents) running in the iPad simulator via NavigationSplitView.
- Sample data visible in every primary screen.

---

## Phase 5 — Platform-Specific Native Feature  *(Day 2 afternoon — ~3 hrs)*

**Objective:** Hit rubric criterion 3 (10 marks) with a *meaningful* native feature.

**LOCKED for this build (two iPadOS-native capabilities):**
- **Multi-column `NavigationSplitView`** — sidebar (Children / Insights / Incidents) → child list → detail. The structural backbone from Phase 4.
- **PencilKit** — a `PKCanvasView` for a handwritten observation note and/or the keyworker's **signature on the daily report** before it is exported/shared.
- *Bonus if time:* keyboard shortcuts (`⌘N` new diary entry, `⌘F` find child) via `.keyboardShortcut`.

*(Other options considered: Drag & Drop, Stage Manager scenes — not used.)*

**Activities**
- Wire `NavigationSplitView` selection state through the view models (no hard-coded widths).
- Add a PencilKit canvas in the report/observation screen; persist the drawing as PNG/`Data` on the relevant SwiftData record.
- Confirm both show clearly in the demo video for the viva.

**Deliverables**
- NavigationSplitView driving the whole app + a working PencilKit canvas saved to data.

---

## Phase 6 — Advanced Library Integration  *(Day 2 evening + Day 3 morning — ~5 hrs)*

**Objective:** Hit rubric criterion 4 (15 marks). The integration must add **genuine value**, not be a label.

**LOCKED: Swift Charts** is the advanced framework.
- Build a **Development & Wellbeing Insights** screen that reads existing `DiaryEntry` data and renders: wellbeing-mood over time (line), nap duration per day (bar), meal/activity counts (stacked bar), per-child and roster-wide.
- This is the "new feature" extension *and* the advanced-library deliverable in one — the strongest value-for-effort in the time available.
- **Stretch (only if Day 3 is ahead): PDFKit** — export the insights + signed observation as a Daily/Weekly PDF report to share with parents. Counts as a second advanced framework if completed.

**Reference — other approved frameworks** (must come from the approved list — *not* MapKit, Core Data, or Localisation):

| Feature idea | Matching framework |
|---|---|
| Auto-tag child photos / detect faces in artwork | **Vision** + **PhotosUI** |
| Voice notes that transcribe to observation text | **Speech** + **AVFoundation** |
| Sentiment / keyword extraction on parent feedback | **NaturalLanguage** |
| Custom child-development trend model | **CoreML** (+ **CreateML** to train) |
| Sync child records across staff devices | **CloudKit** |
| Allergy & nutrition data with charts | **Swift Charts** |
| Sleep/nap-time noise level analysis | **SoundAnalysis** |
| Generate signed PDF daily reports | **PDFKit** |
| Wellbeing dashboard for staff | **HealthKit** |
| Biometric lock on sensitive reports | **LocalAuthentication** *(allowed even though general auth is forbidden — only locks one screen, not app entry)* |
| Live attendance counters | **ActivityKit** (iPadOS only) |
| Quick "Mark present" widget | **WidgetKit** |
| "Hey Siri, log nap for Alex" | **AppIntents** |

**Activities**
- Add the framework, capabilities, and any Info.plist usage strings.
- Wire it into a real user task — outputs should drive UI, not be discarded.
- Handle errors and empty/permission-denied states.

**Deliverables**
- Feature using the advanced framework, visible in the main flow.

---

## Phase 7 — UI Polish, Responsiveness & Accessibility  *(Day 3 afternoon — ~3 hrs)*

**Objective:** Hit the "professional, responsive, accessible" bar (criterion 2).

**Activities**
- Test all common window sizes / iPad orientations (split view, full screen, compact).
- Verify Dynamic Type and Dark Mode.
- Add VoiceOver labels for all interactive elements; check rotor navigation.
- Tune colour contrast (aim WCAG AA), ensure brand colors remain childcare-appropriate.
- Add empty states, loading states, error states for every screen.
- Add subtle animations / transitions where they reinforce hierarchy.
- Confirm typography scale and spacing tokens are consistent.

**Deliverables**
- Polished UI across all target sizes.

---

## Phase 8 — Testing & Debugging  *(Day 3 evening — ~3 hrs)*

**Objective:** Hit rubric criterion 6 (10 marks) — evidence of testing, error handling, edge cases.

**Activities**
- Add unit tests for ViewModels (XCTest) — at least one per primary VM.
- Add UI tests for one critical user flow (e.g., create observation → save → reappears in list).
- Run a manual test pass with a written checklist; record results in `docs/test-log.md`.
- Edge cases: empty data, permission denied, very long names, no network (if CloudKit), large datasets.
- Fix bugs found; rerun.

**Deliverables**
- `Tests/` folder with passing tests.
- `docs/test-log.md` with manual pass + screenshots / notes.

---

## Phase 9 — Documentation, Report & Regulatory Discussion  *(Day 4 morning — ~3 hrs)*

**Objective:** Hit criteria 7 (Report — 5 marks) and 8 (AI Usage — 5 marks).

**Report sections required**
1. Chosen role + feature scope + what's new vs Assignment 1.
2. Architecture overview (MVVM diagram).
3. AI-driven UI design process — tool justification, the 3 mockups, evaluation, final rationale (from Phase 2).
4. Platform-specific feature — what and why.
5. Advanced framework — what, how, and the value it adds.
6. **Regulatory compliance discussion** — childcare context: child data protection (GDPR/UK Data Protection Act / Sri Lanka PDPA depending on jurisdiction), photo/consent handling, safeguarding, App Store/Privacy Manifest, accessibility (Equality Act / WCAG).
7. Testing summary.
8. Challenges & reflections.
9. **AI Usage Documentation appendix** — every code-gen prompt + response, every UI-mockup prompt + response, tool selection rationale for both.

**Deliverables**
- `Report.pdf` (or `.docx`) with all sections.
- `docs/ai-usage-log.md` appendix.

---

## Phase 10 — Demo, Submission & Viva Prep  *(Day 4 afternoon → 3 June — ~3 hrs)*

**Activities**
- Record a 2–4 min screen recording demoing every rubric-aligned feature (carried-forward, new feature, native platform feature, advanced framework).
- Final GitHub push — tag a `submission` release.
- Bundle: source code, report, video link, AI usage log, mockup folder.
- Submit per the LMS guidance.
- For viva (6–7 June): be able to *explain every line of code* and every design choice — including why each framework, why each mockup variation, and how the regulatory discussion shaped decisions.

**Deliverables**
- Submission package on LMS.
- GitHub repo tagged.
- Demo video.

---

## Risk Register

| Risk | Mitigation |
|---|---|
| Advanced framework integration deeper than expected (CoreML, HealthKit) | Pick a leaner framework if Day 2 evening slips — e.g., Swift Charts or PDFKit are fast wins. |
| iPad/Mac layout doesn't truly adapt | Use `NavigationSplitView` from the start; avoid hard-coded widths. |
| AI mockup tool produces generic mockups | Anchor each prompt with: role, screen, NurseryConnect context, platform conventions. |
| Tests pushed to last day | Test the ViewModel as soon as it exists — don't wait. |
| Viva can't explain AI-generated code | Read every AI suggestion; rewrite anything you don't understand. |

---

## Rubric → Phase Traceability

| Rubric criterion (marks) | Covered by phase |
|---|---|
| 1. Functionality & Extension (20) | 1, 4, 5, 6 |
| 2. UI Design & AI Mockup Process (20) | 2, 7 |
| 3. Platform-Specific Feature (10) | 5 |
| 4. Advanced Library Integration (15) | 6 |
| 5. SwiftUI & Code Quality (15) | 3, 4, 6 |
| 6. Testing & Debugging (10) | 8 |
| 7. Documentation & Report (5) | 9 |
| 8. AI Usage Documentation (5) | 2, 6, 9 |
