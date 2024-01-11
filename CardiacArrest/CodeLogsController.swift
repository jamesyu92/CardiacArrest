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
        
        cell.timeLabel.text = codeLogs[rowNumber][0]
        cell.actionLabel.text = codeLogs[rowNumber][1]
        cell.actionNumber.text = "#" + codeLogs[rowNumber][2]
        
        // Empty action number indicates START or ROSC
        if cell.actionNumber.text == "#" {
            cell.actionLabel.textAlignment = .left
            cell.actionNumber.text = ""
        } else {
            cell.actionLabel.textAlignment = .right
            cell.actionNumber.textAlignment = .left
        }
        
        // Update Text Colors based on action
        cell.actionLabel.textColor =
            switch codeLogs[rowNumber][3] {
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
            // The following will not be triggered
            default:
                UIColor.black
            }
        
        return cell
    }
}
