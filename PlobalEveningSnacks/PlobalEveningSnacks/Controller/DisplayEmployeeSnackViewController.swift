
import UIKit

class DisplayEmployeeSnackViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var snackLabel1: UILabel!
    @IBOutlet weak var snackLabel2: UILabel!
    @IBOutlet weak var employeeSnackTV: UITableView!
    
    //MARK: Global Variables
    var snack1: String?
    var snack2: String?
//    var empNameArray: [String] = ["Prathamesh","Pratik"]
//    var empLastNameArray: [String] = ["Pawar","Khandelwal"]
    var employeeArray: [EmployeeModel] = []
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySnacks()
        
        employeeSnackTV.dataSource = self
        employeeSnackTV.delegate = self
        
        let CustomSnacksTableViewCellXib = UINib(nibName: "CustomSnacksTableViewCell", bundle: .main)
        self.employeeSnackTV.register(CustomSnacksTableViewCellXib, forCellReuseIdentifier: "CustomSnacksTableViewCell")
        
        self.employeeSnackTV.reloadData()

    }
    
    //MARK: Display Snacks
    private func displaySnacks() {
        snackLabel1.text = snack1
        snackLabel2.text = snack2
    }
    
}

    //MARK: UITableViewDataSource
extension DisplayEmployeeSnackViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CustomSnacksTableViewCell"
        guard let cell = self.employeeSnackTV.dequeueReusableCell(withIdentifier: cellIdentifier) as? CustomSnacksTableViewCell else {
            return UITableViewCell()
        }
        let employeeIndex = employeeArray[indexPath.row]
        cell.nameLabel.text = employeeIndex.empName
        cell.lastNameLabel.text = employeeIndex.empLastName
        
        return cell
    }
}

    //MARK: UITableViewDelegate
extension DisplayEmployeeSnackViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
}
