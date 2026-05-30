//
//  SidebarSection.swift
//  NurseryConnect-TabOS
//
//  The three top-level destinations of the iPad NavigationSplitView sidebar.
//  Replaces the A1 iPhone TabView — this is the structural backbone of the
//  platform-specific feature (criterion 3).
//

import Foundation

enum SidebarSection: String, CaseIterable, Identifiable {
    case children
    case insights
    case incidents

    var id: String { rawValue }

    var title: String {
        switch self {
        case .children:  return "Children"
        case .insights:  return "Insights"
        case .incidents: return "Incidents"
        }
    }

    var icon: String {
        switch self {
        case .children:  return AppIcons.children
        case .insights:  return AppIcons.insights
        case .incidents: return AppIcons.incidents
        }
    }

    var subtitle: String {
        switch self {
        case .children:  return "Roster, diary & day view"
        case .insights:  return "Development & wellbeing trends"
        case .incidents: return "Reports & audit trail"
        }
    }
}
