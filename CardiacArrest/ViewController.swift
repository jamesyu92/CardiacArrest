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
        
        // Set the scrollView's frame to be the size of the screen
        scrollView = UIScrollView(frame: CGRect(x: 0, y: CPR_EPI_SHOCK_Stack.frame.maxY, width: view.frame.width, height: view.frame.height))
        
        // Set the contentSize to 2 times the height of the phone screen
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: UIScreen.main.bounds.height*1.5)
        
        view.addSubview(scrollView)
        
        // Add the image
        image = UIImageView(image: UIImage(named: "CardiacArrest.jpg"))
        image.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        image.contentMode = .scaleAspectFit
        scrollView.addSubview(image)
    }


}

