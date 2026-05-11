# Dad Strong – Workspace Map

## Über das Projekt
Dad Strong ist ein Kraft- und Ausdauertrainingsprogramm für Väter.
Fixer Trainingsplan (Training A + B), integrierte lineare Progression, Körper-Dokumentation mit Fotos.
Kein Week-Tracker, kein Challenge-Druck — reine Konsistenz und Fortschrittsdokumentation.
Ziel: im App Store veröffentlichen. Vermarktung über den fixen Plan und Community-Vergleich.

**Entwickler:** Christian Bachmann
**Domain:** dadstrong.app
**Sprache:** Deutsch (UI + Kommunikation), Englisch (Code)

---

## Session-Ende Befehl
Wenn der User "Ende für heute", "Wir machen Schluss" oder ähnliches sagt →
`STATUS.md` im Projektstamm aktualisieren: was heute gemacht wurde, was offen ist, nächste Schritte.

---

## Tech Stack
- Swift / SwiftUI (iOS 17+)
- SwiftData — lokale Persistenz (WorkoutSession, BodyCheckIn, Zone2Session, SprintSession)
- WidgetKit + App Group — Home Screen Widget (Small, Medium, Large)
- HealthKit — Körpergewicht lesen, Workouts schreiben
- UserNotifications — wöchentliche Sonntagserinnerung 6:30 Uhr
- xcodegen — Projektdatei aus `project.yml` generieren → nach neuen Dateien immer `xcodegen generate`

**Kein Backend, kein Netzwerk.** Alles lokal.

---

## Ordnerstruktur
```
DadStrong/Sources/
├── DadStrongApp.swift          # Entry Point, ModelContainer, init-Calls
├── Models/                     # Exercise, WorkoutSession, BodyCheckIn, Zone2Session, SprintSession, ProgressionAdvice
├── State/                      # WorkoutSessionState, WorkoutPhase, RestTimerState, AudioService, HealthKitManager, HeartRateManager
├── Data/                       # ExercisesData, SharedWidgetData, StreakCalculator, PhotoStore
├── Services/                   # NotificationService
└── Views/
    ├── AppColors.swift         # Design Tokens (alle Farben hier)
    ├── Components/             # PrimaryButton, RingTimerView, ScrollPicker, RingTimerState
    ├── Home/                   # HomeView, WeekCalendarView, StreakBarView
    ├── Workout/                # WorkoutView, ActiveSetView, SetRestView, SpecificWarmupView,
    │                           # GeneralWarmupView, ExerciseTransitionView, BilateralRestEntryView,
    │                           # TimedSetActiveView, SetView, RestView, SummaryView
    ├── Journey/                # JourneyView, CheckInEntryView, ProgressionView, ProgressChartView
    ├── Zone2/                  # Zone2SetupView, Zone2ActiveView
    └── Sprint/                 # SprintTrainingView

DadStrongWidget/
└── DadStrongWidget.swift       # Small, Medium, Large Widget — alles in einer Datei
```

---

## Trainingsplan (fest, nicht konfigurierbar — das ist das Produkt)

**Training A:** Kniebeuge · Bankdrücken · Rudern · BSS (bilateral) · Farmer Walk (timed)
**Training B:** Kreuzheben · OHP · Klimmzüge · Frontkniebeuge

Progression: Linear. Nach jedem Trainingsblock wird das Gewicht erhöht wenn alle Sätze ≥ Threshold.
Quelle der Wahrheit: `ExercisesData.swift`

---

## State Machine (Workout-Flow)

```
generalWarmup
  → specificWarmup(exerciseIndex, step)   [wenn hasSpecificWarmup]
      → letzter Step → activeSet direkt (kein preSet!)
  → activeSet(exerciseIndex, setIndex, isLeft?)

activeSet → [FERTIG tap]
  → bilateralResting   [bilateral, linke Seite fertig]
  → resting            [normaler Set, 180s zwischen Sets, 60s nach letztem Set]

resting → [Timer 0, auto-advance]
  → activeSet(setIndex+1)         [nächster Satz]
  → exerciseTransition(fromIndex) [letzter Satz → 2min Pause, AUTO-ADVANCE bei Timer=0]

exerciseTransition → activeSet oder specificWarmup der nächsten Übung
  → complete → SummaryView

preSet: nur noch für Timed-Übungen (Farmer Walk bilateral)
```

**Wichtig:** Die Pause ist nicht verhandelbar. Kein Skip-Button in SetRestView.

---

## WorkoutSessionState — Schlüsselmethoden

| Methode | Bedeutung |
|---------|-----------|
| `finishSpecificWarmupStep(exerciseIndex:step:)` | Nächster Warmup-Step oder direkt → activeSet |
| `finishActiveSet(exerciseIndex:setIndex:isLeft:)` | Startet Timer (60s/180s), wechselt zu resting/bilateralResting |
| `confirmAndLogSet(...)` | Loggt Daten OHNE Phase zu ändern — aufgerufen nach Bestätigung in SetRestView |
| `advanceAfterRest(exerciseIndex:setIndex:)` | Bewegt Phase weiter wenn Timer=0 |
| `warmupStepDisplay(for:step:)` | Gibt (label, kg?) zurück für SpecificWarmupView |
| `logBilateralLeft(...)` | Loggt linke Seite, wechselt zu rechter Seite |
| `finishExerciseTransition(fromIndex:)` | Startet nächste Übung |

---

## Design System

```swift
// AppColors.swift
background       = Color.black
surface          = Color(white: 0.1)
surfaceElevated  = Color(white: 0.15)
textPrimary      = Color.white
textSecondary    = Color(white: 0.5)
accent           = Color(red: 0.831, green: 1.0, blue: 0.0)   // #D4FF00 Gelbgrün
zone2            = Color(red: 1.0, green: 0.55, blue: 0.1)    // #FF8C1A Orange
sprint           = Color(red: 0.95, green: 0.15, blue: 0.15)  // #F22626 Rot
```

**Typografie-Pattern** (kein Custom Font, SF Pro):
- Label/Kategorie: `.system(size: 11, weight: .bold)`, `.tracking(2)`, textSecondary
- Überschrift: `.system(size: 28, weight: .black)`, `.tracking(1)`
- Body: `.system(size: 15, weight: .regular/.semibold)`
- Zahl groß: `.system(size: 36, weight: .black)`

**Radius:** 10 (Inputs), 12 (Karten klein), 14 (Karten groß), 16 (große Karten)
**Spacing:** 8 / 12 / 16 / 20 / 24 / 32

---

## Datenmodelle (SwiftData @Model)

| Model | Felder |
|-------|--------|
| `WorkoutSession` | date, type (TrainingType: .a/.b), durationSeconds, logs: [ExerciseLog] |
| `ExerciseLog` | exerciseId, sets: [WorkoutSet] |
| `WorkoutSet` | reps, weightKg, effort (EffortLevel), isLeft? |
| `BodyCheckIn` | date, weightKg, waistCm, photoFront?, photoBack?, photoSide?, photoFilename? (legacy), isStart |
| `Zone2Session` | date, durationSeconds, targetMinutes, avg/min/maxHeartRate |
| `SprintSession` | date |

---

## Widget

App Group ID: `group.com.christianbachmann.dadStrong`
SharedWidgetData schreibt: Sessions (type: "A"/"B"/"zone2"/"sprint") + WidgetStreaks
Widget-Bild: Asset `app-widget-bild` im Widget-Bundle → für public App ersetzen

---

## Fotos

`PhotoStore.swift` — speichert in `Documents/checkin-photos/`. Wird per iCloud gesichert.
Dateinamen werden in BodyCheckIn als String gespeichert.

---

## Für App Store (noch offen)

- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`)
- [ ] Privacy Policy URL (einfache Seite auf dadstrong.app)
- [ ] Bundle ID für public Version ändern
- [ ] Widget-Bild ersetzen (aktuell persönliches Foto von Christian)
- [ ] Screenshots (6.5" + 5.5" iPhone)
- [ ] Share-Karte (Progression teilbar machen)
- [ ] Onboarding (2–3 Screens: was ist das Programm)

---

## Arbeitsregeln
- Immer auf Deutsch kommunizieren
- Code auf Englisch
- Nach neuen Dateien: `xcodegen generate`
- Keine Skip-Buttons für Pausen — die Pause ist nicht verhandelbar
- Kein Week-Tracker, kein Challenge-Druck — reine Dokumentation
