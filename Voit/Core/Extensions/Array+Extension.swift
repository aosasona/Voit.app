//
//  Array+Extension.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import Foundation


extension Array {
    func get(index: Int) -> Element? {
        return 0 <= index && index < count ? self[index] : nil
    }
}
