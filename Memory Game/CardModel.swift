
import Foundation

class CardModel {
    
    let numberOfPaires = 8
    
    // return an array of generated pair of cards
    func getCards() -> [Card] {
        
        var cardArray = [Card]()
        
        for i in 1...numberOfPaires {
            let firstCard = Card()
            let secondCard = Card()
            
            firstCard.imageName = "card\(i)"
            secondCard.imageName = "card\(i)"
            
            cardArray.append(firstCard)
            cardArray.append(secondCard)
            
        }
        // randomize the cards
        for i in 0...numberOfPaires {
            let randomNumber = Int.random(in: 1..<numberOfPaires * 2)
            
            let tempCard = cardArray[i]
            cardArray[i] = cardArray[randomNumber]
            cardArray[randomNumber] = tempCard
        }
        return cardArray
    }
}
