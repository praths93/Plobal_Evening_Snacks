
import UIKit
import SQLite3

class EmployeeDetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var employeeIdTF: UITextField!
    @IBOutlet weak var employeeNameTF: UITextField!
    @IBOutlet weak var employeeLastNameTF: UITextField!
    @IBOutlet weak var teamTF: UITextField!
    
    //MARK: Global Variables
    var teams: [String] = []
    var pickerView = UIPickerView()
    let databaseName = "employeeSnacks.sqlite"
    var dbDetailsObject: OpaquePointer?
    let tableNameEmployee = "Employees"
    var employees = [EmployeeModel]()
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self
        teams = fetchPickerData()
        teamTF.inputView = pickerView
        createToolbar()
        openCreateDatabase() // To call this Function
        createEmployeeTableDB() // To call this Function
        
        for employee in self.employees {
            insertDataInTable(employee: employee)
        }
        
    }
    
    //MARK: DATA IN PICKER-VIEW
    func fetchPickerData() -> [String]{
        let teamlist = ["Design","Support_LAUCH","Support_LIVE","Quality","Dev_IOS","Dev_ANDRIOD","WEB/SERVER","Mobile","Launch_Manager","CSM"]
        var teamsArray  = [String]()
        for i in teamlist {
            //            teamsArray.append("\(i)")
            let teamString = String(i)
            teamsArray.append(teamString)
        }
        return teamsArray
    }
    
    //MARK: "DONE BUTTON" ON PICKER-VIEW
    func createToolbar() // Creating Done Button on Picker View
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EmployeeDetailViewController.closePickerView))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        teamTF.inputAccessoryView = toolbar
    }
    @objc func closePickerView()
    {
        view.endEditing(true)
    }
    
    // MARK: Save Employee Detail Button
    @IBAction func saveEmployeeDetailButtonAction() {
        //ID INTEGER PRIMARY KEY, Name TEXT, PhoneNumber TEXT, Age INTEGER
        let employeeId = Int(employeeIdTF.text ?? "") ?? 0
        let employeeName = employeeNameTF.text ?? ""
        let employeeLastName = employeeLastNameTF.text ?? ""
        let team = teamTF.text ?? ""
        let employeeDataObject = EmployeeModel(empId: employeeId, empName: employeeName, empLastName: employeeLastName, empTeam: team)
        
        insertDataInTable(employee: employeeDataObject)
        
        if (employeeDataObject.empId == 0) ||
            (employeeDataObject.empName.count == 0) ||
            (employeeDataObject.empLastName.count == 0) ||
            (employeeDataObject.empTeam.count == 0) {
            absentfailAlert()
        } else {
            presentSuccessAlert()
        }
        //yourTextFieldOutlet.text = ""  To Clear Text (Func created -> clearText)
        clearText()
    }
}

//MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension EmployeeDetailViewController: UIPickerViewDataSource , UIPickerViewDelegate {
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        1
    }
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        teams.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        teams[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        teamTF.text = teams[row]
        //teamTF.resignFirstResponder() --> for Direct CutOff without Done Button
    }
    
}
extension EmployeeDetailViewController {
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
    
    //MARK: Step 3 - Create Employees Table in Database
    private func createEmployeeTableDB() {
        var opaquePointerObject_CreateTable: OpaquePointer?
        
        
        let createTableQuery = "CREATE TABLE \(tableNameEmployee)(ID INTEGER PRIMARY KEY, Name TEXT, LastName TEXT, Team TEXT)"
        
        //Step-3.1 -> Preparing a Query -> we need query because sqlite understands a query language to communicate.
        // * Query has fixed Syntax
        if sqlite3_prepare_v2(self.dbDetailsObject,
                               createTableQuery,
                               -1,
                               &opaquePointerObject_CreateTable,
                               nil) == SQLITE_OK { /* Sqlite Ok used to check the query condition*/
        print("Query Prepared Successful")
            
            //Step-3.2 -> Execute Query -> If Successful
            
           if sqlite3_step(opaquePointerObject_CreateTable) == SQLITE_DONE { /* Sqlite Done used to execute an action  i.e To create Table */
                print("Table Employee Created Successfully")
            } else {
                print("Table Employee Not Created")
            }
            
       } else {
           print("Query Not Prepared. Some issue in Create Table Query. No proper Query Or Table Already Exists")
       }
    }
    
    //MARK: Step 4 - To Insert Data in Table
    private func insertDataInTable(employee: EmployeeModel) {
        var OpaquePointerInsertData: OpaquePointer?
        
        //(ID INTEGER, Name TEXT, PhoneNumber TEXT, Age INTEGER)
        let insertQuery = "INSERT INTO \(tableNameEmployee) VALUES(?,?,?,?)"
        // Prepare
       if sqlite3_prepare_v2(self.dbDetailsObject,
                           insertQuery,
                           -1,
                           &OpaquePointerInsertData,
                           nil) == SQLITE_OK {/* Sqlite Ok used to check the query condition*/
           // Conversions
           let id = Int32(employee.empId)
           let name = (employee.empName as NSString).utf8String
           let lastName = (employee.empLastName as NSString).utf8String
           let team = (employee.empTeam as NSString).utf8String

           //Binding
           sqlite3_bind_int(OpaquePointerInsertData, 1, id) // Id
           sqlite3_bind_text(OpaquePointerInsertData,
                             2,
                             name,
                             -1,
                             nil) // Name
           sqlite3_bind_text(OpaquePointerInsertData,
                             3,
                             lastName,
                             -1,
                             nil) // Last Name
           sqlite3_bind_text(OpaquePointerInsertData,
                             4,
                             team,
                             -1,
                             nil) // Team
           // step
           if sqlite3_step(OpaquePointerInsertData) == SQLITE_DONE { /* Sqlite Done used to execute an action  i.e To Inserting Data */
               print("Data Inserted Successfully")
           } else {
               print("Insert data Failed")
           }
           
       } else {
           print("Insert Query not Prepared")
       }
  
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
            }
//            } else {
//                print("Read Query NOT executed")
//            }
           return employees
       } else {
           print("Read Query Compilation Failed")
           return [EmployeeModel]()
       }
    }
    
    // MARK: Success Alert
    private func presentSuccessAlert() {
        // Create new Alert
        let dialogMessage = UIAlertController(title: "DATA ADDED", message: "Employee Details Added Successfully?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)

        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }
    // MARK: Failure Alert
    private func absentfailAlert() {
        // Create new Alert
        let dialogMessage = UIAlertController(title: "DATA Incomplete", message: "Employee Details Not Added", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)

        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    // MARK: Clear Text Function
    private func clearText() {
        
        employeeIdTF.text = ""
        employeeNameTF.text = ""
        employeeLastNameTF.text = ""
        teamTF.text = ""
        
    }
}
