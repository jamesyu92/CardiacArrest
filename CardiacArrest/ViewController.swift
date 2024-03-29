//
//  ViewController.swift
//  CardiacArrest
//
//  Created by James on 1/9/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // Store the code logs in case of crash
    let defaults = UserDefaults.standard
    let defaultKey: String = "codeLogsArray"
    
    var soundBrain = SoundBrain()
    
    @IBOutlet weak var appTitle: UINavigationItem!
    
    var scrollView: UIScrollView!
    var flowchartImage: UIImageView!
    var reversibleImage: UIImageView!
    
    // NOTE: SPECIAL LOGIC FOR CPR_Count!
    // This variable is used to track Pre-ER minutes performed, AND
    // used to track the # of CPR performed once the code has started
    
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
    
    @IBOutlet weak var Pre_CPR_Stack: UIStackView!
    @IBOutlet weak var CPR_Stack: UIStackView!
    
    @IBOutlet weak var Pre_CPR_Label: UILabel!
    @IBOutlet weak var CPR_Label: UILabel!
    @IBOutlet weak var EPI_Label: UILabel!
    
    @IBOutlet weak var Pre_CPR_1: UIButton!
    @IBOutlet weak var Pre_CPR_5: UIButton!
    
    @IBOutlet weak var CPR_Button: UIButton!
    @IBOutlet weak var EPI_Button: UIButton!
    @IBOutlet weak var SHOCK_Button: UIButton!
    
    @IBOutlet weak var CPR_EPI_SHOCK_Stack: UIStackView!
    
    @IBOutlet weak var Sound_Button: UIButton!
    @IBOutlet weak var Total_Label: UILabel!
    @IBOutlet weak var Start_End_Button: UIButton!
    @IBOutlet weak var Death_Button: UIButton!
    
    @IBOutlet weak var Bottom_Stack: UIStackView!
    
    var allTimeLabels: [UILabel]!
    var timePassed: [Double]!
    var topButtons: [UIButton]!
    var counts: [Int]!
    var countLabels: [String]! = ["CPR ","EPI ","⚡ "]
    var typeLabels: [String]! = ["CPR","EPI","SHOCK"]
    
    // Play a sound when CPR or EPI reach the following time
    // CPR: 2 minutes
    // EPI: 3, 4, and 5 minutes
    
    // let CPR_Warning: Double = 1.0
    let CPR_Warning: Double = 120.0
    
    // EPI_Warning: [Double] = [1.0, 2.0, 3.0]
    let EPI_Warning: [Double] = [180.0,240.0,300.0]
    
    let dateFormatter = DateFormatter()
    
    // Used in the Code Logs view
    var codeLogs: [[String]] = [["Time","Split","Action","",""]]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Set the scrollView's frame to be the size of the screen
        // scrollView's y-value: Top Safe Area + Height of Top Stack + Margins
        // scrollView's height: Safe Area Height - Top Stack - Bottom Stack
        
        let scrollView_y: Double = view.safeAreaLayoutGuide.layoutFrame.minY + CPR_EPI_SHOCK_Stack.frame.height + 20.0
        
        let scrollView_Height: Double = view.safeAreaLayoutGuide.layoutFrame.height - (CPR_EPI_SHOCK_Stack.frame.height + 20.0) - (Bottom_Stack.frame.height + 20.0)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: scrollView_y, width: view.frame.width, height: scrollView_Height))
        
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
    }
    
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
        
        // Grab the default for CodeLogs (If available)
        if let tempCodeLogs = defaults.array(forKey: defaultKey) as? [[String]] {
            codeLogs = tempCodeLogs
            
            // Derive and update the log count (Ignore "EMPTY" + "Header" rows)
            for i in 0..<codeLogs.count {
                if codeLogs[i][0] != "Time" && codeLogs[i][0] != "" {
                    LOG_Count += 1
                }
            }
            LOG_Button.title = "LOG(\(LOG_Count))"
        }
            
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
        
        // Cosmetic Updates for the Pre-ER CPR buttons
        Pre_CPR_Label.layer.cornerRadius = 5
        Pre_CPR_Label.layer.borderWidth = 1.0
        Pre_CPR_Label.layer.borderColor = UIColor.black.cgColor
        Pre_CPR_1.layer.cornerRadius = 5
        Pre_CPR_5.layer.cornerRadius = 5
        
        Sound_Button.layer.cornerRadius = 5
        Start_End_Button.layer.cornerRadius = 5
        
        // Hide the Death Button. This will be revealed when the app is started
        Death_Button.isHidden = true
        Death_Button.layer.cornerRadius = 5
        
        // Define Date Formatter
        dateFormatter.dateFormat = "HH:mm:ss"
    }
    
    //MARK: - Segue Preparations. There is only one in this app. "if" statement needs to be added in the future if a different segue is added in the future
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let destinationVC = segue.destination as! CodeLogsController
        destinationVC.codeLogs = codeLogs
    }

    @IBAction func resetPressed(_ sender: UIBarButtonItem) {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
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
                self.codeLogs = [["Time","Split","Action","#",""]]
                self.LOG_Count = 0
                self.LOG_Button.title = "LOG(0)"
                self.saveCodeLogs()
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
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Pre-ER logic
        if sender.tag == -1 || sender.tag == -5 {
            counts[0] -= sender.tag
            Pre_CPR_Label.text = "CPR: \(counts[0]) min"
        } else {
            // Update the CPR, EPI, and SHOCK counts
            counts[sender.tag] += 1
            topButtons[sender.tag].setTitle(countLabels[sender.tag] + "\(counts[sender.tag])", for: .normal)
        }
        
        // Timer logic unnecessary if the code is not active
        // Reset the timers when the CPR or the EPI button is pressed
        // 0: CPR | 1: EPI | 2: SHOCK
        if codeActive {
            LOG_Count += 1
            LOG_Button.title = "LOG(\(LOG_Count))"
            
            // formatedDate: Current time in HH:mm:ss (24 hour clock)
            let formattedDate = dateFormatter.string(from: Date())
            if sender.tag != 2 {
                timePassed[sender.tag] = 0.0
                allTimeLabels[sender.tag].text = "0:00"
                allTimeLabels[sender.tag].textColor = UIColor.black
                allTimeLabels[sender.tag].font = UIFont(name: "Helvetica", size: 18.0)
                allTimeLabels[sender.tag].layer.borderColor = UIColor.black.cgColor
                allTimeLabels[sender.tag].layer.borderWidth = 1.0
                
                if sender.tag == 0 {
                    CPR_Timer.invalidate()
                    CPR_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCPRTimer), userInfo:nil, repeats: true)
                } else if sender.tag == 1 {
                    EPI_Timer.invalidate()
                    EPI_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEPITimer), userInfo:nil, repeats: true)
                }
            }
            
            // Add a record in the Code Logs -> "Time","Time Elapses","Action","#","Action Type"
            codeLogs.append([formattedDate,allTimeLabels[2].text!,countLabels[sender.tag],"#\(counts[sender.tag])",typeLabels[sender.tag]])
            
            saveCodeLogs()
        }
    }

    @objc func updateCPRTimer() {
        // 0: CPR
        timePassed[0] += 1.0
        CPR_Label.text = convertToText(timePassed[0])
        
        // Make the CPR shows red color + warning at the 2 minutes mark
        if round(timePassed[0]) == CPR_Warning {
            CPR_Label.textColor = UIColor.systemRed
            CPR_Label.font = UIFont(name: "Helvetica-Bold", size: 18.0)
            CPR_Label.layer.borderColor = UIColor.systemRed.cgColor
            CPR_Label.layer.borderWidth = 2.0
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.soundBrain.playSound(soundTitle: "CPR")
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
        if tempEPITime == EPI_Warning[0] {
            EPI_Label.textColor = UIColor.systemGreen
            EPI_Label.font = UIFont(name: "Helvetica-Bold", size: 18.0)
            EPI_Label.layer.borderColor = UIColor.systemGreen.cgColor
            EPI_Label.layer.borderWidth = 2.0
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.soundBrain.playSound(soundTitle: "EPI3")
                }
            }
        } else if tempEPITime == EPI_Warning[1] {
            EPI_Label.textColor = UIColor.systemOrange
            EPI_Label.layer.borderColor = UIColor.systemOrange.cgColor
            
            if soundOn {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.soundBrain.playSound(soundTitle: "EPI4")
                }
            }
        } else if tempEPITime == EPI_Warning[2] {
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
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // formatedDate: Current time in HH:mm:ss (24 hour clock)
        let formattedDate = dateFormatter.string(from: Date())

        // Start the coding process
        if !codeActive {
            for i in 0...2 {
                // Capture Pre-Code Actions in the log
                // 0: CPR | 1: EPI | 2: SHOCK
                if counts[i] != 0 {
                    LOG_Count += 1
                    
                    // Special logic for CPR
                    if i == 0 {
                        codeLogs.append(["Pre-ER","",countLabels[0],"+\(counts[0]) min",typeLabels[0]])
                        
                        // Reset the CPR Count
                        counts[0] = 0
                    } else {
                        codeLogs.append(["Pre-ER","",countLabels[i],"x\(counts[i])",typeLabels[i]])
                    }
                }
                
                // Set all timers to 0:00
                timePassed[i] = 0.0
                allTimeLabels[i].text = "0:00"
            }
            
            // Add a record in the Code Logs
            codeLogs.append([formattedDate,allTimeLabels[2].text!,"▶️ START","","START"])
            saveCodeLogs()
            
            // Hide the Pre-CPR Stack. Unhide the CPR-Stack
            Pre_CPR_Stack.isHidden = true
            CPR_Stack.isHidden = false
            
            Total_Timer.invalidate()
            Total_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTotalTimer), userInfo:nil, repeats: true)
            
            Start_End_Button.backgroundColor = UIColor.systemGreen
            Start_End_Button.setTitle("ROSC", for: .normal)
            
            codeActive = true
            
            // Unhide the DEATH button
            Death_Button.isHidden = false
        }
        // Reset the CPR, EPI, Shock, and time
        else {
            // RSOC button pressed
            if sender.tag == 0 {
                codeLogs.append([formattedDate,allTimeLabels[2].text!,"🎉 ROSC","","ROSC"])
            }
            // DEATH button pressed
            else {
                codeLogs.append([formattedDate,allTimeLabels[2].text!,"☠️ DEATH","","DEATH"])
            }
            
            // Include two empty rows to separate records
            codeLogs.append(["","","","","EMPTY"])
            codeLogs.append(["","","","","EMPTY"])
            
            saveCodeLogs()
            resetScreen()
        }
        
        // Update LOG Count
        LOG_Count += 1
        LOG_Button.title = "LOG(\(LOG_Count))"
    }
    
    @objc func updateTotalTimer() {
        // 2: Total
        timePassed[2] += 1.0
        Total_Label.text = convertToText(timePassed[2])
    }
    
    @IBAction func SoundOnOffPressed(_ sender: UIButton) {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if soundOn {
            Sound_Button.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            Sound_Button.backgroundColor = UIColor.lightGray
            soundOn = false
        } else {
            Sound_Button.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
            Sound_Button.backgroundColor = UIColor.darkGray
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
        // Consider consolidating the following snippet of code with the "topButtonsPressed" function
        for i in 0...2 {
            // Reset times + timers
            allTimeLabels[i].text = "0:00"
            allTimeLabels[i].textColor = UIColor.black
            allTimeLabels[i].font = UIFont(name: "Helvetica", size: 18.0)
            allTimeLabels[i].layer.borderColor = UIColor.black.cgColor
            allTimeLabels[i].layer.borderWidth = 1.0
            timePassed[i] = 0.0
            
            // Reset counts + background color
            counts[i] = 0
            topButtons[i].setTitle(countLabels[i] + "0", for: .normal)
        }
        
        // Show "Pre-ER" Mode
        Pre_CPR_Stack.isHidden = false
        CPR_Stack.isHidden = true
        
        Pre_CPR_Label.text = "CPR: 0 min"
        EPI_Label.text = "Pre-ER!!!"
        
        Start_End_Button.backgroundColor = UIColor.systemRed
        Start_End_Button.setTitle("START", for: .normal)
        
        Death_Button.isHidden = true
        
        // Stop all timers
        CPR_Timer.invalidate()
        EPI_Timer.invalidate()
        Total_Timer.invalidate()
        
        codeActive = false
    }
    
    // Save the code logs into Default
    func saveCodeLogs () {
        defaults.set(codeLogs, forKey: defaultKey)
    }
}

