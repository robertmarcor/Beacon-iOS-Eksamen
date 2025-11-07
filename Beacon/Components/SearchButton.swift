//
//  SearchButton.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 06/11/2025.
//

import SwiftUI

struct SearchButton: View {
    @Binding var isSearchPresented: Bool
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            Text("Search for a place")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(.black.opacity(0.8))
        .clipShape(Capsule())
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .glassEffect()
        .padding(.vertical, 8)
        .onTapGesture {
            isSearchPresented = true
        }
    }
}

#Preview {
    SearchButton(isSearchPresented: .constant(false))
}
