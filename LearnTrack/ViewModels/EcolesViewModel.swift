//
//  EcolesViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class EcolesViewModel: ObservableObject {
    @Published var ecoles: [Ecole] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    // Will be implemented in Phase 6
}

