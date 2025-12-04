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
    
    private(set) var client: SupabaseClient
    
    private init() {
        // Get values from Constants
        let supabaseURLString = Constants.supabaseURL
        let supabaseKey = Constants.supabasePublishableKey
        
        // Ensure URL has trailing slash (Supabase sometimes requires it)
        let urlString = supabaseURLString.hasSuffix("/") ? supabaseURLString : "\(supabaseURLString)/"
        
        guard let supabaseURL = URL(string: urlString) else {
            fatalError("Invalid Supabase URL: \(supabaseURLString)")
        }
        
        // Debug: Print configuration (remove in production)
        #if DEBUG
        print("🔧 Supabase Configuration:")
        print("   URL: \(supabaseURL.absoluteString)")
        print("   Key: \(supabaseKey.prefix(20))...")
        #endif
        
        // Initialize Supabase client
        // Note: The session warning is harmless and will be fixed in a future SDK version
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    /// Configure and reinitialize the Supabase client (if needed)
    func configure() {
        // Get values from Constants
        let supabaseURLString = Constants.supabaseURL
        let supabaseKey = Constants.supabasePublishableKey
        
        // Ensure URL has trailing slash
        let urlString = supabaseURLString.hasSuffix("/") ? supabaseURLString : "\(supabaseURLString)/"
        
        guard let supabaseURL = URL(string: urlString) else {
            fatalError("Invalid Supabase URL: \(supabaseURLString)")
        }
        
        // Debug: Print configuration
        #if DEBUG
        print("🔧 Supabase Reconfigured:")
        print("   URL: \(supabaseURL.absoluteString)")
        print("   Key: \(supabaseKey.prefix(20))...")
        #endif
        
        // Reinitialize Supabase client
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    /// Verify configuration (for debugging)
    func verifyConfiguration() {
        #if DEBUG
        print("📋 Supabase Service Status:")
        print("   URL: \(Constants.supabaseURL)")
        print("   Key exists: \(!Constants.supabasePublishableKey.isEmpty)")
        print("   Client initialized: Yes (non-optional)")
        #endif
    }
    
    /// Test database connection
    func testConnection() async {
        print("🧪 Testing Supabase connection...")
        print("   URL: \(Constants.supabaseURL)")
        print("   Key: \(Constants.supabasePublishableKey.prefix(20))...")
        
        do {
            // Try a simple query to test connection - Supabase returns an array
            let _: [AnyJSON] = try await client
                .from("formateurs")
                .select("id")
                .limit(1)
                .execute()
                .value
            
            print("✅ Database connection successful! Table 'formateurs' exists and is accessible.")
        } catch {
            let errorMsg = error.localizedDescription
            print("❌ Database connection failed!")
            print("   Error: \(error)")
            print("   Description: \(errorMsg)")
            
            // Check for specific errors
            if errorMsg.contains("relation") || errorMsg.contains("does not exist") || errorMsg.contains("42P01") {
                print("   ⚠️ ISSUE: Table 'formateurs' does not exist!")
                print("   📝 SOLUTION: Run the SQL script from COMPLETE_DATABASE_SETUP.md in Supabase SQL Editor")
            } else if errorMsg.contains("permission denied") || errorMsg.contains("RLS") || errorMsg.contains("row-level security") {
                print("   ⚠️ ISSUE: Row Level Security (RLS) is blocking access!")
                print("   📝 SOLUTION: Run this SQL to disable RLS for testing:")
                print("      ALTER TABLE formateurs DISABLE ROW LEVEL SECURITY;")
            } else if errorMsg.contains("network") || errorMsg.contains("connection") || errorMsg.contains("timeout") {
                print("   ⚠️ ISSUE: Network connection problem!")
                print("   📝 SOLUTION: Check internet connection and Supabase project status")
            } else {
                print("   ⚠️ ISSUE: Unknown error - check Supabase dashboard and table structure")
            }
        }
    }
}

