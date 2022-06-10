
import UIKit

class EnterSnacksViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var welcomeImage: UIImageView!
    
    //MARK: Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Enter Button Action
    @IBAction func enterApp() {
        guard let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "AddSnackEmployeeViewController") as? AddSnackEmployeeViewController else {
            return
        }
        
        self.navigationController?.pushViewController(vc1, animated: true)
        
    }
}
