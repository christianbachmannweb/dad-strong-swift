import WidgetKit
import SwiftUI

// MARK: - Shared constants

private let widgetAccent = Color(red: 0.831, green: 1.0, blue: 0.0)
private let widgetZone2  = Color(red: 1.0, green: 0.55, blue: 0.1)
private let widgetSprint = Color(red: 0.95, green: 0.15, blue: 0.15)
private let groupID = "group.com.christianbachmann.dadStrong"
private let sessionsKey = "widgetSessions"
private let streakKey   = "widgetStreaks"

struct WidgetSession: Codable {
    let date: Date
    let type: String
}

struct WidgetStreaks: Codable {
    let strength: Int
    let zone2: Int
    let sprint: Int
}

// MARK: - Timeline

struct WidgetEntry: TimelineEntry {
    let date: Date
    let sessions: [WidgetSession]
    let streaks: WidgetStreaks
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), sessions: [], streaks: WidgetStreaks(strength: 0, zone2: 0, sprint: 0))
    }
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry(date: Date(), sessions: loadSessions(), streaks: loadStreaks()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = WidgetEntry(date: Date(), sessions: loadSessions(), streaks: loadStreaks())
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
    private func loadSessions() -> [WidgetSession] {
        guard let defaults = UserDefaults(suiteName: groupID),
              let data = defaults.data(forKey: sessionsKey),
              let sessions = try? JSONDecoder().decode([WidgetSession].self, from: data)
        else { return [] }
        return sessions
    }
    private func loadStreaks() -> WidgetStreaks {
        guard let defaults = UserDefaults(suiteName: groupID),
              let data = defaults.data(forKey: streakKey),
              let streaks = try? JSONDecoder().decode(WidgetStreaks.self, from: data)
        else { return WidgetStreaks(strength: 0, zone2: 0, sprint: 0) }
        return streaks
    }
}

// MARK: - Large Widget (Ladder-style: photo left, calendar right)

struct LargeWidgetView: View {
    let entry: WidgetEntry
    private let cal = Calendar.current

    private var today: Date { cal.startOfDay(for: Date()) }

    private var monthDays: [Date?] {
        let comps = cal.dateComponents([.year, .month], from: today)
        let first = cal.date(from: comps)!
        let offset = (cal.component(.weekday, from: first) + 5) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        let range = cal.range(of: .day, in: .month, for: first)!
        for d in range { days.append(cal.date(byAdding: .day, value: d - 1, to: first)) }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private func session(on date: Date) -> WidgetSession? {
        entry.sessions.first { cal.isDate($0.date, inSameDayAs: date) }
    }

    private func primarySession(on date: Date) -> WidgetSession? {
        // Prefer workout (A/B) over zone2/sprint for the primary circle
        let all = entry.sessions.filter { cal.isDate($0.date, inSameDayAs: date) }
        return all.first(where: { $0.type == "A" || $0.type == "B" }) ?? all.first
    }

    private var monthName: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "de_DE")
        fmt.dateFormat = "MMMM"
        return fmt.string(from: today)
    }

    private var nextType: String {
        entry.sessions.sorted { $0.date > $1.date }.first?.type == "B" ? "A" : "B"
    }

    private var photo: UIImage? {
        // User-gewähltes Foto aus App Group hat Vorrang
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent("widget-photo.jpg"),
           let img = UIImage(contentsOfFile: url.path) {
            return img
        }
        // Fallback: statisches Bundle-Asset
        if let url = Bundle.main.url(forResource: "app-widget-bild", withExtension: "png") {
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(named: "app-widget-bild")
    }

    var body: some View {
        HStack(spacing: 0) {

            // MARK: Left — Photo + overlay
            ZStack(alignment: .bottomLeading) {
                if let img = photo {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    Color(white: 0.1).frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                VStack(alignment: .leading, spacing: 1) {
                    Text("Nächstes Training")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(white: 0.7))
                    Text("DAD\nSTRONG")
                        .font(.system(size: 16, weight: .black))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .lineSpacing(-2)
                }
                .padding(.leading, 14)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)

            // MARK: Right — Calendar
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(monthName)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("💪\(entry.streaks.strength)")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(widgetAccent)
                    Text("🚴\(entry.streaks.zone2)")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(widgetZone2)
                    Text("🔥\(entry.streaks.sprint)")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(widgetSprint)
                }
                .padding(.bottom, 8)

                // Day headers
                HStack(spacing: 0) {
                    ForEach(["M","T","W","T","F","S","S"], id: \.self) { d in
                        Text(d)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Color(white: 0.6))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 16)

                // Day grid — fixed row height so all 5-6 weeks fit evenly
                let weeks = stride(from: 0, to: monthDays.count, by: 7).map {
                    Array(monthDays[$0..<min($0 + 7, monthDays.count)])
                }
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { i in
                            Group {
                                if let day = week[i] {
                                    let s = primarySession(on: day)
                                    let isToday = cal.isDateInToday(day)
                                    let dayNum = cal.component(.day, from: day)
                                    dayCircle(session: s, isToday: isToday, day: dayNum, size: 22)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.black)
        }
        .background(Color.black)
        .padding(-20)
    }
}

// MARK: - Shared day circle helper

private func dayCircle(session: WidgetSession?, isToday: Bool, day: Int, size: CGFloat) -> some View {
    let fillColor: Color = {
        guard let s = session else { return isToday ? Color(white: 0.12) : .clear }
        switch s.type {
        case "zone2":  return widgetZone2
        case "sprint": return widgetSprint
        default:       return widgetAccent
        }
    }()
    let iconColor: Color = session?.type == "zone2" ? .black : .black
    return ZStack {
        Circle().fill(fillColor).frame(width: size, height: size)
        if let s = session {
            switch s.type {
            case "zone2":
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: size * 0.38, weight: .black))
                    .foregroundStyle(iconColor)
            case "sprint":
                Image(systemName: "bolt.fill")
                    .font(.system(size: size * 0.38, weight: .black))
                    .foregroundStyle(.white)
            default:
                Text(s.type)
                    .font(.system(size: size * 0.38, weight: .black))
                    .foregroundStyle(.black)
            }
        } else {
            Text("\(day)")
                .font(.system(size: size * 0.36, weight: isToday ? .bold : .regular))
                .foregroundStyle(isToday ? .white : Color(white: 0.45))
        }
    }
}

// MARK: - Medium Widget (week calendar)

struct MediumWidgetView: View {
    let entry: WidgetEntry
    private let calendar = Calendar.current
    private let dayLabels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    private var weekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let daysFromMonday = (calendar.component(.weekday, from: today) + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private func sessions(on date: Date) -> [WidgetSession] {
        entry.sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .cornerRadius(5)
                Spacer()
                Text("💪 \(entry.streaks.strength)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(widgetAccent)
                Text("🚴 \(entry.streaks.zone2)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(widgetZone2)
                Text("🔥 \(entry.streaks.sprint)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(widgetSprint)
            }
            .frame(width: 52)

            Spacer()

            HStack(spacing: 4) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { idx, day in
                    let daySessions = sessions(on: day)
                    let primary = daySessions.first
                    let isToday = calendar.isDateInToday(day)
                    let dayNum = calendar.component(.day, from: day)
                    VStack(spacing: 5) {
                        Text(dayLabels[idx])
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(isToday ? .white : Color(white: 0.5))
                        dayCircle(session: primary, isToday: isToday, day: dayNum, size: 30)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.black)
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: WidgetEntry
    private var lastType: String? { entry.sessions.sorted { $0.date > $1.date }.first?.type }
    private var nextType: String { lastType == "B" ? "A" : "B" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("AppIcon")
                .resizable()
                .frame(width: 24, height: 24)
                .cornerRadius(5)
            Spacer()
            Text("NÄCHSTES")
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Color(white: 0.5))
            Text("Training \(nextType)")
                .font(.system(size: 20, weight: .black))
                .tracking(0.5)
                .foregroundStyle(widgetAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black)
    }
}

// MARK: - Widget definitions

struct DadStrongWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DadStrongWidget", provider: Provider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("Dad Strong – Woche")
        .description("Deine Trainingswoche auf einen Blick.")
        .supportedFamilies([.systemMedium])
    }
}

struct DadStrongSmallWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DadStrongSmallWidget", provider: Provider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("Dad Strong – Nächstes")
        .description("Zeigt dein nächstes Training.")
        .supportedFamilies([.systemSmall])
    }
}

struct DadStrongLargeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DadStrongLargeWidget", provider: Provider()) { entry in
            LargeWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color.black }
        }
        .configurationDisplayName("Dad Strong – Monatskalender")
        .description("Vollständiger Monatskalender mit deinen Trainingstagen.")
        .supportedFamilies([.systemMedium])
    }
}
