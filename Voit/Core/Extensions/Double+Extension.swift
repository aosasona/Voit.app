//
//  Double+Extension.swift
//  Voit
//
//  Created by Ayodeji Osasona on 13/10/2023.
//

import Foundation

enum DoubleFormat {
    /// converts seconds into a human-readable format like `1 hr 20 min`
    case humanReadableDuration
}

extension Double {
    func format(_ target: DoubleFormat) -> String? {
        return switch target {
        case .humanReadableDuration: formatAsHumanReadableDuration(self)
        }
    }
    
}


private func formatAsHumanReadableDuration(_ seconds: Double) -> String? {
    guard seconds > 0 else { return nil }
    
    var formattedDuration = ""
    let hours = Int(seconds / 3600)
    let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(seconds.truncatingRemainder(dividingBy: 60))
    
    if hours > 0 { formattedDuration += "\(hours)h " }
    if minutes > 0 { formattedDuration += "\(minutes)m " }
    
    // only show seconds if it is less than a minute
    if minutes < 1 {
        if seconds > 0 { formattedDuration += "\(seconds)s" }
    }
    
    
    if formattedDuration.isEmpty { formattedDuration = "0m" }
    
    return formattedDuration.trimmingCharacters(in: .whitespaces)
}
