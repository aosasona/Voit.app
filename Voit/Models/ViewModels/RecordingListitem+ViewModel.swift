//
//  RecordingListitem+ViewModel.swift
//  Voit
//
//  Created by Ayodeji Osasona on 13/10/2023.
//

import Foundation
import SwiftUI

final class RecordingListItemViewModel: ObservableObject {
    @Published var isEditing: Bool = false
    @Published var title: String = ""
    @Published var showFullScreen: Bool = false
    
    public func toggleFullScreen() {
        self.showFullScreen = !showFullScreen
    }
}
