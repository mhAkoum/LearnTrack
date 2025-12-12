//
//  SessionsListView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct SessionsListView: View {
    @StateObject private var viewModel = SessionsViewModel()
    @State private var showingAddSession = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Rechercher des sessions...")
                    .padding(.horizontal)
                
                // Filter View
                SessionFilterView(viewModel: viewModel)
                
                // Sessions List
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredSessions.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.filteredSessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session, viewModel: viewModel)) {
                                SessionRowView(session: session)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchSessions()
                    }
                }
            }
            .navigationTitle("\(AppEmojis.sessions) Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSession = true
                    }) {
                        Label("Ajouter", systemImage: "plus.circle.fill")
                            .foregroundColor(AppColors.sessions)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSession) {
                SessionFormView(viewModel: viewModel, session: nil)
            }
            .task {
                await viewModel.fetchSessions()
            }
            .onChange(of: viewModel.errorMessage) { oldValue, newValue in
                if newValue != nil && !showingError {
                    // Add small delay to prevent presentation conflicts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingError = true
                    }
                } else if newValue == nil {
                    showingError = false
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    viewModel.errorMessage = nil
                    showingError = false
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Session Row View
struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji/Icon Badge avec présentiel/distanciel
            ZStack {
                Circle()
                    .fill(statusColor(for: session.statut).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Text(statusEmoji(for: session.statut))
                        .font(.title3)
                    Text(session.presentielEmoji)
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(session.titre)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label {
                        Text(session.formattedDateDebut)
                            .font(.caption)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    
                    if let prix = session.prix {
                        Spacer()
                        HStack(spacing: 4) {
                            Text(AppEmojis.money)
                                .font(.caption2)
                            Text(String(format: "%.0f €", prix))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppColors.success)
                    }
                }
                
                // Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(for: session.statut))
                        .frame(width: 6, height: 6)
                    Text(session.statut.capitalized)
                        .font(.caption2)
                        .foregroundColor(statusColor(for: session.statut))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private func statusColor(for statut: String) -> Color {
        switch statut.lowercased() {
        case "planifié", "planifie":
            return AppColors.sessions
        case "en cours", "encours":
            return AppColors.success
        case "terminé", "termine":
            return AppColors.info
        case "annulé", "annule":
            return AppColors.error
        default:
            return AppColors.warning
        }
    }
    
    private func statusEmoji(for statut: String) -> String {
        switch statut.lowercased() {
        case "planifié", "planifie":
            return "📋"
        case "en cours", "encours":
            return "🔄"
        case "terminé", "termine":
            return "✅"
        case "annulé", "annule":
            return "❌"
        default:
            return "📅"
        }
    }
}



// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("📅")
                .font(.system(size: 80))
            
            Text("Aucune session")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.sessions)
            
            Text("Appuyez sur \(AppEmojis.add) pour créer votre première session")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    SessionsListView()
}

