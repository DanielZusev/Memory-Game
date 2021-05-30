
import UIKit
import MapKit

class TopTenViewController: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var userDefaults: UserDefaults!
    var topTenArray = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        userDefaults = UserDefaults.standard
        
        topTenArray = decodeRecordData()
        print(topTenArray)
        for record in topTenArray {
            renderDataToMap(record: record)
        }
    }
    
    
    @IBAction func onPressBack(_ sender: Any) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let mainVC = main.instantiateViewController(withIdentifier: "mainVC")
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true) {
            self.present(mainVC, animated: true, completion: nil)
        }
        
    }
    
    // MARK: Location Methods
    
    func renderDataToMap(record: Record) {
        let cordinate = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lng)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: cordinate, span: span)
        
        map.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = cordinate
        map.addAnnotation(pin)
    }
    
    // MARK: General Methods
    
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
}

// MARK: Extensions

extension TopTenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("")
    }
}

extension TopTenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topTenArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1). \(topTenArray[indexPath.row].toString())"
        
        return cell
    }
}
