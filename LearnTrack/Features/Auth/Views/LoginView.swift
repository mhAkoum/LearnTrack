
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var signUpNom = ""
    @State private var signUpPrenom = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, nom, prenom
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        LogoView(size: 120)
                            .padding(.top, 40)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 16) {
                            if showingSignUp {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("First Name")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Enter your first name", text: $signUpPrenom)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($focusedField, equals: .prenom)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .nom
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Last Name")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Enter your last name", text: $signUpNom)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($focusedField, equals: .nom)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .email
                                        }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .textContentType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .password
                                    }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        if showingSignUp {
                                            handleSignUp()
                                        } else {
                                            handleLogin()
                                        }
                                    }
                            }
                            
                            if let errorMessage = viewModel.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                            }
                            
                            Button(action: showingSignUp ? handleSignUp : handleLogin) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text(showingSignUp ? "Sign Up" : "Sign In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(viewModel.isLoading ? Color.gray : Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty || (showingSignUp && (signUpNom.isEmpty || signUpPrenom.isEmpty)))
                            
                            Button(action: {
                                showingSignUp.toggle()
                                viewModel.clearError()
                            }) {
                                Text(showingSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handleLogin() {
        focusedField = nil
        Task {
            await viewModel.login(email: email, password: password)
        }
    }
    
    private func handleSignUp() {
        focusedField = nil
        Task {
            await viewModel.signUp(email: email, password: password, nom: signUpNom, prenom: signUpPrenom)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

