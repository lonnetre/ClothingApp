//
//  AddClothesView.swift
//  ClothingApp
//
//  Created by yehor on 28.04.25.
//

import SwiftUI

struct AddClothesView: View {
    
    @Binding var presentMe : Bool    // This is how you trigger the dismissal
    
    var body: some View {
        VStack {
            
            HStack {
            
            Text("Introduction")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding([.top, .leading])
            
            Spacer ()
            
                // This should be the button to return to the main screen that NOW IT'S FINALLY working
               Button  (action: {
                   
                   // Change the value of the Binding
                   presentMe.toggle()
                   
                }, label: {
                Image(systemName: "xmark.circle")
                .foregroundColor(Color.gray)
                })
                    .padding([.top, .trailing])
            }
            
             Divider()
                .padding(.horizontal)
                .frame(height: 3.0)
                .foregroundColor(Color.gray)
        }
    }
}
