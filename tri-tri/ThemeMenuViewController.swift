//
//  ThemeMenuViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-05-23.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class ThemeMenuViewController: UIViewController{

    @IBOutlet weak var day_theme: UIButton!
    @IBOutlet weak var day_theme_y_constraint: NSLayoutConstraint!

    @IBOutlet weak var night_theme: UIButton!
    @IBOutlet weak var night_theme_y_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var BW_theme: UIButton!
    @IBOutlet weak var BW_theme_y_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var Chaos_theme: UIButton!
    @IBOutlet weak var Chaos_theme_y_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var colors_theme: UIButton!
    @IBOutlet weak var school_theme: UIButton!
    
    
    var day_theme_origin = CGPoint(x: 0, y: 0)
    var night_theme_origin = CGPoint(x: 0, y: 0)
    var BW_theme_origin = CGPoint(x: 0, y: 0)
    var Chaos_theme_origin = CGPoint(x: 0, y: 0)
    var colors_theme_origin = CGPoint(x: 0, y: 0)
    var school_theme_origin = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        day_theme_origin = day_theme.frame.origin
        night_theme_origin = night_theme.frame.origin
        BW_theme_origin = BW_theme.frame.origin
        Chaos_theme_origin = Chaos_theme.frame.origin
        colors_theme_origin = colors_theme.frame.origin
        school_theme_origin = school_theme.frame.origin
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
     let transition0 = gesture.translation(in: day_theme)
        if(transition0.y < 40){
        day_theme.frame.origin = CGPoint(x: day_theme_origin.x, y: (day_theme_origin.y + transition0.y))
        //day_theme_y_constraint.constant = 8 + transition0.y
        night_theme.frame.origin = CGPoint(x: night_theme_origin.x, y: (night_theme_origin.y + transition0.y))
        //night_theme_y_constraint.constant = 8 + transition0.y
        BW_theme.frame.origin = CGPoint(x: BW_theme_origin.x, y: (BW_theme_origin.y + transition0.y))
        //BW_theme_y_constraint.constant = -52 + transition0.y
        Chaos_theme.frame.origin = CGPoint(x: Chaos_theme_origin.x, y: (Chaos_theme_origin.y + transition0.y))
        //Chaos_theme_y_constraint.constant = -52 + transition0.y
        school_theme.frame.origin = CGPoint(x: school_theme_origin.x, y: (school_theme_origin.y + transition0.y))
        colors_theme.frame.origin = CGPoint(x: colors_theme_origin.x, y: (colors_theme_origin.y + transition0.y))
        if(gesture.state == .ended){
           day_theme_origin.y = day_theme.frame.origin.y
           night_theme_origin.y = night_theme.frame.origin.y
           BW_theme_origin.y = BW_theme.frame.origin.y
           Chaos_theme_origin.y = Chaos_theme.frame.origin.y
          school_theme_origin.y = school_theme.frame.origin.y
          colors_theme_origin.y = colors_theme.frame.origin.y
        }
        }else{
            if(gesture.state == .ended){
                UIView.animate(withDuration: 0.5, animations: {
                 self.day_theme.frame.origin.y = self.day_theme_origin.y
                 self.night_theme.frame.origin.y = self.night_theme_origin.y
                 self.BW_theme.frame.origin.y = self.BW_theme_origin.y
                 self.Chaos_theme.frame.origin.y = self.Chaos_theme_origin.y
                 self.school_theme.frame.origin.y = self.school_theme_origin.y
                 self.colors_theme.frame.origin.y = self.colors_theme_origin.y
                 
                })
            }
        }
        
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
