//
//  ViewController.swift
//  CardiacArrest
//
//  Created by James on 1/9/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var soundBrain = SoundBrain()
    
    @IBOutlet weak var appTitle: UINavigationItem!
    
    var scrollView: UIScrollView!
    var flowchartImage: UIImageView!
    var reversibleImage: UIImageView!
    
    var CPR_Count: Int = 0
    var EPI_Count: Int = 0
    var SHOCK_Count: Int = 0
    var LOG_Count: Int = 0
    
    var codeActive: Bool = false
    var soundOn: Bool = true
    
    var CPR_Timer = Timer()
    var EPI_Timer = Timer()
    var Total_Timer = Timer()
    
    var CPR_Time_Passed: Double = 0.0
    var EPI_Time_Passed: Double = 0.0
    var Total_Time_Passed: Double = 0.0
    
    @IBOutlet weak var LOG_Button: UIBarButtonItem!
    
    @IBOutlet weak var CPR_Label: UILabel!
    @IBOutlet weak var EPI_Label: UILabel!
    
    @IBOutlet weak var CPR_Button: UIButton!
    @IBOutlet weak var EPI_Button: UIButton!
    @IBOutlet weak var SHOCK_Button: UIButton!
    
    @IBOutlet weak var CPR_EPI_SHOCK_Stack: UIStackView!
    
    @IBOutlet weak var Sound_Button: UIButton!
    @IBOutlet weak var Total_Label: UILabel!
    @IBOutlet weak var Start_End_Button: UIButton!
    
    @IBOutlet weak var Bottom_Stack: UIStackView!
    
    var allTimeLabels: [UILabel]!
    var timePassed: [Double]!
    var topButtons: [UIButton]!
    var counts: [Int]!
    var countLabels: [String]! = ["CPR ","EPI ","⚡ "]
    var typeLabels: [String]! = ["CPR","EPI","SHOCK"]
    
    let dateFormatter = DateFormatter()
    
    // Code Logs: [Time Start/Elapsed, Action Description, Action #, Action Type]
    var codeLogs: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the app from going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Play an initil silence sound to get the app ready to play sound
        // The do block will enable the app to make sounds even when mute is turned on
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        soundBrain.playSound(soundTitle: "Silence")
        
        // Feed labels and buttons into the variables
        allTimeLabels = [CPR_Label, EPI_Label, Total_Label]
        timePassed = [CPR_Time_Passed, EPI_Time_Passed, Total_Time_Passed]
        topButtons = [CPR_Button, EPI_Button, SHOCK_Button]
        counts = [CPR_Count, EPI_Count, SHOCK_Count]
        
        // Cosmetic Updates        
        // 0: CPR | 1: EPI | 2: SHOCK
        for i in 0...2 {
            allTimeLabels[i].layer.cornerRadius = 5
            allTimeLabels[i].layer.borderWidth = 1.0
            allTimeLabels[i].layer.borderColor = UIColor.black.cgColor
            
            topButtons[i].layer.cornerRadius = 5
        }
        
        Sound_Button.layer.cornerRadius = 5
        Start_End_Button.layer.cornerRadius = 5
        
        // Set the scrollView's frame to be the size of the screen
        // Height: Starting y-value of Bottom Stack - Ending y-value of Top Stack - 20.0 (Two times the 10.0 margin)
        let scrollViewHeight = Bottom_Stack.frame.minY - CPR_EPI_SHOCK_Stack.frame.maxY - 20.0
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: CPR_EPI_SHOCK_Stack.frame.maxY, width: view.frame.width, height: scrollViewHeight))
        
        // Define the two images
        flowchartImage = UIImageView(image: UIImage(named: "CardiacArrest.jpg"))
        reversibleImage = UIImageView(image: UIImage(named: "ReversibleCauses.jpg"))
        
        // Determine scaled image height
        let scaledHeightFlowchart = flowchartImage.frame.height * scrollView.frame.width / flowchartImage.frame.width
        let scaledHeightReversible = reversibleImage.frame.height * scrollView.frame.width / reversibleImage.frame.width
        
        flowchartImage.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scaledHeightFlowchart)
        reversibleImage.frame = CGRect(x: 0, y: scaledHeightFlowchart, width: scrollView.frame.width, height: scaledHeightReversible)
        
        // Set the contentSize to the size of the scaled image
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: flowchartImage.frame.height + reversibleImage.frame.height)
        
        view.addSubview(scrollView)
        scrollView.addSubview(flowchartImage)
        scrollView.addSubview(reversibleImage)
        
        // Scroll View Background Color
        scrollView.backgroundColor = UIColor.white
        
        // Define Date Formatter
        dateFormatter.dateFormat = "HH:mm:ss"
    }

    //MARK: - Segue Preparations. There is only one in this app. "if" statement needs to be added in the future if a different segue is added in the future
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            let destinationVC = segue.destination as! CodeLogsController
            destinationVC.codeLogs = codeLogs
    }

    @IBAction func resetPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(
            title: "Are you sure you want to reset everything?"
        ,   message: ""
        ,   preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "Yes"
            ,   style: .destructive
            ,   handler: {action in
                self.resetScreen()
                self.codeLogs = []
                self.LOG_Count = 0
                self.LOG_Button.title = "LOG(0)"
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "No"
            ,   style: .default
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func topButtonsPressed(_ sender: UIButton) {
        LOG_Count += 1
        LOG_Button.title = "LOG\(LOG_Count)"
        
        // Press the START button for the user if code has not started
        if !codeActive {
            Start_End_Button.sendActions(for: .touchUpInside)
        }
        
        // Reset the timers when the CPR or the EPI button is pressed
        // 0: CPR | 1: EPI | 2: SHOCK
        if sender.tag != 2 {
            timePassed[sender.tag] = 0.0
            allTimeLabels[sender.tag].text = "0:00"
            allTimeLabels[sender.tag].textColor = UIColor.black
            allTimeLabels[sender.tag].layer.borderColor = UIColor.black.cgColor
            
            if sender.tag == 0 {
                CPR_Timer.invalidate()
                CPR_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCPRTimer), userInfo:nil, repeats: true)
            } else if sender.tag == 1 {
                EPI_Timer.invalidate()
                EPI_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEPITimer), userInfo:nil, repeats: true)
            }
        }
        
        // Update the CPR, EPI, and SHOCK counts
        counts[sender.tag] += 1
        topButtons[sender.tag].setTitle(countLabels[sender.tag] + "\(counts[sender.tag])", for: .normal)
        
        
        // Add a record in the Code Logs -> "Time Elapses","Action","#"
        codeLogs.append([allTimeLabels[2].text!,countLabels[sender.tag],"\(counts[sender.tag])",typeLabels[sender.tag]])
    }

    @objc func updateCPRTimer() {
        // 0: CPR
        timePassed[0] += 1.0
        CPR_Label.text = convertToText(timePassed[0])
        
        // Make the CPR shows red color + warning at the 2 minutes mark
        if round(timePassed[0]) == 120.0 {
            CPR_Label.textColor = UIColor.systemRed
            CPR_Label.layer.borderColor = UIColor.systemRed.cgColor
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {                    self.soundBrain.playSound(soundTitle: "CPR")
                }
            }
        }
    }
        
    @objc func updateEPITimer() {
        // 1: EPI
        timePassed[1] += 1.0
        EPI_Label.text = convertToText(timePassed[1])
        
        let tempEPITime = round(timePassed[1])
        
        // Warnings at 3 min, 4 min, and 5 min mark
        if tempEPITime == 180.0 {
            EPI_Label.textColor = UIColor.systemGreen
            EPI_Label.layer.borderColor = UIColor.systemGreen.cgColor
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.soundBrain.playSound(soundTitle: "EPI3")
                }
            }
        } else if tempEPITime == 240.0 {
            EPI_Label.textColor = UIColor.systemOrange
            EPI_Label.layer.borderColor = UIColor.systemOrange.cgColor
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.soundBrain.playSound(soundTitle: "EPI4")
                }
            }
        } else if tempEPITime == 300.0 {
            EPI_Label.textColor = UIColor.systemRed
            EPI_Label.layer.borderColor = UIColor.systemRed.cgColor
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.soundBrain.playSound(soundTitle: "EPI5")
                }
            }
        }
    }
    
    @IBAction func Start_ROSC_Pressed(_ sender: UIButton) {
        LOG_Count += 1
        LOG_Button.title = "LOG\(LOG_Count)"
        
        let formattedDate = dateFormatter.string(from: Date())

        // Start the coding process
        if !codeActive {
            // Add a record in the Code Logs
            codeLogs.append([formattedDate,"▶️ START","","START"])
            
            // 2: Total Timer
            timePassed[2] = 0.0
            allTimeLabels[2].text = "0:00"
            
            Total_Timer.invalidate()
            Total_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTotalTimer), userInfo:nil, repeats: true)
            
            Start_End_Button.backgroundColor = UIColor.systemGreen
            Start_End_Button.setTitle("ROSC", for: .normal)
            
            codeActive = true
        }
        // Reset the CPR, EPI, Shock, and time
        else {
            // Add a record in the Code Logs
            codeLogs.append([formattedDate,"⏸️ ROSC","","ROSC"])
            resetScreen()
        }
    }
    
    @objc func updateTotalTimer() {
        // 2: Total
        timePassed[2] += 1.0
        Total_Label.text = convertToText(timePassed[2])
    }
    
    @IBAction func SoundOnOffPressed(_ sender: UIButton) {
        if soundOn {
            Sound_Button.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            soundOn = false
        } else {
            Sound_Button.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
            soundOn = true
        }
    }
    
    func convertToText(_ time: Double) -> String {
        let time_min = Int(time / 60.0)
        let time_sec = time - Double(time_min) * 60.0
        
        // Show mm:ss if there for more than 10 seconds
        if Int(time_sec) <= 9 {
            return "\(time_min):0\(Int(time_sec))"
        } else {
            return "\(time_min):\(Int(time_sec))"
        }
    }
    
    func resetScreen () {
        for i in 0...2 {
            // Reset times + timers
            allTimeLabels[i].text = "0:00"
            allTimeLabels[i].textColor = UIColor.black
            allTimeLabels[i].layer.borderColor = UIColor.black.cgColor
            timePassed[i] = 0.0
            
            // Reset counts + background color
            counts[i] = 0
            topButtons[i].setTitle(countLabels[i] + "0", for: .normal)
        }
        
        Start_End_Button.backgroundColor = UIColor.systemRed
        Start_End_Button.setTitle("START", for: .normal)
        
        // Stop all timers
        CPR_Timer.invalidate()
        EPI_Timer.invalidate()
        Total_Timer.invalidate()
        
        codeActive = false
    }
}

