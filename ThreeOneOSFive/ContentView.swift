import SwiftUI

// MARK: - Modelo de Key Generada
struct GeneratedKey: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let durationDays: Int
    let creationDate: Date
    var isRevoked: Bool = false
    
    var isExpired: Bool {
        if isRevoked { return true }
        let expirationDate = Calendar.current.date(byAdding: .day, value: durationDays, to: creationDate) ?? Date()
        return Date() > expirationDate
    }
}

struct ContentView: View {
    // Estado de Sesión
    @State private var isLoggedIn: Bool = false
    @State private var isAdmin: Bool = false
    @State private var usernameInput: String = ""
    @State private var keyInput: String = ""
    @State private var loginError: String = ""
    
    // Lista global de Keys
    @State private var activeKeys: [GeneratedKey] = [
        GeneratedKey(code: "DEMO-1DAY", durationDays: 1, creationDate: Date()),
        GeneratedKey(code: "DEMO-7DAYS", durationDays: 7, creationDate: Date())
    ]
    
    // Estado Panel Admin
    @State private var selectedDuration: Int = 1
    @State private var newlyGeneratedKey: String = ""
    @State private var showAdminPanel: Bool = false
    
    // Estados de la App
    @State private var selectedTab: String = "AIM"
    @State private var selectedOption: String? = nil
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15)
    @State private var showColorPicker: Bool = false
    @State private var isInjecting: Bool = false
    @State private var injectionSuccess: Bool = false
    
    let availableColors: [(name: String, color: Color)] = [
        ("Amarillo", Color(red: 1.0, green: 0.85, blue: 0.15)),
        ("Celeste", Color(red: 0.20, green: 0.75, blue: 1.0)),
        ("Verde", Color(red: 0.20, green: 0.85, blue: 0.45)),
        ("Rosa", Color(red: 1.0, green: 0.35, blue: 0.60)),
        ("Morado", Color(red: 0.65, green: 0.35, blue: 1.0))
    ]
    
    var body: some View {
        ZStack {
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("USUARIO")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            TextField("Ingresa tu usuario", text: $usernameInput)
                                .padding()
                                .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KEY / CONTRASEÑA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            SecureField("Ingresa tu Key o Pass Admin", text: $keyInput)
                                .padding()
                                .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !loginError.isEmpty {
                        Text(loginError)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: validateAndLogin) {
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
            } else {
                // MARK: - App Principal
                VStack(spacing: 18) {
                    
                    HStack(spacing: 14) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(accentColor.opacity(0.2))
                                .frame(width: 46, height: 46)
                                .overlay(Circle().stroke(accentColor, lineWidth: 1.5))
                            
                            Text(String(usernameInput.prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(accentColor)
                            
                            Circle()
                                .fill(isAdmin ? Color.purple : Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("BIENVENIDO")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(.gray)
                                
                                Text(isAdmin ? "• ADMIN MASTER" : "• VIP")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(isAdmin ? .purple : accentColor)
                            }
                            
                            Text(usernameInput)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        if isAdmin {
                            Button(action: {
                                withAnimation {
                                    showAdminPanel.toggle()
                                    showColorPicker = false
                                }
                            }) {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                showColorPicker.toggle()
                                showAdminPanel = false
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
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
                    
                    // MARK: - PANEL DE ADMINISTRADOR
                    if isAdmin && showAdminPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("PANEL DE CONTROL DE KEYS")
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundColor(.purple)
                                Spacer()
                                Button("Cerrar") {
                                    withAnimation { showAdminPanel = false }
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            }
                            
                            Text("Generar Nueva Key:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 10) {
                                DurationButton(title: "1 Día", days: 1, selectedDays: $selectedDuration)
                                DurationButton(title: "7 Días", days: 7, selectedDays: $selectedDuration)
                                DurationButton(title: "30 Días", days: 30, selectedDays: $selectedDuration)
                            }
                            
                            Button(action: generateNewKey) {
                                Text("CREAR KEY")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                            
                            if !newlyGeneratedKey.isEmpty {
                                HStack {
                                    Text("Key: \(newlyGeneratedKey)")
                                        .font(.system(size: 13, weight: .monospaced))
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(8)
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            Text("Keys Generadas:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(activeKeys) { key in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(key.code)
                                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                    .foregroundColor(key.isExpired ? .red : .white)
                                                
                                                Text("\(key.durationDays) días - \(key.isExpired ? "VENCIDA" : "ACTIVA")")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(key.isExpired ? .red : .gray)
                                            }
                                            Spacer()
                                            
                                            if !key.isRevoked {
                                                Button(action: { revokeKey(key) }) {
                                                    Text("Vencer")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 5)
                                                        .background(Color.red)
                                                        .cornerRadius(6)
                                                }
                                            }
                                        }
                                        .padding(8)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .frame(height: 120)
                        }
                        .padding()
                        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.purple.opacity(0.5), lineWidth: 1))
                        .padding(.horizontal, 20)
                    }
                    
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
                                        .overlay(Circle().stroke(Color.white, lineWidth: accentColor == item.color ? 3 : 0))
                                        .onTapGesture {
                                            withAnimation { accentColor = item.color }
                                        }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    
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
                    
                    Button(action: executeInjection) {
                        HStack {
                            if isInjecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .padding(.trailing, 8)
                            }
                            
                            Text(isInjecting ? "INYECTANDO..." : (injectionSuccess ? "¡INYECTADO!" : "INYECTAR"))
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(injectionSuccess ? Color.green : accentColor)
                        .cornerRadius(28)
                        .shadow(color: (injectionSuccess ? Color.green : accentColor).opacity(0.35), radius: 12, x: 0, y: 0)
                    }
                    .disabled(isInjecting)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                }
            }
        }
    }
    
    private func validateAndLogin() {
        let trimmedUser = usernameInput.trimmingCharacters(in: .whitespaces)
        let trimmedKey = keyInput.trimmingCharacters(in: .whitespaces)
        
        if trimmedUser.isEmpty {
            loginError = "Por favor ingresa un usuario."
            return
        }
        
        if trimmedKey == "Didier 2013" {
            isAdmin = true
            isLoggedIn = true
            loginError = ""
            return
        }
        
        if let foundKey = activeKeys.first(where: { $0.code == trimmedKey }) {
            if foundKey.isExpired {
                loginError = "Esta Key ha caducado o fue revocada."
            } else {
                isAdmin = false
                isLoggedIn = true
                loginError = ""
            }
        } else {
            loginError = "Key inválida o inexistente."
        }
    }
    
    private func generateNewKey() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var result = "KEY-"
        for _ in 0..<6 {
            if let randomChar = letters.randomElement() {
                result.append(randomChar)
            }
        }
        let newKey = GeneratedKey(code: result, durationDays: selectedDuration, creationDate: Date())
        activeKeys.insert(newKey, at: 0)
        newlyGeneratedKey = result
    }
    
    private func revokeKey(_ key: GeneratedKey) {
        if let index = activeKeys.firstIndex(where: { $0.id == key.id }) {
            activeKeys[index].isRevoked = true
        }
    }
    
    private func executeInjection() {
        withAnimation {
            isInjecting = true
            injectionSuccess = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                isInjecting = false
                injectionSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    injectionSuccess = false
                }
            }
        }
    }
}

struct DurationButton: View {
    let title: String
    let days: Int
    @Binding var selectedDays: Int
    
    var body: some View {
        Button(action: { selectedDays = days }) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(selectedDays == days ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(selectedDays == days ? Color.purple : Color(red: 0.15, green: 0.15, blue: 0.18))
                .cornerRadius(8)
        }
    }
}

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
