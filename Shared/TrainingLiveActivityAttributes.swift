import ActivityKit

@available(iOS 16.2, *)
struct TrainingLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var heartRate: Int?
    }
    let trainingName: String  // "Zone 2" | "Sprint" | "Training A" | "Training B"
    let accentColor: String   // "accent" | "zone2" | "sprint"
}
