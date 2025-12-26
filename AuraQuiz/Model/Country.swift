import Foundation

struct Country: Codable, Identifiable, Hashable {
    var id: String { cca3 }
    let name: CountryName
    let cca3: String
    let flags: CountryFlags
    let capital: [String]?
    let region: String
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.cca3 == rhs.cca3
    }
    
    var capitalName: String {
        capital?.first ?? "Sin Capital"
    }
}

struct CountryName: Codable, Hashable {
    let common: String
    let official: String
}

struct CountryFlags: Codable, Hashable {
    let png: String
    let svg: String
}
