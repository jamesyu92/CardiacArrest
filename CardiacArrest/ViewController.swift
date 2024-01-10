//
//  ViewController.swift
//  CardiacArrest
//
//  Created by James on 1/9/24.
//

import UIKit

class ViewController: UIViewController {

    var scrollView: UIScrollView!
    var flowchartImage: UIImageView!
    var reversibleImage: UIImageView!
    
    var CPR_Count: Int = 0
    var EPI_Count: Int = 0
    var SHOCK_Count: Int = 0
    
    var codeActive: Bool = false
    var soundOn: Bool = true
    
    var CPR_Timer = Timer()
    var CPR_Time_Passed: Double = 0.0
    var EPI_Timer = Timer()
    var EPI_Time_Passed: Double = 0.0
    
    @IBOutlet weak var CPR_Label: UILabel!
    @IBOutlet weak var EPI_Label: UILabel!
    @IBOutlet weak var LOG_Button: UIButton!
    
    @IBOutlet weak var CPR_Button: UIButton!
    @IBOutlet weak var EPI_Button: UIButton!
    @IBOutlet weak var SHOCK_Button: UIButton!
    
    @IBOutlet weak var CPR_EPI_SHOCK_Stack: UIStackView!
    
    @IBOutlet weak var Sound_Button: UIButton!
    @IBOutlet weak var Total_Time_Label: UILabel!
    @IBOutlet weak var Start_End_Button: UIButton!
    
    @IBOutlet weak var Bottom_Stack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Cosmetic Updates
        CPR_Label.layer.cornerRadius = 5
        CPR_Label.layer.borderWidth = 1.0
        CPR_Label.layer.borderColor = UIColor.black.cgColor
        
        EPI_Label.layer.cornerRadius = 5
        EPI_Label.layer.borderWidth = 1.0
        EPI_Label.layer.borderColor = UIColor.black.cgColor
        
        LOG_Button.layer.cornerRadius = 5
        LOG_Button.layer.borderWidth = 1.0
        LOG_Button.layer.borderColor = UIColor.black.cgColor
        
        CPR_Button.layer.cornerRadius = 5
        EPI_Button.layer.cornerRadius = 5
        SHOCK_Button.layer.cornerRadius = 5
        
        Total_Time_Label.layer.cornerRadius = 5
        Total_Time_Label.layer.borderWidth = 1.0
        Total_Time_Label.layer.borderColor = UIColor.black.cgColor
        
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
    
    @IBAction func CPR_Pressed(_ sender: UIButton) {
        // Press the START button for the user if code has not started
        if !codeActive {
            Start_End_Button.sendActions(for: .touchUpInside)
        }
        
        // Reset the CPR Timer
        CPR_Timer.invalidate()
        CPR_Time_Passed = 0.0
        CPR_Label.text = "0:00"
        
        CPR_Timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(updateCPRTimer), userInfo:nil, repeats: true)
        
        CPR_Count += 1
        CPR_Button.setTitle("CPR \(CPR_Count)", for: .normal)
    }
    
    @objc func updateCPRTimer() {
        CPR_Time_Passed += 1.0
        CPR_Label.text = convertToText(CPR_Time_Passed)
    }
    
    @IBAction func EPI_Pressed(_ sender: UIButton) {
        // Press the START button for the user if code has not started
        if !codeActive {
            Start_End_Button.sendActions(for: .touchUpInside)
        }
        
        EPI_Count += 1
        EPI_Button.setTitle("EPI \(EPI_Count)", for: .normal)
    }
    
    @IBAction func SHOCK_Pressed(_ sender: UIButton) {
        // Press the START button for the user if code has not started
        if !codeActive {
            Start_End_Button.sendActions(for: .touchUpInside)
        }
        
        SHOCK_Count += 1
        SHOCK_Button.setTitle("⚡ \(SHOCK_Count)", for: .normal)
    }
    
    @IBAction func Start_ROSC_Pressed(_ sender: UIButton) {
        
        // Start the coding process
        if !codeActive {
            Start_End_Button.backgroundColor = UIColor.systemIndigo
            Start_End_Button.setTitle("ROSC", for: .normal)
            
            codeActive = true
        }
        // Reset the CPR, EPI, Shock, and time
        else {
            CPR_Label.text = "0:00"
            CPR_Count = 0
            CPR_Button.setTitle("CPR 0", for: .normal)
            CPR_Button.backgroundColor = UIColor.systemIndigo
            
            EPI_Label.text = "0:00"
            EPI_Count = 0
            EPI_Button.setTitle("EPI 0", for: .normal)
            EPI_Button.backgroundColor = UIColor.systemIndigo
            
            SHOCK_Count = 0
            SHOCK_Button.setTitle("⚡ 0", for: .normal)
            SHOCK_Button.backgroundColor = UIColor.systemIndigo
            
            Total_Time_Label.text = "0:00"
            Start_End_Button.backgroundColor = UIColor.systemPink
            Start_End_Button.setTitle("START", for: .normal)
            
            codeActive = false
        }
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

