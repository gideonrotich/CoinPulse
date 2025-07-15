//
//  SortButton.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct SortButton: View {
    let label: String
    let key:   SortKey
    @ObservedObject var model: SortingModel
    
    private var isActive:  Bool { model.descriptor.key == key }
    private var ascending: Bool { model.descriptor.ascending }
    
    private var bgColour: Color {
        guard isActive else { return Color(.systemGray6) }
        return ascending ? .red : .green
    }
    
    var body: some View {
        Button { model.pick(key) } label: {
            HStack(spacing: 4) {
                Text(label)
                if isActive {
                    Image(systemName: ascending ? "arrow.up" : "arrow.down")
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isActive ? .white : .primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(bgColour, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
