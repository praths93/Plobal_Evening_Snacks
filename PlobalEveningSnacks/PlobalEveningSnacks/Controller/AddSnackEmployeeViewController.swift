
import UIKit
import SQLite3

class AddSnackEmployeeViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var snack1: UITextField!
    @IBOutlet weak var snack2: UITextField!
    
    //MARK: Global Variables
    var dbDetailsObject: OpaquePointer?
    let tableNameEmployee = "Employees"
    let databaseName = "employeeSnacks.sqlite" //Step 3 - create Database Name
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openCreateDatabase()
    }
    
    //MARK: Add Employee Detail Button
    @IBAction func addEmployeeDetail() {
        guard let vcEmployee = self.storyboard?.instantiateViewController(withIdentifier: "EmployeeDetailViewController") as? EmployeeDetailViewController else {
            return
        }
        self.navigationController?.pushViewController(vcEmployee, animated: true)
    }
    
    //MARK: Employee List Button
    @IBAction func employeeList() {
        guard let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "DisplayEmployeeSnackViewController") as? DisplayEmployeeSnackViewController else {
            return
        }
        vc2.snack1 = snack1.text!
        vc2.snack2 = snack2.text!
        vc2.employeeArray = readData()
        
        self.navigationController?.pushViewController(vc2, animated: true)
    }
    
    //MARK: Step 5 - Read Data
    private func readData() -> [EmployeeModel] {
        var readStatement: OpaquePointer?
        let readQuery = "SELECT * FROM \(tableNameEmployee)"
        
        var employees = [EmployeeModel]()
        
       if sqlite3_prepare_v2(self.dbDetailsObject,
                           readQuery,
                           -1,
                           &readStatement,
                           nil) == SQLITE_OK {
            print("Read Query Compiled Successfully")
            while sqlite3_step(readStatement) == SQLITE_ROW {
                // (ID INTEGER PRIMARY KEY, Name TEXT, PhoneNumber TEXT, Age INTEGER)
               print("Read Query executed successfully")
                let idInt32 = sqlite3_column_int(readStatement, 0)
                let id = Int(idInt32)
           guard
                let nameCStr = sqlite3_column_text(readStatement, 1),
                let lastNameCStr = sqlite3_column_text(readStatement, 2),
                let teamCStr = sqlite3_column_text(readStatement, 3)
                else {
                    return [EmployeeModel]()
                }
                let name = String(cString: nameCStr)
                let lastName = String(cString: lastNameCStr)
                let team = String(cString: teamCStr)
                
                print("Employee Details:\nId: \(id),\nName:\(name),\nLast Name: \(lastName),\nTeam: \(team)")
                
                let employee = EmployeeModel(empId: id, empName: name, empLastName: lastName, empTeam: team)
                employees.append(employee)
                
//            } else {
//                print("Read Query NOT executed")
            }
           return employees
       } else {
           print("Read Query Compilation Failed")
           return [EmployeeModel]()
       }
    }
    
    //MARK: Step 2 - Create DataBase
   private func openCreateDatabase() {
        guard let dbPath = getPathForDocumentsDirectory() else{
            print("Documents Directory Path is Missing")
            return
        }
        print("DB Path: \(dbPath)")
       
       //Step2.1 - Importing SQLite3 and To check Database is Created or already present (employeeSnacks.sqlite)
       var dbdetails: OpaquePointer?

       if sqlite3_open(dbPath,
                       &dbdetails) == SQLITE_OK { /* Sqlite Ok used to check the query condition*/
           print("Database is successfully created Or Already Present & we are able to access it/Open it")
           self.dbDetailsObject = dbdetails
       } else {
           print("Unable to Create Or Open DB")

       }
    }
    
    //MARK: Step 1 - To Get Path For Documents Directory
    private func getPathForDocumentsDirectory() -> String? {
    
        do {
            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory,
                                                               in: .userDomainMask,
                                                               appropriateFor: nil,
                                                               create: false)
            let dbPath = documentDirectoryURL.appendingPathComponent(self.databaseName)
            return dbPath.absoluteString
        } catch {
            print(error.localizedDescription)
            return nil
        }

    }

}

