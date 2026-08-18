import SwiftUI
import UIKit

// MARK: - Modelo de Key
struct KeyItem: Identifiable {
    let id = UUID()
    let code: String
    let durationDays: Int
    let expirationDate: Date
}

struct ContentView: View {
    // Estado de Sesión
    @State private var isLoggedIn: Bool = false
    @State private var usernameInput: String = ""
    @State private var keyInput: String = ""
    @State private var loginError: String = ""
    
    // Estados de la App Principal
    @State private var selectedTab: String = "AIM" // "AIM", "VISUAL", "KEYS"
    @State private var selectedOption: String? = nil
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15)
    @State private var showColorPicker: Bool = false
    
    // Estados del Gestor de Keys
    @State private var generatedKeys: [KeyItem] = []
    @State private var customDaysInput: String = ""
    @State private var keyNotificationMessage: String = ""
    
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
                        // Campo de Usuario
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
                VStack(spacing: 18) {
                    
                    // MARK: - Header de Bienvenida
                    HStack(spacing: 14) {
                        // Avatar Circular con Inicial del Usuario
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(accentColor.opacity(0.2))
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Circle()
                                        .stroke(accentColor, lineWidth: 1.5)
                                )
                            
                            Text(String(usernameInput.prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(accentColor)
                            
                            // Punto de estado "En línea"
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        }
                        
                        // Información del Usuario
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("BIENVENIDO")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(.gray)
                                    .tracking(1)
                                
                                Text("• VIP")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(accentColor)
                            }
                            
                            Text(usernameInput)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Botón Tuerca Ajustes
                        Button(action: {
                            withAnimation {
                                showColorPicker.toggle()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                    .cornerRadius(20)
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
                    
                    // Selector AIM / VISUAL / KEYS
                    HStack(spacing: 0) {
                        TabButton(title: "AIM", isSelected: selectedTab == "AIM", accentColor: accentColor) {
                            selectedTab = "AIM"
                        }
                        TabButton(title: "VISUAL", isSelected: selectedTab == "VISUAL", accentColor: accentColor) {
                            selectedTab = "VISUAL"
                        }
                        TabButton(title: "KEYS", isSelected: selectedTab == "KEYS", accentColor: accentColor) {
                            selectedTab = "KEYS"
                        }
                    }
                    .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Contenido Dinámico según la Pestaña
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == "AIM" {
                                OptionCard(title: "AIM CABEZA", iconName: "target", isSelected: selectedOption == "CABEZA", accentColor: accentColor) { selectedOption = "CABEZA" }
                                OptionCard(title: "AIM CUELLO", iconName: "person.fill", isSelected: selectedOption == "CUELLO", accentColor: accentColor) { selectedOption = "CUELLO" }
                                OptionCard(title: "AIM PECHO", iconName: "scope", isSelected: selectedOption == "PECHO", accentColor: accentColor) { selectedOption = "PECHO" }
                                OptionCard(title: "AIM DRAG", iconName: "hand.tap.fill", isSelected: selectedOption == "DRAG", accentColor: accentColor) { selectedOption = "DRAG" }
                            } else if selectedTab == "VISUAL" {
                                Text("Opciones Visuales")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else if selectedTab == "KEYS" {
                                // MARK: - Administrador de Keys
                                VStack(alignment: .leading, spacing: 20) {
                                    
                                    // Bloque: Generar Key
                                    VStack(alignment: .leading, spacing: 14) {
                                        Text("GENERAR NUEVA KEY")
                                            .font(.system(size: 13, weight: .heavy))
                                            .foregroundColor(.gray)
                                        
                                        // Accesos Rápidos (1, 5, 7, 30 días)
                                        HStack(spacing: 10) {
                                            QuickDaysButton(days: 1, accentColor: accentColor) { createKey(days: 1) }
                                            QuickDaysButton(days: 5, accentColor: accentColor) { createKey(days: 5) }
                                            QuickDaysButton(days: 7, accentColor: accentColor) { createKey(days: 7) }
                                            QuickDaysButton(days: 30, accentColor: accentColor) { createKey(days: 30) }
                                        }
                                        
                                        // Entrada Personalizada
                                        HStack(spacing: 10) {
                                            TextField("Días personalizados", text: $customDaysInput)
                                                .keyboardType(.numberPad)
                                                .padding(.horizontal, 14)
                                                .frame(height: 44)
                                                .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                                .cornerRadius(12)
                                                .foregroundColor(.white)
                                            
                                            Button(action: {
                                                if let days = Int(customDaysInput), days > 0 {
                                                    createKey(days: days)
                                                    customDaysInput = ""
                                                }
                                            }) {
                                                Text("GENERAR")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(.black)
                                                    .frame(height: 44)
                                                    .padding(.horizontal, 16)
                                                    .background(accentColor)
                                                    .cornerRadius(12)
                                            }
                                        }
                                        
                                        if !keyNotificationMessage.isEmpty {
                                            Text(keyNotificationMessage)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(Color.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                                    .cornerRadius(18)
                                    
                                    // Bloque: Keys Activas
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("KEYS ACTIVAS")
                                                .font(.system(size: 13, weight: .heavy))
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("\(generatedKeys.count) Totales")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(accentColor)
                                        }
                                        
                                        if generatedKeys.isEmpty {
                                            Text("No hay keys generadas aún.")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                                .padding(.vertical, 10)
                                        } else {
                                            ForEach(generatedKeys) { item in
                                                KeyRowView(keyItem: item, accentColor: accentColor, onRevoke: {
                                                    revokeKey(id: item.id)
                                                })
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                                    .cornerRadius(18)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    // MARK: - Botón Principal INYECTAR
                    if selectedTab != "KEYS" {
                        Button(action: {
                            // Acción de inyección
                        }) {
                            Text("INYECTAR")
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
                }
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Lógica de Keys
    private func createKey(days: Int) {
        let newCode = "KEY-" + String((0..<8).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        let expiration = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let newKey = KeyItem(code: newCode, durationDays: days, expirationDate: expiration)
        
        withAnimation {
            generatedKeys.insert(newKey, at: 0)
            keyNotificationMessage = "¡Key creada y copiada!"
        }
        
        UIPasteboard.general.string = newCode
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            keyNotificationMessage = ""
        }
    }
    
    private func revokeKey(id: UUID) {
        withAnimation {
            generatedKeys.removeAll { $0.id == id }
        }
    }
}

// MARK: - Botón Rápido de Días
struct QuickDaysButton: View {
    let days: Int
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(days)D")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color(red: 0.14, green: 0.14, blue: 0.17))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColor.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Fila de Key Activa
struct KeyRowView: View {
    let keyItem: KeyItem
    let accentColor: Color
    let onRevoke: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(keyItem.code)
                    .font(.custom("Menlo", size: 14))
                    .foregroundColor(accentColor)
                
                HStack(spacing: 8) {
                    Text("\(keyItem.durationDays) Días")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text("• Expira: \(formattedDate(keyItem.expirationDate))")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Botón Copiar
            Button(action: {
                UIPasteboard.general.string = keyItem.code
            }) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.20))
                    .clipShape(Circle())
            }
            
            // Botón Revocar / Eliminar
            Button(action: onRevoke) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(Color(red: 0.11, green: 0.11, blue: 0.14))
        .cornerRadius(12)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

// MARK: - Subvistas Auxiliares
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? accentColor : Color.clear)
                .cornerRadius(12)
                .padding(4)
        }
    }
}

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
