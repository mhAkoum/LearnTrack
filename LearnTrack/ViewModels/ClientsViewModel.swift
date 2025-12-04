//
//  ClientsViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    // Will be implemented in Phase 5
}

