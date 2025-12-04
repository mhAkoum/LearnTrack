//
//  SupabaseService.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import Supabase

/// Singleton service for managing Supabase client connection
class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        guard let url = URL(string: Constants.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Constants.supabasePublishableKey
        )
    }
}

