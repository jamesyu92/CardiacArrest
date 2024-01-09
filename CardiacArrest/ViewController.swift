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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the scrollView's frame to be the size of the screen
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
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

