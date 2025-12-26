import SwiftUI
import Observation

enum AppState {
    case menu, levelSelection, studySelection, studyList, loading, playing, gameOver, error
}

enum GameMode { case flags, capitals }

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Fácil", medium = "Medio", hard = "Difícil"
    var totalRounds: Int { 10 }
    var storageKey: String { "completed_\(self.rawValue)" }
}

struct QuizQuestion {
    let countryToGuess: Country
    let options: [Country]
}

@Observable
class GameViewModel {
    var appState: AppState = .menu
    var currentDifficulty: Difficulty = .medium
    var gameMode: GameMode = .flags
    
    var score: Int = 0
    var currentRound: Int = 1
    var lives: Int = 3
    var currentQuestion: QuizQuestion?
    var userSelectedCountry: Country?
    var showResult: Bool = false
    
    var timeRemaining: CGFloat = 15.0
    var totalTime: CGFloat = 15.0
    private var timer: Timer?
    
    var selectedContinent: String = "Europe"
    
    private var allCountries: [Country] = []
    private var levelCountries: [Country] = []
    private let service = CountryService()
    
    private let easyCodes: Set<String> = ["USA", "ESP", "ITA", "FRA", "DEU", "GBR", "JPN", "CHN", "BRA", "CAN", "ARG", "PRT", "RUS", "AUS", "MEX", "IND", "KOR"]
    private let mediumCodes: Set<String> = ["SWE", "NOR", "DNK", "FIN", "POL", "UKR", "TUR", "EGY", "ZAF", "COL", "CHL", "PER", "SAU", "THA", "VNM", "IDN", "MYS", "PHL", "NZL", "IRL", "AUT", "HUN", "CZE", "GRC", "NLD", "BEL", "CHE", "HRV", "MAR", "URY"]
    
    func goToMenu() { stopTimer(); appState = .menu }
    func goToLevelSelection(mode: GameMode) { self.gameMode = mode; appState = .levelSelection; resetGameState() }
    func goToStudy() {
        if allCountries.isEmpty {
            appState = .loading
            Task { try? await loadData(); await MainActor.run { appState = .studySelection } }
        } else { appState = .studySelection }
    }
    func openContinent(_ c: String) { selectedContinent = c; appState = .studyList }
    func getCountriesForCurrentContinent() -> [Country] {
        allCountries.filter { $0.region == selectedContinent }.sorted { $0.name.common < $1.name.common }
    }
    func isLevelCompleted(_ d: Difficulty) -> Bool { UserDefaults.standard.bool(forKey: d.storageKey) }
    
    private func resetGameState() {
        userSelectedCountry = nil; showResult = false; score = 0; lives = 3; currentRound = 1; stopTimer()
    }
    
    private func loadData() async throws {
        if allCountries.isEmpty { allCountries = try await service.fetchCountries() }
    }
    
    func startGame(difficulty: Difficulty) {
        currentDifficulty = difficulty; resetGameState(); appState = .loading
        Task {
            do {
                try await loadData()
                await MainActor.run {
                    filterCountriesForLevel(difficulty); generateNewQuestion(); appState = .playing
                }
            } catch { appState = .error }
        }
    }
    
    private func filterCountriesForLevel(_ difficulty: Difficulty) {
        var filtered: [Country] = []
        switch difficulty {
        case .easy: filtered = allCountries.filter { easyCodes.contains($0.cca3) }
        case .medium: filtered = allCountries.filter { mediumCodes.contains($0.cca3) }
        case .hard: filtered = allCountries.filter { !easyCodes.contains($0.cca3) && !mediumCodes.contains($0.cca3) }
        }
        if gameMode == .capitals { filtered = filtered.filter { $0.capital?.first?.isEmpty == false } }
        levelCountries = filtered.count < 4 ? allCountries : filtered
    }
    
    private func generateNewQuestion() {
        userSelectedCountry = nil; showResult = false
        guard let correct = levelCountries.randomElement() else { return }
        let distractors = levelCountries.filter { $0.id != correct.id }.shuffled().prefix(3)
        var options = Array(distractors); options.append(correct)
        currentQuestion = QuizQuestion(countryToGuess: correct, options: options.shuffled())
        startTimer()
    }
    
    private func startTimer() {
        stopTimer(); timeRemaining = 15.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.timeRemaining > 0 { self.timeRemaining -= 0.1 } else { self.handleTimeUp() }
            }
        }
    }
    
    func stopTimer() { timer?.invalidate(); timer = nil }
    
    private func handleTimeUp() {
        stopTimer(); guard !showResult else { return }
        lives -= 1; showResult = true
        if lives == 0 { finishGame(won: false) } else { scheduleNextRound() }
    }
    
    func checkAnswer(_ selected: Country) {
        guard !showResult, let correct = currentQuestion?.countryToGuess else { return }
        stopTimer(); userSelectedCountry = selected; showResult = true
        if selected.id == correct.id { score += 10 + Int(timeRemaining) * 2 } else { lives -= 1 }
        if lives == 0 { finishGame(won: false) } else { scheduleNextRound() }
    }
    
    private func scheduleNextRound() {
        Task { try? await Task.sleep(nanoseconds: 2_000_000_000); await MainActor.run { if currentRound < currentDifficulty.totalRounds { currentRound += 1; generateNewQuestion() } else { finishGame(won: true) } } }
    }
    
    private func finishGame(won: Bool) {
        stopTimer(); if won { UserDefaults.standard.set(true, forKey: currentDifficulty.storageKey) }; appState = .gameOver
    }
    
    func retryLevel() { startGame(difficulty: currentDifficulty) }
}
