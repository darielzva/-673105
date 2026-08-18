import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "AIM"
    @State private var selectedOption: String? = nil
    
    var body: some View {
        ZStack {
            // Fondo oscuro
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Selector Superior (AIM / VISUAL)
                HStack(spacing: 12) {
                    TabButton(title: "AIM", isSelected: selectedTab == "AIM") {
                        selectedTab = "AIM"
                    }
                    TabButton(title: "VISUAL", isSelected: selectedTab == "VISUAL") {
                        selectedTab = "VISUAL"
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Lista de Opciones
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == "AIM" {
                            OptionCard(
                                title: "AIM CABEZA",
                                iconName: "target",
                                isSelected: selectedOption == "CABEZA"
                            ) { selectedOption = "CABEZA" }
                            
                            OptionCard(
                                title: "AIM CUELLO",
                                iconName: "person.fill",
                                isSelected: selectedOption == "CUELLO"
                            ) { selectedOption = "CUELLO" }
                            
                            OptionCard(
                                title: "AIM PECHO",
                                iconName: "scope",
                                isSelected: selectedOption == "PECHO"
                            ) { selectedOption = "PECHO" }
                            
                            OptionCard(
                                title: "AIM DRAG",
                                iconName: "hand.tap.fill",
                                isSelected: selectedOption == "DRAG"
                            ) { selectedOption = "DRAG" }
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
                
                // Botón Inferior Accionar
                Button(action: {
                    // Acción al presionar
                }) {
                    Text("ACCIONAR")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 1.0, green: 0.85, blue: 0.15))
                        .cornerRadius(28)
                        .shadow(color: Color(red: 1.0, green: 0.85, blue: 0.15).opacity(0.3), radius: 10, x: 0, y: 0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
        }
    }
}

// Subvista para las pestañas superiores
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color(red: 1.0, green: 0.85, blue: 0.15) : Color(red: 0.15, green: 0.15, blue: 0.18))
                .cornerRadius(16)
        }
    }
}

// Subvista para las tarjetas de opciones (más altas y redondeadas)
struct OptionCard: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Contenedor del Icono
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.25, green: 0.10, blue: 0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.45))
                }
                .padding(.leading, 12)
                
                // Texto de la opción
                Text(title)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80) // Mayor altura
            .background(Color(red: 0.14, green: 0.14, blue: 0.17))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(red: 1.0, green: 0.85, blue: 0.15) : Color.clear, lineWidth: 2)
            )
        }
    }
}
