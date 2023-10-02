//
//  ProcessingQueue.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import Foundation
import SwiftUI

final class ProcessingQueue: ObservableObject {
    private var queue: [UUID] = []
    
    public func enqueue(uuid: UUID) {
        self.queue.append(uuid)
    }
    
    public func isEmpty() -> Bool {
        return self.queue.isEmpty
    }
    
    public func count() -> Int {
        return self.queue.count
    }
}
