//
//  FilterView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedFilter: FilterOption?
    let filters: [FilterOption]
    let color: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Tous
                FilterChip(
                    title: "Tous",
                    emoji: "🔍",
                    isSelected: selectedFilter == nil,
                    color: color
                ) {
                    selectedFilter = nil
                }
                
                // Filtres disponibles
                ForEach(filters, id: \.id) { filter in
                    FilterChip(
                        title: filter.title,
                        emoji: filter.emoji,
                        isSelected: selectedFilter?.id == filter.id,
                        color: color
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct FilterChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct FilterOption: Identifiable {
    let id: String
    let title: String
    let emoji: String
    let value: Any?
    
    init(id: String, title: String, emoji: String, value: Any? = nil) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.value = value
    }
}

