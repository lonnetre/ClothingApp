//
//  TagSelectorView.swift
//  ClothingApp
//
//  Created by yehor on 19.06.25.
//

import SwiftUI

struct TagSelectorSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedIcon: String
    @Binding var customLabel: String

    let availableIcons = ["hat.cap.fill", "tshirt.fill", "pants", "shoe.fill"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Select Item Type")
                .font(.headline)
                .padding(.top, 10)

            HStack(spacing: 20) {
                ForEach(availableIcons, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                    }) {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding()
                            .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)

            Divider()

            VStack(alignment: .leading) {
                Text("Describe this item:")
                    .font(.subheadline)
                    .padding(.horizontal)

                TextField("e.g. Sport Shoes", text: $customLabel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            Spacer()

            Button("Confirm") {
                isPresented = false
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(24)
        .background(Color(.systemBackground))
    }
}
