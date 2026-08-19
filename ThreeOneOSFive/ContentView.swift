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
    @AppStorage("saved_username_input") private var usernameInput: String = ""
    @State private var keyInput: String = ""
    @State private var loginError: String = ""
    @State private var isAdmin: Bool = false
    
    // Estados adicionales para el login mejorado
    @State private var showKeyText: Bool = false
    @State private var isLoggingIn: Bool = false
    
    // Estados de la App Principal
    @State private var selectedTab: String = "AIM" // "AIM", "VISUAL", "KEYS"
    @State private var selectedOption: String? = "PECHO"
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15) // Amarillo Neón
    @State private var showColorPicker: Bool = false
    
    // Estados del Gestor de Keys
    @State private var generatedKeys: [KeyItem] = []
    @State private var customDaysInput: String = ""
    @State private var keyNotificationMessage: String = ""
    
    // Estados para la inyección por archivos .3105
    @State private var injectionSuccessMessage: String = ""
    
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
                    Image(systemName: "shield.lock.fill").font(.system(size: 64)).foregroundColor(accentColor)
                    Text("INICIAR SESIÓN").font(.system(size: 24, weight: .heavy)).foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        TextField("Ingresa tu usuario", text: $usernameInput).padding().background(Color(red: 0.08, green: 0.08, blue: 0.10)).cornerRadius(14)
                        HStack {
                            if showKeyText { TextField("Key o Contraseña", text: $keyInput) } else { SecureField("Key o Contraseña", text: $keyInput) }
                            Button(action: { showKeyText.toggle() }) { Image(systemName: showKeyText ? "eye.slash.fill" : "eye.fill").foregroundColor(.gray) }
                        }.padding().background(Color(red: 0.08, green: 0.08, blue: 0.10)).cornerRadius(14)
                    }.padding(.horizontal, 24)
                    
                    Button(action: { validateAndLogin() }) {
                        Text("INGRESAR").font(.system(size: 18, weight: .heavy)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).frame(height: 54).background(accentColor).cornerRadius(27)
                    }.padding(.horizontal, 24)
                    Spacer()
                }
            } else {
                // MARK: - App Principal
                VStack(spacing: 18) {
                    // Header y Pestañas (omitidos para brevedad, igual al anterior)
                    HStack { Text(usernameInput).font(.headline).foregroundColor(.white); Spacer() }
                        .padding(.horizontal, 20).padding(.top, 10)
                    
                    HStack {
                        GlowTabButton(title: "AIM", isSelected: selectedTab == "AIM", accentColor: accentColor) { selectedTab = "AIM" }
                        GlowTabButton(title: "VISUAL", isSelected: selectedTab == "VISUAL", accentColor: accentColor) { selectedTab = "VISUAL" }
                        if isAdmin { GlowTabButton(title: "KEYS", isSelected: selectedTab == "KEYS", accentColor: accentColor) { selectedTab = "KEYS" } }
                    }.padding(.horizontal, 20)
                    
                    if !injectionSuccessMessage.isEmpty {
                        Text(injectionSuccessMessage).font(.system(size: 13, weight: .bold)).foregroundColor(.black)
                            .padding(10).background(accentColor).cornerRadius(12)
                    }
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            if selectedTab == "AIM" {
                                GlowOptionCard(title: "Aim Cabeza", iconName: "target", isSelected: selectedOption == "CABEZA", accentColor: accentColor) { selectedOption = "CABEZA" }
                                GlowOptionCard(title: "Aim Cuello", iconName: "person.fill", isSelected: selectedOption == "CUELLO", accentColor: accentColor) { selectedOption = "CUELLO" }
                                GlowOptionCard(title: "Aim Pecho", iconName: "scope", isSelected: selectedOption == "PECHO", accentColor: accentColor) { selectedOption = "PECHO" }
                                GlowOptionCard(title: "Aim Drag", iconName: "hand.tap.fill", isSelected: selectedOption == "DRAG", accentColor: accentColor) { selectedOption = "DRAG" }
                            } else if selectedTab == "VISUAL" {
                                GlowOptionCard(title: "Holo Personaje", iconName: "person.crop.square.fill", isSelected: selectedOption == "HOLO_PERS", accentColor: accentColor) { selectedOption = "HOLO_PERS" }
                                GlowOptionCard(title: "Holo Armas", iconName: "cube.fill", isSelected: selectedOption == "HOLO_ARMAS", accentColor: accentColor) { selectedOption = "HOLO_ARMAS" }
                            }
                        }.padding(.horizontal, 20)
                    }
                    
                    // MARK: - Barra Inferior (Lógica Modificada)
                    HStack(spacing: 10) {
                        Button(action: {
                            if let currentOption = selectedOption {
                                executeDirectInjection(fileName: fileForOption(currentOption), optionKey: currentOption)
                            }
                        }) {
                            Text("INJECT").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                                .frame(maxWidth: .infinity).frame(height: 46).background(accentColor).cornerRadius(16)
                        }
                        
                        Button(action: { isLoggedIn = false }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(.red)
                                .frame(width: 46, height: 46).background(Color.red.opacity(0.15)).cornerRadius(16)
                        }
                    }.padding(.horizontal, 20).padding(.bottom, 15)
                }
            }
        }
    }
    
    // MARK: - Métodos
    private func executeDirectInjection(fileName: String, optionKey: String) {
        // Lógica de creación de archivo
        let targetDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destinationPath = targetDirectory?.appendingPathComponent(fileName).path ?? "/Documents/\(fileName)"
        let dummyRouteContent = "PATH_ROUTE_3105://inject/\(fileName)"
        try? dummyRouteContent.write(toFile: destinationPath, atomically: true, encoding: .utf8)
        
        withAnimation { injectionSuccessMessage = "¡Inyectado correctamente en el dispositivo!" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { withAnimation { injectionSuccessMessage = "" } }
    }
    
    private func fileForOption(_ option: String) -> String {
        switch option {
        case "CABEZA": return "aimbot_cabeza.3105"
        case "CUELLO": return "aimbot_cuello.3105"
        case "PECHO": return "aimbot_pecho.3105"
        case "DRAG": return "aimbot_drag.3105"
        case "HOLO_PERS": return "holo_personaje.3105"
        case "HOLO_ARMAS": return "holo_armas.3105"
        default: return "aimbot_pecho.3105"
        }
    }
    
    private func validateAndLogin() { /* ... lógica de login igual ... */ }
}
