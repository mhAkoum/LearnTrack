//
//  SessionFilterView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct SessionFilterView: View {
    @ObservedObject var viewModel: SessionsViewModel
    @State private var selectedStatusFilter: String? = nil
    @State private var selectedModeFilter: String? = nil
    
    var body: some View {
        VStack(spacing: 8) {
            // Filtres par statut
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Tous
                    FilterChip(
                        title: "Tous",
                        emoji: "🔍",
                        isSelected: viewModel.selectedFilter == nil && selectedStatusFilter == nil && selectedModeFilter == nil,
                        color: AppColors.sessions
                    ) {
                        viewModel.selectedFilter = nil
                        selectedStatusFilter = nil
                        selectedModeFilter = nil
                    }
                    
                    // Filtres par statut
                    FilterChip(
                        title: "Planifié",
                        emoji: "📋",
                        isSelected: selectedStatusFilter == "planifié",
                        color: AppColors.sessions
                    ) {
                        if selectedStatusFilter == "planifié" {
                            selectedStatusFilter = nil
                        } else {
                            selectedStatusFilter = "planifié"
                        }
                    }
                    
                    FilterChip(
                        title: "En cours",
                        emoji: "🔄",
                        isSelected: selectedStatusFilter == "en cours",
                        color: AppColors.sessions
                    ) {
                        if selectedStatusFilter == "en cours" {
                            selectedStatusFilter = nil
                        } else {
                            selectedStatusFilter = "en cours"
                        }
                    }
                    
                    FilterChip(
                        title: "Terminé",
                        emoji: "✅",
                        isSelected: selectedStatusFilter == "terminé",
                        color: AppColors.sessions
                    ) {
                        if selectedStatusFilter == "terminé" {
                            selectedStatusFilter = nil
                        } else {
                            selectedStatusFilter = "terminé"
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Filtres par mode (présentiel/distanciel)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "Présentiel",
                        emoji: "🏢",
                        isSelected: selectedModeFilter == "Présentiel",
                        color: AppColors.sessions
                    ) {
                        if selectedModeFilter == "Présentiel" {
                            selectedModeFilter = nil
                        } else {
                            selectedModeFilter = "Présentiel"
                        }
                    }
                    
                    FilterChip(
                        title: "Distanciel",
                        emoji: "💻",
                        isSelected: selectedModeFilter == "Distanciel",
                        color: AppColors.sessions
                    ) {
                        if selectedModeFilter == "Distanciel" {
                            selectedModeFilter = nil
                        } else {
                            selectedModeFilter = "Distanciel"
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .onChange(of: selectedStatusFilter) { oldValue, newValue in
            viewModel.selectedStatusFilter = newValue
        }
        .onChange(of: selectedModeFilter) { oldValue, newValue in
            viewModel.selectedModeFilter = newValue
        }
    }
}

