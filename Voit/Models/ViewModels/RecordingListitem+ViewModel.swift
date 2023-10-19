//
//  RecordingListitem+ViewModel.swift
//  Voit
//
//  Created by Ayodeji Osasona on 13/10/2023.
//

import Foundation

final class RecordingListItemViewModel: ObservableObject {
    @Published var isEditing: Bool = false
    @Published var title: String = ""
    @Published var isFullScreen = false
}
