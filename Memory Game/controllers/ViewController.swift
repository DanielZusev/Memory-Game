
import UIKit
import CoreLocation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var stepCounter: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var model = CardModel()
    var cardArray = [Card]()
    var firstFlippedCardIndex: IndexPath?
    var steps: Int = 0
    var userDefaults: UserDefaults!
    var topTenArray = [Record]()
    var lat: Double = 0.0
    var lng: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        cardArray = model.getCards()
        
        userDefaults = UserDefaults.standard
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
    
    func locationManager( _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else {
            return
        }
        
        self.lat = first.coordinate.latitude
        self.lng = first.coordinate.longitude
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
        var count: Int = cardArray.count
        
        for card in cardArray {
            if card.isMatched == false{
                isWon = false
                break
            }
            count -= 1
        }
        
        if isWon == true {
            showTextAlert()
        }
        else{
            if count > 0 {
                return
            }
        }
    }
    
    
    // MARK: General Methods
    
    // Show Alert with custom title & message
    func showAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    // show alert with textfiled
    func showTextAlert () {
        let alertController = UIAlertController(title: "Congratualation !", message: "New High Score", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "My Name Is.."
        }
        
        let alertAction = UIAlertAction(title: "Submit", style: .default) { UIAlertAction in
            let userName = alertController.textFields![0].text ?? "John Doe"
            let score = self.steps
            let record = Record(name: userName, score: score, lat: self.lat, lng: self.lng)
            
            self.checkTopTen(record: record)
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Check if score entered top 10
    func checkTopTen( record: Record) {
        let records = self.decodeRecordData()
        
        self.topTenArray = records.sorted { $0.score < $1.score}
        
        let arraySize = self.topTenArray.count
        
        if arraySize < 10 {
            topTenArray.append(record)
            
        } else {
            if topTenArray[arraySize].score > record.score {
                topTenArray.remove(at: arraySize)
                topTenArray.append(record)
            }
        }
        
        topTenArray = topTenArray.sorted { $0.score < $1.score}
        self.encodeRecordData(records: topTenArray)
        self.goToMain()
    }
    
    
    // encode record to user defaults
    func encodeRecordData(records: [Record]) {
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(records)
            
            self.userDefaults.set(data, forKey: "Records")
            
        } catch {
            print("Unable encode record")
        }
    }
    
    // decode record from user defaults
    func decodeRecordData() -> [Record] {
        if let data = self.userDefaults.data(forKey: "Records"){
            do {
                let decoder = JSONDecoder()
                let records = try decoder.decode([Record].self, from: data)
                
                return records
                
            } catch {
                print("Unable decode records")
            }
        }
        return [Record]()
    }
    
    
    // Go to main
    func goToMain() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let mainVC = main.instantiateViewController(withIdentifier: "mainVC")
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true) {
            self.present(mainVC, animated: true, completion: nil)
        }
        
    }
}

