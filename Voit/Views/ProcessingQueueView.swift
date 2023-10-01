//
//  ProcessingQueueView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct ProcessingQueueView: View {
    @State private var showQueue = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Text("Processing 2 items")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Button(action: { }) {
                        Image(systemName: "plus")
                            .padding([.all], 8)
                            .font(.title3)
                            .background(.accent.opacity(0.1))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                    .sheet(isPresented: $showQueue) {
                        Text("Sheet")
                            .presentationDetents([.fraction(0.3), .large])
                            .presentationDragIndicator(.automatic)
                    }
                }
                .padding([.horizontal], 16)
                .padding([.vertical], 15)
            }
            .background(.accent.opacity(0.02))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        }
        .onTapGesture {
            showQueue = true
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
    }
}

#Preview {
    ProcessingQueueView()
}
