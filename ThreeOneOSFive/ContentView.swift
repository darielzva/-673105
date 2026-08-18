import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Colores de la nueva interfaz
    let bgDark = Color(red: 0.08, green: 0.08, blue: 0.10)
    let cardDark = Color(red: 0.12, green: 0.12, blue: 0.14)
    let iconBg = Color(red: 0.25, green: 0.12, blue: 0.15)
    let iconRed = Color(red: 0.90, green: 0.30, blue: 0.40)
    let brightYellow = Color(red: 1.0, green: 0.88, blue: 0.20)

    var body: some View {
        ZStack {
            bgDark.ignoresSafeArea()

            VStack(spacing: 20) {
                // Header espacio
                Spacer().frame(height: 10)

                // Selector Superior (AIM / VISUAL)
                HStack(spacing: 12) {
                    Button(action: { selectedTab = 0 }) {
                        Text("AIM")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 0 ? brightYellow : cardDark)
                            .cornerRadius(12)
                    }

                    Button(action: { selectedTab = 1 }) {
                        Text("VISUAL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(selectedTab == 1 ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 1 ? brightYellow : cardDark)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // Lista de Botones con Icono
                VStack(spacing: 14) {
                    MenuRowButton(title: "Opción Pecho", iconName: "scope", cardBg: cardDark, iconBg: iconBg, iconColor: iconRed)
                    MenuRowButton(title: "Opción Cuello", iconName: "person.fill", cardBg: cardDark, iconBg: iconBg, iconColor: iconRed)
                    MenuRowButton(title: "Opción Drag", iconName: "hand.tap.fill", cardBg: cardDark, iconBg: iconBg, iconColor: iconRed)
                    MenuRowButton(title: "Opción Cabeza", iconName: "target", cardBg: cardDark, iconBg: iconBg, iconColor: iconRed)
                }
                .padding(.horizontal)

                Spacer()

                // Botón Acción Principal Inferior
                Button(action: {
                    // Acción al presionar
                }) {
                    Text("ACCIONAR")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(brightYellow)
                        .cornerRadius(16)
                        .shadow(color: brightYellow.opacity(0.3), radius: 8, x: 0, y: 0)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Componente para la fila de botón con icono cuadrado
struct MenuRowButton: View {
    let title: String
    let iconName: String
    let cardBg: Color
    let iconBg: Color
    let iconColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBg)
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18, weight: .bold))
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(10)
        .background(cardBg)
        .cornerRadius(14)
    }
}
