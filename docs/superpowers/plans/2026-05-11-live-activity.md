# Live Activity / Dynamic Island Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Herzfrequenz auf Dynamic Island und Lock Screen anzeigen während Zone2-, Sprint- und Krafttraining im Hintergrund läuft.

**Architecture:** Ein gemeinsames `ActivityAttributes`-Struct (kompiliert in beide Targets via `Shared/`-Verzeichnis) definiert das Live Activity Datenmodell. Ein `@MainActor`-Singleton `LiveActivityManager` in der App steuert start/update/end. Das Widget rendert compact leading (Icon), compact trailing (BPM), minimal (BPM) und Lock Screen (Name + BPM). Kein Expanded View — Tap öffnet die App.

**Tech Stack:** ActivityKit, WidgetKit, SwiftUI, XcodeGen (project.yml)

---

### Task 1: project.yml — Shared/ Verzeichnis und ActivityKit

**Files:**
- Modify: `project.yml`

- [ ] **Step 1: Shared-Verzeichnis anlegen**

```bash
mkdir -p /Users/christianbachmann/Development/projects/dad-strong-swift/Shared
```

- [ ] **Step 2: project.yml anpassen**

`DadStrong`-Target: `Shared/` zu sources und ActivityKit zu dependencies hinzufügen.  
`DadStrongWidget`-Target: `Shared/` zu sources und ActivityKit zu dependencies hinzufügen.

Vollständige aktualisierte targets-Sektion:

```yaml
targets:
  DadStrong:
    type: application
    platform: iOS
    entitlements:
      path: DadStrong.entitlements
      properties:
        com.apple.developer.healthkit: true
        com.apple.security.application-groups:
          - group.com.christianbachmann.dadStrong
    sources:
      - path: DadStrong/Sources
      - path: DadStrong/Resources
      - path: Shared
    resources:
      - path: DadStrong/Resources/Assets.xcassets
      - path: DadStrong/Resources/10sek.mp3
      - path: DadStrong/Resources/start.mp3
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.christianbachmann.dadStrong
        INFOPLIST_FILE: DadStrong/Resources/Info.plist
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        ENABLE_PREVIEWS: YES
    dependencies:
      - target: DadStrongWidget
        embed: true
        codeSign: true
      - sdk: ActivityKit.framework

  DadStrongWidget:
    type: app-extension
    platform: iOS
    entitlements:
      path: DadStrongWidget/DadStrongWidget.entitlements
      properties:
        com.apple.security.application-groups:
          - group.com.christianbachmann.dadStrong
    sources:
      - path: DadStrongWidget
      - path: Shared
    resources:
      - path: DadStrongWidget/app-widget-bild.png
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.christianbachmann.dadStrong.widget
        INFOPLIST_FILE: DadStrongWidget/Info.plist
        SKIP_INSTALL: YES
    dependencies:
      - sdk: WidgetKit.framework
      - sdk: SwiftUI.framework
      - sdk: ActivityKit.framework
```

- [ ] **Step 3: xcodegen ausführen**

```bash
cd /Users/christianbachmann/Development/projects/dad-strong-swift && xcodegen generate
```

Erwartet: `✅ Generating project DadStrong` ohne Fehler.

- [ ] **Step 4: Commit**

```bash
git add project.yml
git commit -m "build: add Shared source dir and ActivityKit to both targets"
```

---

### Task 2: TrainingLiveActivityAttributes — Shared Data Model

**Files:**
- Create: `Shared/TrainingLiveActivityAttributes.swift`

- [ ] **Step 1: Datei erstellen**

```swift
import ActivityKit

struct TrainingLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var heartRate: Int?
    }
    let trainingName: String  // "Zone 2" | "Sprint" | "Training A" | "Training B"
    let accentColor: String   // "accent" | "zone2" | "sprint"
}
```

- [ ] **Step 2: Build prüfen**

```bash
cd /Users/christianbachmann/Development/projects/dad-strong-swift
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Shared/TrainingLiveActivityAttributes.swift
git commit -m "feat: add TrainingLiveActivityAttributes shared model"
```

---

### Task 3: LiveActivityManager — App-seitiger Singleton

**Files:**
- Create: `DadStrong/Sources/State/LiveActivityManager.swift`

- [ ] **Step 1: Datei erstellen**

```swift
import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {}

    private var activity: Activity<TrainingLiveActivityAttributes>?

    func start(trainingName: String, accentColor: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end()
        let attributes = TrainingLiveActivityAttributes(
            trainingName: trainingName,
            accentColor: accentColor
        )
        let content = ActivityContent(
            state: TrainingLiveActivityAttributes.ContentState(heartRate: nil),
            staleDate: nil
        )
        do {
            activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            // Live Activities nicht verfügbar (Simulator, ältere Geräte, Nutzereinstellung)
        }
    }

    func update(heartRate: Int?) {
        guard let activity else { return }
        let content = ActivityContent(
            state: TrainingLiveActivityAttributes.ContentState(heartRate: heartRate),
            staleDate: nil
        )
        Task { await activity.update(content) }
    }

    func end() {
        guard let a = activity else { return }
        let content = ActivityContent(
            state: TrainingLiveActivityAttributes.ContentState(heartRate: nil),
            staleDate: nil
        )
        Task { await a.end(content, dismissalPolicy: .immediate) }
        activity = nil
    }
}
```

- [ ] **Step 2: Build prüfen**

```bash
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add DadStrong/Sources/State/LiveActivityManager.swift
git commit -m "feat: add LiveActivityManager singleton"
```

---

### Task 4: Info.plist — NSSupportsLiveActivities

**Files:**
- Modify: `DadStrong/Resources/Info.plist`

- [ ] **Step 1: Key hinzufügen**

Vor dem abschließenden `</dict>` in `DadStrong/Resources/Info.plist` einfügen:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

- [ ] **Step 2: Build prüfen**

```bash
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add DadStrong/Resources/Info.plist
git commit -m "feat: enable NSSupportsLiveActivities"
```

---

### Task 5: Widget — Live Activity Views

**Files:**
- Create: `DadStrongWidget/TrainingLiveActivityWidget.swift`
- Modify: `DadStrongWidget/DadStrongWidgetBundle.swift`

- [ ] **Step 1: TrainingLiveActivityWidget.swift erstellen**

```swift
import ActivityKit
import WidgetKit
import SwiftUI

struct TrainingLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrainingLiveActivityAttributes.self) { context in
            LiveActivityLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) { EmptyView() }
            } compactLeading: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(liveActivityColor(context.attributes.accentColor))
            } compactTrailing: {
                if let hr = context.state.heartRate {
                    Text("\(hr)")
                        .font(.system(size: 14, weight: .black))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                } else {
                    Text("–")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.secondary)
                }
            } minimal: {
                if let hr = context.state.heartRate {
                    Text("\(hr)")
                        .font(.system(size: 11, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(liveActivityColor(context.attributes.accentColor))
                }
            }
        }
    }
}

private struct LiveActivityLockScreenView: View {
    let context: ActivityViewContext<TrainingLiveActivityAttributes>

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.trainingName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                if let hr = context.state.heartRate {
                    Text("\(hr)")
                        .font(.system(size: 48, weight: .black))
                        .monospacedDigit()
                        .foregroundStyle(liveActivityColor(context.attributes.accentColor))
                } else {
                    Text("–")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(.secondary)
                }
                Text("bpm")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "heart.fill")
                .font(.system(size: 32))
                .foregroundStyle(liveActivityColor(context.attributes.accentColor))
        }
        .padding(16)
        .background(.black)
    }
}

private func liveActivityColor(_ key: String) -> Color {
    switch key {
    case "zone2":  return Color(red: 1.0,   green: 0.55, blue: 0.1)
    case "sprint": return Color(red: 0.95,  green: 0.15, blue: 0.15)
    default:       return Color(red: 0.831, green: 1.0,  blue: 0.0)
    }
}
```

- [ ] **Step 2: In DadStrongWidgetBundle.swift registrieren**

```swift
import WidgetKit
import SwiftUI

@main
struct DadStrongWidgetBundle: WidgetBundle {
    var body: some Widget {
        DadStrongWidget()
        DadStrongSmallWidget()
        DadStrongLargeWidget()
        TrainingLiveActivityWidget()
    }
}
```

- [ ] **Step 3: Build prüfen**

```bash
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add DadStrongWidget/TrainingLiveActivityWidget.swift DadStrongWidget/DadStrongWidgetBundle.swift
git commit -m "feat: add TrainingLiveActivityWidget with Dynamic Island and Lock Screen views"
```

---

### Task 6: Zone2ActiveView — LiveActivityManager einbinden

**Files:**
- Modify: `DadStrong/Sources/Views/Zone2/Zone2ActiveView.swift`

- [ ] **Step 1: start in onAppear**

```swift
.onAppear {
    startTimer()
    hrManager.startScanningIfNeeded()
    LiveActivityManager.shared.start(trainingName: "Zone 2", accentColor: "zone2")
}
```

- [ ] **Step 2: update in onChange(of: currentHR)**

```swift
.onChange(of: currentHR) { _, hr in
    guard let hr else { return }
    hrSamples.append((date: Date(), bpm: hr))
    checkZoneAlert()
    LiveActivityManager.shared.update(heartRate: hr)
}
```

- [ ] **Step 3: end in finish()**

`LiveActivityManager.shared.end()` als erste Zeile in `finish()` einfügen (vor `timer?.invalidate()`):

```swift
private func finish() {
    LiveActivityManager.shared.end()
    timer?.invalidate()
    // ... rest unverändert ...
}
```

- [ ] **Step 4: Build prüfen**

```bash
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add DadStrong/Sources/Views/Zone2/Zone2ActiveView.swift
git commit -m "feat: wire LiveActivityManager into Zone2ActiveView"
```

---

### Task 7: SprintTrainingView — LiveActivityManager einbinden

**Files:**
- Modify: `DadStrong/Sources/Views/Sprint/SprintTrainingView.swift`

- [ ] **Step 1: start in onAppear**

```swift
.onAppear {
    startWarmup()
    hrManager.startScanningIfNeeded()
    LiveActivityManager.shared.start(trainingName: "Sprint", accentColor: "sprint")
}
```

- [ ] **Step 2: update in onChange(of: hrManager.heartRate)**

```swift
.onChange(of: hrManager.heartRate) { _, hr in
    if let hr {
        hrSamples.append((date: Date(), bpm: hr))
        LiveActivityManager.shared.update(heartRate: hr)
    }
}
```

- [ ] **Step 3: end in finish()**

`LiveActivityManager.shared.end()` als erste Zeile in `finish()`:

```swift
private func finish() {
    LiveActivityManager.shared.end()
    ticker?.invalidate()
    // ... rest unverändert ...
}
```

- [ ] **Step 4: Build prüfen**

```bash
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add DadStrong/Sources/Views/Sprint/SprintTrainingView.swift
git commit -m "feat: wire LiveActivityManager into SprintTrainingView"
```

---

### Task 8: WorkoutView — LiveActivityManager einbinden

**Files:**
- Modify: `DadStrong/Sources/Views/Workout/WorkoutView.swift`

WorkoutView hat noch kein `onAppear`. `onDisappear` existiert bereits. `onChange(of: hrManager.heartRate)` existiert bereits.

- [ ] **Step 1: onAppear hinzufügen (nach bestehendem onDisappear)**

```swift
.onDisappear {
    sessionState.timer.cancel()
    LiveActivityManager.shared.end()
}
.onAppear {
    hrManager.startScanningIfNeeded()
    LiveActivityManager.shared.start(
        trainingName: sessionState.trainingType.label,
        accentColor: "accent"
    )
}
```

- [ ] **Step 2: update in bestehendem onChange(of: hrManager.heartRate)**

```swift
.onChange(of: hrManager.heartRate) { _, hr in
    if let hr {
        hrSamples.append((date: Date(), bpm: hr))
        LiveActivityManager.shared.update(heartRate: hr)
    }
}
```

- [ ] **Step 3: Build prüfen**

```bash
xcodebuild -scheme DadStrong -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Erwartet: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add DadStrong/Sources/Views/Workout/WorkoutView.swift
git commit -m "feat: wire LiveActivityManager into WorkoutView"
```

---

### Task 9: Manuelle Verifikation auf Gerät

Live Activities laufen nicht im Simulator — ein iPhone 14 Pro oder neuer ist erforderlich.

- [ ] App auf physischem Gerät bauen und starten
- [ ] Zone2-Training starten, HR-Sensor verbinden → BPM erscheint in Dynamic Island compact trailing
- [ ] Screen sperren → Lock Screen Banner zeigt "ZONE 2" + BPM groß in oranger Farbe
- [ ] App in Hintergrund → Dynamic Island bleibt mit Live-BPM-Updates
- [ ] Training beenden → Dynamic Island verschwindet sofort
- [ ] Wiederholen für Sprint (rote Farbe) und Krafttraining (gelb-grüne Farbe)
