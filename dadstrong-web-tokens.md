# Dad Strong — Design Tokens für dadstrong.app

Dieser File dient als Referenz für die Astro-Webseite.
Gleiche visuelle Sprache wie die iOS-App.

---

## Farben

```css
/* CSS Custom Properties */
--color-bg:           #000000;
--color-surface:      #1A1A1A;   /* Color(white: 0.1) */
--color-surface-high: #262626;   /* Color(white: 0.15) */
--color-text:         #FFFFFF;
--color-text-muted:   #808080;   /* Color(white: 0.5) */
--color-accent:       #D4FF00;   /* Gelbgrün — Kraft, Fortschritt */
--color-zone2:        #FF8C1A;   /* Orange — Zone 2 Ausdauer */
--color-sprint:       #F22626;   /* Rot — Sprint */
```

```js
// Tailwind / tokens.js
export const colors = {
  bg:          '#000000',
  surface:     '#1A1A1A',
  surfaceHigh: '#262626',
  text:        '#FFFFFF',
  muted:       '#808080',
  accent:      '#D4FF00',
  zone2:       '#FF8C1A',
  sprint:      '#F22626',
}
```

---

## Typografie

Die App nutzt SF Pro (iOS System Font). Für Web: **Inter** ist die nächste Entsprechung.
Alternativ für Headlines: **Bebas Neue** (passt zum schwarzen, rohen Look).

```css
/* Font Stack */
--font-body:    'Inter', system-ui, sans-serif;
--font-display: 'Inter', system-ui, sans-serif;  /* oder Bebas Neue für Hero */

/* Größen */
--text-label:   11px;   /* Kategorien, Caps-Labels — letter-spacing: 0.15em */
--text-body:    15px;
--text-lead:    18px;
--text-h3:      22px;
--text-h2:      28px;
--text-h1:      36px;
--text-hero:    56px;   /* Hero-Headline */

/* Gewichte */
/* Labels:      700 (bold) */
/* Body:        400 / 600 */
/* Headlines:   900 (black) */
```

---

## Spacing & Radius

```css
--space-1:   8px;
--space-2:  12px;
--space-3:  16px;
--space-4:  20px;
--space-5:  24px;
--space-6:  32px;
--space-7:  48px;

--radius-sm:  10px;   /* Inputs, Tags */
--radius-md:  12px;   /* Karten klein */
--radius-lg:  14px;   /* Karten normal */
--radius-xl:  16px;   /* Karten groß */
```

---

## UI-Muster der App (für Web adaptieren)

### Label + Headline Stack
```
KATEGORIE IN CAPS          ← 11px, bold, letter-spacing 2px, color: accent/muted
Große Überschrift          ← 28–36px, black (900), white
```

### Karte / Surface
```
background: surface (#1A1A1A)
border-radius: 14px
padding: 16–20px
```

### Primary Button
```
background: accent (#D4FF00)
color: black
font: 15px, black (900), letter-spacing: 1.5px, uppercase
border-radius: 14px
padding: 18px vertikal, full width
```

### Divider
```
background: rgba(255,255,255,0.08)
height: 1px
```

---

## Tonalität / Copy-Stil

- Kurz. Direkt. Kein Bullshit.
- Uppercase Labels für Kategorien
- Zahlen sprechen lassen ("95 kg · 8 Wdh")
- Keine Adjektiv-Inflation ("das revolutionäre…")
- Zielgruppe: Väter 30–45, beschäftigt, wollen einfach Ergebnisse sehen

### Beispiel-Headlines
```
DAD STRONG
Zwei Einheiten. Echter Fortschritt.

DEIN TRAINING. DEINE ZAHLEN.
Kniebeuge von 60 auf 100 kg — in 12 Wochen.

KONSISTENZ SCHLÄGT PERFEKTION
Kein Week-Tracker. Kein Druck.
Nur deine Progression, schwarz auf weiß.
```

---

## Astro-Projektstruktur (Empfehlung)

```
dadstrong-web/
├── src/
│   ├── styles/
│   │   └── global.css          ← CSS Custom Properties oben
│   ├── components/
│   │   ├── Hero.astro
│   │   ├── FeatureCard.astro
│   │   ├── AppScreenshot.astro
│   │   └── ShareCard.astro     ← zeigt Beispiel Share-Karte
│   └── pages/
│       └── index.astro
├── public/
│   └── screenshots/            ← App Screenshots hier ablegen
└── dadstrong-web-tokens.md     ← dieser File
```
