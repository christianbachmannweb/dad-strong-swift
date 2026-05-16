# Dad Strong — Future Features

## Apple Watch App

**Priorität:** Nach App Store Launch als Update

**Gewünschte Features:**
- Pausentimer anzeigen während Krafttraining
- Gewicht eingeben via Digital Crown
- Zone 2: Herzfrequenz anzeigen (Watch eigener HR-Sensor)
- Sprint: Timer + Vibration/Haptics bei Phasenwechsel

**Technischer Aufwand:**
- Separates watchOS-Target im Xcode-Projekt
- WatchConnectivity für iPhone ↔ Watch Kommunikation (aktueller Set-Zustand, Gewichte, Timer)
- Eigene SwiftUI Views für watchOS (kein SwiftData direkt auf Watch)
- Einschätzung: 2–3 Tage Arbeit

---

## Steps-Feature

**Status:** UX-Platzierung noch offen — User überlegt noch wo es am sinnvollsten eingebettet wird.

**Mögliche Plätze:**
- StreakBarView (vierte Zelle)
- WeekCalendarView (zusätzliche Info pro Tag)
- Eigene Mini-Card neben Cardio

**Technisch:** HealthKit `HKQuantityType(.stepCount)`, Query pro Tag, kein Schreibzugriff nötig.

---

## Weitere Ideen (noch nicht bewertet)

<!-- Hier weitere Feature-Ideen sammeln -->
