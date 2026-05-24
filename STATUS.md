# Dad Strong — Status

**Letzte Session:** 2026-05-23

---

## Heute erledigt

- **Bug: Körper-Check-In erscheint beim ersten App-Start** — `isCheckInDue` gibt `false` wenn kein Check-In vorhanden (statt `true`); Check-In nur über Einstellungen oder Sonntags-Trigger
- **Körper-Check-In schließbar** — X-Button oben rechts (Orange-Rot), Bestätigungs-Dialog "Eintrag verwerfen?"
- **Körper-Check-In UX** — Gewicht/Hüfte als Zahlenfeld (TextField, `.decimalPad`) statt Stepper; "SPEICHERN" Button zentriert und vollflächig tappbar
- **Challenge: A+B Bedingung** — Challenge startet erst wenn beide Trainingstypen je einmal absolviert; Hinweis-Text wenn Bedingung nicht erfüllt
- **Hint "Krank eintragen"** — Text unter Challenge-Legende: "Leere Tage antippen → als Krank markieren"
- **Trainings bearbeiten: Swipe to Delete** — `List` mit `.swipeActions` statt `ScrollView`; `modelContext.delete(session)` per Wisch
- **AddWorkoutSheet UX** — Gewicht als TextField (`.decimalPad`), korrektes Padding, vollflächige Buttons mit `.contentShape(Rectangle())`
- **PrimaryButton vollflächig** — `.contentShape(Rectangle())` im Button-Label
- **Farmer's Walk: Zeit-Übergabe** — `pendingTimedSeconds` auf `WorkoutSessionState`; -1 Sek. Kompensation (`max(elapsed - 1, 1)`); letzter Satz geht nicht direkt zu `complete`, immer über `resting` → `SetRestView`
- **Effort-Symbole konsistent** — überall `level.rawValue` statt Custom-Funktion (`-` / `*` / `**`)
- **OK-Button in Pausen-Screens** — `ToolbarItem` rechts oben in `SetRestView` und `BilateralRestEntryView`
- **Instagram Stories Teilen** — "STORY TEILEN" Button in `SummaryView`; `UIPasteboard` + `instagram-stories://` URL-Scheme; `LSApplicationQueriesSchemes` in Info.plist
- **TestFlight-Link in Einstellungen** — `https://testflight.apple.com/join/7MQz3GNG`
- **Pre-Workout Prep-Screen** — `TrainingPrepView` zeigt Übungsübersicht + Warm-Up-Info; öffnet sich als `.sheet(item:)` bei Tap auf Training A/B; `TrainingType: Identifiable`
- **Onboarding** — 3 Screens (Willkommen / Training A&B / Fortschritt), `TabView(.page)`, animierte Punkte, einmalig beim ersten Start; `RootView` in `DadStrongApp.swift`

---

## Nächste Schritte

1. **Englische Lokalisierung** ← höchste Priorität vor Launch (US-Tester kämpft sich durch deutsche App)
   - `Text("...")` → `String(localized:)`
   - `Localizable.strings` für "de" und "en"
   - Info.plist Privacy-Texte übersetzen
   - iOS wählt Sprache automatisch, kein In-App-Picker nötig
2. **Dynamic Island & Lock Screen** — kompakte DI-Ansicht prominenter (wie Ladder App); Lock Screen zeigt Puls groß bei Zone 2 / Sprint (LiveActivityManager bereits vorhanden, UI-Verbesserung nötig)
3. **Progress Bar im Training** — Balken zeigt wieviel % des Trainings abgeschlossen (wie Ladder App)
3. **App Store App-ID** — Platzhalter in `SettingsView` ersetzen wenn live
4. **Screenshots** — 6.5" (iPhone 14/15 Pro Max) + 5.5" (iPhone 8 Plus)

---

## Geplant (nach Launch / v1.1)

- **Audio-Coaching** — Christians Stimme in Pausen, exercise-spezifisch, via PocketBase (`weekly_audio` Collection); Konzept noch in Planung
- **Looping-Video Hintergrund** — Christian nimmt selbst auf
- **Geführtes Warm-Up mit Video** + Toggle im Prep-Screen

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
- [x] Trainings nachträglich hinzufügen/editieren/löschen
- [x] Onboarding
- [x] TestFlight-Link in Einstellungen
- [ ] Englische Lokalisierung ← nächster Schritt
- [ ] App Store App-ID eintragen
- [ ] Screenshots

---

## Technische Hinweise

- SourceKit zeigt false-positive Fehler nach Datei-Änderungen — verschwindet nach Build
- `app-widget-bild.png` im Widget-Bundle ist Fallback solange User kein Foto gesetzt hat
- xcodegen nach neuen Dateien immer ausführen: `xcodegen generate`
