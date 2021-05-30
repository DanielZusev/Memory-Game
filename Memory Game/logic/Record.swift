

import Foundation

struct Record: Codable {
    let name: String
    let score: Int
    let lat: Double
    let lng: Double
    
    
    func toString() -> String {
        return "\(self.name), Moves: \(self.score)"
    }
    
}
