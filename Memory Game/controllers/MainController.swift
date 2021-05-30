
import UIKit

class MainController: UIViewController {
    
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var topTenBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onTopTenPress() {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let topTenVC = main.instantiateViewController(withIdentifier: "topVC")
        topTenVC.modalPresentationStyle = .fullScreen
        topTenVC.modalTransitionStyle = .crossDissolve
        
        self.dismiss(animated: true) {
            self.present(topTenVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPlayPress() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = main.instantiateViewController(withIdentifier: "gameVC")
        secondVC.modalPresentationStyle = .fullScreen
        secondVC.modalTransitionStyle = .crossDissolve
        
        self.dismiss(animated: true) {
            self.present(secondVC, animated: true, completion: nil)
        }
    }
}
