import SwiftUI

struct ContentView: View {
    // Estado de Sesión
    @State private var isLoggedIn: Bool = false
    @State private var usernameInput: String = ""
    @State private var keyInput: String = ""
    @State private var loginError: String = ""
    
    // Estados de la App Principal
    @State private var selectedTab: String = "AIM"
    @State private var selectedOption: String? = nil
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15)
    @State private var showColorPicker: Bool = false
    
    let availableColors: [(name: String, color: Color)] = [
        ("Amarillo", Color(red: 1.0, green: 0.85, blue: 0.15)),
        ("Celeste", Color(red: 0.20, green: 0.75, blue: 1.0)),
        ("Verde", Color(red: 0.20, green: 0.85, blue: 0.45)),
        ("Rosa", Color(red: 1.0, green: 0.35, blue: 0.60)),
        ("Morado", Color(red: 0.65, green: 0.35, blue: 1.0))
    ]
    
    var body: some View {
        ZStack {
            // Fondo oscuro unificado
            Color(red: 0.03, green: 0.03, blue: 0.04)
                .ignoresSafeArea()
            
            if !isLoggedIn {
                // MARK: - Pantalla de Login
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: "shield.lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(accentColor)
                        
                        Text("INICIAR SESIÓN")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        // Campo de Usuario (Cualquier nombre)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("USUARIO")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            TextField("Ingresa tu usuario", text: $usernameInput)
                                .padding()
                                .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                        }
                        
                        // Campo de Key / Llave
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KEY (LLAVE DE ACCESO)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            SecureField("Ingresa tu Key", text: $keyInput)
                                .padding()
                                .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !loginError.isEmpty {
                        Text(loginError)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    
                    // Botón de Entrar
                    Button(action: {
                        // Validación: Usuario cualquiera (no vacío) y Key requerida
                        if usernameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                            loginError = "Por favor ingresa un usuario."
                        } else if keyInput.isEmpty {
                            loginError = "Por favor ingresa tu Key."
                        } else {
                            loginError = ""
                            withAnimation {
                                isLoggedIn = true
                            }
                        }
                    }) {
                        Text("INGRESAR")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(accentColor)
                            .cornerRadius(27)
                            .shadow(color: accentColor.opacity(0.35), radius: 10, x: 0, y: 0)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .transition(.opacity)
            } else {
                // MARK: - App Principal (Menú)
                VStack(spacing: 20) {
                    // Barra Superior
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bienvenido,")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text(usernameInput)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showColorPicker.toggle()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(10)
                                .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Selector de Colores
                    if showColorPicker {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COLOR DE TEMA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 15) {
                                ForEach(availableColors, id: \.name) { item in
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: accentColor == item.color ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                accentColor = item.color
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Selector AIM / VISUAL
                    HStack(spacing: 0) {
                        TabButton(title: "AIM", isSelected: selectedTab == "AIM", accentColor: accentColor) {
                            selectedTab = "AIM"
                        }
                        TabButton(title: "VISUAL", isSelected: selectedTab == "VISUAL", accentColor: accentColor) {
                            selectedTab = "VISUAL"
                        }
                    }
                    .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Lista de Tarjetas
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == "AIM" {
                                OptionCard(title: "AIM CABEZA", iconName: "target", isSelected: selectedOption == "CABEZA", accentColor: accentColor) { selectedOption = "CABEZA" }
                                OptionCard(title: "AIM CUELLO", iconName: "person.fill", isSelected: selectedOption == "CUELLO", accentColor: accentColor) { selectedOption = "CUELLO" }
                                OptionCard(title: "AIM PECHO", iconName: "scope", isSelected: selectedOption == "PECHO", accentColor: accentColor) { selectedOption = "PECHO" }
                                OptionCard(title: "AIM DRAG", iconName: "hand.tap.fill", isSelected: selectedOption == "DRAG", accentColor: accentColor) { selectedOption = "DRAG" }
                            } else {
                                Text("Opciones Visuales")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    // Botón Accionar
                    Button(action: {
                        // Acción al presionar
                    }) {
                        Text("ACCIONAR")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(accentColor)
                            .cornerRadius(28)
                            .shadow(color: accentColor.opacity(0.35), radius: 12, x: 0, y: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                }
                .transition(.opacity)
            }
        }
    }
}

// Subvista para las pestañas
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isSelected ? accentColor : Color.clear)
                .cornerRadius(14)
                .padding(4)
        }
    }
}

// Subvista para las tarjetas
struct OptionCard: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.18, green: 0.08, blue: 0.12))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.45))
                }
                .padding(.leading, 12)
                
                Text(title)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color(red: 0.09, green: 0.09, blue: 0.11))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}
