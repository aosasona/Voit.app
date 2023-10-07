//
//  ProcessingQueue.swift
//  Voit
//
//  Created by Ayodeji Osasona on 05/10/2023.
//

import Foundation

final class ProcessingQueue {
    private var queue: [Recording] = []
    
    public func enqueue(_ recording: Recording) {
        self.queue.append(recording)
    }
    
    public func enqueueMultiple(_ recordings: [Recording]) {
        recordings.forEach { recording in
            self.enqueue(recording)
        }
    }
    
    public func pop() {
        guard self.count() > 0 else { return }
        self.queue.remove(at: 0)
    }
    
    public func next() -> Recording? {
        return self.queue.first
    }
    
    public func isEmpty() -> Bool {
        return self.queue.isEmpty
    }
    
    public func count() -> Int {
        return self.queue.count
    }
}
