//
//  AnalyticsServise.swift
//  Tracker
//
//  Created by Alesia Matusevich on 06/06/2025.
//
import Foundation
import YandexMobileMetrica

enum Event: String {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum Screen: String {
    case main = "Main"
}

enum Item: String {
    case add_track = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

struct AnalyticsService {
    private enum ParamKeys {
        static let screen = "screen"
        static let item = "item"
    }
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "c6f6b0be-3ad9-4806-aaec-cabe0afe4d7f") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: Event, screen: Screen, item: Item? = nil) {
        var params: [String : String] = [ParamKeys.screen : screen.rawValue]
        if let item = item {
            params[ParamKeys.item] = item.rawValue
        }
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
