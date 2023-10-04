//
//  GetStartedView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import SwiftUI

struct GetStartedView: View {
    @AppStorage("hasCompletedSetup") var hasCompletedSetup: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.white)
                    .font(.system(size: 64.0))
                
                Text("You're all set!")
                    .foregroundStyle(.white)
                    .font(.title2.bold())
                    .padding()
            }
            
            Spacer()
            
            Button("Get Started") {
                hasCompletedSetup = true
            }
            .buttonStyle(PrimaryButton())
            .padding()
        }
    }
}

#Preview {
    ZStack {
        Rectangle().fill().ignoresSafeArea()
        GetStartedView()
    }
}
