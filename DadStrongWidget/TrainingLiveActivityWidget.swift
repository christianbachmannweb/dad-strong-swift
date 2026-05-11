import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
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

@available(iOS 16.2, *)
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
