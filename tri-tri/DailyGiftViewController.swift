//
//  DailyGiftViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-06-29.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class DailyGiftViewController: UIViewController {
//screen width and height
    var screen_width : CGFloat = 0
    var screen_height : CGFloat = 0
    
    @IBOutlet weak var wheel_text: UIImageView!

    @IBOutlet weak var wheel_pointer: UIImageView!
    
    @IBOutlet weak var wheel_outer: UIImageView!
    @IBOutlet weak var wheel: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        screen_width = self.view.frame.width
        screen_height = self.view.frame.height
        view.backgroundColor = UIColor(patternImage: UIImage(named: "wheel_background.png")!)
        let cancel_button = MyButton(frame: CGRect(x: screen_x_transform(250), y: screen_y_transform(542), width: screen_x_transform(125), height: screen_y_transform(125)))
        cancel_button.setImage(UIImage(named: "wheel_cancel"), for: .normal)
        self.view.addSubview(cancel_button)
        // Do any additional setup after loading the view.
        cancel_button.whenButtonIsClicked(action: {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            nextViewController.modalTransitionStyle = .crossDissolve
            self.present(nextViewController, animated: true, completion: nil)
            
        })
        wheel_text.frame = self.view.frame
        wheel_text.image = UIImage(named: "wheel_text")
        wheel.frame = CGRect(x: screen_x_transform(Double(wheel.frame.origin.x)), y: screen_y_transform(Double(wheel.frame.origin.y)), width: screen_x_transform(Double(wheel.frame.width)), height: screen_y_transform(Double(wheel.frame.height)))
        wheel.image = UIImage(named: "wheel")
        wheel_outer.frame = self.view.frame
        wheel_outer.image = #imageLiteral(resourceName: "wheel_outer")
        wheel_pointer.frame = CGRect(x: screen_x_transform(Double(wheel_pointer.frame.origin.x)), y: screen_y_transform(Double(wheel_pointer.frame.origin.y)), width: screen_x_transform(Double(wheel_pointer.frame.width)), height: screen_y_transform(Double(wheel_pointer.frame.height)))
        wheel_pointer.image = #imageLiteral(resourceName: "wheel_pointer")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //modify position according to iphone generation functions
    func screen_x_transform(_ x: Double) -> CGFloat {
        let const = x/Double(375)
        let new_x = Double(screen_width)*const
        return CGFloat(new_x)
        
    }
    func screen_y_transform(_ y: Double) -> CGFloat {
        let const = y/Double(667)
        let new_y = Double(screen_height)*const
        return CGFloat(new_y)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    class MyButton: UIButton {
        var action: (()->())?
        
        func whenButtonIsClicked(action: @escaping ()->()) {
            self.action = action
            self.addTarget(self, action: #selector(MyButton.clicked), for: .touchUpInside)
        }
        
        
        func clicked() {
            action?()
        }
    }

    @IBAction func wheel_spin(_ sender: UIButton) {
        UIView.animate(withDuration: 2, animations: {
           self.wheel.transform = CGAffineTransform(rotationAngle: CGFloat(MH_PIE))
            
        })
    }

}
