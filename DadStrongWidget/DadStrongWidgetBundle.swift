import WidgetKit
import SwiftUI

@main
struct DadStrongWidgetBundle: WidgetBundle {
    var body: some Widget {
        DadStrongWidget()
        DadStrongSmallWidget()
        DadStrongLargeWidget()
        if #available(iOS 16.2, *) {
            TrainingLiveActivityWidget()
        }
    }
}
