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
    
    var codeActive: Bool = false
    var soundOn: Bool = true
    
    var CPR_Timer = Timer()
    var EPI_Timer = Timer()
    var Total_Timer = Timer()
    
    var CPR_Time_Passed: Double = 0.0
    var EPI_Time_Passed: Double = 0.0
    var Total_Time_Passed: Double = 0.0
    
    @IBOutlet weak var CPR_Label: UILabel!
    @IBOutlet weak var EPI_Label: UILabel!
    @IBOutlet weak var LOG_Button: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Play an initil silence sound to get the app ready to play sound
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
        
        LOG_Button.layer.cornerRadius = 5
        LOG_Button.layer.borderWidth = 1.0
        LOG_Button.layer.borderColor = UIColor.black.cgColor
        
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
    }

    @IBAction func LOG_Pressed(_ sender: UIButton) {
    }
 
    @IBAction func topButtonsPressed(_ sender: UIButton) {
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
    }

    @objc func updateCPRTimer() {
        // 0: CPR
        timePassed[0] += 1.0
        CPR_Label.text = convertToText(timePassed[0])
        
        // Make the CPR shows red color + warning at the 2 minutes mark
        if round(timePassed[0]) == 12.0 {
            CPR_Label.textColor = UIColor.systemRed
            CPR_Label.layer.borderColor = UIColor.systemRed.cgColor
            
            if soundOn {
                soundBrain.playSound(soundTitle: "CPR")
            }
        }
    }
        
    @objc func updateEPITimer() {
        // 1: EPI
        timePassed[1] += 1.0
        EPI_Label.text = convertToText(timePassed[1])
        
        let tempEPITime = round(timePassed[1])
        
        // Warnings at 3 min, 4 min, and 5 min mark
        if tempEPITime == 18.0 {
            EPI_Label.textColor = UIColor.systemGreen
            EPI_Label.layer.borderColor = UIColor.systemGreen.cgColor
            
            if soundOn {
                soundBrain.playSound(soundTitle: "EPI3")
            }
        } else if tempEPITime == 24.0 {
            EPI_Label.textColor = UIColor.systemOrange
            EPI_Label.layer.borderColor = UIColor.systemOrange.cgColor
            
            if soundOn {
                soundBrain.playSound(soundTitle: "EPI4")
            }
        } else if tempEPITime == 30.0 {
            EPI_Label.textColor = UIColor.systemRed
            EPI_Label.layer.borderColor = UIColor.systemRed.cgColor
            
            if soundOn {
                soundBrain.playSound(soundTitle: "EPI5")
            }
        }
    }
    
    @IBAction func Start_ROSC_Pressed(_ sender: UIButton) {
        
        // Start the coding process
        if !codeActive {
            // 2: Total Timer
            timePassed[2] = 0.0
            allTimeLabels[2].text = "0:00"
            
            Total_Timer.invalidate()
            Total_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTotalTimer), userInfo:nil, repeats: true)
            
            Start_End_Button.backgroundColor = UIColor.systemIndigo
            Start_End_Button.setTitle("ROSC", for: .normal)
            
            codeActive = true
        }
        // Reset the CPR, EPI, Shock, and time
        else {
            for i in 0...2 {
                // Reset times + timers
                allTimeLabels[i].text = "0:00"
                allTimeLabels[i].textColor = UIColor.black
                allTimeLabels[i].layer.borderColor = UIColor.black.cgColor
                timePassed[i] = 0.0
                
                // Reset counts + background color
                counts[i] = 0
                topButtons[i].setTitle(countLabels[i] + "0", for: .normal)
                topButtons[i].backgroundColor = UIColor.systemIndigo
            }
            
            Start_End_Button.backgroundColor = UIColor.systemPink
            Start_End_Button.setTitle("START", for: .normal)
            
            // Stop all timers
            CPR_Timer.invalidate()
            EPI_Timer.invalidate()
            Total_Timer.invalidate()
            
            codeActive = false
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
}

