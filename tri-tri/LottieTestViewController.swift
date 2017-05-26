//
//  LottieTestViewController.swift
//  tri-tri
//
//  Created by mac on 2017-05-26.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import Lottie


class LottieTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let animationView = LOTAnimationView(name: "servishero_loading") {
            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            animationView.center = self.view.center
            animationView.contentMode = .scaleAspectFill
            
            view.addSubview(animationView)
            
            animationView.play()
        }
        // Do any additional setup after loading the view.
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
