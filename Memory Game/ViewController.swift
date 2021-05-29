
import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var stepCounter: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var model = CardModel()
    var cardArray = [Card]()
    var firstFlippedCardIndex: IndexPath?
    var steps: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        cardArray = model.getCards()
    }
    
    // MARK: - Protocol Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        let card = cardArray[indexPath.row]
        
        cell.setCard(card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        let card = cardArray[indexPath.row]
        
        if card.isFlipped  == false && card.isMatched == false{
            cell.flip()
            card.isFlipped = true
            if firstFlippedCardIndex == nil {
                firstFlippedCardIndex = indexPath
            }
            else{
                checkForMatches(indexPath)
            }
        }
    }
    
    // MARK: Game Logic Methods
    
    // Check if two cards selected match or not
    func checkForMatches(_ secondFlippedCardIndex: IndexPath) {
        
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        if cardOne.imageName == cardTwo.imageName {
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            cardOneCell?.removeCard()
            cardTwoCell?.removeCard()
            
            checkGameEnded()
        }
        else{
            
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
        }
        
        if cardOneCell == nil {
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        firstFlippedCardIndex = nil
        
        // Step counter
        steps += 1
        stepCounter.text = String(steps)
        
    }
    
    //Check whether game ended
    func checkGameEnded() {
        var isWon = true
        var messageTitle = ""
        var messageValue = ""
        var count: Int = cardArray.count
        
        for card in cardArray {
            if card.isMatched == false{
                isWon = false
                break
            }
            count -= 1
        }
        
        if isWon == true {
            messageTitle = "Congratualtions"
            messageValue = "You Won !"
        }
        else{
            if count > 0 {
                return
            }
            messageTitle = "Game Over"
            messageValue = "You Lost !"
        }
        
        showAlert(messageTitle, messageValue)
    }
    
    
    // MARK: General Methods
    
    // Show Alert with custom title & message
    func showAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
}

