import SwiftUI
import UIKit

// MARK: - Modelo de Key Persistente
struct KeyItem: Identifiable, Codable {
    var id = UUID()
    let code: String
    let durationDays: Int
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
}

struct ContentView: View {
    // Credenciales de Administrador
    private let adminUsername: String = "darielzx"
    private let adminPassword: String = "didierdariel2013"
    
    // Estado de Sesión
    @State private var isLoggedIn: Bool = false
    @State private var usernameInput: String = ""
    @State private var keyInput: String = ""
    @State private var loginError: String = ""
    @State private var isAdmin: Bool = false
    
    // Estados de la App Principal
    @State private var selectedTab: String = "AIM" // "AIM", "VISUAL", "KEYS"
    @State private var selectedOption: String? = "PECHO"
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15) // Amarillo Neón
    @State private var showColorPicker: Bool = false
    
    // Estados del Gestor de Keys
    @State private var generatedKeys: [KeyItem] = []
    @State private var customDaysInput: String = ""
    @State private var keyNotificationMessage: String = ""
    
    let availableColors: [(name: String, color: Color)] = [
        ("Amarillo", Color(red: 1.0, green: 0.85, blue: 0.15)),
        ("Celeste", Color(red: 0.20, green: 0.80, blue: 1.0)),
        ("Verde", Color(red: 0.20, green: 0.90, blue: 0.45)),
        ("Rosa", Color(red: 1.0, green: 0.35, blue: 0.65)),
        ("Morado", Color(red: 0.70, green: 0.35, blue: 1.0))
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.03)
                .ignoresSafeArea()
            
            if !isLoggedIn {
                // MARK: - Pantalla de Login
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "shield.lock.fill")
                            .font(.system(size: 64))
                            .foregroundColor(accentColor)
                            .shadow(color: accentColor.opacity(0.8), radius: 15, x: 0, y: 0)
                            .shadow(color: accentColor.opacity(0.4), radius: 30, x: 0, y: 0)
                        
                        Text("INICIAR SESIÓN")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("USUARIO")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            TextField("Ingresa tu usuario", text: $usernameInput)
                                .padding()
                                .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KEY / CONTRASEÑA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            SecureField("Ingresa tu Key o Contraseña", text: $keyInput)
                                .padding()
                                .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !loginError.isEmpty {
                        Text(loginError)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Button(action: validateAndLogin) {
                        Text("INGRESAR")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(accentColor)
                            .cornerRadius(27)
                    }
                    .shadow(color: accentColor.opacity(0.7), radius: 12, x: 0, y: 0)
                    .shadow(color: accentColor.opacity(0.3), radius: 25, x: 0, y: 0)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .transition(.opacity)
                .onAppear {
                    loadKeysFromStorage()
                }
            } else {
                // MARK: - App Principal
                VStack(spacing: 18) {
                    
                    // Header
                    HStack(spacing: 14) {
                        ZStack(alignment: .bottomTrailing) {
                            if let uiImage = UIImage(named: "IMG_4462.jpeg") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 46, height: 46)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(accentColor, lineWidth: 1.5)
                                    )
                                    .shadow(color: accentColor.opacity(0.5), radius: 6, x: 0, y: 0)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 46, height: 46)
                                    .foregroundColor(accentColor.opacity(0.8))
                                    .shadow(color: accentColor.opacity(0.5), radius: 6, x: 0, y: 0)
                            }
                            
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .shadow(color: Color.green.opacity(0.8), radius: 4, x: 0, y: 0)
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("BIENVENIDO")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(.gray)
                                    .tracking(1)
                                
                                Text(isAdmin ? "• ADMIN" : "• VIP")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(accentColor)
                                    .shadow(color: accentColor.opacity(0.6), radius: 4, x: 0, y: 0)
                            }
                            
                            Text(usernameInput)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showColorPicker.toggle()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color(red: 0.10, green: 0.10, blue: 0.13))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Selector de Tema Neón
                    if showColorPicker {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COLOR DE TEMA NEÓN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 15) {
                                ForEach(availableColors, id: \.name) { item in
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 30, height: 30)
                                        .shadow(color: item.color.opacity(accentColor == item.color ? 0.8 : 0), radius: 8, x: 0, y: 0)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: accentColor == item.color ? 2.5 : 0)
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
                        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Pestañas Principales (KEYS estrictamente reservado para Admin)
                    HStack(spacing: 10) {
                        GlowTabButton(title: "AIM", isSelected: selectedTab == "AIM", accentColor: accentColor) {
                            selectedTab = "AIM"
                        }
                        GlowTabButton(title: "VISUAL", isSelected: selectedTab == "VISUAL", accentColor: accentColor) {
                            selectedTab = "VISUAL"
                        }
                        
                        if isAdmin {
                            GlowTabButton(title: "KEYS", isSelected: selectedTab == "KEYS", accentColor: accentColor) {
                                selectedTab = "KEYS"
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Contenido de la pestaña activa
                    ScrollView {
                        VStack(spacing: 14) {
                            if selectedTab == "AIM" {
                                GlowOptionCard(title: "Aim Cabeza", iconName: "target", isSelected: selectedOption == "CABEZA", accentColor: accentColor) { selectedOption = "CABEZA" }
                                GlowOptionCard(title: "Aim Cuello", iconName: "person.fill", isSelected: selectedOption == "CUELLO", accentColor: accentColor) { selectedOption = "CUELLO" }
                                GlowOptionCard(title: "Aim Pecho", iconName: "scope", isSelected: selectedOption == "PECHO", accentColor: accentColor) { selectedOption = "PECHO" }
                                GlowOptionCard(title: "Aim Drag", iconName: "hand.tap.fill", isSelected: selectedOption == "DRAG", accentColor: accentColor) { selectedOption = "DRAG" }
                            } else if selectedTab == "VISUAL" {
                                GlowOptionCard(title: "Holo Personaje", iconName: "person.crop.square.fill", isSelected: false, accentColor: accentColor) {}
                                GlowOptionCard(title: "Holo Armas", iconName: "cube.fill", isSelected: false, accentColor: accentColor) {}
                            } else if selectedTab == "KEYS" && isAdmin {
                                VStack(alignment: .leading, spacing: 20) {
                                    
                                    // Sección para Generar Key
                                    VStack(alignment: .leading, spacing: 14) {
                                        Text("GENERAR NUEVA KEY")
                                            .font(.system(size: 12, weight: .heavy))
                                            .foregroundColor(.gray)
                                        
                                        HStack(spacing: 8) {
                                            QuickDaysButton(days: 1, accentColor: accentColor) { createKey(days: 1) }
                                            QuickDaysButton(days: 5, accentColor: accentColor) { createKey(days: 5) }
                                            QuickDaysButton(days: 7, accentColor: accentColor) { createKey(days: 7) }
                                            QuickDaysButton(days: 30, accentColor: accentColor) { createKey(days: 30) }
                                        }
                                        
                                        HStack(spacing: 10) {
                                            TextField("Días personalizados", text: $customDaysInput)
                                                .keyboardType(.numberPad)
                                                .padding(.horizontal, 14)
                                                .frame(height: 44)
                                                .background(Color(red: 0.10, green: 0.10, blue: 0.13))
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
                                            .shadow(color: accentColor.opacity(0.5), radius: 8, x: 0, y: 0)
                                        }
                                        
                                        if !keyNotificationMessage.isEmpty {
                                            Text(keyNotificationMessage)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(Color.green)
                                                .shadow(color: Color.green.opacity(0.6), radius: 6, x: 0, y: 0)
                                        }
                                    }
                                    .padding()
                                    .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                                    .cornerRadius(18)
                                    
                                    // Lista de Keys Activas
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("KEYS ACTIVAS")
                                                .font(.system(size: 12, weight: .heavy))
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
                                    .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                                    .cornerRadius(18)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    // Botones Inferiores de Acción
                    if selectedTab != "KEYS" {
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Text("INJECT")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(accentColor)
                                    .cornerRadius(18)
                            }
                            .shadow(color: accentColor.opacity(0.8), radius: 10, x: 0, y: 0)
                            .shadow(color: accentColor.opacity(0.3), radius: 20, x: 0, y: 0)
                            
                            Button(action: {}) {
                                Text("BYPASS")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.cyan, lineWidth: 1.5)
                                    )
                            }
                            .shadow(color: Color.cyan.opacity(0.7), radius: 8, x: 0, y: 0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                }
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Lógica de Login Ajustada
    private func validateAndLogin() {
        let cleanUsername = usernameInput.trimmingCharacters(in: .whitespaces)
        let cleanKey = keyInput.trimmingCharacters(in: .whitespaces)
        
        guard !cleanUsername.isEmpty else {
            loginError = "Por favor ingresa un usuario."
            return
        }
        
        guard !cleanKey.isEmpty else {
            loginError = "Por favor ingresa tu Key o contraseña."
            return
        }
        
        loadKeysFromStorage()
        
        // 1. Verificación para Administrador Exclusivo
        if cleanUsername.lowercased() == adminUsername.lowercased() {
            if cleanKey == adminPassword {
                loginError = ""
                isAdmin = true
                withAnimation {
                    isLoggedIn = true
                    selectedTab = "AIM"
                }
                return
            } else {
                loginError = "Contraseña de Administrador incorrecta."
                return
            }
        }
        
        // 2. Verificación Estricta para Usuarios / Clientes Normales
        if let matchingKey = generatedKeys.first(where: { $0.code == cleanKey }) {
            if matchingKey.isExpired {
                loginError = "La Key ingresada ha expirado."
                return
            }
            
            loginError = ""
            isAdmin = false
            withAnimation {
                isLoggedIn = true
                selectedTab = "AIM"
            }
        } else {
            loginError = "Key no válida o no registrada."
        }
    }
    
    // MARK: - Métodos de Persistencia de Keys
    private func createKey(days: Int) {
        let newCode = "KEY-" + String((0..<8).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        let expiration = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let newKey = KeyItem(code: newCode, durationDays: days, expirationDate: expiration)
        
        withAnimation {
            generatedKeys.insert(newKey, at: 0)
            saveKeysToStorage()
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
            saveKeysToStorage()
        }
    }
    
    private func saveKeysToStorage() {
        if let encoded = try? JSONEncoder().encode(generatedKeys) {
            UserDefaults.standard.set(encoded, forKey: "SAVED_KEYS_LIST")
        }
    }
    
    private func loadKeysFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "SAVED_KEYS_LIST"),
           let decoded = try? JSONDecoder().decode([KeyItem].self, from: data) {
            self.generatedKeys = decoded
        }
    }
}

// MARK: - Componente de Pestaña
struct GlowTabButton: View {
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
                .frame(height: 46)
                .background(isSelected ? accentColor : Color(red: 0.08, green: 0.08, blue: 0.10))
                .cornerRadius(16)
        }
        .shadow(color: isSelected ? accentColor.opacity(0.7) : Color.clear, radius: 10, x: 0, y: 0)
    }
}

// MARK: - Tarjeta de Opción
struct GlowOptionCard: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(accentColor)
                }
                .padding(.leading, 12)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                ZStack(alignment: isSelected ? .trailing : .leading) {
                    Capsule()
                        .fill(isSelected ? accentColor : Color(red: 0.20, green: 0.20, blue: 0.24))
                        .frame(width: 48, height: 26)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 22, height: 22)
                        .padding(.horizontal, 2)
                }
                .padding(.trailing, 14)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? accentColor : Color.white.opacity(0.05), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .shadow(color: isSelected ? accentColor.opacity(0.6) : Color.clear, radius: 8, x: 0, y: 0)
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
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(red: 0.10, green: 0.10, blue: 0.13))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Fila de Key
struct KeyRowView: View {
    let keyItem: KeyItem
    let accentColor: Color
    let onRevoke: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(keyItem.code)
                    .font(.custom("Menlo", size: 13))
                    .foregroundColor(accentColor)
                    .shadow(color: accentColor.opacity(0.5), radius: 4, x: 0, y: 0)
                
                HStack(spacing: 8) {
                    Text("\(keyItem.durationDays) Días")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text("• Expira: \(formattedDate(keyItem.expirationDate))")
                        .font(.system(size: 11))
                        .foregroundColor(keyItem.isExpired ? .red : .gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                UIPasteboard.general.string = keyItem.code
            }) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color(red: 0.14, green: 0.14, blue: 0.18))
                    .clipShape(Circle())
            }
            
            Button(action: onRevoke) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(Color(red: 0.09, green: 0.09, blue: 0.11))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
