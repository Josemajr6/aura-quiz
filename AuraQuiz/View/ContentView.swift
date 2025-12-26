import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            // MARK: - FONDO
            Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea()
            
            // Luz ambiental
            GeometryReader { proxy in
                Circle()
                    .fill(Color.indigo.opacity(0.2))
                    .frame(width: 600)
                    .blur(radius: 120)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.3)
            }
            .ignoresSafeArea()
            
            // CONTENIDO
            VStack(spacing: 0) {
                switch viewModel.appState {
                case .menu:
                    MainMenu(viewModel: viewModel)
                case .levelSelection:
                    LevelSelectionView(viewModel: viewModel)
                case .studySelection:
                    StudySelectionView(viewModel: viewModel)
                case .studyList:
                    StudyListView(viewModel: viewModel)
                case .loading:
                    LoadingView()
                case .playing:
                    GameView(viewModel: viewModel)
                        .transition(.opacity)
                case .gameOver:
                    GameOverView(viewModel: viewModel)
                case .error:
                    ErrorView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.appState)
    }
}

// MARK: - PANTALLA DE CARGA
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView().tint(.white)
            Text("Cargando...").font(.subheadline).foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - MENÚ PRINCIPAL
struct MainMenu: View {
    var viewModel: GameViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) { // Reducido el espaciado vertical
                
                // HEADER (Un poco más compacto para ganar espacio)
                VStack(spacing: 8) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 60)) // Reducido de 70 a 60
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 20)
                        .padding(.top, 40)
                    
                    Text("AuraQuiz")
                        .font(.system(size: 44, weight: .bold, design: .rounded)) // Reducido de 48 a 44
                        .foregroundStyle(.white)
                    
                    Text("Explora. Aprende. Compite.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.bottom, 10)
                
                // CONTENEDOR DE BOTONES
                VStack(spacing: 24) {
                    
                    // SECCIÓN JUGAR
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(text: "JUGAR")
                        
                        HStack(spacing: 16) {
                            MenuCard(
                                title: "Banderas",
                                subtitle: "Países",
                                icon: "flag.fill",
                                gradient: [.blue, .purple],
                                height: 160
                            ) {
                                viewModel.goToLevelSelection(mode: .flags)
                            }
                            
                            MenuCard(
                                title: "Capitales",
                                subtitle: "Ciudades",
                                icon: "building.columns.fill",
                                gradient: [.purple, .pink],
                                height: 160
                            ) {
                                viewModel.goToLevelSelection(mode: .capitals)
                            }
                        }
                    }
                    
                    // SECCIÓN APRENDER
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeader(text: "APRENDIZAJE")
                        
                        // Tarjeta ancha mejorada
                        MenuCard(
                            title: "Biblioteca",
                            subtitle: "Explora todos los continentes",
                            icon: "book.closed.fill",
                            gradient: [.green, .teal], // Color ajustado a Teal para más elegancia
                            height: 140 // Altura aumentada para que no se vea aplastada
                        ) {
                            viewModel.goToStudy()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 650)
            }
            .padding(.bottom, 80) // Padding extra abajo para que nada se corte
        }
        .scrollIndicators(.hidden) // Sin barra de scroll
        .frame(maxWidth: .infinity)
    }
}

// MARK: - COMPONENTES
struct SectionHeader: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white.opacity(0.5))
            .textCase(.uppercase)
            .kerning(1.2)
            .padding(.leading, 4)
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Fondo Degradado
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                
                // Decoración Geométrica
                GeometryReader { geo in
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .offset(x: geo.size.width - 40, y: -40)
                    
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 80, height: 80)
                        .offset(x: geo.size.width - 90, y: 10)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                // Contenido
                VStack(alignment: .leading, spacing: 0) {
                    // Parte Superior
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(20)
                    
                    Spacer()
                    
                    // Parte Inferior (Textos)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(20)
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            // Sombra suave
            .shadow(color: gradient.first!.opacity(0.3), radius: 10, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// SELECCION DE NIVEL
struct LevelSelectionView: View {
    var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            FloatingHeader(title: "Dificultad", action: { viewModel.goToMenu() })
            
            ScrollView {
                VStack(spacing: 16) {
                    LevelCard(level: .easy, color: .green, viewModel: viewModel)
                    LevelCard(level: .medium, color: .orange, viewModel: viewModel)
                    LevelCard(level: .hard, color: .red, viewModel: viewModel)
                }
                .padding(24)
                .frame(maxWidth: 600)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - ESTUDIO (GRID)
struct StudySelectionView: View {
    var viewModel: GameViewModel
    let continents = [
        ("Europa", "Europe", "🌍"), ("América", "Americas", "🌎"),
        ("Asia", "Asia", "🌏"), ("África", "Africa", "🌍"), ("Oceanía", "Oceania", "🌏")
    ]
    
    let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]
    
    var body: some View {
        VStack(spacing: 0) {
            FloatingHeader(title: "Biblioteca", action: { viewModel.goToMenu() })
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(continents, id: \.1) { item in
                        Button { viewModel.openContinent(item.1) } label: {
                            VStack(spacing: 16) {
                                Text(item.2).font(.system(size: 50))
                                Text(item.0).font(.headline).foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .background(Color(white: 0.1))
                            .cornerRadius(24)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.1)))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(24)
                .frame(maxWidth: 800)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - LISTA PAÍSES
struct StudyListView: View {
    var viewModel: GameViewModel
    let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]
    
    var body: some View {
        VStack(spacing: 0) {
            FloatingHeader(title: viewModel.selectedContinent, action: { viewModel.goToStudy() })
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.getCountriesForCurrentContinent()) { country in
                        VStack(spacing: 10) {
                            AsyncImage(url: URL(string: country.flags.png)) { phase in
                                if let img = phase.image {
                                    img.resizable().aspectRatio(contentMode: .fit).cornerRadius(8)
                                } else {
                                    Rectangle().fill(.gray.opacity(0.2)).frame(height: 60)
                                }
                            }
                            .frame(height: 80)
                            .shadow(radius: 4)
                            
                            Text(country.name.common)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color(white: 0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(24)
                .frame(maxWidth: 1000)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - HEADER FLOTANTE (Icono limpio)
struct FloatingHeader: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack {
                Button(action: action) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                .buttonStyle(ScaleButtonStyle())
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - OTROS COMPONENTES
struct LevelCard: View {
    let level: Difficulty
    let color: Color
    let viewModel: GameViewModel
    
    var body: some View {
        Button {
            viewModel.startGame(difficulty: level)
        } label: {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue).font(.title3).fontWeight(.bold).foregroundStyle(.white)
                    HStack(spacing: 6) {
                        Image(systemName: "clock").font(.caption)
                        Text("15 seg/ronda").font(.caption)
                    }.foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                if viewModel.isLevelCompleted(level) {
                    Image(systemName: "checkmark.circle.fill").font(.title2).foregroundStyle(color)
                } else {
                    Image(systemName: "play.fill").foregroundStyle(color.opacity(0.8)).padding(10).background(color.opacity(0.2)).clipShape(Circle())
                }
            }
            .padding(20)
            .background(Color(white: 0.1))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct GameOverView: View {
    var viewModel: GameViewModel
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: viewModel.lives > 0 ? "trophy.fill" : "flag.slash.fill")
                .font(.system(size: 80))
                .foregroundStyle(viewModel.lives > 0 ? .yellow : .red)
            VStack(spacing: 10) {
                Text(viewModel.lives > 0 ? "¡Nivel Completado!" : "Fin del Juego")
                    .font(.title).bold().foregroundStyle(.white)
                Text("\(viewModel.score) Puntos").font(.largeTitle).bold().foregroundStyle(.white)
            }
            Spacer()
            HStack(spacing: 16) {
                Button("Salir") { viewModel.goToMenu() }
                    .padding().frame(maxWidth: .infinity)
                    .background(Color(white: 0.1)).cornerRadius(14).foregroundStyle(.white)
                Button("Reintentar") { viewModel.retryLevel() }
                    .padding().frame(maxWidth: .infinity)
                    .background(Color.blue).cornerRadius(14).foregroundStyle(.white)
            }.padding(40)
        }
    }
}

struct ErrorView: View {
    var viewModel: GameViewModel
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash").font(.largeTitle).foregroundStyle(.red)
            Text("Sin conexión").foregroundStyle(.white).padding()
            Button("Reintentar") { viewModel.goToMenu() }.buttonStyle(.borderedProminent)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview { ContentView() }
