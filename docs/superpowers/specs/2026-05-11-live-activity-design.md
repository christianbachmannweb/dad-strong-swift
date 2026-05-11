# Live Activity / Dynamic Island — Dad Strong

## Ziel

Herzfrequenz auf der Dynamic Island und dem Lock Screen anzeigen, wenn Zone2-, Sprint- oder Krafttraining im Hintergrund läuft. Compact: nur BPM. Tap öffnet die App.

---

## Shared Data Model

**Datei:** `Shared/TrainingLiveActivityAttributes.swift`  
**Target-Mitgliedschaft:** DadStrong + DadStrongWidget

```swift
import ActivityKit

struct TrainingLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var heartRate: Int?
    }
    let trainingName: String   // "Zone 2" | "Sprint" | "Training A" | "Training B"
    let accentColor: String    // "accent" | "zone2" | "sprint"
}
```

Farbkodierung per String statt Color (Color nicht Codable).

---

## LiveActivityManager

**Datei:** `DadStrong/Sources/State/LiveActivityManager.swift`  
`@MainActor` Singleton. Hält die laufende Activity-Referenz.

```
start(trainingName:accentColor:)  → startet neue Activity (beendet vorherige falls nötig)
update(heartRate:)                → aktualisiert ContentState
end()                             → beendet Activity mit .immediate dismissal
```

Fehlerbehandlung: `ActivityAuthorizationInfo().areActivitiesEnabled` prüfen vor Start. Kein Crash wenn nicht verfügbar (iPhone ohne Dynamic Island, iOS < 16.2).

---

## Widget-Views

**Datei:** `DadStrongWidget/TrainingLiveActivityWidget.swift`

| Präsentation | Inhalt |
|---|---|
| `compactLeading` | SF Symbol `heart.fill` in Trainingsfarbe |
| `compactTrailing` | BPM-Zahl (`.black` weight) oder `–` |
| `minimal` | BPM-Zahl klein |
| `expanded` | — (nicht implementiert, Tap öffnet App) |
| Lock Screen | Trainingsname-Label + BPM groß in Trainingsfarbe |

Farben lokal im Widget definiert (wie bestehende `widgetAccent` etc.).

---

## Integration in Training-Views

Alle drei Views erhalten denselben Lifecycle-Aufruf:

```
onAppear            → LiveActivityManager.shared.start(trainingName:accentColor:)
onChange(heartRate) → LiveActivityManager.shared.update(heartRate:)
finish()            → LiveActivityManager.shared.end()
```

**Zone2ActiveView:** Farbe `zone2`, Name `"Zone 2"`  
**SprintTrainingView:** Farbe `sprint`, Name `"Sprint"`  
**WorkoutView:** Farbe `accent`, Name `"Training A"` oder `"Training B"` (aus `trainingType.label`)

---

## project.yml Änderungen

1. Neues `Shared/` Verzeichnis als Quelle in **beiden** Targets
2. `ActivityKit.framework` als Dependency in DadStrong-Target
3. `ActivityKit.framework` als Dependency in DadStrongWidget-Target

---

## Info.plist Änderung

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

---

## Nicht im Scope

- Expanded-View (Tap öffnet App stattdessen)
- Timer/Elapsed-Zeit in der Live Activity
- Push-Updates (alles lokal)
