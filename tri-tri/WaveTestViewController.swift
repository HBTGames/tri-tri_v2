//
//  WaveTestViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-07-08.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit




class WaveTestViewController: UIViewController {
   var screen_width = CGFloat(0)
   var screen_height = CGFloat(0)
    
    var wave_indicator = waveAnimator(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    //var progress = Double(1)
    var timer = Timer()
    override func viewDidLoad() {
        screen_width = self.view.frame.width
        screen_height = self.view.frame.height
                // Do any additional setup after loading the view.
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var test_image: UIImageView!
    @IBAction func explode_action(_ sender: UIButton) {
        //Explodable:
        test_image.explode(.chaos, duration: 2)
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
