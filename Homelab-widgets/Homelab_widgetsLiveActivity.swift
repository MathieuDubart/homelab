// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  Homelab_widgetsLiveActivity.swift
//  Homelab-widgets
//
//  Created by Mathieu Dubart on 19/03/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Homelab_widgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Homelab_widgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Homelab_widgetsAttributes.self) { context in
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

extension Homelab_widgetsAttributes {
    fileprivate static var preview: Homelab_widgetsAttributes {
        Homelab_widgetsAttributes(name: "World")
    }
}

extension Homelab_widgetsAttributes.ContentState {
    fileprivate static var smiley: Homelab_widgetsAttributes.ContentState {
        Homelab_widgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Homelab_widgetsAttributes.ContentState {
         Homelab_widgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Homelab_widgetsAttributes.preview) {
   Homelab_widgetsLiveActivity()
} contentStates: {
    Homelab_widgetsAttributes.ContentState.smiley
    Homelab_widgetsAttributes.ContentState.starEyes
}
