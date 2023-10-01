//
//  Home.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query var recordings: [Recording]
    var body: some View {
        NavigationStack {
            List(recordings) { _ in
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .navigationTitle("All recordings")
        }
    }
}

#Preview {
    HomeView()
}
