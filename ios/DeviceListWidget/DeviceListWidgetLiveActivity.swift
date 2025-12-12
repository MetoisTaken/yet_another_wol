//
//  DeviceListWidgetLiveActivity.swift
//  DeviceListWidget
//
//  Created by Metehan on 12.12.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DeviceListWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DeviceListWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeviceListWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DeviceListWidgetAttributes {
    fileprivate static var preview: DeviceListWidgetAttributes {
        DeviceListWidgetAttributes(name: "World")
    }
}

extension DeviceListWidgetAttributes.ContentState {
    fileprivate static var smiley: DeviceListWidgetAttributes.ContentState {
        DeviceListWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DeviceListWidgetAttributes.ContentState {
         DeviceListWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DeviceListWidgetAttributes.preview) {
   DeviceListWidgetLiveActivity()
} contentStates: {
    DeviceListWidgetAttributes.ContentState.smiley
    DeviceListWidgetAttributes.ContentState.starEyes
}
