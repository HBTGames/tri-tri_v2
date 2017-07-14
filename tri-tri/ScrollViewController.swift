//
//  ScrollViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-07-14.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    var imageArray = [UIImage]()
    var theme_height = CGFloat(0)
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        theme_height = self.view.frame.height/3.0
        imageArray = [#imageLiteral(resourceName: "day_mode_theme_menu_button"),#imageLiteral(resourceName: "night_mode_theme_menu_button"),#imageLiteral(resourceName: "BW_theme_menu_button"),#imageLiteral(resourceName: "school_mode_theme_menu_button"),#imageLiteral(resourceName: "colors_theme_menu_button")]
        
        for i in 0..<imageArray.count{
        let imageView = UIImageView()
        imageView.image = imageArray[i]
        let y_position = theme_height*CGFloat(i)
        imageView.frame = CGRect(x: 0, y: y_position, width: self.view.frame.width, height: theme_height)
        mainScrollView.contentSize.height = theme_height*CGFloat(i+1)
        mainScrollView.addSubview(imageView)
        
           
        // Do any additional setup after loading the view.
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
