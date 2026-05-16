# Dad Strong — Status

**Letzte Session:** 2026-05-16

---

## Heute erledigt

- **Trainings nachträglich hinzufügen** — `AddWorkoutSheet` + „+" Button in `WorkoutHistoryEditView`: Typ (A/B) + Datum wählen, Übungen durchgehen, Sätze eintragen, speichern
- **Bug: BSS bilateral Pause** — 60s Pflichtpause zwischen Beinen erzwungen; `BilateralRestEntryView` mit `guard !submitted` gegen Doppel-Submit wenn `cancel()` `remaining=0` setzt
- **Debug-Panel** `#if DEBUG` — `DebugJumpSheet` in `GeneralWarmupView`, springt direkt zu jeder Phase/Übung
- **Bug: Keyboard blockiert Bestätigen** — `ToolbarItemGroup(placement: .keyboard)` in `SetRestView`; kein separater Button mehr
- **Auto-Advance BilateralRestEntryView** — Timer=0 löst `submit()` aus (mit guard gegen Doppelfire)
- **Timer-Zentrierung** — nach Bestätigung in `SetRestView` zentriert sich Timer vertikal
- **Bug: Status-Bar-Timer springt** — `TimelineView(.periodic)` statt `Timer.publish` in `WorkoutStatusBar`
- **Farmer Walk beidhändig** — `isBilateral: false`, Flow wie alle anderen Übungen (Pause + Gewicht eintragen)
- **Share Card 9:16** — `ShareCardView` vollflächig 360×640pt, `ImageRenderer` mit `proposedSize` → 1080×1920px für Instagram Stories

---

## Nächste Schritte

1. **Onboarding (2–3 Screens)** — beim ersten App-Start, nie wieder danach
   - Screen 1: Was ist Dad Strong (Headline + kurzer Text)
   - Screen 2: Wie funktioniert A/B + lineare Progression
   - Screen 3: Widget einrichten + Einstellungen-Hinweis
   - Flag: `UserDefaults.standard.bool(forKey: "hasSeenOnboarding")`
2. **App Store App-ID** — Platzhalter `id0000000000` in `SettingsView` ersetzen
3. **Screenshots** — 6.5" (iPhone 14/15 Pro Max) + 5.5" (iPhone 8 Plus)

---

## App Store Checkliste

- [x] Privacy Manifest (`PrivacyInfo.xcprivacy`)
- [x] Privacy Policy — https://dadstrong.app
- [x] Bundle ID `com.christianbachmann.dadStrong`
- [x] Share-Karte (9:16 Stories-Format)
- [x] HealthKit auf HKWorkoutBuilder migriert
- [x] Widget-Foto vom User wählbar
- [x] Zone 2 Pulszonen editierbar + Karvonen-Empfehlung
- [x] Dynamic Island / Live Activity
- [x] 12-Wochen-Challenge Card
- [x] BottomPillBar Navigation
- [x] Sprint-Training (Ring-Timer, Auto-Flow, HR-Anzeige)
- [x] Trainings nachträglich hinzufügen/editieren
- [ ] Onboarding ← nächster Schritt
- [ ] App Store App-ID eintragen
- [ ] Screenshots

---

## Technische Hinweise

- SourceKit zeigt false-positive Fehler nach Datei-Änderungen — verschwindet nach Build
- `app-widget-bild.png` im Widget-Bundle ist Fallback solange User kein Foto gesetzt hat
- Steps-Feature: UX-Platzierung noch offen
