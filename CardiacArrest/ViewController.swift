//
//  ViewController.swift
//  CardiacArrest
//
//  Created by James on 1/9/24.
//

import UIKit

class ViewController: UIViewController {

    var scrollView: UIScrollView!
    var image: UIImageView!
    
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
        
        // Define the image
        image = UIImageView(image: UIImage(named: "CardiacArrest.jpg"))
        image.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        image.contentMode = .scaleAspectFit
        
        // Set the scrollView's frame to be the size of the screen
        // Height: Starting y-value of Bottom Stack - Ending y-value of Top Stack - 20.0 (Two times the 10.0 margin)
        var scrollViewHeight = Bottom_Stack.frame.minY - CPR_EPI_SHOCK_Stack.frame.maxY - 20.0
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: CPR_EPI_SHOCK_Stack.frame.maxY, width: view.frame.width, height: scrollViewHeight))
        
        // Set the contentSize to 2 times the height of the phone screen
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: image.frame.height)
        
        view.addSubview(scrollView)
        scrollView.addSubview(image)
        
        // Scroll View Background Color
        scrollView.backgroundColor = UIColor.black
    }


}

