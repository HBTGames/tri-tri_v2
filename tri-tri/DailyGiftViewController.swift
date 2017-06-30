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
    var real_velocity = Double(0)
    var display_reward : Bool = false
    var defaults = UserDefaults.standard
    var star_score = 0
    var gesture_passing_area = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
    //left up: 0 right up: 1 right down: 2 left down: 3 unknown: -1
    
    @IBOutlet weak var wheel_background: UIImageView!
    @IBOutlet weak var wheel_text: UIImageView!

    @IBOutlet weak var wheel_pointer: UIImageView!
    
    @IBOutlet weak var wheel_outer: UIImageView!
    @IBOutlet weak var wheel: UIImageView!
    
    var final_translation = CGPoint(x: 0, y: 0)
    var spin_initial_point = CGPoint(x: 0, y: 0)
    
    var current_passing_area = 0
    var current_passing_array_index = 0
    
    //rotation_direction == 0 (clockwise)
    //rotation_direction == 1 (counterclockwise)
    var rotation_direction = 0
    
    //override touch begin function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        spin_initial_point = touches.first!.location(in: view)
        print("initial touch location is x: \(spin_initial_point.x), y: \(spin_initial_point.y)")
        current_passing_array_index = 0
        if((spin_initial_point.x - wheel.frame.origin.x) < wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y < wheel.frame.height/2 ){
            current_passing_area = 0
            gesture_passing_area[0] = 0
        }
            
            //current position in right uper boundary
        else if((spin_initial_point.x - wheel.frame.origin.x) > wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y < wheel.frame.height/2 ){
             current_passing_area = 1
            gesture_passing_area[0] = 1
        }
            //current postion in right downer boundary
        else if((spin_initial_point.x - wheel.frame.origin.x) > wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y > wheel.frame.height/2 ){
             current_passing_area = 2
            gesture_passing_area[0] = 2
        }
            //current position in left downer
        else if((spin_initial_point.x - wheel.frame.origin.x) < wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y > wheel.frame.height/2 ){
             current_passing_area = 3
            gesture_passing_area[0] = 3
        }

        
     }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display_reward = false
        screen_width = self.view.frame.width
        screen_height = self.view.frame.height
        wheel_background.frame = self.view.frame
        wheel_background.image = #imageLiteral(resourceName: "wheel_background")
        wheel_background.contentMode = .scaleAspectFill
         star_score = defaults.value(forKey: "tritri_star_score") as! NSInteger
        //view.backgroundColor = UIColor(patternImage: UIImage(named: "wheel_background.png")!)
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
        //add pan gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
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

    
    
    //pan gesture recognizer
    func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
        if(wheel.frame.contains(spin_initial_point) && !display_reward){
        let velocity = gesture.velocity(in: view)
        //print("velocity x: \(velocity.x), velocity y: \(velocity.y)")
        if(velocity.x != 0 || velocity.y != 0){
        real_velocity = Double(velocity.x*velocity.x + velocity.y*velocity.y)
        real_velocity = sqrt(real_velocity)
        //print("real_velocity is : \(real_velocity)")
        }
        let translation = gesture.translation(in: view)
        let current_position = CGPoint(x: spin_initial_point.x+translation.x, y: spin_initial_point.y+translation.y)
        //record passing area
        //current position in left upper boundary
            if((current_position.x - wheel.frame.origin.x) < wheel.frame.width/2 && current_position.y - wheel.frame.origin.y < wheel.frame.height/2 ){
                if(current_passing_area != 0){
                    current_passing_array_index += 1
                    current_passing_area = 0
                    gesture_passing_area[current_passing_array_index] = 0
                }
            }
                
                //current position in right uper boundary
            else if((current_position.x - wheel.frame.origin.x) > wheel.frame.width/2 && current_position.y - wheel.frame.origin.y < wheel.frame.height/2 ){
                if(current_passing_area != 1){
                    current_passing_array_index += 1
                    current_passing_area = 1
                    gesture_passing_area[current_passing_array_index] = 1
                }
            }
                //current postion in right downer boundary
            else if((current_position.x - wheel.frame.origin.x) > wheel.frame.width/2 && current_position.y - wheel.frame.origin.y > wheel.frame.height/2 ){
                if(current_passing_area != 2){
                    current_passing_array_index += 1
                    current_passing_area = 2
                    gesture_passing_area[current_passing_array_index] = 2
                }
            }
                //current position in left downer
            else if((current_position.x - wheel.frame.origin.x) < wheel.frame.width/2 && current_position.y - wheel.frame.origin.y > wheel.frame.height/2 ){
                if(current_passing_area != 3){
                    current_passing_array_index += 1
                    current_passing_area = 3
                    gesture_passing_area[current_passing_array_index] = 3
                }
            }
     
        final_translation = translation
        if(gesture.state == .ended){
            var i = 0
            while(gesture_passing_area[i] != -1){
                print("gesture passing at index \(i) is \(gesture_passing_area[i])")
                i += 1
            }
            let direction = determine_rotation_direction()
            print("final translation: x: \(final_translation.x) y: \(final_translation.y)")
            if(direction != -1){
                rotation_direction = direction
                spin_wheel()
            }
            //print("\(translation.x)")
            //print("\(translation.y)")
        }
        
        }
    }
    
    
    func spin_wheel () -> Void {
        var final_angle = Int(arc4random_uniform(UInt32(360)))
        while(final_angle%45 == 0){
            final_angle = Int(arc4random_uniform(UInt32(360)))
        }
        let final_proportion = Double(final_angle) / Double(360)
        let fullRotation = CGFloat(Double.pi * 2)
        let spin_animation = CAKeyframeAnimation()
        print("final_angle is \(final_angle)")
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                CATransaction.begin()
                self.display_reward = true
                CATransaction.setCompletionBlock({
                    let category = self.determine_final_case(final_angle: final_angle)
                    //print("category is \(category)")
                    if(category == 0){
                        let ten_points = UIImageView(frame: self.view.frame)
                        ten_points.image = #imageLiteral(resourceName: "ten_points")
                        self.view.addSubview(ten_points)
                        ten_points.alpha = 0
                        ten_points.fadeIn()
                        self.star_score += 10
                        self.defaults.set(self.star_score, forKey: "tritri_star_score")
                        
                        
                    }else if(category == 1){
                        let twenty_five_points = UIImageView(frame: self.view.frame)
                        twenty_five_points.image = #imageLiteral(resourceName: "twenty-five_points")
                        self.view.addSubview(twenty_five_points)
                        twenty_five_points.alpha = 0
                        twenty_five_points.fadeIn()
                        self.star_score += 25
                        self.defaults.set(self.star_score, forKey: "tritri_star_score")
                        
                        
                    }else if(category == 2){
                        let thirty_five_points = UIImageView(frame: self.view.frame)
                        thirty_five_points.image = #imageLiteral(resourceName: "thirty-five_points")
                        self.view.addSubview(thirty_five_points)
                        thirty_five_points.alpha = 0
                        thirty_five_points.fadeIn()
                        self.star_score += 35
                        self.defaults.set(self.star_score, forKey: "tritri_star_score")
                    }
                    
                })
                
                spin_animation.keyPath = "transform.rotation.z"
                spin_animation.duration = 1
                spin_animation.isRemovedOnCompletion = false
                spin_animation.fillMode = kCAFillModeForwards
                spin_animation.repeatCount = Float(1)
                spin_animation.values = [CGFloat(final_proportion)*fullRotation]
                self.wheel.layer.add(spin_animation, forKey: "rotate")
                CATransaction.commit()
            })
            //low speed one round
            let slow_spin = CAKeyframeAnimation()
            slow_spin.keyPath = "transform.rotation.z"
            slow_spin.duration = 2
            slow_spin.isRemovedOnCompletion = false
            slow_spin.fillMode = kCAFillModeForwards
            slow_spin.repeatCount = Float(1)
            if(self.rotation_direction == 0){
                slow_spin.values = [fullRotation/4, fullRotation/2, fullRotation*3/4, fullRotation]
            }else if(self.rotation_direction == 1){
                slow_spin.values = [fullRotation*3/4, fullRotation/2, fullRotation/4, 0]
                
            }
            self.wheel.layer.add(slow_spin, forKey: "rotate")
            
            CATransaction.commit()
         
        })
        spin_animation.keyPath = "transform.rotation.z"
        
        spin_animation.isRemovedOnCompletion = false
        spin_animation.fillMode = kCAFillModeForwards
        if(real_velocity<500){
            spin_animation.repeatCount = Float(1)
            spin_animation.duration = 1
        }else if(real_velocity >= 500 && real_velocity < 1000){
            spin_animation.repeatCount = Float(2)
            spin_animation.duration = 0.8
        }else if(real_velocity >= 1000 && real_velocity < 1500){
            spin_animation.repeatCount = Float(3)
            spin_animation.duration = 0.5
        }else if(real_velocity >= 1500){
            spin_animation.repeatCount = Float(4)
            spin_animation.duration = 0.4
        }
        if(rotation_direction == 0){
        spin_animation.values = [fullRotation/4, fullRotation/2, fullRotation*3/4, fullRotation]
        }else if(rotation_direction == 1){
            spin_animation.values = [fullRotation*3/4, fullRotation/2, fullRotation/4, 0]
    
        }
        wheel.layer.add(spin_animation, forKey: "rotate")
        CATransaction.commit()
        
    }
    
    
    //function to determine spinning direction (need more implementation)
    func determine_rotation_direction() -> Int{
        let wheel_center = CGPoint(x: (wheel.frame.origin.x + wheel.frame.width/2), y: (wheel.frame.origin.y + wheel.frame.height/2))
        let final_position = CGPoint(x: spin_initial_point.x+final_translation.x, y: spin_initial_point.y+final_translation.y)
        print("inital point: x: \(spin_initial_point.x) y: \(spin_initial_point.y)")
        print("final point: x: \(final_position.x) y: \(final_position.y)")
        
        var valid_length = 0
        var i = 0
        //get valid length first
        while(gesture_passing_area[i] != -1 && valid_length != gesture_passing_area.count){
            //clockwise find the pattern of 0 -> 1 -> 2 -> 3 -> 4
            i += 1
            valid_length += 1
        }
        

        //left upper area
        if((spin_initial_point.x - wheel.frame.origin.x) < wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y < wheel.frame.height/2 ){
        let angle_init = atan((spin_initial_point.y - wheel_center.y)/(spin_initial_point.x - wheel_center.x))
        let angle_final = atan((final_position.y - wheel.center.y)/(final_position.x - wheel_center.x))
        let degree_angle_init = Double(angle_init)*180/Double.pi
        let degree_angle_final = Double(angle_final)*180/Double.pi
        print("init angle : \(degree_angle_init)  final angle: \(degree_angle_final)")
       //final_position in left upper boundary (same area)
       /** if((final_position.x - wheel.frame.origin.x) < wheel.frame.width/2 && final_position.y - wheel.frame.origin.y < wheel.frame.height/2 ){
            if(degree_angle_init > degree_angle_final){
                return 1
            }else if(degree_angle_init < degree_angle_final){
                return 0
            }else{
                return -1
            }
        }
 **/
            //use the last two area to get the direction
            //only one area
            if(valid_length == 1){
                if(degree_angle_init > degree_angle_final){
                    return 1
                }else if(degree_angle_init < degree_angle_final){
                    return 0
                }else{
                    return -1
                }
                
            }
            //two areas
            else if(valid_length == 2){
                if(gesture_passing_area[1] == 1){
                    return 0
                }else if(gesture_passing_area[1] == 3){
                    return 1
                }
            }else{
               let second_last_area = gesture_passing_area[valid_length-2]
               let last_area = gesture_passing_area[valid_length-1]
                if(last_area == second_last_area+1 || last_area == second_last_area - 3){
                    return 0
                }else if(last_area == second_last_area-1 || last_area == second_last_area + 3){
                    return 1
                }
            }
            
            
            
    
        
        /**final position in right_upper boundary
        else if((final_position.x - wheel.frame.origin.x) > wheel.frame.width/2 && final_position.y - wheel.frame.origin.y < wheel.frame.height/2 ){
            return 0
            }
        //final postion in right downer boundary
        else if((final_position.x - wheel.frame.origin.x) > wheel.frame.width/2 && final_position.y - wheel.frame.origin.y > wheel.frame.height/2 ){
            if(degree_angle_init > degree_angle_final){
                return 0
            }else if(degree_angle_init < degree_angle_final){
                return 1
            }else{
                return -1
            }
        }
        //final position in left downer
         else if((final_position.x - wheel.frame.origin.x) < wheel.frame.width/2 && final_position.y - wheel.frame.origin.y > wheel.frame.height/2 ){
            return 1
            
            
            
            }
    **/
            
        }//right upper area
        else if((spin_initial_point.x - wheel.frame.origin.x) > wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y < wheel.frame.height/2 ){
            let angle_init = atan((spin_initial_point.y - wheel_center.y)/(spin_initial_point.x - wheel_center.x))
            let angle_final = atan((final_position.y - wheel.center.y)/(final_position.x - wheel_center.x))
            let degree_angle_init = Double(angle_init)*180/Double.pi
            let degree_angle_final = Double(angle_final)*180/Double.pi
            print("init angle : \(degree_angle_init)  final angle: \(degree_angle_final)")
            //use the last two area to get the direction
            //only one area
            if(valid_length == 1){
                if(degree_angle_init > degree_angle_final){
                    return 1
                }else if(degree_angle_init < degree_angle_final){
                    return 0
                }else{
                    return -1
                }
                
            }
                //more areas
            else {
                let second_last_area = gesture_passing_area[valid_length-2]
                let last_area = gesture_passing_area[valid_length-1]
                if(last_area == second_last_area+1 || last_area == second_last_area - 3){
                    return 0
                }else if(last_area == second_last_area-1 || last_area == second_last_area + 3){
                    return 1
                }
            }
            
            
            
            
            
            
            
            
            
            
            
        }
        
        //right downer area
        else if((spin_initial_point.x - wheel.frame.origin.x) > wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y > wheel.frame.height/2 ){
            let angle_init = atan((spin_initial_point.y - wheel_center.y)/(spin_initial_point.x - wheel_center.x))
            let angle_final = atan((final_position.y - wheel.center.y)/(final_position.x - wheel_center.x))
            let degree_angle_init = Double(angle_init)*180/Double.pi
            let degree_angle_final = Double(angle_final)*180/Double.pi
            print("init angle : \(degree_angle_init)  final angle: \(degree_angle_final)")
            //use the last two area to get the direction
            //only one area
            if(valid_length == 1){
                if(degree_angle_init > degree_angle_final){
                    return 0
                }else if(degree_angle_init < degree_angle_final){
                    return 1
                }else{
                    return -1
                }
                
            }
                //more areas
            else {
                let second_last_area = gesture_passing_area[valid_length-2]
                let last_area = gesture_passing_area[valid_length-1]
                if(last_area == second_last_area+1 || last_area == second_last_area - 3){
                    return 0
                }else if(last_area == second_last_area-1 || last_area == second_last_area + 3){
                    return 1
                }
            }
            
            
            
        }
        //left downer area
        else if((spin_initial_point.x - wheel.frame.origin.x) < wheel.frame.width/2 && spin_initial_point.y - wheel.frame.origin.y > wheel.frame.height/2 ){
            let angle_init = atan((spin_initial_point.y - wheel_center.y)/(spin_initial_point.x - wheel_center.x))
            let angle_final = atan((final_position.y - wheel.center.y)/(final_position.x - wheel_center.x))
            let degree_angle_init = Double(angle_init)*180/Double.pi
            let degree_angle_final = Double(angle_final)*180/Double.pi
            print("init angle : \(degree_angle_init)  final angle: \(degree_angle_final)")
            //use the last two area to get the direction
            //only one area
            if(valid_length == 1){
                if(degree_angle_init > degree_angle_final){
                    return 0
                }else if(degree_angle_init < degree_angle_final){
                    return 1
                }else{
                    return -1
                }
                
            }
                //more areas
            else {
                let second_last_area = gesture_passing_area[valid_length-2]
                let last_area = gesture_passing_area[valid_length-1]
                if(last_area == second_last_area+1 || last_area == second_last_area - 3){
                    return 0
                }else if(last_area == second_last_area-1 || last_area == second_last_area + 3){
                    return 1
                }
            }
        }
        
        return 1
    }
    
    //determine case:
    //case 0 : +10
    //case 1 : +25
    //case 2 : +35
    //case -1 : none
    func determine_final_case(final_angle : Int) -> Int{
        if(final_angle > 0 && final_angle < 45 ){
         return 2
        }else if(final_angle > 45 && final_angle < 90){
            return 0
        }else if(final_angle > 90 && final_angle < 135){
            return 1
        }else if(final_angle > 135 && final_angle < 180){
            return 0
        }else if(final_angle > 180 && final_angle < 225 ){
            return 2
        }else if(final_angle > 225 && final_angle < 270){
            return 0
        }else if(final_angle > 270 && final_angle < 315){
            return 1
        }else if(final_angle > 315 && final_angle < 360){
            return 0
        }else{
            return -1
        }
    }

}
