import Foundation

enum APIError: Error {
    case invalidURL
    case networkError
    case decodingError
}

class CountryService {
    private let baseURL = "https://restcountries.com/v3.1/all?fields=name,flags,cca3,capital,region"
    
    func fetchCountries() async throws -> [Country] {
        guard let url = URL(string: baseURL) else { throw APIError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.networkError
        }
        
        do {
            let countries = try JSONDecoder().decode([Country].self, from: data)
            // Filtramos países válidos
            return countries.filter { !$0.flags.png.isEmpty && $0.capital?.isEmpty == false }
        } catch {
            throw APIError.decodingError
        }
    }
}
