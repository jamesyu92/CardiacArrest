//
//  CodeLogsController.swift
//  CardiacArrest
//
//  Created by James on 1/10/24.
//

import UIKit

class CodeLogsController: UIViewController {
    
    
    var codeLogs: [[String]]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prepare Table View
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CodeLogsCell", bundle: nil), forCellReuseIdentifier: "codeLogsCell")
        
        self.tableView.backgroundColor = UIColor.white
    }
}

//MARK: - Table Cells
extension CodeLogsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codeLogs.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "codeLogsCell", for: indexPath) as! CodeLogsCell
        
        let rowNumber: Int = indexPath.row
        
        cell.currentTimeLabel.text = codeLogs[rowNumber][0]
        cell.timeLabel.text = codeLogs[rowNumber][1]
        cell.actionLabel.text = codeLogs[rowNumber][2]
        cell.actionNumber.text = codeLogs[rowNumber][3]
        
        // Color for empty rolls
        if codeLogs[rowNumber][4] == "EMPTY" {
            cell.backgroundColor = .darkGray
        }
        // Background coloring to make it easier for the user to look at the records
        else if rowNumber % 2 == 1 {
            cell.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.918, alpha: 1.0)
        }
        
        if rowNumber == 0 {
            // Helvetica-Bold for the Header
            cell.currentTimeLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
            cell.timeLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
            cell.actionLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
            cell.actionNumber.font = UIFont(name: "Helvetica-Bold", size: 18.0)
        }
        // Empty action number indicates START, ROSC, or DEATH
        else if cell.actionNumber.text == "" {
            cell.actionLabel.textAlignment = .left
            cell.actionNumber.isHidden = true
        } 
        // Following are default alignment -> additional code unnecessary
        /*else {
            cell.actionLabel.textAlignment = .right
            cell.actionNumber.textAlignment = .left
        }
         */
        
        // Update Text Colors based on action
        cell.actionLabel.textColor =
            switch codeLogs[rowNumber][4] {
            case "START":
                UIColor.systemRed
            case "ROSC":
                UIColor.systemGreen
            case "CPR":
                UIColor.systemTeal
            case "EPI":
                UIColor.systemBlue
            case "SHOCK":
                UIColor.systemIndigo
            // The following will be used for the header
            default:
                UIColor.black
            }
        
        return cell
    }
}
