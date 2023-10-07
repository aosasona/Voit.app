//
//  ProcessingQueueListView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import SwiftUI

struct ProcessingQueueListView: View {
    @Namespace private var animation
    @Binding var showQueue: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { withAnimation(.bouncy(duration: 0.5))
                        { showQueue = false }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24.0))
                        .foregroundColor(.secondary.opacity(0.75))
                }
            }
            .padding(12.0)

            ScrollView {
                Text("Oh hey")
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .matchedGeometryEffect(id: "FullQueue", in: animation)
    }
}

struct ContentView: View {
    @State var showQueueDummy = false
    var body: some View {
        ProcessingQueueListView(showQueue: $showQueueDummy)
    }
}

#Preview {
    ContentView()
}
