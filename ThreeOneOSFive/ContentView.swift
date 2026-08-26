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

// MARK: - Administrador de Inyección y Gestión de Parches (Offline Cache)
class PatchInjectionManager: ObservableObject {
    static let shared = PatchInjectionManager()
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Carpeta física requerida: offline cache
    private var offlineCacheFolder: URL {
        documentsDirectory.appendingPathComponent("offline cache", isDirectory: true)
    }
    
    func applyPatch(fileName: String, completion: (Bool, String) -> Void) {
        do {
            if !FileManager.default.fileExists(atPath: offlineCacheFolder.path) {
                try FileManager.default.createDirectory(at: offlineCacheFolder, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Limpiamos la carpeta primero para asegurar que SOLO exista un archivo inyectado a la vez
            let existingFiles = try FileManager.default.contentsOfDirectory(at: offlineCacheFolder, includingPropertiesForKeys: nil)
            for file in existingFiles {
                try FileManager.default.removeItem(at: file)
            }
            
            let destinationURL = offlineCacheFolder.appendingPathComponent(fileName)
            let patchPayload = "DARIELMODZ_OFFLINE_CACHE_PAYLOAD://inject/\(fileName)//timestamp/\(Date().timeIntervalSince1970)"
            
            try patchPayload.write(to: destinationURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: destinationURL.path)
            
            completion(true, "Parche \(fileName) inyectado en offline cache.")
        } catch {
            completion(false, "Error al inyectar: \(error.localizedDescription)")
        }
    }
    
    func removeAllPatches(completion: (Bool, String) -> Void) {
        do {
            if FileManager.default.fileExists(atPath: offlineCacheFolder.path) {
                let existingFiles = try FileManager.default.contentsOfDirectory(at: offlineCacheFolder, includingPropertiesForKeys: nil)
                for file in existingFiles {
                    try FileManager.default.removeItem(at: file)
                }
            }
            completion(true, "Parches removidos con éxito.")
        } catch {
            completion(false, "Error al limpiar caché: \(error.localizedDescription)")
        }
    }
}

// MARK: - Modelo de Parche UI
struct PatchItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let fileName: String
    var isEnabled: Bool
}

struct ContentView: View {
    private let adminUsername: String = "darielzx"
    private let adminPassword: String = "didierdariel2013"
    
    @State private var isLoggedIn: Bool = false
    @AppStorage("saved_username_input") private var usernameInput: String = ""
    @State private var keyInput: String = ""
    @State private var loginError: String = ""
    @State private var showKeyText: Bool = false
    @State private var isLoggingIn: Bool = false
    @State private var isAdmin: Bool = false
    
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15)
    @State private var showSettingsModal: Bool = false
    
    let availableColors: [(name: String, color: Color)] = [
        ("Ámbar", Color(red: 1.0, green: 0.85, blue: 0.15)),
        ("Celeste", Color(red: 0.20, green: 0.80, blue: 1.0)),
        ("Verde", Color(red: 0.20, green: 0.90, blue: 0.45)),
        ("Rosa", Color(red: 1.0, green: 0.35, blue: 0.65)),
        ("Morado", Color(red: 0.70, green: 0.35, blue: 1.0))
    ]
    
    @State private var generatedKeys: [KeyItem] = []
    @State private var customDaysInput: String = ""
    @State private var keyNotificationMessage: String = ""
    
    @State private var patches: [PatchItem] = [
        PatchItem(title: "AIM DRAG", subtitle: "FREE FIRE NORMAL / MAX", fileName: "aim_drag.3105", isEnabled: false),
        PatchItem(title: "AIM NECK", subtitle: "FREE FIRE NORMAL / MAX", fileName: "neck.3105", isEnabled: false),
        PatchItem(title: "HSSLA", subtitle: "FREE FIRE NORMAL / MAX", fileName: "hssla.3105", isEnabled: false),
        PatchItem(title: "HSPESCOÇO SEM ANTENA", subtitle: "FREE FIRE NORMAL / MAX", fileName: "hspescoco.3105", isEnabled: false),
        PatchItem(title: "AIM BODY", subtitle: "FREE FIRE NORMAL / MAX", fileName: "aim_body.3105", isEnabled: false),
        PatchItem(title: "HYPER BALAMAGICA", subtitle: "FREE FIRE NORMAL / MAX", fileName: "hyper_balamagica.3105", isEnabled: false)
    ]
    
    @State private var injectionMessage: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.04)
                .ignoresSafeArea()
            
            if !isLoggedIn {
                // MARK: - Pantalla de Login
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 64))
                            .foregroundColor(accentColor)
                            .shadow(color: accentColor.opacity(0.8), radius: 15, x: 0, y: 0)
                        
                        Text("DARIELMODZ")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .tracking(2)
                        
                        Text("PATCH CONTROL CENTER")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.5)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("USUARIO")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            
                            TextField("Ingresa tu usuario", text: $usernameInput)
                                .padding()
                                .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KEY / CONTRASEÑA")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                if showKeyText {
                                    TextField("Ingresa tu Key", text: $keyInput)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Ingresa tu Key", text: $keyInput)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: { showKeyText.toggle() }) {
                                    Image(systemName: showKeyText ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !loginError.isEmpty {
                        Text(loginError)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Button(action: {
                        isLoggingIn = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            validateAndLogin()
                            isLoggingIn = false
                        }
                    }) {
                        ZStack {
                            if isLoggingIn {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("INGRESAR")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(accentColor)
                        .cornerRadius(26)
                    }
                    .padding(.horizontal, 24)
                    .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    Spacer()
                }
                .onAppear { loadKeysFromStorage() }
            } else {
                // MARK: - Interfaz Principal
                VStack(spacing: 0) {
                    
                    // Header Superior
                    HStack(spacing: 12) {
                        ZStack {
                            if let uiImage = UIImage(named: "IMG_4462.jpeg") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(accentColor, lineWidth: 1))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentColor.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .overlay(Image(systemName: "crown.fill").foregroundColor(accentColor))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("DARIELMODZ")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.white)
                                    .tracking(1)
                                
                                Text(isAdmin ? "• ADMIN" : "• VIP")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(accentColor)
                            }
                            
                            Text("PATCH CONTROL CENTER")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(accentColor)
                                .tracking(0.5)
                            
                            Text(usernameInput)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation { showSettingsModal.toggle() } }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 42, height: 42)
                                .background(accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: accentColor.opacity(0.4), radius: 6, x: 0, y: 0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            
                            // Consola de Estado
                            HStack(spacing: 12) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(accentColor)
                                    .frame(width: 36, height: 36)
                                    .background(accentColor.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("OFFLINE CACHE INJECTOR")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Select only one active patch before entering game.")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: Color.green, radius: 4)
                                    Text("READY")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentColor.opacity(0.3), lineWidth: 1))
                            
                            // Device Status (Versión de iOS real del dispositivo)
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(accentColor)
                                    Text("DEVICE STATUS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(accentColor)
                                    
                                    Spacer()
                                    
                                    Text("VERIFIED")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack {
                                    Label("iOS", systemImage: "apple.logo")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(UIDevice.current.systemVersion)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                                
                                HStack {
                                    Label("Device", systemImage: "iphone")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(UIDevice.current.model)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                                
                                HStack {
                                    Label("Support", systemImage: "checkmark.shield.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("SUPPORTED")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(accentColor)
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            
                            // Patch Options Título
                            HStack {
                                Label("PATCH OPTIONS", systemImage: "bolt.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(accentColor)
                                Spacer()
                                Text("SELECT ONE EXCLUSIVE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 4)
                            
                            // Cuadrícula de Parches (Exclusivos: al activar uno, se desactivan los demás)
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach($patches) { $patch in
                                    PatchCardView(patch: $patch, accentColor: accentColor) {
                                        if patch.isEnabled {
                                            // Si ya estaba activo, se apaga y limpia la carpeta
                                            PatchInjectionManager.shared.removeAllPatches { success, message in
                                                patch.isEnabled = false
                                                injectionMessage = "Parche removido del caché."
                                                clearInjectionMessageAfterDelay()
                                            }
                                        } else {
                                            // Apagamos todos los demás visualmente
                                            for index in 0..<patches.count {
                                                patches[index].isEnabled = false
                                            }
                                            
                                            // Inyectamos el seleccionado en 'offline cache'
                                            PatchInjectionManager.shared.applyPatch(fileName: patch.fileName) { success, message in
                                                if success {
                                                    patch.isEnabled = true
                                                    injectionMessage = "¡Inyectado en offline cache: \(patch.fileName)!"
                                                    clearInjectionMessageAfterDelay()
                                                } else {
                                                    injectionMessage = message
                                                    clearInjectionMessageAfterDelay()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if !injectionMessage.isEmpty {
                                Text(injectionMessage)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(accentColor)
                                    .cornerRadius(10)
                                    .shadow(color: accentColor.opacity(0.5), radius: 6, x: 0, y: 0)
                            }
                            
                            // Enter Game con apertura real de Free Fire y Free Fire Max
                            VStack(alignment: .leading, spacing: 10) {
                                Label("ENTER GAME", systemImage: "arrow.up.right.square.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(accentColor)
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        launchGame(urlSchemes: ["com.dts.freefireth://", "freefire://", "com.garena.msdk.freefire://"], gameName: "Free Fire Normal")
                                    }) {
                                        gameButtonContent(title: "FF NORMAL", subtitle: "Free Fire")
                                    }
                                    
                                    Button(action: {
                                        launchGame(urlSchemes: ["com.dts.freefiremax://", "freefiremax://"], gameName: "Free Fire Max")
                                    }) {
                                        gameButtonContent(title: "FF MAX", subtitle: "Free Fire Max")
                                    }
                                }
                            }
                            .padding(.top, 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    
                    // Footer
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .shadow(color: Color.green, radius: 4)
                        Text("SYSTEM READY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("DARIELMODZ • OFFLINE CACHE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.05, green: 0.05, blue: 0.07))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .sheet(isPresented: $showSettingsModal) {
                    NavigationView {
                        ZStack {
                            Color(red: 0.03, green: 0.03, blue: 0.04)
                                .ignoresSafeArea()
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    
                                    // Selector de Color
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("COLOR DE TEMA NEÓN")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.gray)
                                        
                                        HStack(spacing: 16) {
                                            ForEach(availableColors, id: \.name) { item in
                                                Circle()
                                                    .fill(item.color)
                                                    .frame(width: 36, height: 36)
                                                    .shadow(color: item.color.opacity(accentColor == item.color ? 0.8 : 0), radius: 8)
                                                    .overlay(Circle().stroke(Color.white, lineWidth: accentColor == item.color ? 2.5 : 0))
                                                    .onTapGesture { withAnimation { accentColor = item.color } }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                                    .cornerRadius(16)
                                    
                                    // Generador de Keys (Admin Panel)
                                    if isAdmin {
                                        VStack(alignment: .leading, spacing: 14) {
                                            Text("PANEL DE ADMINISTRADOR: KEYS")
                                                .font(.system(size: 12, weight: .heavy))
                                                .foregroundColor(accentColor)
                                            
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
                                            }
                                            
                                            if !keyNotificationMessage.isEmpty {
                                                Text(keyNotificationMessage)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.green)
                                            }
                                            
                                            Text("KEYS ACTIVAS (\(generatedKeys.count))")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.gray)
                                                .padding(.top, 6)
                                            
                                            if generatedKeys.isEmpty {
                                                Text("No hay keys generadas.")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            } else {
                                                ForEach(generatedKeys) { item in
                                                    KeyRowView(keyItem: item, accentColor: accentColor, onRevoke: { revokeKey(id: item.id) })
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
                                        .cornerRadius(16)
                                    }
                                    
                                    Button(action: {
                                        showSettingsModal = false
                                        isLoggedIn = false
                                        isAdmin = false
                                        keyInput = ""
                                    }) {
                                        HStack {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                            Text("CERRAR SESIÓN")
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.red.opacity(0.15))
                                        .cornerRadius(14)
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.4), lineWidth: 1))
                                    }
                                    .padding(.top, 10)
                                }
                                .padding(20)
                            }
                        }
                        .navigationTitle("Ajustes y Panel")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Listo") { showSettingsModal = false }
                                    .foregroundColor(accentColor)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func clearInjectionMessageAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            injectionMessage = ""
        }
    }
    
    // Método mejorado para comprobar varios esquemas posibles del juego y abrirlo correctamente
    private func launchGame(urlSchemes: [String], gameName: String) {
        var opened = false
        for scheme in urlSchemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                opened = true
                break
            }
        }
        
        if !opened {
            injectionMessage = "No se pudo abrir \(gameName). Asegúrate de tenerlo instalado."
            clearInjectionMessageAfterDelay()
        }
    }
    
    private func gameButtonContent(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundColor(accentColor)
        }
        .padding(12)
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(accentColor.opacity(0.3), lineWidth: 1))
    }
    
    private func validateAndLogin() {
        let cleanUsername = usernameInput.trimmingCharacters(in: .whitespaces)
        let cleanKey = keyInput.trimmingCharacters(in: .whitespaces)
        
        guard !cleanUsername.isEmpty, !cleanKey.isEmpty else {
            loginError = "Por favor ingresa usuario y contraseña."
            return
        }
        
        loadKeysFromStorage()
        
        if cleanUsername.lowercased() == adminUsername.lowercased() {
            if cleanKey == adminPassword {
                loginError = ""
                isAdmin = true
                withAnimation { isLoggedIn = true }
                return
            } else {
                loginError = "Contraseña de Administrador incorrecta."
                return
            }
        }
        
        if let matchingKey = generatedKeys.first(where: { $0.code == cleanKey }) {
            if matchingKey.isExpired {
                loginError = "La Key ingresada ha expirado."
                return
            }
            loginError = ""
            isAdmin = false
            withAnimation { isLoggedIn = true }
        } else {
            loginError = "Key no válida o no registrada."
        }
    }
    
    private func createKey(days: Int) {
        let newCode = "KEY-" + String((0..<8).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        let expiration = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let newKey = KeyItem(code: newCode, durationDays: days, expirationDate: expiration)
        
        withAnimation {
            generatedKeys.insert(newKey, at: 0)
            saveKeysToStorage()
            keyNotificationMessage = "¡Key creada y copiada al portapapeles!"
        }
        UIPasteboard.general.string = newCode
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { keyNotificationMessage = "" }
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

// MARK: - Subcomponentes de UI
struct PatchCardView: View {
    @Binding var patch: PatchItem
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundColor(patch.isEnabled ? Color.green : accentColor)
                        .frame(width: 30, height: 30)
                        .background((patch.isEnabled ? Color.green : accentColor).opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                    
                    Text(patch.isEnabled ? "ON" : "OFF")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(patch.isEnabled ? .black : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(patch.isEnabled ? Color.green : Color(red: 0.12, green: 0.12, blue: 0.15))
                        .cornerRadius(6)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(patch.title)
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(patch.subtitle)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(accentColor)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(patch.isEnabled ? Color.green : Color.gray)
                        .frame(width: 5, height: 5)
                    
                    Text(patch.isEnabled ? "PATCH ACTIVE" : "TAP TO ACTIVATE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.06, green: 0.06, blue: 0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(patch.isEnabled ? Color.green.opacity(0.6) : accentColor.opacity(0.2), lineWidth: patch.isEnabled ? 1.5 : 1)
            )
        }
        .shadow(color: patch.isEnabled ? Color.green.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 0)
    }
}

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
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(accentColor.opacity(0.3), lineWidth: 1))
        }
    }
}

struct KeyRowView: View {
    let keyItem: KeyItem
    let accentColor: Color
    let onRevoke: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(keyItem.code)
                    .font(.custom("Menlo", size: 12))
                    .foregroundColor(accentColor)
                
                HStack(spacing: 8) {
                    Text("\(keyItem.durationDays) Días")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text("• Exp: \(formattedDate(keyItem.expirationDate))")
                        .font(.system(size: 10))
                        .foregroundColor(keyItem.isExpired ? .red : .gray)
                }
            }
            
            Spacer()
            
            Button(action: { UIPasteboard.general.string = keyItem.code }) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color(red: 0.14, green: 0.14, blue: 0.18))
                    .clipShape(Circle())
            }
            
            Button(action: onRevoke) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(10)
        .background(Color(red: 0.09, green: 0.09, blue: 0.11))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accentColor.opacity(0.2), lineWidth: 1))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
