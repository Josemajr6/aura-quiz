import SwiftUI

struct GameView: View {
    var viewModel: GameViewModel
    
    // Grid de respuestas simétrico
    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    
    var body: some View {
        ZStack {
            // Fondo
            Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // TOP BAR
                HStack {
                    Button { viewModel.goToLevelSelection(mode: viewModel.gameMode) } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill").font(.caption2)
                        Text("\(viewModel.currentRound)/\(viewModel.currentDifficulty.totalRounds)")
                            .font(.subheadline).fontWeight(.bold)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.1)))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { i in
                            Image(systemName: "heart.fill")
                                .foregroundStyle(i < viewModel.lives ? .red : .gray.opacity(0.3))
                        }
                    }
                }
                .padding()
                
                // BARRA TIEMPO
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1))
                        Capsule().fill(viewModel.timeRemaining > 5 ? Color.green : Color.red)
                            .frame(width: geo.size.width * (viewModel.timeRemaining / viewModel.totalTime))
                            .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
                    }
                }
                .frame(height: 6).padding(.horizontal, 20)
                
                Spacer()
                
                // PREGUNTA
                if let question = viewModel.currentQuestion {
                    VStack(spacing: 24) {
                        if viewModel.gameMode == .flags {
                            FlagImageView(urlString: question.countryToGuess.flags.png, size: 180)
                                .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
                            Text("¿Qué país es?").font(.title3).foregroundStyle(.white.opacity(0.8))
                        } else {
                            VStack(spacing: 8) {
                                Text(question.countryToGuess.name.common)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center).foregroundStyle(.white)
                                    .padding(.horizontal)
                                Text("¿Cuál es su capital?").font(.subheadline).foregroundStyle(.white.opacity(0.6))
                            }
                            .padding(30).background(Color(white: 0.1)).cornerRadius(20)
                        }
                    }
                    .id("Q-\(question.countryToGuess.id)")
                }
                
                Spacer()
                
                Text("\(viewModel.score)").font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white.opacity(0.2)).padding(.bottom, 10)
                
                // RESPUESTAS
                if let question = viewModel.currentQuestion {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(question.options) { country in
                            Button { viewModel.checkAnswer(country) } label: {
                                Text(viewModel.gameMode == .flags ? country.name.common : country.capitalName)
                                    .font(.system(size: 15, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity).frame(height: 60)
                                    .background(backgroundColor(for: country))
                                    .foregroundStyle(textColor(for: country))
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05)))
                            }
                            .disabled(viewModel.showResult)
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(20).padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: 600).frame(maxWidth: .infinity)
    }
    
    private func backgroundColor(for country: Country) -> Color {
        guard viewModel.showResult else { return Color(white: 0.15) }
        if country.id == viewModel.currentQuestion?.countryToGuess.id { return .green.opacity(0.8) }
        if country.id == viewModel.userSelectedCountry?.id { return .red.opacity(0.8) }
        return Color(white: 0.15).opacity(0.5)
    }
    
    private func textColor(for country: Country) -> Color {
        guard viewModel.showResult else { return .white }
        if country.id == viewModel.currentQuestion?.countryToGuess.id || country.id == viewModel.userSelectedCountry?.id { return .white }
        return .white.opacity(0.3)
    }
}

struct FlagImageView: View {
    let urlString: String
    let size: CGFloat
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let img = phase.image {
                img.resizable().aspectRatio(contentMode: .fit).frame(height: size).cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.2)).frame(height: size)
            }
        }
    }
}
