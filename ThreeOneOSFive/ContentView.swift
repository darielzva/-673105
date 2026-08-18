import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "AIM"
    @State private var selectedOption: String? = nil
    
    // Color por defecto (Amarillo) y control del selector de color
    @State private var accentColor: Color = Color(red: 1.0, green: 0.85, blue: 0.15)
    @State private var showColorPicker: Bool = false
    
    // Lista de colores predefinidos para la paleta
    let availableColors: [(name: String, color: Color)] = [
        ("Amarillo", Color(red: 1.0, green: 0.85, blue: 0.15)),
        ("Celeste", Color(red: 0.20, green: 0.75, blue: 1.0)),
        ("Verde", Color(red: 0.20, green: 0.85, blue: 0.45)),
        ("Rosa", Color(red: 1.0, green: 0.35, blue: 0.60)),
        ("Morado", Color(red: 0.65, green: 0.35, blue: 1.0))
    ]
    
    var body: some View {
        ZStack {
            // Fondo aún más oscuro (Casi negro absoluto)
            Color(red: 0.03, green: 0.03, blue: 0.04)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Barra Superior: Tuerca de Ajustes a la derecha
                HStack {
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
                
                // Menú desplegable de Paleta de Colores
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
                
                // Selector Superior (AIM / VISUAL) — Contenedor unificado
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
                
                // Lista de Opciones
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == "AIM" {
                            OptionCard(
                                title: "AIM CABEZA",
                                iconName: "target",
                                isSelected: selectedOption == "CABEZA",
                                accentColor: accentColor
                            ) { selectedOption = "CABEZA" }
                            
                            OptionCard(
                                title: "AIM CUELLO",
                                iconName: "person.fill",
                                isSelected: selectedOption == "CUELLO",
                                accentColor: accentColor
                            ) { selectedOption = "CUELLO" }
                            
                            OptionCard(
                                title: "AIM PECHO",
                                iconName: "scope",
                                isSelected: selectedOption == "PECHO",
                                accentColor: accentColor
                            ) { selectedOption = "PECHO" }
                            
                            OptionCard(
                                title: "AIM DRAG",
                                iconName: "hand.tap.fill",
                                isSelected: selectedOption == "DRAG",
                                accentColor: accentColor
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
                
                // Botón Inferior ACCIONAR (Vinculado al color de acento)
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
        }
    }
}

// Subvista para las pestañas superiores unificadas
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
