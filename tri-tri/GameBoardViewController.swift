//
//  GameBoardViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-05-10.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import UserNotifications

public extension UIView {
    func fadeIn(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeInWithDisplacement(withDuration duration: TimeInterval = 0.5){
        self.frame.origin.y += 40
        UIView.animate(withDuration: duration, animations: {
            self.frame.origin.y -= 40
            self.alpha = 1.0
        })
    }
    
    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}

private var pTouchAreaEdgeInsets: UIEdgeInsets = .zero

extension UIButton {
    
    var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &pTouchAreaEdgeInsets) as? NSValue {
                var edgeInsets: UIEdgeInsets = .zero
                value.getValue(&edgeInsets)
                return edgeInsets
            }
            else {
                return .zero
            }
        }
        set(newValue) {
            var newValueCopy = newValue
            let objCType = NSValue(uiEdgeInsets: .zero).objCType
            let value = NSValue(&newValueCopy, withObjCType: objCType)
            objc_setAssociatedObject(self, &pTouchAreaEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if UIEdgeInsetsEqualToEdgeInsets(self.touchAreaEdgeInsets, .zero) || !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
        }
        
        let relativeFrame = self.bounds
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.touchAreaEdgeInsets)
        
        return hitFrame.contains(point)
    }
}

var defaults = UserDefaults.standard


class GameBoardViewController: UIViewController {
//constraints
    var pause_screen = UIView()
    
    @IBOutlet weak var starBoard: UILabel!
    var star_score = 0
    
    
    @IBOutlet weak var center: UILabel!
    @IBOutlet weak var green_drag_tri_x_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var star_counter: UIImageView!
    
    @IBOutlet weak var green_drag_tri_y_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var orange_drag_tri_x_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var orange_drag_tri_y_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var light_brown_drag_tri_x_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var light_brown_drag_tri_y_constraint: NSLayoutConstraint!
//create an array to store shape_index for each UIImageView
    @IBAction func test_gameover(_ sender: Any) {
        Jump_to_Game_Over()
    }
// each int inside array reprensents shape index
//every shape is the same name as they are in Assets.xcassets file
//shape index 0: 绿色tri  index 1: 橙色tri index 2: 棕色tri index 3:brown_downwards 4:brown_left_direction 5:dark_green_tri 6:pink_right_direction 7 purple upwards  8 purple downwards 9 brown_left_downwards 10 brown_right_downwards

    var shape_type_index : Array<Int> = [0 , 0, 0]
    //indicate pause
    var paused = false
    
    //indicate into theme menu
    var in_theme_menu = false

    var player = AVPlayer()
    
    //record highest score
    var HighestScore = 0
    
    //record theme type for now
    //start from 1
    var ThemeType = 1
    
    //store lines erased
    var number_of_lines_erased = 0
    
    
    var multiple_marker = UILabel(frame: CGRect(x: 90, y: 90, width: 200, height: 21))
    
    
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
    
    var home_button = MyButton()
    
    let default_erase_situation_0 = [[0,0],[0,1],[0,2],[0,3],[0,4],[0,5],[0,6]]
    let default_erase_situation_1 = [[1,0],[1,1],[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8]]
    let default_erase_situation_2 = [[2,0],[2,1],[2,2],[2,3],[2,4],[2,5],[2,6],[2,7],[2,8],[2,9],[2,10]]
    let default_erase_situation_3 = [[3,0],[3,1],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7],[3,8],[3,9],[3,10]]
    let default_erase_situation_4 = [[4,0],[4,1],[4,2],[4,3],[4,4],[4,5],[4,6],[4,7],[4,8]]
    let default_erase_situation_5 = [[5,0],[5,1],[5,2],[5,3],[5,4],[5,5],[5,6]]
    
    let default_erase_situation_6 = [[2,0],[3,0],[3,1],[4,0],[4,1],[5,0],[5,1]]
    let default_erase_situation_7 = [[1,0],[2,1],[2,2],[3,2],[3,3],[4,2],[4,3],[5,2],[5,3]]
    let default_erase_situation_8 = [[0,0],[1,1],[1,2],[2,3],[2,4],[3,4],[3,5],[4,4],[4,5],[5,4],[5,5]]
    let default_erase_situation_9 = [[0,1],[0,2],[1,3],[1,4],[2,5],[2,6],[3,6],[3,7],[4,6],[4,7],[5,6]]
    let default_erase_situation_10 = [[0,3],[0,4],[1,5],[1,6],[2,7],[2,8],[3,8],[3,9],[4,8]]
    let default_erase_situation_11 = [[0,5],[0,6],[1,7],[1,8],[2,9],[2,10],[3,10]]
    
    let default_erase_situation_12 = [[0,1],[0,0],[1,1],[1,0],[2,1],[2,0],[3,0]]
    let default_erase_situation_13 = [[0,3],[0,2],[1,3],[1,2],[2,3],[2,2],[3,2],[3,1],[4,0]]
    let default_erase_situation_14 = [[0,5],[0,4],[1,5],[1,4],[2,5],[2,4],[3,4],[3,3],[4,2],[4,1],[5,0]]
    let default_erase_situation_15 = [[0,6],[1,7],[1,6],[2,7],[2,6],[3,6],[3,5],[4,4],[4,3],[5,2],[5,1]]
    let default_erase_situation_16 = [[1,8],[2,9],[2,8],[3,8],[3,7],[4,6],[4,5],[5,4],[5,3]]
    let default_erase_situation_17 = [[2,10],[3,10],[3,9],[4,8],[4,7],[5,6],[5,5]]
    
    
    var erase_situation_0 : Array<Array<Int>> = []
    var erase_situation_1 : Array<Array<Int>> = []
    var erase_situation_2 : Array<Array<Int>> = []
    var erase_situation_3 : Array<Array<Int>> = []
    var erase_situation_4 : Array<Array<Int>> = []
    var erase_situation_5 : Array<Array<Int>> = []
    
    var erase_situation_6 : Array<Array<Int>> = []
    var erase_situation_7 : Array<Array<Int>> = []
    var erase_situation_8 : Array<Array<Int>> = []
    var erase_situation_9 : Array<Array<Int>> = []
    var erase_situation_10 : Array<Array<Int>> = []
    var erase_situation_11 : Array<Array<Int>> = []
    
    var erase_situation_12 : Array<Array<Int>> = []
    var erase_situation_13 : Array<Array<Int>> = []
    var erase_situation_14 : Array<Array<Int>> = []
    var erase_situation_15 : Array<Array<Int>> = []
    var erase_situation_16 : Array<Array<Int>> = []
    var erase_situation_17 : Array<Array<Int>> = []
    
    var cur_shape_tri : Array<Array<Int>> = []
//--------------------------------------------------------------------------------------------------------------------------
//draggable element three drag triangles implementation
    
    @IBOutlet weak var green_drag_tri: UIImageView!//first
    @IBOutlet weak var light_brown_drag_tri: UIImageView!//third
    @IBOutlet weak var orange_drag_tri: UIImageView!//second
    //the index of position which is being dragged
    var position_in_use: Int = 3
    //0 for green_drag_tri 1 for orange_drag_tri 2 for light_brown_tri
    var previous_drag_fit_UIImage_index : Int = 3
    var exist1 = true
    var exist2 = true
    var exist3 = true
    //original location of drag_image (only declaration here
    var green_drag_origin = CGPoint(x: 0, y:0 )
    var orange_drag_origin = CGPoint(x: 0, y:0 )
    var light_brown_drag_origin = CGPoint(x:0 , y:0)
    var green_drag_tri_orig_rec = CGRect(origin:  CGPoint(x: 0, y:0 ) , size: CGSize(width: 0 , height: 0))
    var orange_drag_tri_orig_rec = CGRect(origin:  CGPoint(x: 0, y:0 ) , size: CGSize(width: 0 , height: 0))
    var light_brown_drag_tri_orig_rec = CGRect(origin:  CGPoint(x: 0, y:0 ) , size: CGSize(width: 0 , height: 0))
    //adding one method by overriding touchesBegan function to get initial touch location
    var initialTouchLocation: CGPoint!
  
    //shape index refers to different shape type (FOR NOW)
    var Shape_Index_1 = 0   //0 green
    var Shape_Index_2 = 1   //1 orange
    var Shape_Index_3 = 2   //2 LIGHT BROWN
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first!.location(in: view)
        if(green_drag_tri_orig_rec.contains(initialTouchLocation)){
        UIView.animate(withDuration: 0.3, animations: {
            self.green_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
        })
        }else if(orange_drag_tri_orig_rec.contains(initialTouchLocation)){
            UIView.animate(withDuration: 0.3, animations: {
                self.orange_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(light_brown_drag_tri_orig_rec.contains(initialTouchLocation)){
            UIView.animate(withDuration: 0.3, animations: {
                self.light_brown_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
    }
        //print("Touche at x: \(initialTouchLocation.x), y:\(initialTouchLocation.y)")

    override func touchesEnded( _ touches: Set<UITouch>, with event: UIEvent?){
        super.touchesEnded(touches, with: event)
            let finalTouchLocation = touches.first!.location(in: view)
            if(green_drag_tri_orig_rec.contains(finalTouchLocation)){
                UIView.animate(withDuration: 0.3, animations: {
                    self.green_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                })
            }else if(orange_drag_tri_orig_rec.contains(finalTouchLocation)){
                UIView.animate(withDuration: 0.3, animations: {
                    self.orange_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                })
            }else if(light_brown_drag_tri_orig_rec.contains(finalTouchLocation)){
                UIView.animate(withDuration: 0.3, animations: {
                    self.light_brown_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                })
        }
        }
        
    
    
    
    
    @IBAction func stop_music_when_pause(_ sender: UIButton) {
        //self.audioPlayer.stop()
        //self.timer.invalidate()
  
    }
    
    //--------------------------------------------------------------------------------------------------------------------------
    //initialize an array for random generator
    var generator_array : Array<UIImage> = [UIImage(named:"绿色tri.png")!,UIImage(named:"橙色tri.png")!,UIImage(named:"棕色tri.png")!,UIImage(named:"brown_downwards.png")!,UIImage(named:"brown_left_direction.png")!,UIImage(named:"dark_green_tri.png")!,UIImage(named:"pink_right_direction.png")!,UIImage(named:"purple_upwards_as_shape.png")!,UIImage(named:"purple_downwards_as_shape")!, UIImage(named:"brown_left_downwards.png")!, UIImage(named: "brown_right_downwards.png")!]
    
    //--------------------------------------------------------------------------------------------------------------------------
    @IBOutlet weak var HightestScoreBoard: UILabel!
   // @IBOutlet weak var HightestScoreBoard: UITextField!

    @IBOutlet weak var triangle_title: UIImageView!
    
    
    //declare an audio player
    var fit_in_player = AVAudioPlayer()
    var audioPlayer = AVAudioPlayer()
    var timer = Timer()
   // screen width
    var screen_width : CGFloat = 0
    var screen_height : CGFloat = 0
    
    //audio players
    var restart_player = AVAudioPlayer()
    var erase_player = AVAudioPlayer()
    var button_player = AVAudioPlayer()
    var not_fit_player = AVAudioPlayer()
    var game_over_player = AVAudioPlayer()
    override func viewDidLoad() {
       // print("Green tri x constraint is\(green_drag_tri_x_constraint.constant), y is \(green_drag_tri_y_constraint.constant)")
        //let screen_Rect = UIScreen.main.bounds
        super.viewDidLoad()
        
        do{restart_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "restart_soundeffect", ofType: "wav")!))
        restart_player.prepareToPlay()
        }
        catch{
        
        }
        

        ///
        //add UIPanGestureRecognizer
        ////
        screen_width = view.frame.width
        screen_height = view.frame.height
        print("screen width: \(screen_width), screen height: \(screen_height)")
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        //assign original locations of three tris located at the location on storyboard of each of them
        orange_drag_origin.y = screen_height - (51 + orange_drag_tri.frame.height)
        orange_drag_origin.x = (screen_width/2+4.5) -  (orange_drag_tri.frame.width/2)    //34
        orange_drag_tri.frame.origin = orange_drag_origin
        
        green_drag_origin.y = screen_height - (51 + green_drag_tri.frame.height)
        green_drag_origin.x = 4   //4   //50 - (green_drag_tri.frame.width/2)
        green_drag_tri.frame.origin = green_drag_origin

        
        
        light_brown_drag_origin.y = screen_height - (51 + light_brown_drag_tri.frame.height)
        light_brown_drag_origin.x = screen_width - 3.5 - (light_brown_drag_tri.frame.width)
        light_brown_drag_tri.frame.origin = light_brown_drag_origin
        //declare original frames of the tris
        green_drag_tri_orig_rec = green_drag_tri.frame
        print("green origin x: \(green_drag_origin.x), y: \(green_drag_origin.y)")
        orange_drag_tri_orig_rec = orange_drag_tri.frame
        light_brown_drag_tri_orig_rec = light_brown_drag_tri.frame
        green_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
        orange_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
        light_brown_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
        // Do any additional setup after loading the view.
        //generate first group
        if(score == 0){
            auto_random_generator()
        }
        //
        
        var HighScoreDefault = UserDefaults.standard
        
        if(HighScoreDefault.value(forKey: "tritri_HighestScore") != nil ){
        HighestScore = HighScoreDefault.value(forKey: "tritri_HighestScore") as! NSInteger
        print("Highest Score is \(HighestScore)")
        }else{
         HighScoreDefault.set(0, forKey: "tritri_HighestScore")
         HighestScore = 0
        }
        HightestScoreBoard.text = String(HighestScore)
        
        if(defaults.value(forKey: "tritri_star_score") != nil ){
            star_score = defaults.value(forKey: "tritri_star_score") as! NSInteger
        }else{
            defaults.set(0, forKey: "tritri_star_score")
            star_score = 0
        }
        starBoard.text = String(star_score)
        
        
        
        
        //---------------------------------------------------------------------------
        //var to decide various theme type
        //1: day mode
        //2: night mode
        //3: B&W mode
        //4: chaos mode
        //5: school mode
        //6: color mode
        if (defaults.value(forKey: "tritri_Theme") == nil){
            ThemeType = 1
            defaults.set(1, forKey: "tritri_Theme")
        }
        else {
            ThemeType = defaults.integer(forKey: "tritri_Theme")
        }
        //change bg color
        if ThemeType == 1{
            self.view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
            downwards_tri = UIImage(named:"grey_tir_downwards")
            upwards_tri = UIImage(named:"grey_tri_upwards")
            star_counter.image = UIImage(named:"day_mode_star")
            Restore_Grey_Tris()
            change_all_back_tris_image()
            HightestScoreBoard.textColor = UIColor(red: 59.0/255, green: 76.0/255, blue: 65.0/255, alpha: 1.0)
            MarkBoard.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            trophy.image = UIImage(named:"trophy_new")
            pause.setImage(UIImage(named: "pause_button"), for: .normal)
            triangle_title.image = UIImage(named:"day mode triangle title")
            starBoard.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
            
            
        } else if ThemeType == 2{
            self.view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
            downwards_tri = UIImage(named:"bgtri_downward_night_mode")
            upwards_tri = UIImage(named:"bgtri_upward_night_mode")
            star_counter.image = UIImage(named:"night_mode_star")
            Restore_Grey_Tris()
            change_all_back_tris_image()
            HightestScoreBoard.textColor = UIColor(red: 186.0/255, green: 179.0/255, blue: 150.0/255, alpha: 1.0)
            MarkBoard.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            trophy.image = UIImage(named:"night mode 奖杯")
            pause.setImage(UIImage(named: "night mode pause"), for: .normal)
            triangle_title.image = UIImage(named:"night mode triangle title")
            starBoard.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            
        }else if ThemeType == 3{
            self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BW_background")!)
            downwards_tri = UIImage(named:"BW_white_tri_downwards")
            upwards_tri = UIImage(named:"BW_white_tri_upwards")
            star_counter.image = UIImage(named:"BW_mode_star")
            Restore_Grey_Tris()
            change_all_back_tris_image()
            HightestScoreBoard.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            MarkBoard.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            trophy.image = UIImage(named: "BW_trophy")
            pause.setImage(UIImage(named: "BW_pause"), for: .normal)
            triangle_title.image = UIImage(named: "day mode triangle title")
             starBoard.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            
        }else if ThemeType == 4{
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chaos_background")!)
            self.downwards_tri = UIImage(named:"bgtri_downward_night_mode")
            self.upwards_tri = UIImage(named:"bgtri_upward_night_mode")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 236.0/255, green: 232.0/255, blue: 187.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 254.0/255, green: 254.0/255, blue: 254.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"chaos_j_icon")
            self.pause.setImage(UIImage(named: "chaos_pause_button"), for: .normal)
            self.triangle_title.image = UIImage(named:"night mode triangle title")
        }else if ThemeType == 5{
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "school_background")!)
            self.downwards_tri = UIImage(named:"grey_tir_downwards")
            self.upwards_tri = UIImage(named:"grey_tri_upwards")
            star_counter.image = UIImage(named:"school_mode_star")

            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 34.0/255, green: 61.0/255, blue: 128.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 113.0/255, green: 105.0/255, blue: 183.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"school_j-icon")
            self.pause.setImage(UIImage(named: "school_pause-button"), for: .normal)

            self.triangle_title.image = UIImage(named:"school_triangle_title")

            self.triangle_title.image = UIImage(named:"night mode triangle title")
             starBoard.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
        }else if ThemeType == 6{
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "colors_background")!)
            self.downwards_tri = UIImage(named:"bgtri_downward_night_mode")
            self.upwards_tri = UIImage(named:"bgtri_upward_night_mode")
            star_counter.image = UIImage(named:"colors_mode_star")

            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 255.0/255, green: 195.0/255, blue: 1.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 251.0/255, green: 250.0/255, blue: 249.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"colors_j-icon")
            self.pause.setImage(UIImage(named: "colors_pause-button"), for: .normal)
            self.triangle_title.image = UIImage(named:"night mode triangle title")
            self.starBoard.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
        }
        change_shape_in_generate_array()
        change_current_shapes_according_to_theme()
        
        
        //update tris origin

        //center.frame.height
        
        //third row
        tri_2_5.frame.origin.y = screen_height/2 - 21 - (tri_2_5.frame.height/2)
        tri_2_5.frame.origin.x = (screen_width/2) - (tri_2_5.frame.width/2)
        tri_2_4.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_4.frame.origin.x = tri_2_5.frame.origin.x - 26
        tri_2_3.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_3.frame.origin.x = tri_2_4.frame.origin.x - 26
        tri_2_2.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_2.frame.origin.x = tri_2_3.frame.origin.x - 26
        tri_2_1.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_1.frame.origin.x = tri_2_2.frame.origin.x - 26
        tri_2_0.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_0.frame.origin.x = tri_2_1.frame.origin.x - 26
        tri_2_6.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_6.frame.origin.x = tri_2_5.frame.origin.x + 26
        tri_2_7.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_7.frame.origin.x = tri_2_6.frame.origin.x + 26
        tri_2_8.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_8.frame.origin.x = tri_2_7.frame.origin.x + 26
        tri_2_9.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_9.frame.origin.x = tri_2_8.frame.origin.x + 26
        tri_2_10.frame.origin.y = tri_2_5.frame.origin.y
        tri_2_10.frame.origin.x = tri_2_9.frame.origin.x + 26

        
        //second row
        tri_1_4.frame.origin.y = tri_2_5.frame.origin.y - 43
        tri_1_4.frame.origin.x = tri_2_5.frame.origin.x
        tri_1_3.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_3.frame.origin.x = tri_1_4.frame.origin.x - 26
        tri_1_2.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_2.frame.origin.x = tri_1_3.frame.origin.x - 26
        tri_1_1.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_1.frame.origin.x = tri_1_2.frame.origin.x - 26
        tri_1_0.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_0.frame.origin.x = tri_1_1.frame.origin.x - 26
        tri_1_5.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_5.frame.origin.x = tri_1_4.frame.origin.x + 26
        tri_1_6.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_6.frame.origin.x = tri_1_5.frame.origin.x + 26
        tri_1_7.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_7.frame.origin.x = tri_1_6.frame.origin.x + 26
        tri_1_8.frame.origin.y =  tri_1_4.frame.origin.y
        tri_1_8.frame.origin.x = tri_1_7.frame.origin.x + 26
        
        
         //first row
        tri_0_3.frame.origin.x = tri_1_4.frame.origin.x
        tri_0_3.frame.origin.y = tri_1_4.frame.origin.y - 43
        tri_0_2.frame.origin.y = tri_0_3.frame.origin.y
        tri_0_2.frame.origin.x = tri_0_3.frame.origin.x - 26
        tri_0_1.frame.origin.y = tri_0_3.frame.origin.y
        tri_0_1.frame.origin.x = tri_0_2.frame.origin.x - 26
        tri_0_0.frame.origin.y = tri_0_3.frame.origin.y
        tri_0_0.frame.origin.x = tri_0_1.frame.origin.x - 26
        tri_0_4.frame.origin.y = tri_0_3.frame.origin.y
        tri_0_4.frame.origin.x = tri_0_3.frame.origin.x + 26
        tri_0_5.frame.origin.y = tri_0_3.frame.origin.y
        tri_0_5.frame.origin.x = tri_0_4.frame.origin.x + 26
        tri_0_6.frame.origin.y = tri_0_3.frame.origin.y
        tri_0_6.frame.origin.x = tri_0_5.frame.origin.x + 26
        
               //fourth row
        tri_3_5.frame.origin.y = screen_height/2 + 11
        tri_3_5.frame.origin.x = tri_2_5.frame.origin.x
        tri_3_4.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_4.frame.origin.x = tri_3_5.frame.origin.x - 26
        tri_3_3.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_3.frame.origin.x = tri_3_4.frame.origin.x - 26
        tri_3_2.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_2.frame.origin.x = tri_3_3.frame.origin.x - 26
        tri_3_1.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_1.frame.origin.x = tri_3_2.frame.origin.x - 26
        tri_3_0.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_0.frame.origin.x = tri_3_1.frame.origin.x - 26
        tri_3_6.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_6.frame.origin.x = tri_3_5.frame.origin.x + 26
        tri_3_7.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_7.frame.origin.x = tri_3_6.frame.origin.x + 26
        tri_3_8.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_8.frame.origin.x = tri_3_7.frame.origin.x + 26
        tri_3_9.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_9.frame.origin.x = tri_3_8.frame.origin.x + 26
        tri_3_10.frame.origin.y = tri_3_5.frame.origin.y
        tri_3_10.frame.origin.x = tri_3_9.frame.origin.x + 26
        //fifth row
        tri_4_4.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_4.frame.origin.x = tri_3_5.frame.origin.x
        tri_4_3.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_3.frame.origin.x = tri_4_4.frame.origin.x - 26
        tri_4_2.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_2.frame.origin.x = tri_4_3.frame.origin.x - 26
        tri_4_1.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_1.frame.origin.x = tri_4_2.frame.origin.x - 26
        tri_4_0.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_0.frame.origin.x = tri_4_1.frame.origin.x - 26
        tri_4_5.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_5.frame.origin.x = tri_4_4.frame.origin.x + 26
        tri_4_6.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_6.frame.origin.x = tri_4_5.frame.origin.x + 26
        tri_4_7.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_7.frame.origin.x = tri_4_6.frame.origin.x + 26
        tri_4_8.frame.origin.y = tri_3_5.frame.origin.y + 43
        tri_4_8.frame.origin.x = tri_4_7.frame.origin.x + 26
        //sixth row
        tri_5_3.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_3.frame.origin.x = tri_4_4.frame.origin.x
        tri_5_2.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_2.frame.origin.x = tri_5_3.frame.origin.x - 26
        tri_5_1.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_1.frame.origin.x = tri_5_2.frame.origin.x - 26
        tri_5_0.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_0.frame.origin.x = tri_5_1.frame.origin.x - 26
        tri_5_4.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_4.frame.origin.x = tri_5_3.frame.origin.x + 26
        tri_5_5.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_5.frame.origin.x = tri_5_4.frame.origin.x + 26
        tri_5_6.frame.origin.y = tri_4_4.frame.origin.y + 43
        tri_5_6.frame.origin.x = tri_5_5.frame.origin.x + 26

        
        
        
        //set CGPoint value of all grey tringles
        
        //---------------------------------------------------------------------------------------------------------------------
        //ugly and long init start:
        
        tri_location[0][0] = tri_0_0.frame.origin
        print(tri_location[0][0].x)
        print(tri_location[0][0].y)
        tri_location[0][1] = tri_0_1.frame.origin
        print(tri_location[0][1].x)
        print(tri_location[0][1].y)
        tri_location[0][2] = tri_0_2.frame.origin
        tri_location[0][3] = tri_0_3.frame.origin
        tri_location[0][4] = tri_0_4.frame.origin
        tri_location[0][5] = tri_0_5.frame.origin
        tri_location[0][6] = tri_0_6.frame.origin
        tri_location[1][0] = tri_1_0.frame.origin
        print(tri_location[1][0].x)
        print(tri_location[1][0].y)
        tri_location[1][1] = tri_1_1.frame.origin
        tri_location[1][2] = tri_1_2.frame.origin
        tri_location[1][3] = tri_1_3.frame.origin
        tri_location[1][4] = tri_1_4.frame.origin
        tri_location[1][5] = tri_1_5.frame.origin
        tri_location[1][6] = tri_1_6.frame.origin
        tri_location[1][7] = tri_1_7.frame.origin
        tri_location[1][8] = tri_1_8.frame.origin
        tri_location[2][0] = tri_2_0.frame.origin
        //print(tri_location[2][0].x)
       // print(tri_location[2][0].y)
        tri_location[2][1] = tri_2_1.frame.origin
        //print(tri_location[2][1].x)
        //print(tri_location[2][1].y)
        tri_location[2][2] = tri_2_2.frame.origin
       // print(tri_location[2][2].x)
       // print(tri_location[2][2].y)
        tri_location[2][3] = tri_2_3.frame.origin
        //print(tri_location[2][3].x)
        //print(tri_location[2][3].y)
        tri_location[2][4] = tri_2_4.frame.origin
       // print(tri_location[2][4].x)
       // print(tri_location[2][4].y)
        tri_location[2][5] = tri_2_5.frame.origin
        //print(tri_location[2][5].x)
       // print(tri_location[2][5].y)
        tri_location[2][6] = tri_2_6.frame.origin
       // print(tri_location[2][6].x)
       // print(tri_location[2][6].y)
        tri_location[2][7] = tri_2_7.frame.origin
       // print(tri_location[2][7].x)
       // print(tri_location[2][7].y)
        tri_location[2][8] = tri_2_8.frame.origin
        //print(tri_location[2][8].x)
        //print(tri_location[2][8].y)
        tri_location[2][9] = tri_2_9.frame.origin
        //print(tri_location[2][9].x)
        //print(tri_location[2][9].y)
        tri_location[2][10] = tri_2_10.frame.origin
        //print(tri_location[2][10].x)
        //print(tri_location[2][10].y)
        tri_location[3][0] = tri_3_0.frame.origin
        //print(tri_location[3][0].x)
        //print(tri_location[3][0].y)
        tri_location[3][1] = tri_3_1.frame.origin
        tri_location[3][2] = tri_3_2.frame.origin
        tri_location[3][3] = tri_3_3.frame.origin
        tri_location[3][4] = tri_3_4.frame.origin
        tri_location[3][5] = tri_3_5.frame.origin
        tri_location[3][6] = tri_3_6.frame.origin
        tri_location[3][7] = tri_3_7.frame.origin
        tri_location[3][8] = tri_3_8.frame.origin
        tri_location[3][9] = tri_3_9.frame.origin
        tri_location[3][10] = tri_3_10.frame.origin
        tri_location[4][0] = tri_4_0.frame.origin
        //print(tri_location[4][0].x)
        //print(tri_location[4][0].y)
        tri_location[4][1] = tri_4_1.frame.origin
        tri_location[4][2] = tri_4_2.frame.origin
        tri_location[4][3] = tri_4_3.frame.origin
        tri_location[4][4] = tri_4_4.frame.origin
        tri_location[4][5] = tri_4_5.frame.origin
        tri_location[4][6] = tri_4_6.frame.origin
        tri_location[4][7] = tri_4_7.frame.origin
        tri_location[4][8] = tri_4_8.frame.origin
        tri_location[5][0] = tri_5_0.frame.origin
        //print(tri_location[5][0].x)
        //print(tri_location[5][0].y)
        tri_location[5][1] = tri_5_1.frame.origin
        tri_location[5][2] = tri_5_2.frame.origin
        tri_location[5][3] = tri_5_3.frame.origin
        tri_location[5][4] = tri_5_4.frame.origin
        tri_location[5][5] = tri_5_5.frame.origin
        tri_location[5][6] = tri_5_6.frame.origin
        
        //-----------------------------------------------------------------------------------------------
        //ugly and long init finished XD
        
        //audio intialize
        //do{
         //   audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "background music", ofType: "mp3")!))
         //   audioPlayer.prepareToPlay()
        //}
       // catch{
            //print("error")
        //}
        //
        
        //
        //print("origin x is\(green_drag_tri.frame.origin.x), origin y is \(green_drag_tri.frame.origin.y)")
        //
        //initialize shape array
        //shape_type_index = [0 , 1 , 2]
        
       // audioPlayer.play()
        //self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                       // self.audioPlayer.play()   } )
        
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameBoardViewController.background_music_pause) , name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(GameBoardViewController.background_music_continue), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
    }
    
    func background_music_pause () {
        audioPlayer.pause()
        //timer.invalidate()
    }
    
    func background_music_continue() {
        //audioPlayer.play()
        //timer.fire()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pause_screen_x_transform(_ x: Double) -> CGFloat {
      let const = x/Double(375)
      let new_x = Double(screen_width)*const
      return CGFloat(new_x)
        
    }
    func pause_screen_y_transform(_ y: Double) -> CGFloat {
        let const = y/Double(667)
        let new_y = Double(screen_height)*const
        return CGFloat(new_y)
    }
    
    
    //origin
    var day_theme_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var night_theme_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var BW_theme_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var chaos_theme_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var school_theme_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var colors_theme_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var theme_star_counter = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var theme_star_board = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var day_theme_origin = CGPoint(x: 0, y: 0)
    var night_theme_origin = CGPoint(x: 0, y: 0)
    var BW_theme_origin = CGPoint(x: 0, y: 0)
    var chaos_theme_origin = CGPoint(x: 0, y: 0)
    var school_theme_origin = CGPoint(x: 0, y: 0)
    var colors_theme_origin = CGPoint(x: 0, y: 0)

    func theme_menu_action() -> Void {
        in_theme_menu = true
        let theme_menu: UIView = UIView(frame: CGRect(origin: CGPoint(x: 0, y:0),size: CGSize(width: screen_width, height: screen_height)))
        theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(1))
        theme_menu.alpha = 0
        theme_menu.tag = 100
        super.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(theme_menu)
        theme_menu.fadeIn()
        
        let white_cover = UIView(frame: CGRect(x: pause_screen_x_transform(0), y: pause_screen_y_transform(0), width: pause_screen_x_transform(400), height: pause_screen_y_transform(120)))
        let triangle_text = UIImageView(frame: CGRect(x: pause_screen_x_transform(110), y: pause_screen_y_transform(40), width: pause_screen_x_transform(155), height: pause_screen_y_transform(50)))
        theme_star_counter = UIImageView(frame: CGRect(x:pause_screen_x_transform(250), y:pause_screen_y_transform(90),width: pause_screen_x_transform(97), height: pause_screen_y_transform(41)))
         theme_star_board = UILabel(frame: CGRect(x:pause_screen_x_transform(270),y:pause_screen_y_transform(95),width: pause_screen_x_transform(80),height:pause_screen_y_transform(30)))
        let return_button = MyButton(frame: CGRect(x: pause_screen_x_transform(20), y: pause_screen_y_transform(90), width: pause_screen_x_transform(30), height: pause_screen_y_transform(30)))
        //add buttons
        day_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(20), y: pause_screen_y_transform(145), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
        day_theme_origin = day_theme_button.frame.origin
        day_theme_button.setBackgroundImage(UIImage(named:"day_theme"), for: .normal)
        day_theme_button.alpha = 0
        day_theme_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            defaults.set(1, forKey: "tritri_Theme")
            self.ThemeType = 1
            self.view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
            self.downwards_tri = UIImage(named:"grey_tir_downwards")
            self.upwards_tri = UIImage(named:"grey_tri_upwards")
            self.star_counter.image = UIImage(named:"day_mode_star")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 59.0/255, green: 76.0/255, blue: 65.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"trophy_new")
            self.pause.setImage(UIImage(named: "pause_button"), for: .normal)
            self.triangle_title.image = UIImage(named:"day mode triangle title")
            self.home_button.setBackgroundImage(self.home_pic, for: .normal)
            self.continue_button.setBackgroundImage(self.continue_pic, for: .normal)
            self.restart_button.setBackgroundImage(self.restart_pic, for: .normal)
            self.shopping_button.setBackgroundImage(self.shopping_pic, for: .normal)
            self.change_shape_in_generate_array()
            self.change_current_shapes_according_to_theme()
            self.change_current_board_according_to_theme()
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.in_theme_menu = false
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
             self.starBoard.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
            self.theme_star_counter.image = UIImage(named:"day_mode_star")
            self.theme_star_board.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
            
            
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

        })
        
        self.view.addSubview(day_theme_button)
        day_theme_button.fadeInWithDisplacement()
        
        night_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(206), y: pause_screen_y_transform(145), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
        night_theme_origin = night_theme_button.frame.origin
        night_theme_button.setBackgroundImage(UIImage(named:"night_theme"), for: .normal)
        night_theme_button.alpha = 0
        night_theme_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            defaults.set(2, forKey: "tritri_Theme")
            self.ThemeType = 2
            self.view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
            self.downwards_tri = UIImage(named:"bgtri_downward_night_mode")
            self.upwards_tri = UIImage(named:"bgtri_upward_night_mode")
            self.star_counter.image = UIImage(named:"night_mode_star")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 186.0/255, green: 179.0/255, blue: 150.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"night mode 奖杯")
            self.pause.setImage(UIImage(named: "night mode pause"), for: .normal)
            self.triangle_title.image = UIImage(named:"night mode triangle title")
            
            self.home_button.setBackgroundImage(self.night_home_pic, for: .normal)
            self.continue_button.setBackgroundImage(self.continue_pic, for: .normal)
            self.restart_button.setBackgroundImage(self.restart_pic, for: .normal)
            self.shopping_button.setBackgroundImage(self.shopping_pic, for: .normal)

            self.change_shape_in_generate_array()
            self.change_current_shapes_according_to_theme()
            self.change_current_board_according_to_theme()
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.8))
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.in_theme_menu = false
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.8))
            self.starBoard.textColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            self.theme_star_counter.image = UIImage(named:"night_mode_star")
            self.theme_star_board.textColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

        })
        self.view.addSubview(night_theme_button)
        night_theme_button.fadeInWithDisplacement()
        
        BW_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(20), y: pause_screen_y_transform(319), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
        BW_theme_origin = BW_theme_button.frame.origin
        BW_theme_button.setBackgroundImage(UIImage(named:"B&W_theme"), for: .normal)
        BW_theme_button.alpha = 0
        BW_theme_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            defaults.set(3, forKey: "tritri_Theme")
            self.ThemeType = 3
            self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BW_background")!)
            self.downwards_tri = UIImage(named:"BW_white_tri_downwards")
            self.upwards_tri = UIImage(named:"BW_white_tri_upwards")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"BW_trophy")
            self.pause.setImage(UIImage(named: "BW_pause"), for: .normal)
            self.triangle_title.image = UIImage(named:"day mode triangle title")
            self.star_counter.image = UIImage(named:"BW_mode_star")
            self.home_button.setBackgroundImage(self.BW_home_pic, for: .normal)
            self.continue_button.setBackgroundImage(self.BW_continue_pic, for: .normal)
            self.restart_button.setBackgroundImage(self.BW_restart_pic, for: .normal)
            self.shopping_button.setBackgroundImage(self.BW_shopping_pic, for: .normal)

            self.change_shape_in_generate_array()
            self.change_current_shapes_according_to_theme()
            self.change_current_board_according_to_theme()
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.8))
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.in_theme_menu = false
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
            self.starBoard.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            self.theme_star_counter.image = UIImage(named:"BW_mode_star")
            self.theme_star_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)

            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

            
            
            
            
            
            
            
            
            
            
        })
        self.view.addSubview(BW_theme_button)
        BW_theme_button.fadeInWithDisplacement()
        
        chaos_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(206), y: pause_screen_y_transform(319), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
        chaos_theme_origin = chaos_theme_button.frame.origin
        chaos_theme_button.setBackgroundImage(UIImage(named:"Chaos_theme"), for: .normal)
        chaos_theme_button.alpha = 0
        chaos_theme_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            defaults.set(4, forKey: "tritri_Theme")
            self.ThemeType = 4
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chaos_background")!)
            
            
            self.downwards_tri = UIImage(named:"bgtri_downward_night_mode")
            self.upwards_tri = UIImage(named:"bgtri_upward_night_mode")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 236.0/255, green: 232.0/255, blue: 187.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 254.0/255, green: 254.0/255, blue: 254.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"chaos_j_icon")
            self.pause.setImage(UIImage(named: "chaos_pause_button"), for: .normal)
            self.triangle_title.image = UIImage(named:"night mode triangle title")
            
            self.home_button.setBackgroundImage(self.chaos_home_pic, for: .normal)
            self.continue_button.setBackgroundImage(self.chaos_continue_pic, for: .normal)
            self.restart_button.setBackgroundImage(self.chaos_restart_small_pic, for: .normal)
            self.shopping_button.setBackgroundImage(self.chaos_shopping_pic, for: .normal)
            
            self.change_shape_in_generate_array()
            self.change_current_shapes_according_to_theme()
            self.change_current_board_according_to_theme()
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.8))
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.in_theme_menu = false
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

            
            
            
            
            
            
            
            
        })
        self.view.addSubview(chaos_theme_button)
        chaos_theme_button.fadeInWithDisplacement()
        
        
        school_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(20), y: pause_screen_y_transform(493), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
        school_theme_origin = school_theme_button.frame.origin
        school_theme_button.setBackgroundImage(UIImage(named:"School_Theme"), for: .normal)
        school_theme_button.alpha = 0
        school_theme_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            defaults.set(5, forKey: "tritri_Theme")
            self.ThemeType = 5
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "school_background")!)
            
            
            self.downwards_tri = UIImage(named:"grey_tir_downwards")
            self.upwards_tri = UIImage(named:"grey_tri_upwards")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 113.0/255, green: 113.0/255, blue: 142.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 113.0/255, green: 105.0/255, blue: 183.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"school_j-icon")
            self.pause.setImage(UIImage(named: "school_pause-button"), for: .normal)
            self.triangle_title.image = UIImage(named:"school_triangle_title")
            self.star_counter.image = UIImage(named:"school_mode_star")
            self.home_button.setBackgroundImage(self.school_home_pic, for: .normal)
            self.continue_button.setBackgroundImage(self.school_continue_pic, for: .normal)
            self.restart_button.setBackgroundImage(self.school_restart_small_pic, for: .normal)
            self.shopping_button.setBackgroundImage(self.school_shopping_pic, for: .normal)
            
            self.change_shape_in_generate_array()
            self.change_current_shapes_according_to_theme()
            self.change_current_board_according_to_theme()
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255/255.0), green:CGFloat(255/255.0), blue:CGFloat(255/255.0), alpha:CGFloat(0.8))
            
            
            
            self.starBoard.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.theme_star_counter.image = UIImage(named:"school_mode_star")
            self.theme_star_board.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
            self.in_theme_menu = false
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

        })
        self.view.addSubview(school_theme_button)
        school_theme_button.fadeInWithDisplacement()
        
        colors_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(206), y: pause_screen_y_transform(493), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
        colors_theme_origin = colors_theme_button.frame.origin
        colors_theme_button.setBackgroundImage(UIImage(named:"Colors_theme"), for: .normal)
        colors_theme_button.alpha = 0
        colors_theme_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            defaults.set(6, forKey: "tritri_Theme")
            self.ThemeType = 6
            self.view.backgroundColor = UIColor(patternImage: UIImage(named:"colors_background")!)
            self.downwards_tri = UIImage(named:"bgtri_downward_night_mode")
            self.upwards_tri = UIImage(named:"bgtri_upward_night_mode")
            self.Restore_Grey_Tris()
            self.change_all_back_tris_image()
            self.HightestScoreBoard.textColor = UIColor(red: 34.0/255, green: 61.0/255, blue: 128.0/255, alpha: 1.0)
            self.MarkBoard.textColor = UIColor(red: 251.0/255, green: 250.0/255, blue: 249.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"colors_j-icon")
            self.pause.setImage(UIImage(named: "colors_pause-button"), for: .normal)
            self.triangle_title.image = UIImage(named:"night mode triangle title")
            self.star_counter.image = UIImage(named:"colors_mode_star")
            self.home_button.setBackgroundImage(self.colors_home_pic, for: .normal)
            self.continue_button.setBackgroundImage(self.colors_continue_pic, for: .normal)
            self.restart_button.setBackgroundImage(self.colors_restart_small_pic, for: .normal)
            self.shopping_button.setBackgroundImage(self.colors_shopping_pic, for: .normal)
            
            self.change_shape_in_generate_array()
            self.change_current_shapes_according_to_theme()
            self.change_current_board_according_to_theme()
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.8))
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.in_theme_menu = false
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
            self.starBoard.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
            self.theme_star_counter.image = UIImage(named:"colors_mode_star")
            self.theme_star_board.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

            
            
            
            
            
            
            
            
        })

        self.view.addSubview(colors_theme_button)
        colors_theme_button.fadeInWithDisplacement()
        
        //add white to 遮挡
        
        white_cover.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(1))
        white_cover.alpha = 0
        self.view.addSubview(white_cover)
        white_cover.fadeInWithDisplacement()
        
        
        //add triangle text
        
        triangle_text.image = UIImage(named: "day mode triangle title")
        triangle_text.contentMode = .scaleAspectFit
        //triangle_text.sizeToFit()
        triangle_text.alpha = 0
        self.view.addSubview(triangle_text)
        triangle_text.fadeInWithDisplacement()
        
        //add star_counter in theme menu
        if(ThemeType == 1){
            theme_star_counter.image = UIImage(named:"day_mode_star")
        }else if(ThemeType == 2){
            theme_star_counter.image = UIImage(named:"night_mode_star")
            
        }else if(ThemeType == 3){
            theme_star_counter.image = UIImage(named:"BW_mode_star")
        }else if(ThemeType == 5){
            theme_star_counter.image = UIImage(named:"school_mode_star")
        }else if(ThemeType == 6){
            theme_star_counter.image = UIImage(named:"colors_mode_star")
        }
        theme_star_counter.alpha = 0
        self.view.addSubview(theme_star_counter)
        theme_star_counter.fadeInWithDisplacement()
        
        
        
        //add text
        theme_star_board.font = UIFont(name: "Helvetica", size: CGFloat(17))
        theme_star_board.text = String(star_score)
        theme_star_board.textAlignment = .center
        if(ThemeType == 1){
            theme_star_board.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
        }else if(ThemeType == 2){
            theme_star_board.textColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        }else if(ThemeType == 3){
            theme_star_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
        }else if(ThemeType == 5){
            theme_star_board.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
        }else if(ThemeType == 6){
            theme_star_board.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
        }
        theme_star_board.alpha = 0
        self.view.addSubview(theme_star_board)
        theme_star_board.fadeInWithDisplacement()
        
        
        //add  return button
        
        return_button.setBackgroundImage(UIImage(named:"return_button"), for: .normal)
        
        
        return_button.whenButtonIsClicked(action: {
            self.in_theme_menu = false
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            
            self.button_player.play()
            
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            self.chaos_theme_button.removeFromSuperview()
            self.school_theme_button.removeFromSuperview()
            self.colors_theme_button.removeFromSuperview()
            triangle_text.removeFromSuperview()
            return_button.removeFromSuperview()
            white_cover.removeFromSuperview()
            theme_menu.removeFromSuperview()
            self.theme_star_counter.removeFromSuperview()
            self.theme_star_board.removeFromSuperview()

        })
        
        return_button.alpha = 0
        self.view.addSubview(return_button)
        
        return_button.fadeInWithDisplacement()
    }

    var continue_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var shopping_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var restart_button = MyButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    
    
    
    
    
    @IBAction func pause_button(_ sender: UIButton) {
        do{button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            button_player.prepareToPlay()
        }
        catch{
            
        }
        button_player.play()
        self.pause_screen = UIView(frame: CGRect(origin: CGPoint(x: 0, y:0),size: CGSize(width: screen_width, height: screen_height)))
        if (ThemeType == 1){
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
        } else if (ThemeType == 2){
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.8))
        } else if (ThemeType == 3){
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
        } else if (ThemeType == 4){
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
        } else if (ThemeType == 5){
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
        }else if (ThemeType == 6){
             self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0.8))
        }
        
        self.pause_screen.alpha = 0
        self.pause_screen.tag = 100
        super.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(pause_screen)
        self.pause_screen.fadeIn()
        paused = true
         continue_button = MyButton(frame: CGRect(x: pause_screen_x_transform(87.5), y: pause_screen_y_transform(283.5), width: pause_screen_x_transform(200), height: pause_screen_y_transform(170)))
        if(ThemeType == 1 || ThemeType == 2){
        continue_button.setBackgroundImage(continue_pic, for: .normal)
        }else if (ThemeType == 3){
        continue_button.setBackgroundImage(BW_continue_pic, for: .normal)
        }else if (ThemeType == 4){
        continue_button.setBackgroundImage(chaos_continue_pic, for: .normal)
        }else if (ThemeType == 5){
        continue_button.setBackgroundImage(school_continue_pic, for: .normal)
        }else if (ThemeType == 6){
    continue_button.setBackgroundImage(colors_continue_pic, for: .normal)
        }
        continue_button.tag = 50
        continue_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(40), bottom: pause_screen_y_transform(40), right: pause_screen_x_transform(40))
        
        self.home_button = MyButton(frame: CGRect(x: pause_screen_x_transform(52), y: pause_screen_y_transform(333.5), width: pause_screen_x_transform(100), height: pause_screen_y_transform(85)))
        if (ThemeType == 1){
            self.home_button.setBackgroundImage(home_pic, for: .normal)
        }
        else if (ThemeType == 2){
            self.home_button.setBackgroundImage(night_home_pic, for: .normal)
        }else if(ThemeType == 3){
            self.home_button.setBackgroundImage(BW_home_pic, for: .normal)
        }else if(ThemeType == 4){
            self.home_button.setBackgroundImage(chaos_home_pic, for: .normal)
        }else if(ThemeType == 5){
            self.home_button.setBackgroundImage(school_home_pic, for: .normal)
        }else if (ThemeType == 6){
    self.home_button.setBackgroundImage(colors_home_pic, for: .normal)
    }
        self.home_button.tag = 51
        self.home_button.touchAreaEdgeInsets = UIEdgeInsets(top: pause_screen_y_transform(10), left: pause_screen_x_transform(15), bottom: pause_screen_y_transform(0), right: pause_screen_x_transform(15))
        
         shopping_button = MyButton(frame: CGRect(x: pause_screen_x_transform(222.5), y: pause_screen_y_transform(333.5), width: pause_screen_x_transform(100), height: pause_screen_y_transform(85)))
        if(ThemeType == 1 || ThemeType == 2){
        shopping_button.setBackgroundImage(shopping_pic, for: .normal)
        }else if(ThemeType == 3){
            shopping_button.setBackgroundImage(BW_shopping_pic, for: .normal)
        }else if(ThemeType == 4){
            shopping_button.setBackgroundImage(chaos_shopping_pic, for: .normal)
        }else if(ThemeType == 5){
            shopping_button.setBackgroundImage(school_shopping_pic, for: .normal)
        }else if (ThemeType == 6){
    shopping_button.setBackgroundImage(colors_shopping_pic, for: .normal)
    }
        shopping_button.tag = 52
        shopping_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(25), bottom: 0, right: pause_screen_x_transform(25))
        
         restart_button = MyButton(frame: CGRect(x: pause_screen_x_transform(137.5), y: pause_screen_y_transform(190), width: pause_screen_x_transform(100), height: pause_screen_y_transform(85)))
            //
        if(ThemeType == 1 || ThemeType == 2){
        restart_button.setBackgroundImage(restart_pic, for: .normal)
        }
        else if(ThemeType == 3){
            restart_button.setBackgroundImage(BW_restart_pic, for: .normal)
        }
        else if(ThemeType == 4){
            restart_button.setBackgroundImage(chaos_restart_small_pic, for: .normal)
        }else if(ThemeType == 5){
            restart_button.setBackgroundImage(school_restart_small_pic, for: .normal)
        }else if (ThemeType == 6){
            restart_button.setBackgroundImage(colors_restart_small_pic, for: .normal)
        }
        restart_button.tag = 53
        restart_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(25), bottom: 0, right: pause_screen_x_transform(25))
        
        let change_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(222.5), y: pause_screen_y_transform(570), width: pause_screen_x_transform(100), height: pause_screen_y_transform(30)))
        change_theme_button.setTitle("day/night", for: .normal)
        change_theme_button.setTitleColor(.red, for: .normal)
        change_theme_button.tag = 54
        
        //let theme_menu_button = MyButton(frame: CG)
    
        
        continue_button.whenButtonIsClicked(action:{
            self.pause_screen.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.continue_button.removeFromSuperview()
            self.home_button.removeFromSuperview()
            self.shopping_button.removeFromSuperview()
            self.restart_button.removeFromSuperview()
            change_theme_button.removeFromSuperview()
            self.pause_screen.removeFromSuperview()
            self.paused = false
            //self.audioPlayer.play()
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()

        })
        
        shopping_button.whenButtonIsClicked(action:{
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            self.theme_menu_action()
        })
        
        restart_button.whenButtonIsClicked(action:{

            self.restart_player.play()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GameBoardViewController") as! GameBoardViewController
            nextViewController.ThemeType = self.ThemeType
            nextViewController.modalTransitionStyle = .crossDissolve
            self.present(nextViewController, animated: true, completion: nil)
            //self.timer.invalidate()

        })
        
        self.home_button.whenButtonIsClicked(action:{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            nextViewController.modalTransitionStyle = .crossDissolve
            self.present(nextViewController, animated: true, completion: nil)
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()

           // self.timer.invalidate()
        })
        
        
        continue_button.alpha = 0
        self.home_button.alpha = 0
        shopping_button.alpha = 0
        restart_button.alpha = 0
        self.view.addSubview(continue_button)
        self.view.addSubview(home_button)
        self.view.addSubview(shopping_button)
        self.view.addSubview(restart_button)
        //self.view.addSubview(change_theme_button)
        
        //fade in
        continue_button.fadeInWithDisplacement()
        home_button.fadeInWithDisplacement()
        shopping_button.fadeInWithDisplacement()
        restart_button.fadeInWithDisplacement()
        
        
        
        
    }
    
    @IBOutlet weak var pause: UIButton!
    @IBOutlet weak var trophy: UIImageView!
    
    //function in response to drag movement
    func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
        if (!paused && !in_theme_menu){
            
        
        var actual_type_index = 0
        var actual_location = CGPoint(x:0, y:0)
        //if original frame contains the initial point
        if(green_drag_tri_orig_rec.contains(initialTouchLocation)){
            if (exist1 == false){
                return
            }
  
            position_in_use = 0
            //alternative_drag_tri = green_drag_tri
            let transition0 = gesture.translation(in: green_drag_tri)
            green_drag_tri.frame.origin = CGPoint(x: green_drag_origin.x+transition0.x , y: green_drag_origin.y+transition0.y)
            actual_type_index = shape_type_index[0]
            actual_location = green_drag_tri.frame.origin
            green_drag_tri_x_constraint.constant = -100
            green_drag_tri_y_constraint.constant = -100
        } else if(orange_drag_tri_orig_rec.contains(initialTouchLocation)){
            if (exist2 == false){
                return
            }
            position_in_use = 1
            //alternative_drag_tri = orange_drag_tri
            let transition1 = gesture.translation(in: orange_drag_tri)
            orange_drag_tri.frame.origin = CGPoint(x:orange_drag_origin.x+transition1.x , y:orange_drag_origin.y+transition1.y)
            actual_type_index = shape_type_index[1]
            actual_location = orange_drag_tri.frame.origin
            orange_drag_tri_x_constraint.constant = -100
            orange_drag_tri_y_constraint.constant = -100
        }else if(light_brown_drag_tri_orig_rec.contains(initialTouchLocation)){
            if (exist3 == false){
                return
            }
            position_in_use = 2
            //alternative_drag_tri = *light_brown_drag_tri
            let transition2 = gesture.translation(in: light_brown_drag_tri)
            light_brown_drag_tri.frame.origin = CGPoint(x:light_brown_drag_origin.x+transition2.x , y:light_brown_drag_origin.y+transition2.y)
            actual_type_index = shape_type_index[2]
            actual_location = light_brown_drag_tri.frame.origin
            light_brown_drag_tri_x_constraint.constant = -100
            light_brown_drag_tri_y_constraint.constant = -100
        }
        
        //when dragging, keep scanning whether the shape fits any space
       /** if( Shape_fitting_When_Dragging(Shape_Type: actual_type_index, position: actual_location) ){
        
        
        } else if (!Shape_fitting_When_Dragging(Shape_Type: actual_type_index, position: actual_location)){
           Restore_Grey_Tris()
            if(position_in_use == 0){
                green_drag_tri.image = generator_array [actual_type_index]
           }
            else if(position_in_use == 1){
                orange_drag_tri.image = generator_array [actual_type_index]
        }else if(position_in_use == 2){
                 light_brown_drag_tri.image = generator_array [actual_type_index]
        }
        }
 **/
        
    
        //if dragging ended, return to original location (with animiation)
        if(gesture.state == .ended){
            let cond_before_insert = filled
            if (Shape_fitting(Shape_Type: actual_type_index, position: actual_location)){
                //play fit in sound effect
                do{
                    fit_in_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Fit_In", ofType: "aif")!))
                    fit_in_player.prepareToPlay()
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                    try AVAudioSession.sharedInstance().setActive(false)
                }
                catch{
                    //print("error")
                }
                fit_in_player.play()
                let cond_before_erase = filled
                last_score = score
                modify_counter(before: cond_before_insert, after: cond_before_erase)
                current_score = score
                star_score_increment()
                Check_and_Erase()
                let cond_after_erase = filled
                last_score = score
                modify_counter_after_erase(before: cond_before_erase, after: cond_after_erase)
                current_score = score
                star_score_increment()
               //if the triangles are fit
                if (position_in_use == 0){
                    green_drag_tri.frame.origin = green_drag_origin
                    green_drag_tri_x_constraint.constant = CGFloat(4)
                    green_drag_tri_y_constraint.constant = CGFloat(51)
                    green_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                    exist1 = false
                }else if (position_in_use == 1){
                    orange_drag_tri.frame.origin = orange_drag_origin
                    orange_drag_tri_x_constraint.constant = CGFloat(4.5)
                    orange_drag_tri_y_constraint.constant = CGFloat(51)
                    orange_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                    exist2 = false
                }else if (position_in_use == 2){
                    light_brown_drag_tri.frame.origin = light_brown_drag_origin
                    light_brown_drag_tri_x_constraint.constant = CGFloat(3.5)
                    light_brown_drag_tri_y_constraint.constant = CGFloat(51)
                    light_brown_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                    exist3 = false
                }
                position_in_use = 3
                
                
               

                //
                if(Eligible_to_Generate()){
                    auto_random_generator()
                    

                }
                    
                if(Check_for_Gameover()){
            // here code perfomed with delay
  
                self.Jump_to_Game_Over ()
    
                    //print("haaaaaaaaaaaaaaaaa")
                    //let subView = UIView.init(frame: CGRect(origin: CGPoint(x: 0, y:0 ), size: CGSize(width: 200, height: 100)))
                   // subView.backgroundColor = UIColor.yellow
                   // self.view.addSubview(subView)
                
            
                }

                
            } else {
                do{not_fit_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "not_fit", ofType: "wav")!))
                    not_fit_player.prepareToPlay()
                }
                catch{
                    
                }
                not_fit_player.play()
         
                UIView.animate(withDuration: 0.3, animations: {
                    if(self.position_in_use == 0){
                    self.green_drag_tri.frame.origin = self.green_drag_origin
                    }else if(self.position_in_use == 1){
                    self.orange_drag_tri.frame.origin = self.orange_drag_origin
                    }else if(self.position_in_use == 2){
                    self.light_brown_drag_tri.frame.origin = self.light_brown_drag_origin
                    }
                }, completion: {
                    (finished) -> Void in
                    UIView.animate(withDuration: 0.3, animations: {
                        if(self.position_in_use == 0){
                        self.green_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                        }else if(self.position_in_use == 1){
                        self.orange_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                        }else if(self.position_in_use == 2){
                        self.light_brown_drag_tri.transform = CGAffineTransform(scaleX: CGFloat(0.6), y: CGFloat(0.6))
                        }

                    }, completion: {
                   (finished) -> Void in
                        self.position_in_use = 3
                        self.green_drag_tri_x_constraint.constant = CGFloat(4)
                        self.green_drag_tri_y_constraint.constant = CGFloat(51)
                        self.orange_drag_tri_x_constraint.constant = CGFloat(4.5)
                        self.orange_drag_tri_y_constraint.constant = CGFloat(51)
                        self.light_brown_drag_tri_x_constraint.constant = CGFloat(3.5)
                        self.light_brown_drag_tri_y_constraint.constant = CGFloat(51)
                        
   
                        
                    })
   
                })
                
                
            }
            

        }
        }
        else if(in_theme_menu){
            let transition0 = gesture.translation(in: day_theme_button)
            //上1/3和下1/3的空间
            if(day_theme_button.frame.origin.y < (pause_screen_y_transform(145)+day_theme_button.frame.height/3) && school_theme_button.frame.origin.y > pause_screen_y_transform(493+144) - school_theme_button.frame.height/3 - school_theme_button.frame.height){
                day_theme_button.frame.origin = CGPoint(x: day_theme_origin.x, y: (day_theme_origin.y + transition0.y))
                night_theme_button.frame.origin = CGPoint(x: night_theme_origin.x, y: (night_theme_origin.y + transition0.y))
                BW_theme_button.frame.origin = CGPoint(x: BW_theme_origin.x, y: (BW_theme_origin.y + transition0.y))
                chaos_theme_button.frame.origin = CGPoint(x: chaos_theme_origin.x, y: (chaos_theme_origin.y + transition0.y))
                school_theme_button.frame.origin = CGPoint(x: school_theme_origin.x, y: (school_theme_origin.y + transition0.y))
                colors_theme_button.frame.origin = CGPoint(x: colors_theme_origin.x, y: (colors_theme_origin.y + transition0.y))
                if(gesture.state == .ended){
                    day_theme_origin.y = day_theme_button.frame.origin.y
                    night_theme_origin.y = night_theme_button.frame.origin.y
                    BW_theme_origin.y = BW_theme_button.frame.origin.y
                    chaos_theme_origin.y = chaos_theme_button.frame.origin.y
                    school_theme_origin.y = school_theme_button.frame.origin.y
                    colors_theme_origin.y = colors_theme_button.frame.origin.y
                }
            }else{
                if(gesture.state == .ended){
                    day_theme_origin.y = pause_screen_y_transform(145)
                    night_theme_origin.y =  pause_screen_y_transform(145)
                    BW_theme_origin.y = pause_screen_y_transform(319)
                    chaos_theme_origin.y = pause_screen_y_transform(319)
                    school_theme_origin.y = pause_screen_y_transform(493)
                    colors_theme_origin.y = pause_screen_y_transform(493)
                    UIView.animate(withDuration: 0.5, animations: {
                        self.day_theme_button.frame.origin.y = self.day_theme_origin.y
                        self.night_theme_button.frame.origin.y = self.night_theme_origin.y
                        self.BW_theme_button.frame.origin.y = self.BW_theme_origin.y
                        self.chaos_theme_button.frame.origin.y = self.chaos_theme_origin.y
                        self.school_theme_button.frame.origin.y = self.school_theme_origin.y
                        self.colors_theme_button.frame.origin.y = self.colors_theme_origin.y
                        
                    })
                }
            }
            
            
            
        }
        
  
            
            
            
            
        }
    
    
    //compute distance between two CGPoint (Square Form) (not using rn)
    func distance_generator( drag_location: CGPoint, triangle_location: CGPoint) -> Double {
        let temp_distance = (drag_location.x-triangle_location.x)*(drag_location.x-triangle_location.x)+(drag_location.y-triangle_location.y)*(drag_location.y-triangle_location.y)
        return Double(temp_distance)
    }
    //--------------------------------------------------------------------------------------------------------------------
    //pause button activate
    
    @IBAction func pauseButton(_ sender: UIButton) {
        
        
    }
    
    func change_all_back_tris_image() -> Void{
        tri_0_0_back.image = upwards_tri
        tri_0_1_back.image = downwards_tri
        tri_0_2_back.image = upwards_tri
        tri_0_3_back.image = downwards_tri
        tri_0_4_back.image = upwards_tri
        tri_0_5_back.image = downwards_tri
        tri_0_6_back.image = upwards_tri
        
        tri_1_0_back.image = upwards_tri
        tri_1_1_back.image = downwards_tri
        tri_1_2_back.image = upwards_tri
        tri_1_3_back.image = downwards_tri
        tri_1_4_back.image = upwards_tri
        tri_1_5_back.image = downwards_tri
        tri_1_6_back.image = upwards_tri
        tri_1_7_back.image = downwards_tri
        tri_1_8_back.image = upwards_tri
        
        tri_2_0_back.image = upwards_tri
        tri_2_1_back.image = downwards_tri
        tri_2_2_back.image = upwards_tri
        tri_2_3_back.image = downwards_tri
        tri_2_4_back.image = upwards_tri
        tri_2_5_back.image = downwards_tri
        tri_2_6_back.image = upwards_tri
        tri_2_7_back.image = downwards_tri
        tri_2_8_back.image = upwards_tri
        tri_2_9_back.image = downwards_tri
        tri_2_10_back.image = upwards_tri
        
        tri_3_0_back.image = downwards_tri
        tri_3_1_back.image = upwards_tri
        tri_3_2_back.image = downwards_tri
        tri_3_3_back.image = upwards_tri
        tri_3_4_back.image = downwards_tri
        tri_3_5_back.image = upwards_tri
        tri_3_6_back.image = downwards_tri
        tri_3_7_back.image = upwards_tri
        tri_3_8_back.image = downwards_tri
        tri_3_9_back.image = upwards_tri
        tri_3_10_back.image = downwards_tri
        
        tri_4_0_back.image = downwards_tri
        tri_4_1_back.image = upwards_tri
        tri_4_2_back.image = downwards_tri
        tri_4_3_back.image = upwards_tri
        tri_4_4_back.image = downwards_tri
        tri_4_5_back.image = upwards_tri
        tri_4_6_back.image = downwards_tri
        tri_4_7_back.image = upwards_tri
        tri_4_8_back.image = downwards_tri
        
        tri_5_0_back.image = downwards_tri
        tri_5_1_back.image = upwards_tri
        tri_5_2_back.image = downwards_tri
        tri_5_3_back.image = upwards_tri
        tri_5_4_back.image = downwards_tri
        tri_5_5_back.image = upwards_tri
        tri_5_6_back.image = downwards_tri
    }
    
    
    //--------------------------------------------------------------------------------------------------------------------
    //construct a list of colors that will be implemented in gameboard
    
    //color No.0 is 绿色tri (st 0)
    let tri_color_0 = UIColor(red:CGFloat(113/255.0), green:CGFloat(148/255.0), blue:CGFloat(92/255.0), alpha:CGFloat(1))
    
    //color No.1 is 橙色tri (st 1)
    let tri_color_1 = UIColor(red:CGFloat(223/255.0), green:CGFloat(110/255.0), blue:CGFloat(67/255.0), alpha:CGFloat(1))
    
    //color No.2 is 棕色tri (st 2 3 4)
    let tri_color_2 = UIColor(red:CGFloat(213/255.0), green:CGFloat(193/255.0), blue:CGFloat(151/255.0), alpha:CGFloat(1))
    
    //color No.3 is dark green (st 5)
    let tri_color_3 = UIColor(red:CGFloat(27/255.0), green:CGFloat(58/255.0), blue:CGFloat(49/255.0), alpha:CGFloat(1))
    
    //color No.4 is not yet used
     let tri_color_4 = UIColor(red:CGFloat(111/255.0), green:CGFloat(151/255.0), blue:CGFloat(91/255.0), alpha:CGFloat(1))
    
    //color No.5 is trans
    let tri_color_5 = UIColor(red:CGFloat(111/255.0), green:CGFloat(151/255.0), blue:CGFloat(91/255.0), alpha:CGFloat(0))
    
    
    //--------------------------------------------------------------------------------------------------------------------
    
    
    
    
    
    
    
    //--------------------------------------------------------------------------------------------------------------------
    //outlet connection variable for each triangle in gameboard
    //name follows protocol:
    //  "tri_(row)_(column)"
    @IBOutlet weak var tri_0_0: UIImageView!
    @IBOutlet weak var tri_0_1: UIImageView!
    @IBOutlet weak var tri_0_2: UIImageView!
    @IBOutlet weak var tri_0_3: UIImageView!
    @IBOutlet weak var tri_0_4: UIImageView!
    @IBOutlet weak var tri_0_5: UIImageView!
    @IBOutlet weak var tri_0_6: UIImageView!
    @IBOutlet weak var tri_1_0: UIImageView!
    @IBOutlet weak var tri_1_1: UIImageView!
    @IBOutlet weak var tri_1_2: UIImageView!
    @IBOutlet weak var tri_1_3: UIImageView!
    @IBOutlet weak var tri_1_4: UIImageView!
    @IBOutlet weak var tri_1_5: UIImageView!
    @IBOutlet weak var tri_1_6: UIImageView!
    @IBOutlet weak var tri_1_7: UIImageView!
    @IBOutlet weak var tri_1_8: UIImageView!
    @IBOutlet weak var tri_2_0: UIImageView!
    @IBOutlet weak var tri_2_1: UIImageView!
    @IBOutlet weak var tri_2_2: UIImageView!
    @IBOutlet weak var tri_2_3: UIImageView!
    @IBOutlet weak var tri_2_4: UIImageView!
    @IBOutlet weak var tri_2_5: UIImageView!
    @IBOutlet weak var tri_2_6: UIImageView!
    @IBOutlet weak var tri_2_7: UIImageView!
    @IBOutlet weak var tri_2_8: UIImageView!
    @IBOutlet weak var tri_2_9: UIImageView!
    @IBOutlet weak var tri_2_10: UIImageView!
    @IBOutlet weak var tri_3_0: UIImageView!
    @IBOutlet weak var tri_3_1: UIImageView!
    @IBOutlet weak var tri_3_2: UIImageView!
    @IBOutlet weak var tri_3_3: UIImageView!
    @IBOutlet weak var tri_3_4: UIImageView!
    @IBOutlet weak var tri_3_5: UIImageView!
    @IBOutlet weak var tri_3_6: UIImageView!
    @IBOutlet weak var tri_3_7: UIImageView!
    @IBOutlet weak var tri_3_8: UIImageView!
    @IBOutlet weak var tri_3_9: UIImageView!
    @IBOutlet weak var tri_3_10: UIImageView!
    @IBOutlet weak var tri_4_0: UIImageView!
    @IBOutlet weak var tri_4_1: UIImageView!
    @IBOutlet weak var tri_4_2: UIImageView!
    @IBOutlet weak var tri_4_3: UIImageView!
    @IBOutlet weak var tri_4_4: UIImageView!
    @IBOutlet weak var tri_4_5: UIImageView!
    @IBOutlet weak var tri_4_6: UIImageView!
    @IBOutlet weak var tri_4_7: UIImageView!
    @IBOutlet weak var tri_4_8: UIImageView!
    @IBOutlet weak var tri_5_0: UIImageView!
    @IBOutlet weak var tri_5_1: UIImageView!
    @IBOutlet weak var tri_5_2: UIImageView!
    @IBOutlet weak var tri_5_3: UIImageView!
    @IBOutlet weak var tri_5_4: UIImageView!
    @IBOutlet weak var tri_5_5: UIImageView!
    @IBOutlet weak var tri_5_6: UIImageView!
    
    
    
    //following stores the triangle used for background
    
    @IBOutlet weak var tri_0_0_back: UIImageView!
    @IBOutlet weak var tri_0_1_back: UIImageView!
    @IBOutlet weak var tri_0_2_back: UIImageView!
    @IBOutlet weak var tri_0_3_back: UIImageView!
    @IBOutlet weak var tri_0_4_back: UIImageView!
    @IBOutlet weak var tri_0_5_back: UIImageView!
    @IBOutlet weak var tri_0_6_back: UIImageView!
    
    @IBOutlet weak var tri_1_0_back: UIImageView!
    @IBOutlet weak var tri_1_1_back: UIImageView!
    @IBOutlet weak var tri_1_2_back: UIImageView!
    @IBOutlet weak var tri_1_3_back: UIImageView!
    @IBOutlet weak var tri_1_4_back: UIImageView!
    @IBOutlet weak var tri_1_5_back: UIImageView!
    @IBOutlet weak var tri_1_6_back: UIImageView!
    @IBOutlet weak var tri_1_7_back: UIImageView!
    @IBOutlet weak var tri_1_8_back: UIImageView!
    
    @IBOutlet weak var tri_2_0_back: UIImageView!
    @IBOutlet weak var tri_2_1_back: UIImageView!
    @IBOutlet weak var tri_2_2_back: UIImageView!
    @IBOutlet weak var tri_2_3_back: UIImageView!
    @IBOutlet weak var tri_2_4_back: UIImageView!
    @IBOutlet weak var tri_2_5_back: UIImageView!
    
    @IBOutlet weak var tri_2_6_back: UIImageView!
    
    
    @IBOutlet weak var tri_2_7_back: UIImageView!
    @IBOutlet weak var tri_2_8_back: UIImageView!
    @IBOutlet weak var tri_2_9_back: UIImageView!
    @IBOutlet weak var tri_2_10_back: UIImageView!
    
    @IBOutlet weak var tri_3_0_back: UIImageView!
    @IBOutlet weak var tri_3_1_back: UIImageView!
    @IBOutlet weak var tri_3_2_back: UIImageView!
    @IBOutlet weak var tri_3_3_back: UIImageView!
    @IBOutlet weak var tri_3_4_back: UIImageView!
    @IBOutlet weak var tri_3_5_back: UIImageView!
    @IBOutlet weak var tri_3_6_back: UIImageView!
    @IBOutlet weak var tri_3_7_back: UIImageView!
    @IBOutlet weak var tri_3_8_back: UIImageView!
    @IBOutlet weak var tri_3_9_back: UIImageView!
    @IBOutlet weak var tri_3_10_back: UIImageView!
    
    @IBOutlet weak var tri_4_0_back: UIImageView!
    @IBOutlet weak var tri_4_1_back: UIImageView!
    @IBOutlet weak var tri_4_2_back: UIImageView!
    @IBOutlet weak var tri_4_3_back: UIImageView!
    @IBOutlet weak var tri_4_4_back: UIImageView!
    @IBOutlet weak var tri_4_5_back: UIImageView!
    @IBOutlet weak var tri_4_6_back: UIImageView!
    @IBOutlet weak var tri_4_7_back: UIImageView!
    @IBOutlet weak var tri_4_8_back: UIImageView!
    
    @IBOutlet weak var tri_5_0_back: UIImageView!
    @IBOutlet weak var tri_5_1_back: UIImageView!
    @IBOutlet weak var tri_5_2_back: UIImageView!
    @IBOutlet weak var tri_5_3_back: UIImageView!
    @IBOutlet weak var tri_5_4_back: UIImageView!
    @IBOutlet weak var tri_5_5_back: UIImageView!
    @IBOutlet weak var tri_5_6_back: UIImageView!
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   //--------------------------------------------------------------------------------------------------------------------
    
    //2-D array saves whether each triangle is filled or not
    var filled: Array<Array<Bool>> = [[false,false,false,false,false,false,false],[false,false,false,false,false,false,false,false,false],[false,false,false,false,false,false,false,false, false,false, false],[false,false,false,false,false,false,false,false, false,false, false],[false,false,false,false,false,false,false,false, false],[false,false,false,false,false,false,false]]
    
    //store the current block type of any single tri
    //-1 imply that the tri is not occupied
    var single_tri_stored_type_index: Array<Array<Int>> = [[-1,-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,-1,-1,-1, -1,-1, -1],[-1,-1,-1,-1,-1,-1,-1,-1, -1,-1, -1],[-1,-1,-1,-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,-1,-1]]

    //2-D array saves corresponding location
    var tri_location: Array<Array<CGPoint>> = [
        [CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 )],
        [CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 )],
        [CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 )],
        [CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 )],
        [CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 )],
        [CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 ),CGPoint(x: 0, y:0 )]]
    
    
//--------------------------------------------------------------------------------------------------------------------
//set two default grey triangle
    
//downwards triangle
    var downwards_tri = UIImage(named:"grey_tir_downwards")
    
//upwards triangle
    var upwards_tri = UIImage(named:"grey_tri_upwards")

//green tri elements
    let super_light_green_down = UIImage(named:"super_light_green_down")
    
    let super_light_green_up = UIImage(named:"super_light_green_up")
    
//orange tri elements
    
    let orange_down = UIImage(named:"orange_downwards")
    
    let orange_up = UIImage(named:"orange_up")
    
//light brown elements
    
    let light_brown_up = UIImage(named:"light_brown_up")
    
    let light_brown_down = UIImage(named:"light_brown_down")
    
//dark green elements
    
    let dark_green_up = UIImage(named:"green_up")
    
    let dark_green_down = UIImage(named:"green_down")
    
//pink elements
    
    let pink_up = UIImage(named:"pink_upwards")
    
    let pink_down = UIImage(named:"pink_downwards")
    
//purple elements
    
    let pur_up = UIImage(named:"purple_upwards")
    
    let pur_down = UIImage(named:"purple_downwards")
    
//小肉 elements
    
    let meat_up = UIImage(named:"小肉 up")
    
    let meat_down = UIImage(named:"小肉 down")
    
//black elements
    let BW_black_up = UIImage(named:"BW_black_tri_up")
    let BW_black_down = UIImage(named:"BW_black_tri_down")
    
//chaos elements
    let chaos_up = UIImage(named:"chaos_up")
    let chaos_up_left = UIImage(named:"chaos_up_left")
    let chaos_up_right = UIImage(named:"chaos_up_right")
    let chaos_up_3 = UIImage(named:"chaos_up")
    let chaos_up_4 = UIImage(named:"chaos_up_left")
    let chaos_up_5 = UIImage(named:"chaos_up_right")
    let chaos_down = UIImage(named:"chaos_down")
    

//colors elements
    let colors_green_up = UIImage(named:"colors_green_up")
    let colors_green_down = UIImage(named:"colors_green_down")
    let colors_blue_up = UIImage(named: "colors_blue_up")
    let colors_blue_down = UIImage(named: "colors_blue_down")
    let colors_gold_up = UIImage(named: "colors_gold_up")
    let colors_gold_down = UIImage(named: "colors_gold_down")
    let colors_pink_up = UIImage(named: "colors_pink_up")
    let colors_pink_down = UIImage(named: "colors_pink_down")
    
    

//school elements
    let school_up = UIImage(named:"school_up")
    let school_up_left = UIImage(named:"school_up-left")
    let school_up_right = UIImage(named:"school_up-right")
    let school_down = UIImage(named:"school_down")

//pause icons
    
    let home_pic = UIImage(named:"home")
    
    let restart_pic = UIImage(named:"restart")
    
    let like_pic = UIImage(named:"like")
    
    let shopping_pic = UIImage(named:"shopping_cart")
    
    let continue_pic = UIImage(named:"continue")
    
    let night_home_pic = UIImage(named:"night mode home")
    
    let BW_home_pic = UIImage(named:"BW_home")
    
    let BW_continue_pic = UIImage(named:"BW_continue")
    
    let BW_shopping_pic = UIImage(named:"BW_shopping")
    
    let BW_restart_pic = UIImage(named:"BW_restart")
    
    let BW_like_pic = UIImage(named:"BW_like")
    
    let chaos_home_pic = UIImage(named:"chaos_home_icon")
    
    let chaos_continue_pic = UIImage(named:"chaos_start_icon")
    
    let chaos_shopping_pic = UIImage(named:"chaos_theme_button")
    
    let chaos_restart_small_pic = UIImage(named:"chaos_restart_small")
    
    let chaos_restart_big_pic = UIImage(named:"chaos_restart_big")
    
    let chaos_like_pic = UIImage(named:"chaos_like_icon")
    

    let colors_home_pic = UIImage(named:"colors_home-icon")
    
    let colors_continue_pic = UIImage(named:"colors_start")
    
    let colors_shopping_pic = UIImage(named:"colors_theme-button")
    
    let colors_restart_small_pic = UIImage(named:"colors_restart")
    
    let colors_restart_big_pic = UIImage(named:"colors_restart-big")
    
    let colors_like_pic = UIImage(named:"colors_like-icon")

    let school_home_pic = UIImage(named:"school_home-icon")
    
    let school_continue_pic = UIImage(named:"school_start-icon")
    
    let school_shopping_pic = UIImage(named:"school_theme-button")
    
    let school_restart_small_pic = UIImage(named:"school_restart_small")
    
    let school_restart_big_pic = UIImage(named:"school_restart_big")
    
    let school_like_pic = UIImage(named:"school_like-icon")

//--------------------------------------------------------------------------------------------------------------------

    
    
    
    
    
    
    //outlet connection variable for MarkBoard (top left)
    @IBOutlet weak var MarkBoard: UILabel!
    

    
    func auto_make_transparent() -> Void {
        
        if(position_in_use == 0){
            green_drag_tri.image = UIImage(named:"绿色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
        }else if(position_in_use == 1){
           orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
        }else if(position_in_use == 2){
             light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
        }

    }
    
    
    
    func Shape_fitting(Shape_Type: Int, position: CGPoint) -> Bool {
        if (Shape_Type == 0){
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1 || i == 2){//upper half
                    if (j%2 == 1){//only downward
                        if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                            position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                            if (!filled[i][j] && !filled[i][j-1] && !filled[i][j+1]){//check available
                                
                                //green_drag_tri.image = UIImage(named:"绿色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                auto_make_transparent()
                                if(ThemeType == 1 || ThemeType == 2){
                                Change_Corresponding_Color_With_Image(x:i, y:j, image: super_light_green_down)
                                Change_Corresponding_Color_With_Image(x:i, y:j-1, image: super_light_green_up)
                                Change_Corresponding_Color_With_Image(x:i, y:j+1, image: super_light_green_up)
                                }else if(ThemeType == 3){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_up)
   
                                }else if(ThemeType == 4){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_up)

                                }else if(ThemeType == 5){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: school_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_up)

                                }else if(ThemeType == 6){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_green_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_green_up)
                                }
                                
                                filled[i][j] = true
                                filled[i][j-1] = true
                                filled[i][j+1] = true
                                single_tri_stored_type_index[i][j] = 0
                                single_tri_stored_type_index[i][j-1] = 0
                                single_tri_stored_type_index[i][j+1] = 0
                                
                                return true
                            }
                            return false
                        }
                    }
                        
                    } else if (i == 3 || i == 4 || i == 5){
                        if (j%2 == 0 && j != 0 && j != tri_location[i].count - 1){//lower half&&not edge
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i][j+1]){
                                    //green_drag_tri.image = UIImage(named:"绿色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: super_light_green_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: super_light_green_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_up)
   
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_up)
                                        
                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_up)
                                        
                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_green_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_green_up)
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j-1] = true
                                    filled[i][j+1] = true
                                    single_tri_stored_type_index[i][j] = 0
                                    single_tri_stored_type_index[i][j-1] = 0
                                    single_tri_stored_type_index[i][j+1] = 0
                                   
                                    return true
                                }
                                return false
                            }
                        }

                    }
                    j += 1
                }
                i += 1
            }
        } else if (Shape_Type == 1){
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1){//upper half row 0 1
                        if (j%2 == 0){//only upward
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 4 <= triangle_location.y + 20 && position.y + 4 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i+1][j+1]){//check available
                                    //orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: orange_up)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: orange_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: school_down)
                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: colors_green_down)
                                        
                                    }
                                    filled[i+1][j+1] = true
                                    filled[i][j] = true
                                    single_tri_stored_type_index[i][j] = 1
                                    single_tri_stored_type_index[i+1][j+1] = 1
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 2){//upper half row 2
                        if (j%2 == 0){//only upward
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 4 <= triangle_location.y + 20 && position.y + 4 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i+1][j]){//check available
                                    //orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: orange_up)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j, image: orange_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: BW_black_down)
  
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: chaos_down)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: school_down)
                                        
                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: colors_green_down)
                                        
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i+1][j] = true
                                    single_tri_stored_type_index[i][j] = 1
                                    single_tri_stored_type_index[i+1][j] = 1
                                

                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 3 || i == 4){
                        if (j%2 == 1){//lower half
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 4 <= triangle_location.y + 20 && position.y + 4 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i+1][j-1]){
                                    //orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: orange_up)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: orange_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_up)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: colors_green_down)
                                        
                                    }
                        
                                    
                                    filled[i][j] = true
                                    filled[i+1][j-1] = true
                                    single_tri_stored_type_index[i][j] = 1
                                    single_tri_stored_type_index[i+1][j-1] = 1
                                 

                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
        } else if (Shape_Type == 2) {    //Shape_Type == 2
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 1 || i == 2){//upper half row 1 2
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 48 <= triangle_location.y + 20 && position.y + 48 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i-1][j]){//check available
                                   //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i-1, y:j, image: light_brown_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: BW_black_up)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_5)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: school_up_right)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: colors_gold_up)
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i-1][j] = true
                                   
                                    single_tri_stored_type_index[i][j] = 2
                                    single_tri_stored_type_index[i][j+1] = 2
                                    single_tri_stored_type_index[i-1][j] = 2
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3){//lower half row 3
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 48 <= triangle_location.y + 20 && position.y + 48 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i-1][j+1]){//check available
                                   // light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: light_brown_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: BW_black_up)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_5)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: chaos_up_5)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: school_up_right)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: colors_gold_up)
                                        
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i-1][j+1] = true
                                    single_tri_stored_type_index[i][j] = 2
                                    single_tri_stored_type_index[i][j+1] = 2
                                    single_tri_stored_type_index[i-1][j+1] = 2
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 4 || i == 5){
                        if (j%2 == 1){//lower half
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 48 <= triangle_location.y + 20 && position.y + 48 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i-1][j+2]){
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: light_brown_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: BW_black_up)

                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_5)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: chaos_up_5)
                                        
                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: school_up_right)
                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: colors_gold_up)
                                        
                                        
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i-1][j+2] = true
                                    single_tri_stored_type_index[i][j] = 2
                                    single_tri_stored_type_index[i][j+1] = 2
                                    single_tri_stored_type_index[i-1][j+2] = 2
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }

        }
        else if (Shape_Type == 3) {    //Shape_Type == 3
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half row 1 2
                        if (j%2 == 0 && j != tri_location[i].count - 1 && j != 0){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1]){//check available
                                    
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_green_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_green_down)
                                        
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i][j-1] = true
                                    single_tri_stored_type_index[i][j] = 3
                                    single_tri_stored_type_index[i][j+1] = 3
                                    single_tri_stored_type_index[i][j-1] = 3
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1]){//check available
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_green_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_green_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_green_down)
                                        
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i][j-1] = true
                                    single_tri_stored_type_index[i][j] = 3
                                    single_tri_stored_type_index[i][j+1] = 3
                                    single_tri_stored_type_index[i][j-1] = 3
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 4) {    //Shape_Type == 4
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 1){//only downward
                            if (position.x + 15.5 <= triangle_location.x + 20 && position.x + 15.5 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: super_light_green_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_up)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_up_3)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_up)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_up)
 
                                    }
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    single_tri_stored_type_index[i][j] = 4
                                    single_tri_stored_type_index[i][j+1] = 4
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only downward
                            if (position.x + 15.5 <= triangle_location.x + 20 && position.x + 15.5 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: super_light_green_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_up)
    
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_up_3)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_up)
                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_up)
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    single_tri_stored_type_index[i][j] = 4
                                    single_tri_stored_type_index[i][j+1] = 4
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 5) {    //Shape_Type == 5
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 1 || i == 2){//upper half row 1 2
                        if (j%2 == 0 && j != 0 && j != tri_location[i].count - 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 46 <= triangle_location.y + 20 && position.y + 46 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1] && !filled[i-1][j] && !filled[i-1][j-2]){//check available
                                    
                                    auto_make_transparent()
                                    if (ThemeType == 1){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-2, image: dark_green_up)
                                    } else if(ThemeType == 2){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: meat_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: meat_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-2, image: meat_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-2, image: BW_black_up)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-2, image: chaos_up_right)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_left)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: school_up_left)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-2, image: school_up_left)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-2, image: colors_blue_up)
                                        
                                    }
                                    
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i][j-1] = true
                                    filled[i-1][j] = true
                                    filled[i-1][j-2] = true
                                    single_tri_stored_type_index[i][j] = 5
                                    single_tri_stored_type_index[i][j+1] = 5
                                    single_tri_stored_type_index[i][j-1] = 5
                                    single_tri_stored_type_index[i-1][j] = 5
                                    single_tri_stored_type_index[i-1][j-2] = 5
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3){//lower half row 3
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 46 <= triangle_location.y + 20 && position.y + 46 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1] && !filled[i-1][j-1] && !filled[i-1][j+1]){//check available
                                    
                                    auto_make_transparent()
                                    if (ThemeType == 1){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-1, image: dark_green_up)
                                    } else if (ThemeType == 2){
                                        
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: meat_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: meat_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: meat_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-1, image: meat_up)
                                    } else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-1, image: BW_black_up)

                                    } else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-1, image: chaos_up_right)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_left)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: school_up_left)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-1, image: school_up_left)
                                        

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+1, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j-1, image: colors_blue_up)
                                        
                                    }
                                    
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i][j-1] = true
                                    filled[i-1][j-1] = true
                                    filled[i-1][j+1] = true
                                    single_tri_stored_type_index[i][j] = 5
                                    single_tri_stored_type_index[i][j+1] = 5
                                    single_tri_stored_type_index[i][j-1] = 5
                                    single_tri_stored_type_index[i-1][j-1] = 5
                                    single_tri_stored_type_index[i-1][j+1] = 5
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 4 || i == 5){//lower half row 4 5
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 46 <= triangle_location.y + 20 && position.y + 46 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1] && !filled[i-1][j] && !filled[i-1][j+2]){//check available
                                    
                                    auto_make_transparent()
                                    if (ThemeType == 1){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: dark_green_up)
                                    } else if (ThemeType == 2){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: meat_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: meat_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: meat_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: meat_up)
                                    } else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: BW_black_up)
                                    } else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: chaos_down)
                                    }  else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_left)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: school_up_left)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: school_up_left)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_blue_down)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j+2, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i-1, y:j, image: colors_blue_up)
                                        
                                       // Change_Corresponding_Color_With_Image(x:i-1, y:j, image: chaos_up_right)
                                    }
                                    
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i][j-1] = true
                                    filled[i-1][j] = true
                                    filled[i-1][j+2] = true
                                    
                                    single_tri_stored_type_index[i][j] = 5
                                    single_tri_stored_type_index[i][j+1] = 5
                                    single_tri_stored_type_index[i][j-1] = 5
                                    single_tri_stored_type_index[i-1][j] = 5
                                    single_tri_stored_type_index[i-1][j+2] = 5
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 6) {    //Shape_Type == 6 pink right direction
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only upward not last one
                            if (position.x + 15 <= triangle_location.x + 20 && position.x + 15 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: pink_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: pink_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_down)
                                        
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    single_tri_stored_type_index[i][j] = 6
                                    single_tri_stored_type_index[i][j+1] = 6

                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 1){//only upward
                            if (position.x + 15 <= triangle_location.x + 20 && position.x + 15 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: pink_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: pink_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_blue_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_blue_down)
                                        
                                    }

                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    single_tri_stored_type_index[i][j] = 6
                                    single_tri_stored_type_index[i][j+1] = 6
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }

        else if (Shape_Type == 7) {    //Shape_Type == 7 purple single up
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 0){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: pur_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
    
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)
                                        
                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_pink_up)
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    single_tri_stored_type_index[i][j] = 7
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: pur_up)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
   
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_pink_up)
                                        
                                    }
                                    filled[i][j] = true
                                    single_tri_stored_type_index[i][j] = 7
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 8) {    //Shape_Type == 8 purple single down
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 1){//only downward
                            if (position.x + 28 <= triangle_location.x + 20 && position.x + 28 >= triangle_location.x - 20 &&
                                position.y + 24 <= triangle_location.y + 20 && position.y + 24 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: pur_down)
                                    }else if(ThemeType == 3){
                                     Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_pink_down)
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    single_tri_stored_type_index[i][j] = 8
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 0){//only downward
                            if (position.x + 28 <= triangle_location.x + 20 && position.x + 28 >= triangle_location.x - 20 &&
                                position.y + 24 <= triangle_location.y + 20 && position.y + 24 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: pur_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_down)
    
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_down)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_down)
                                        

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_pink_down)
                                        
                                    }
                                    filled[i][j] = true
                                    single_tri_stored_type_index[i][j] = 8
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 9) {    //Shape_Type == 9 brown left downwards
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1){//upper half row 0 1
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only upward
                            if (position.x + 3 <= triangle_location.x + 20 && position.x + 3 >= triangle_location.x - 20 &&
                                position.y + 3.5 <= triangle_location.y + 20 && position.y + 3.5 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i+1][j+1]){//check available
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: colors_gold_down)
                                        
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i+1][j+1] = true
                                    single_tri_stored_type_index[i][j] = 9
                                    single_tri_stored_type_index[i][j+1] = 9
                                    single_tri_stored_type_index[i+1][j+1] = 9
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 2){//upper half row 2
                        if (j%2 == 0){//only upward
                            if (position.x + 3 <= triangle_location.x + 20 && position.x + 3 >= triangle_location.x - 20 &&
                                position.y + 3.5 <= triangle_location.y + 20 && position.y + 3.5 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i+1][j]){//check available
                                    // light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: BW_black_down)

                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: chaos_down)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: school_down)
                                        

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: colors_gold_down)
                                        
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i+1][j] = true
                                    single_tri_stored_type_index[i][j] = 9
                                    single_tri_stored_type_index[i][j+1] = 9
                                    single_tri_stored_type_index[i+1][j] = 9
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 3 || i == 4){
                        if (j%2 == 1){//lower half row 3 4
                            if (position.x + 3 <= triangle_location.x + 20 && position.x + 3 >= triangle_location.x - 20 &&
                                position.y + 3.5 <= triangle_location.y + 20 && position.y + 3.5 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i+1][j-1]){
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j+1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: colors_gold_down)
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j+1] = true
                                    filled[i+1][j-1] = true
                                    single_tri_stored_type_index[i][j] = 9
                                    single_tri_stored_type_index[i][j+1] = 9
                                    single_tri_stored_type_index[i+1][j-1] = 9
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 10) {    //Shape_Type == 10 brown right downwards
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1){//upper half row 0 1
                        if (j%2 == 0 && j != 0){//only upward
                            if (position.x + 52 <= triangle_location.x + 20 && position.x + 52 >= triangle_location.x - 20 &&
                                position.y + 3 <= triangle_location.y + 20 && position.y + 3 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i+1][j+1]){//check available
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_5)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: colors_gold_down)
                                        
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    filled[i][j-1] = true
                                    filled[i+1][j+1] = true
                                    single_tri_stored_type_index[i][j] = 10
                                    single_tri_stored_type_index[i][j-1] = 10
                                    single_tri_stored_type_index[i+1][j+1] = 10
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 2){//upper half row 2
                        if (j%2 == 0 && j != 0){//only upward
                            if (position.x + 52 <= triangle_location.x + 20 && position.x + 52 >= triangle_location.x - 20 &&
                                position.y + 3 <= triangle_location.y + 20 && position.y + 3 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i+1][j]){//check available
                                    // light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: BW_black_down)

                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_5)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: chaos_down)
                                        

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j, image: colors_gold_down)
                                        
                                    }
                                    
                                    filled[i][j] = true
                                    filled[i][j-1] = true
                                    filled[i+1][j] = true
                                    single_tri_stored_type_index[i][j] = 10
                                    single_tri_stored_type_index[i][j-1] = 10
                                    single_tri_stored_type_index[i+1][j] = 10
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 3 || i == 4){
                        if (j%2 == 1){//lower half row 3, 4
                            if (position.x + 52 <= triangle_location.x + 20 && position.x + 52 >= triangle_location.x - 20 &&
                                position.y + 3 <= triangle_location.y + 20 && position.y + 3 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i+1][j-1]){
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    if(ThemeType == 1 || ThemeType == 2){
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: light_brown_down)
                                    }else if(ThemeType == 3){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: BW_black_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: BW_black_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: BW_black_down)
                                    }else if(ThemeType == 4){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: chaos_up_5)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: chaos_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: chaos_down)

                                    }else if(ThemeType == 5){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: school_up_right)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: school_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: school_down)

                                    }else if(ThemeType == 6){
                                        Change_Corresponding_Color_With_Image(x:i, y:j, image: colors_gold_up)
                                        Change_Corresponding_Color_With_Image(x:i, y:j-1, image: colors_gold_down)
                                        Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: colors_gold_down)
                                        
                                    }
                                    filled[i][j] = true
                                    filled[i][j-1] = true
                                    filled[i+1][j-1] = true
                                    single_tri_stored_type_index[i][j] = 10
                                    single_tri_stored_type_index[i][j-1] = 10
                                    single_tri_stored_type_index[i+1][j-1] = 10
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }

        return false
    }
    
    
    func Shape_fitting_When_Dragging(Shape_Type: Int, position: CGPoint) -> Bool {
        if (Shape_Type == 0){
            
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1 || i == 2){//upper half
                        if (j%2 == 1){//only downward
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i][j+1]){//check available
                                    //green_drag_tri.image = UIImage(named:"绿色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: super_light_green_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: super_light_green_up)
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    } else if (i == 3 || i == 4 || i == 5){
                        if (j%2 == 0 && j != 0 && j != tri_location[i].count - 1){//lower half&&not edge
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i][j+1]){
                                    //green_drag_tri.image = UIImage(named:"绿色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: super_light_green_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: super_light_green_up)
            
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
        } else if (Shape_Type == 1){
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1){//upper half row 0 1
                        if (j%2 == 0){//only upward
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 4 <= triangle_location.y + 20 && position.y + 4 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i+1][j+1]){//check available
                                    //orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: orange_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i+1, y:j+1, image: orange_down)
                           
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 2){//upper half row 2
                        if (j%2 == 0){//only upward
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 4 <= triangle_location.y + 20 && position.y + 4 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i+1][j]){//check available
                                    //orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: orange_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i+1, y:j, image: orange_down)
                              
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 3 || i == 4){
                        if (j%2 == 1){//lower half
                            if (position.x + 25 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 4 <= triangle_location.y + 20 && position.y + 4 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i+1][j-1]){
                                    //orange_drag_tri.image = UIImage(named:"橙色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: orange_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i+1, y:j-1, image: orange_down)
                                 
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
        } else if (Shape_Type == 2) {    //Shape_Type == 2
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 1 || i == 2){//upper half row 1 2
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 48 <= triangle_location.y + 20 && position.y + 48 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i-1][j]){//check available
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j, image: light_brown_up)
                                  
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3){//lower half row 3
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 48 <= triangle_location.y + 20 && position.y + 48 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i-1][j+1]){//check available
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j+1, image: light_brown_up)
                                   
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 4 || i == 5){
                        if (j%2 == 1){//lower half
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 48 <= triangle_location.y + 20 && position.y + 48 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i-1][j+2]){
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j+2, image: light_brown_up)
                                  
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 3) {    //Shape_Type == 3
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half row 1 2
                        if (j%2 == 0 && j != tri_location[i].count - 1 && j != 0){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 25 >= triangle_location.x - 20 &&
                                position.y + 27 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1]){//check available
                                    
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: light_brown_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1]){//check available
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: light_brown_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 4) {    //Shape_Type == 4
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 1){//only upward
                            if (position.x + 15.5 <= triangle_location.x + 20 && position.x + 15.5 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: super_light_green_up)
                                    
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only downward
                            if (position.x + 15.5 <= triangle_location.x + 20 && position.x + 15.5 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: super_light_green_down)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: super_light_green_up)
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 5) {    //Shape_Type == 5
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 1 || i == 2){//upper half row 1 2
                        if (j%2 == 0 && j != 0 && j != tri_location[i].count - 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 46 <= triangle_location.y + 20 && position.y + 46 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1] && !filled[i-1][j] && !filled[i-1][j-2]){//check available
                                    
                                    auto_make_transparent()
                                    if (ThemeType == 1){
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j-2, image: dark_green_up)
                                    } else if (ThemeType == 2){
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: meat_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: meat_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j-2, image: meat_up)
                                    }
                                    
                                    
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3){//lower half row 3
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 46 <= triangle_location.y + 20 && position.y + 46 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1] && !filled[i-1][j-1] && !filled[i-1][j+1]){//check available
                                    
                                    auto_make_transparent()
                                    if (ThemeType == 1){
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j+1, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j-1, image: dark_green_up)
                                        
                                    }else if (ThemeType == 2){
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: meat_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: meat_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: meat_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j+1, image: meat_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j-1, image: meat_up)
                                        
                                    }
                                   
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 4 || i == 5){//lower half row 4 5
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 46 <= triangle_location.y + 20 && position.y + 46 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i][j-1] && !filled[i-1][j] && !filled[i-1][j+2]){//check available
                                    
                                    auto_make_transparent()
                                    if (ThemeType == 1){
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: dark_green_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j+2, image: dark_green_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j, image: dark_green_up)
                                    } else if (ThemeType == 2){
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image:meat_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: meat_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j-1, image: meat_down)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j+2, image: meat_up)
                                        Change_Corresponding_Color_With_Image_Without_Animation(x:i-1, y:j, image: meat_up)
                                    }
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 6) {    //Shape_Type == 6 pink right direction
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only upward not last one
                            if (position.x + 15 <= triangle_location.x + 20 && position.x + 15 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: pink_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: pink_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 1){//only upward
                            if (position.x + 15 <= triangle_location.x + 20 && position.x + 15 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1]){//check available
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: pink_up)
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j+1, image: pink_down)
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 7) {    //Shape_Type == 7 purple single up
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 0){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: pur_up)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 1){//only upward
                            if (position.x + 27 <= triangle_location.x + 20 && position.x + 27 >= triangle_location.x - 20 &&
                                position.y + 25 <= triangle_location.y + 20 && position.y + 25 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: pur_up)
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 8) {    //Shape_Type == 8 purple single down
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0||i == 1 || i == 2){//upper half
                        if (j%2 == 1){//only downward
                            if (position.x + 28 <= triangle_location.x + 20 && position.x + 28 >= triangle_location.x - 20 &&
                                position.y + 24 <= triangle_location.y + 20 && position.y + 24 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: pur_down)
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 3 || i == 4 || i == 5){//lower half
                        if (j%2 == 0){//only downward
                            if (position.x + 28 <= triangle_location.x + 20 && position.x + 28 >= triangle_location.x - 20 &&
                                position.y + 24 <= triangle_location.y + 20 && position.y + 24 >= triangle_location.y - 20){//check location
                                if (!filled[i][j]){//check available
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image_Without_Animation(x:i, y:j, image: pur_down)
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 9) {    //Shape_Type == 9 brown left downwards
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1){//upper half row 0 1
                        if (j%2 == 0 && j != tri_location[i].count - 1){//only upward
                            if (position.x + 3 <= triangle_location.x + 20 && position.x + 3 >= triangle_location.x - 20 &&
                                position.y + 3.5 <= triangle_location.y + 20 && position.y + 3.5 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i+1][j+1]){//check available
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: light_brown_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 2){//lower half row 2
                        if (j%2 == 0){//only upward
                            if (position.x + 3 <= triangle_location.x + 20 && position.x + 3 >= triangle_location.x - 20 &&
                                position.y + 3.5 <= triangle_location.y + 20 && position.y + 3.5 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i+1][j]){//check available
                                    // light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j, image: light_brown_down)
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 3 || i == 4){
                        if (j%2 == 1){//lower half row 3 4
                            if (position.x + 3 <= triangle_location.x + 20 && position.x + 3 >= triangle_location.x - 20 &&
                                position.y + 3.5 <= triangle_location.y + 20 && position.y + 3.5 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j+1] && !filled[i+1][j-1]){
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j+1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: light_brown_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        else if (Shape_Type == 10) {    //Shape_Type == 10 brown right downwards
            var i = 0
            for triangles_location in tri_location{
                var j = 0
                
                for triangle_location in triangles_location{
                    if (i == 0 || i == 1){//upper half row 0 1
                        if (j%2 == 0 && j != 0){//only upward
                            if (position.x + 52 <= triangle_location.x + 20 && position.x + 52 >= triangle_location.x - 20 &&
                                position.y + 3 <= triangle_location.y + 20 && position.y + 3 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i+1][j+1]){//check available
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j+1, image: light_brown_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }else if (i == 2){//upper half row 2
                        if (j%2 == 0 && j != 0){//only upward
                            if (position.x + 52 <= triangle_location.x + 20 && position.x + 52 >= triangle_location.x - 20 &&
                                position.y + 3 <= triangle_location.y + 20 && position.y + 3 >= triangle_location.y - 20){//check location
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i+1][j]){//check available
                                    // light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j, image: light_brown_down)
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    else if (i == 3 || i == 4){
                        if (j%2 == 1){//lower half row 3, 4
                            if (position.x + 52 <= triangle_location.x + 20 && position.x + 52 >= triangle_location.x - 20 &&
                                position.y + 3 <= triangle_location.y + 20 && position.y + 3 >= triangle_location.y - 20){
                                if (!filled[i][j] && !filled[i][j-1] && !filled[i+1][j-1]){
                                    //light_brown_drag_tri.image = UIImage(named:"棕色tri")?.tint(color: tri_color_5, blendMode: .destinationIn)
                                    auto_make_transparent()
                                    Change_Corresponding_Color_With_Image(x:i, y:j, image: light_brown_up)
                                    Change_Corresponding_Color_With_Image(x:i, y:j-1, image: light_brown_down)
                                    Change_Corresponding_Color_With_Image(x:i+1, y:j-1, image: light_brown_down)
                                    
                                    
                                    
                                    return true
                                }
                                return false
                            }
                        }
                        
                    }
                    j += 1
                }
                i += 1
            }
            
        }
        return false
    }

    
    
    
    func Change_Corresponding_Color(x:Int, y:Int, color: UIColor) -> (){
        //row NO 0
        if (x == 0 && y == 0){
            tri_0_0.image = tri_0_0.image!.withRenderingMode(.alwaysTemplate)
            tri_0_0.tintColor = color
        }else if(x == 0 && y == 1) {
            tri_0_1.image = tri_0_1.image!.withRenderingMode(.alwaysTemplate)
            tri_0_1.tintColor = color
        }else if (x == 0 && y == 2){
            tri_0_2.image = tri_0_2.image!.withRenderingMode(.alwaysTemplate)
            tri_0_2.tintColor = color
        }else if(x == 0 && y == 3) {
            tri_0_3.image = tri_0_3.image!.withRenderingMode(.alwaysTemplate)
            tri_0_3.tintColor = color
        }else if (x == 0 && y == 4){
            tri_0_4.image = tri_0_4.image!.withRenderingMode(.alwaysTemplate)
            tri_0_4.tintColor = color
        }else if(x == 0 && y == 5) {
            tri_0_5.image = tri_0_5.image!.withRenderingMode(.alwaysTemplate)
            tri_0_5.tintColor = color
        }else if (x == 0 && y == 6){
            tri_0_6.image = tri_0_6.image!.withRenderingMode(.alwaysTemplate)
            tri_0_6.tintColor = color
        }
        //row NO 1
        else if (x == 1 && y == 0){
            tri_1_0.image = tri_1_0.image!.withRenderingMode(.alwaysTemplate)
            tri_1_0.tintColor = color
        }else if(x == 1 && y == 1) {
            tri_1_1.image = tri_1_1.image!.withRenderingMode(.alwaysTemplate)
            tri_1_1.tintColor = color
        }else if (x == 1 && y == 2){
            tri_1_2.image = tri_1_2.image!.withRenderingMode(.alwaysTemplate)
            tri_1_2.tintColor = color
        }else if(x == 1 && y == 3) {
            tri_1_3.image = tri_1_3.image!.withRenderingMode(.alwaysTemplate)
            tri_1_3.tintColor = color
        }else if (x == 1 && y == 4){
            tri_1_4.image = tri_1_4.image!.withRenderingMode(.alwaysTemplate)
            tri_1_4.tintColor = color
        }else if(x == 1 && y == 5) {
            tri_1_5.image = tri_1_5.image!.withRenderingMode(.alwaysTemplate)
            tri_1_5.tintColor = color
        }else if (x == 1 && y == 6){
            tri_1_6.image = tri_1_6.image!.withRenderingMode(.alwaysTemplate)
            tri_1_6.tintColor = color
        }else if(x == 1 && y == 7) {
            tri_1_7.image = tri_1_7.image!.withRenderingMode(.alwaysTemplate)
            tri_1_7.tintColor = color
        }else if (x == 1 && y == 8){
            tri_1_8.image = tri_1_8.image!.withRenderingMode(.alwaysTemplate)
            tri_1_8.tintColor = color
        }
        //row NO 2
        else if(x == 2 && y == 0) {
            tri_2_0.image = tri_2_0.image!.withRenderingMode(.alwaysTemplate)
            tri_2_0.tintColor = color
        }else if(x == 2 && y == 1) {
            tri_2_1.image = tri_2_1.image!.withRenderingMode(.alwaysTemplate)
            tri_2_1.tintColor = color
        }else if(x == 2 && y == 2) {
            tri_2_2.image = tri_2_2.image!.withRenderingMode(.alwaysTemplate)
            tri_2_2.tintColor = color
        }else if(x == 2 && y == 3) {
            tri_2_3.image = tri_2_3.image!.withRenderingMode(.alwaysTemplate)
            tri_2_3.tintColor = color
        }else if(x == 2 && y == 4) {
            tri_2_4.image = tri_2_4.image!.withRenderingMode(.alwaysTemplate)
            tri_2_4.tintColor = color
        }else if(x == 2 && y == 5) {
            tri_2_5.image = tri_2_5.image!.withRenderingMode(.alwaysTemplate)
            tri_2_5.tintColor = color
        }else if(x == 2 && y == 6) {
            tri_2_6.image = tri_2_6.image!.withRenderingMode(.alwaysTemplate)
            tri_2_6.tintColor = color
        }else if(x == 2 && y == 7) {
            tri_2_7.image = tri_2_7.image!.withRenderingMode(.alwaysTemplate)
            tri_2_7.tintColor = color
        }else if(x == 2 && y == 8) {
            tri_2_8.image = tri_2_8.image!.withRenderingMode(.alwaysTemplate)
            tri_2_8.tintColor = color
        }else if(x == 2 && y == 9) {
            tri_2_9.image = tri_2_9.image!.withRenderingMode(.alwaysTemplate)
            tri_2_9.tintColor = color
        }else if(x == 2 && y == 10) {
            tri_2_10.image = tri_2_10.image!.withRenderingMode(.alwaysTemplate)
            tri_2_10.tintColor = color
        }
        //row NO 3
        else if(x == 3 && y == 0) {
            tri_3_0.image = tri_3_0.image!.withRenderingMode(.alwaysTemplate)
            tri_3_0.tintColor = color
        }else if(x == 3 && y == 1) {
            tri_3_1.image = tri_3_1.image!.withRenderingMode(.alwaysTemplate)
            tri_3_1.tintColor = color
        }else if(x == 3 && y == 2) {
            tri_3_2.image = tri_3_2.image!.withRenderingMode(.alwaysTemplate)
            tri_3_2.tintColor = color
        }else if(x == 3 && y == 3) {
            tri_3_3.image = tri_3_3.image!.withRenderingMode(.alwaysTemplate)
            tri_3_3.tintColor = color
        }else if(x == 3 && y == 4) {
            tri_3_4.image = tri_3_4.image!.withRenderingMode(.alwaysTemplate)
            tri_3_4.tintColor = color
        }else if(x == 3 && y == 5) {
            tri_3_5.image = tri_3_5.image!.withRenderingMode(.alwaysTemplate)
            tri_3_5.tintColor = color
        }else if(x == 3 && y == 6) {
            tri_3_6.image = tri_3_6.image!.withRenderingMode(.alwaysTemplate)
            tri_3_6.tintColor = color
        }else if(x == 3 && y == 7) {
            tri_3_7.image = tri_3_7.image!.withRenderingMode(.alwaysTemplate)
            tri_3_7.tintColor = color
        }else if(x == 3 && y == 8) {
            tri_3_8.image = tri_3_8.image!.withRenderingMode(.alwaysTemplate)
            tri_3_8.tintColor = color
        }else if(x == 3 && y == 9) {
            tri_3_9.image = tri_3_9.image!.withRenderingMode(.alwaysTemplate)
            tri_3_9.tintColor = color
        }else if(x == 3 && y == 10) {
            tri_3_10.image = tri_3_10.image!.withRenderingMode(.alwaysTemplate)
            tri_3_10.tintColor = color
        }
        //row NO 4
        else if (x == 4 && y == 0){
            tri_4_0.image = tri_4_0.image!.withRenderingMode(.alwaysTemplate)
            tri_4_0.tintColor = color
        }else if(x == 4 && y == 1) {
            tri_4_1.image = tri_4_1.image!.withRenderingMode(.alwaysTemplate)
            tri_4_1.tintColor = color
        }else if (x == 4 && y == 2){
            tri_4_2.image = tri_4_2.image!.withRenderingMode(.alwaysTemplate)
            tri_4_2.tintColor = color
        }else if(x == 4 && y == 3) {
            tri_4_3.image = tri_4_3.image!.withRenderingMode(.alwaysTemplate)
            tri_4_3.tintColor = color
        }else if (x == 4 && y == 4){
            tri_4_4.image = tri_4_4.image!.withRenderingMode(.alwaysTemplate)
            tri_4_4.tintColor = color
        }else if(x == 4 && y == 5) {
            tri_4_5.image = tri_4_5.image!.withRenderingMode(.alwaysTemplate)
            tri_4_5.tintColor = color
        }else if (x == 4 && y == 6){
            tri_4_6.image = tri_4_6.image!.withRenderingMode(.alwaysTemplate)
            tri_4_6.tintColor = color
        }else if(x == 4 && y == 7) {
            tri_4_7.image = tri_4_7.image!.withRenderingMode(.alwaysTemplate)
            tri_4_7.tintColor = color
        }else if (x == 4 && y == 8){
            tri_4_8.image = tri_4_8.image!.withRenderingMode(.alwaysTemplate)
            tri_4_8.tintColor = color
        }
        //row NO 5
        else if (x == 5 && y == 0){
            tri_5_0.image = tri_5_0.image!.withRenderingMode(.alwaysTemplate)
            tri_5_0.tintColor = color
        }else if(x == 5 && y == 1) {
            tri_5_1.image = tri_5_1.image!.withRenderingMode(.alwaysTemplate)
            tri_5_1.tintColor = color
        }else if (x == 5 && y == 2){
            tri_5_2.image = tri_5_2.image!.withRenderingMode(.alwaysTemplate)
            tri_5_2.tintColor = color
        }else if(x == 5 && y == 3) {
            tri_5_3.image = tri_5_3.image!.withRenderingMode(.alwaysTemplate)
            tri_5_3.tintColor = color
        }else if (x == 5 && y == 4){
            tri_5_4.image = tri_5_4.image!.withRenderingMode(.alwaysTemplate)
            tri_5_4.tintColor = color
        }else if(x == 5 && y == 5) {
            tri_5_5.image = tri_5_5.image!.withRenderingMode(.alwaysTemplate)
            tri_5_5.tintColor = color
        }else if (x == 5 && y == 6){
            tri_5_6.image = tri_5_6.image!.withRenderingMode(.alwaysTemplate)
            tri_5_6.tintColor = color
        }


        return
    }
    
    @IBAction func random_generator(_ sender: UIButton) {
        auto_random_generator()
    }
    
    
    func force_recenter_drag_tris ( tri: UIImageView, tri_img: UIImage!) -> Void{
        switch tri_img {
        case UIImage(named:"绿色tri.png")!:
            if(tri == green_drag_tri){
                tri.frame.origin = green_drag_origin
            }else if(tri == orange_drag_tri){
                tri.frame.origin = CGPoint(x:orange_drag_origin.x-CGFloat(30), y:orange_drag_origin.y + CGFloat(17))
            }else if(tri == light_brown_drag_tri){
                tri.frame.origin = CGPoint(x:light_brown_drag_origin.x, y:light_brown_drag_origin.y + CGFloat(10))
            }
       // case UIImage(nm)
        default:
            if(tri == green_drag_tri){
            tri.frame.origin = green_drag_origin
            }else if(tri == orange_drag_tri){
                tri.frame.origin = orange_drag_origin
            }else if(tri == light_brown_drag_tri){
          
                
                tri.frame.origin = light_brown_drag_origin
            }
        }
    }
    
    func Restore_A_Grey_Tri(i: Int, j: Int) ->Void {
        //row NO 0
        if (i == 0 && j == 0){
            tri_0_0.image = upwards_tri
        }
       else if(i == 0 && j == 1) {
            tri_0_1.image = downwards_tri
        }
        else if (i == 0 && j == 2){
            tri_0_2.image = upwards_tri
        }
       else if(i == 0 && j == 3) {
            tri_0_3.image = downwards_tri
        }
      else  if (i == 0 && j == 4){
            tri_0_4.image = upwards_tri
        }
       else if(i == 0 && j == 5) {
            tri_0_5.image = downwards_tri
        }
       else if (i == 0 && j == 6){
            tri_0_6.image = upwards_tri
        }
        //row NO 1
      else  if (i == 1 && j == 0){
            tri_1_0.image = upwards_tri
        }
      else  if(i == 1 && j == 1) {
            tri_1_1.image = downwards_tri
        }
     else   if (i == 1 && j == 2){
            tri_1_2.image = upwards_tri
        }
      else  if(i == 1 && j == 3) {
            tri_1_3.image = downwards_tri
        }
    else    if (i == 1 && j == 4){
            tri_1_4.image = upwards_tri
        }
    else if(i == 1 && j == 5) {
            tri_1_5.image = downwards_tri
        }
        else if (i == 1 && j == 6){
            tri_1_6.image = upwards_tri
        }
        else if(i == 1 && j == 7) {
            tri_1_7.image = downwards_tri
        }
        else if (i == 1 && j == 8){
            tri_1_8.image = upwards_tri
        }
        //row NO 2
        else if(i == 2 && j == 0) {
            tri_2_0.image = upwards_tri
        }
        else if(i == 2 && j == 1) {
            tri_2_1.image = downwards_tri
        }
        else if(i == 2 && j == 2) {
            tri_2_2.image = upwards_tri
        }
        else if(i == 2 && j == 3) {
            tri_2_3.image = downwards_tri
        }
        else if(i == 2 && j == 4) {
            tri_2_4.image = upwards_tri
        }
        else if(i == 2 && j == 5) {
            tri_2_5.image = downwards_tri
        }
        else if(i == 2 && j == 6) {
            tri_2_6.image = upwards_tri
        }
        else if(i == 2 && j == 7) {
            tri_2_7.image = downwards_tri
        }
        else if(i == 2 && j == 8) {
            tri_2_8.image = upwards_tri
        }
        else if(i == 2 && j == 9) {
            tri_2_9.image = downwards_tri
        }
        else if(i == 2 && j == 10) {
            tri_2_10.image = upwards_tri
        }
        //row NO 3
        else if(i == 3 && j == 0) {
            tri_3_0.image = downwards_tri
        }
        else if(i == 3 && j == 1) {
            tri_3_1.image = upwards_tri
        }
        else if(i == 3 && j == 2) {
            tri_3_2.image = downwards_tri
        }
        else if(i == 3 && j == 3) {
            tri_3_3.image = upwards_tri
        }
        else if(i == 3 && j == 4) {
            tri_3_4.image = downwards_tri
        }
        else if(i == 3 && j == 5) {
            tri_3_5.image = upwards_tri
        }
        else if(i == 3 && j == 6) {
            tri_3_6.image = downwards_tri
        }
        else if(i == 3 && j == 7) {
            tri_3_7.image = upwards_tri
        }
        else if(i == 3 && j == 8) {
            tri_3_8.image = downwards_tri
        }
        else if(i == 3 && j == 9) {
            tri_3_9.image = upwards_tri
        }
        else if(i == 3 && j == 10) {
             tri_3_10.image = downwards_tri
        }
        //row NO 4
        
        else if (i == 4 && j == 0){
            tri_4_0.image = downwards_tri
        }
        else if(i == 4 && j == 1) {
            tri_4_1.image = upwards_tri
        }
        else if (i == 4 && j == 2){
            tri_4_2.image = downwards_tri
        }
        else if(i == 4 && j == 3) {
            tri_4_3.image = upwards_tri
        }
        else if (i == 4 && j == 4){
            tri_4_4.image = downwards_tri
        }
        else if(i == 4 && j == 5) {
            tri_4_5.image = upwards_tri
        }
        else if (i == 4 && j == 6){
            tri_4_6.image = downwards_tri
        }
        else if(i == 4 && j == 7) {
            tri_4_7.image = upwards_tri
        }
        else if (i == 4 && j == 8){
            tri_4_8.image = downwards_tri
        }
        //row NO 5
        else if (i == 5 && j == 0){
            tri_5_0.image = downwards_tri
        }
        else if(i == 5 && j == 1) {
            tri_5_1.image = upwards_tri
        }
        else if (i == 5 && j == 2){
            tri_5_2.image = downwards_tri
        }
        else if(i == 5 && j == 3) {
            tri_5_3.image = upwards_tri
        }
        else if (i == 5 && j == 4){
            tri_5_4.image = downwards_tri
        }
        else if(i == 5 && j == 5) {
            tri_5_5.image = upwards_tri
        }
        else if (i == 5 && j == 6){
            tri_5_6.image = downwards_tri
        }
        
    
    }
    
    func Restore_Grey_Tris( ) ->Void {
        //row NO 0
        if (!filled[0][0]){
            tri_0_0.image = upwards_tri
        }
        if(!filled[0][1]) {
            tri_0_1.image = downwards_tri
        }
        if (!filled[0][2]){
            tri_0_2.image = upwards_tri
        }
        if(!filled[0][3]) {
            tri_0_3.image = downwards_tri
        }
        if (!filled[0][4]){
            tri_0_4.image = upwards_tri
        }
        if(!filled[0][5]) {
            tri_0_5.image = downwards_tri
        }
        if (!filled[0][6]){
            tri_0_6.image = upwards_tri
        }
            //row NO 1
        if (!filled[1][0]){
            tri_1_0.image = upwards_tri
        }
        if(!filled[1][1]) {
            tri_1_1.image = downwards_tri
        }
        if (!filled[1][2]){
            tri_1_2.image = upwards_tri
        }
        if(!filled[1][3]) {
            tri_1_3.image = downwards_tri
        }
        if (!filled[1][4]){
            tri_1_4.image = upwards_tri
        }
        if(!filled[1][5]) {
            tri_1_5.image = downwards_tri
        }
        if (!filled[1][6]){
            tri_1_6.image = upwards_tri
        }
        if(!filled[1][7]) {
            tri_1_7.image = downwards_tri
        }
        if (!filled[1][8]){
            tri_1_8.image = upwards_tri
        }
            //row NO 2
        if(!filled[2][0]) {
            tri_2_0.image = upwards_tri
        }
        if(!filled[2][1]) {
            tri_2_1.image = downwards_tri
        }
        if(!filled[2][2]) {
            tri_2_2.image = upwards_tri
        }
        if(!filled[2][3]) {
            tri_2_3.image = downwards_tri
        }
        if(!filled[2][4]) {
            tri_2_4.image = upwards_tri
       }
        if(!filled[2][5]) {
            tri_2_5.image = downwards_tri
        }
        if(!filled[2][6]) {
            tri_2_6.image = upwards_tri
        }
        if(!filled[2][7]) {
            tri_2_7.image = downwards_tri
        }
        if(!filled[2][8]) {
            tri_2_8.image = upwards_tri
        }
        if(!filled[2][9]) {
            tri_2_9.image = downwards_tri
        }
        if(!filled[2][10]) {
            tri_2_10.image = upwards_tri
        }
            //row NO 3
        if(!filled[3][0]) {
            tri_3_0.image = downwards_tri
        }
        if(!filled[3][1]) {
            tri_3_1.image = upwards_tri
        }
        if(!filled[3][2]) {
            tri_3_2.image = downwards_tri
        }
        if(!filled[3][3]) {
            tri_3_3.image = upwards_tri
        }
        if(!filled[3][4]) {
            tri_3_4.image = downwards_tri
        }
        if(!filled[3][5]) {
            tri_3_5.image = upwards_tri
        }
        if(!filled[3][6]) {
            tri_3_6.image = downwards_tri
        }
        if(!filled[3][7]) {
            tri_3_7.image = upwards_tri
        }
        if(!filled[3][8]) {
            tri_3_8.image = downwards_tri
       }
        if(!filled[3][9]) {
            tri_3_9.image = upwards_tri
      }
        if(!filled[3][10]) {
            tri_3_10.image = downwards_tri
        }
            //row NO 4
        
        if (!filled[4][0]){
            tri_4_0.image = downwards_tri
        }
        if(!filled[4][1]) {
            tri_4_1.image = upwards_tri
        }
        if (!filled[4][2]){
            tri_4_2.image = downwards_tri
        }
        if(!filled[4][3]) {
            tri_4_3.image = upwards_tri
        }
        if (!filled[4][4]){
            tri_4_4.image = downwards_tri
        }
        if(!filled[4][5]) {
            tri_4_5.image = upwards_tri
        }
        if (!filled[4][6]){
            tri_4_6.image = downwards_tri
        }
        if(!filled[4][7]) {
            tri_4_7.image = upwards_tri
       }
        if (!filled[4][8]){
            tri_4_8.image = downwards_tri
        }
            //row NO 5
        if (!filled[5][0]){
            tri_5_0.image = downwards_tri
        }
        if(!filled[5][1]) {
            tri_5_1.image = upwards_tri
        }
        if (!filled[5][2]){
            tri_5_2.image = downwards_tri
        }
        if(!filled[5][3]) {
            tri_5_3.image = upwards_tri
        }
        if (!filled[5][4]){
            tri_5_4.image = downwards_tri
        }
        if(!filled[5][5]) {
            tri_5_5.image = upwards_tri
        }
        if (!filled[5][6]){
            tri_5_6.image = downwards_tri
        }

    }
    
    //change color with image
    func Change_Corresponding_Color_With_Image(x:Int, y:Int, image: UIImage?) -> (){
        //row NO 0
        if (x == 0 && y == 0){
            tri_0_0.image = image
            tri_0_0.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_0.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 0 && y == 1) {
            tri_0_1.image = image
            tri_0_1.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_1.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 0 && y == 2){
            tri_0_2.image = image
            tri_0_2.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_2.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 0 && y == 3) {
            tri_0_3.image = image
            tri_0_3.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_3.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 0 && y == 4){
            tri_0_4.image = image
            tri_0_4.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_4.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 0 && y == 5) {
            tri_0_5.image = image
            tri_0_5.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_5.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 0 && y == 6){
            tri_0_6.image = image
            tri_0_6.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_6.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
            //row NO 1
        else if (x == 1 && y == 0){
            tri_1_0.image = image
            tri_1_0.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
               self.tri_1_0.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 1 && y == 1) {
            tri_1_1.image = image
            tri_1_1.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_1.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 1 && y == 2){
            tri_1_2.image = image
            tri_1_2.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_2.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 1 && y == 3) {
            tri_1_3.image = image
            tri_1_3.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_3.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 1 && y == 4){
            tri_1_4.image = image
            tri_1_4.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_4.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 1 && y == 5) {
            tri_1_5.image = image
            tri_1_5.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_5.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 1 && y == 6){
            tri_1_6.image = image
            tri_1_6.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_6.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 1 && y == 7) {
            tri_1_7.image = image
            tri_1_7.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_7.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 1 && y == 8){
            tri_1_8.image = image
            tri_1_8.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_8.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
            //row NO 2
        else if(x == 2 && y == 0) {
            tri_2_0.image = image
            tri_2_0.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_0.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 1) {
            tri_2_1.image = image
            tri_2_1.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_1.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 2) {
            tri_2_2.image = image
            tri_2_2.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_2.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 3) {
            tri_2_3.image = image
            tri_2_3.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_3.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 4) {
            tri_2_4.image = image
            tri_2_4.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_4.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 5) {
            tri_2_5.image = image
            tri_2_5.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_5.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 6) {
            tri_2_6.image = image
            tri_2_6.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_6.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 7) {
            tri_2_7.image = image
            tri_2_7.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_7.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 8) {
            tri_2_8.image = image
            tri_2_8.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_8.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 9) {
            tri_2_9.image = image
            tri_2_9.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_9.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 2 && y == 10) {
            tri_2_10.image = image
            tri_2_10.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_10.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
            //row NO 3
        else if(x == 3 && y == 0) {
            tri_3_0.image = image
            tri_3_0.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_0.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 1) {
            tri_3_1.image = image
            tri_3_1.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_1.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 2) {
            tri_3_2.image = image
            tri_3_2.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_2.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 3) {
            tri_3_3.image = image
            tri_3_3.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_3.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 4) {
            tri_3_4.image = image
            tri_3_4.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_4.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 5) {
            tri_3_5.image = image
            tri_3_5.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_5.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 6) {
            tri_3_6.image = image
            tri_3_6.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_6.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 7) {
            tri_3_7.image = image
            tri_3_7.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
               self.tri_3_7.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 8) {
            tri_3_8.image = image
            tri_3_8.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_8.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 9) {
            tri_3_9.image = image
            tri_3_9.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_9.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 3 && y == 10) {
            tri_3_10.image = image
            tri_3_10.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_10.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
            //row NO 4
        else if (x == 4 && y == 0){
            tri_4_0.image = image
            tri_4_0.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_0.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 4 && y == 1) {
            tri_4_1.image = image
            tri_4_1.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_1.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 4 && y == 2){
            tri_4_2.image = image
            tri_4_2.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_2.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 4 && y == 3) {
            tri_4_3.image = image
            tri_4_3.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_3.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 4 && y == 4){
            tri_4_4.image = image
            tri_4_4.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_4.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 4 && y == 5) {
            tri_4_5.image = image
            tri_4_5.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_5.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 4 && y == 6){
            tri_4_6.image = image
            tri_4_6.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_6.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 4 && y == 7) {
            tri_4_7.image = image
            tri_4_7.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_7.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 4 && y == 8){
            tri_4_8.image = image
            tri_4_8.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_8.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
            //row NO 5
        else if (x == 5 && y == 0){
            tri_5_0.image = image
            tri_5_0.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_0.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 5 && y == 1) {
            tri_5_1.image = image
            tri_5_1.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_1.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 5 && y == 2){
            tri_5_2.image = image
            tri_5_2.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_2.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 5 && y == 3) {
            tri_5_3.image = image
            tri_5_3.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_3.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 5 && y == 4){
            tri_5_4.image = image
            tri_5_4.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_4.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if(x == 5 && y == 5) {
            tri_5_5.image = image
            tri_5_5.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_5.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }else if (x == 5 && y == 6){
            tri_5_6.image = image
            tri_5_6.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_6.transform =  CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
            })
        }
        
        
        return
    }
    
    func Change_Corresponding_Color_With_Image_Without_Animation(x:Int, y:Int, image: UIImage?) -> (){
        //row NO 0
        if (x == 0 && y == 0){
            tri_0_0.image = image
        }else if(x == 0 && y == 1) {
            tri_0_1.image = image
        }else if (x == 0 && y == 2){
            tri_0_2.image = image
        }else if(x == 0 && y == 3) {
            tri_0_3.image = image
        }else if (x == 0 && y == 4){
            tri_0_4.image = image
        }else if(x == 0 && y == 5) {
            tri_0_5.image = image
        }else if (x == 0 && y == 6){
            tri_0_6.image = image
        }
            //row NO 1
        else if (x == 1 && y == 0){
            tri_1_0.image = image
        }else if(x == 1 && y == 1) {
            tri_1_1.image = image
        }else if (x == 1 && y == 2){
            tri_1_2.image = image
        }else if(x == 1 && y == 3) {
            tri_1_3.image = image
        }else if (x == 1 && y == 4){
            tri_1_4.image = image
        }else if(x == 1 && y == 5) {
            tri_1_5.image = image
        }else if (x == 1 && y == 6){
            tri_1_6.image = image
        }else if(x == 1 && y == 7) {
            tri_1_7.image = image
        }else if (x == 1 && y == 8){
            tri_1_8.image = image
        }
            //row NO 2
        else if(x == 2 && y == 0) {
            tri_2_0.image = image
        }else if(x == 2 && y == 1) {
            tri_2_1.image = image
        }else if(x == 2 && y == 2) {
            tri_2_2.image = image
        }else if(x == 2 && y == 3) {
            tri_2_3.image = image
        }else if(x == 2 && y == 4) {
            tri_2_4.image = image
        }else if(x == 2 && y == 5) {
            tri_2_5.image = image
        }else if(x == 2 && y == 6) {
            tri_2_6.image = image
        }else if(x == 2 && y == 7) {
            tri_2_7.image = image
        }else if(x == 2 && y == 8) {
            tri_2_8.image = image
        }else if(x == 2 && y == 9) {
            tri_2_9.image = image
        }else if(x == 2 && y == 10) {
            tri_2_10.image = image
        }
            //row NO 3
        else if(x == 3 && y == 0) {
            tri_3_0.image = image
        }else if(x == 3 && y == 1) {
            tri_3_1.image = image
        }else if(x == 3 && y == 2) {
            tri_3_2.image = image
        }else if(x == 3 && y == 3) {
            tri_3_3.image = image
        }else if(x == 3 && y == 4) {
            tri_3_4.image = image
        }else if(x == 3 && y == 5) {
            tri_3_5.image = image
        }else if(x == 3 && y == 6) {
            tri_3_6.image = image
            
        }else if(x == 3 && y == 7) {
            tri_3_7.image = image
        }else if(x == 3 && y == 8) {
            tri_3_8.image = image
        }else if(x == 3 && y == 9) {
            tri_3_9.image = image
        }else if(x == 3 && y == 10) {
            tri_3_10.image = image
        }
            //row NO 4
        else if (x == 4 && y == 0){
            tri_4_0.image = image
        }else if(x == 4 && y == 1) {
            tri_4_1.image = image

        }else if (x == 4 && y == 2){
            tri_4_2.image = image

        }else if(x == 4 && y == 3) {
            tri_4_3.image = image

        }else if (x == 4 && y == 4){
            tri_4_4.image = image

        }else if(x == 4 && y == 5) {
            tri_4_5.image = image

        }else if (x == 4 && y == 6){
            tri_4_6.image = image

        }else if(x == 4 && y == 7) {
            tri_4_7.image = image

        }else if (x == 4 && y == 8){
            tri_4_8.image = image

        }
            //row NO 5
        else if (x == 5 && y == 0){
            tri_5_0.image = image

        }else if(x == 5 && y == 1) {
            tri_5_1.image = image

        }else if (x == 5 && y == 2){
            tri_5_2.image = image

        }else if(x == 5 && y == 3) {
            tri_5_3.image = image

        }else if (x == 5 && y == 4){
            tri_5_4.image = image

        }else if(x == 5 && y == 5) {
            tri_5_5.image = image

        }else if (x == 5 && y == 6){
            tri_5_6.image = image

        }
        
        
        return
    }

    
    func Eligible_to_Generate () -> Bool {
        if(!exist1 && !exist2 && !exist3){
            exist1 = true
            exist2 = true
            exist3 = true
            return true
        }else{
            return false
        }
            }
    
    
    func generate_a_non_dark_green_dri_random() -> Int {
       var randomIx = 5
        while(randomIx == 5){
            randomIx = Int(arc4random_uniform(UInt32(generator_array.count)))
        }
       
        return randomIx
        
    }
    
    func generate_a_non_green_or_brown_downwards_tri_random() -> Int {
      var randomIx = 0
        while(randomIx == 0 || randomIx == 3){
            randomIx = Int(arc4random_uniform(UInt32(generator_array.count)))

        }
        return randomIx
    }
    
    func generate_a_non_green_or_brown_downwards_tri_random_or_dark_tri() -> Int {
     var randomIx = 0
        while(randomIx == 5 || randomIx == 0 || randomIx == 3){
            randomIx = Int(arc4random_uniform(UInt32(generator_array.count)))
        }
        
        return randomIx
    }
    
    //auto generate three tris when previous are all fit in
      func auto_random_generator() -> Void {
        var number_of_dark_tri = 0
        Check_for_Placable_Shape_And_Generate()
       var position_index = 0
        var end_loop = false
        var random_shape_index = 0
        while(!end_loop){
            position_index = Int(arc4random_uniform(UInt32(3)))
            random_shape_index = randomShape_for_Difficulty_Level ()
            //need rewrite later
            if(shape_placable_array[random_shape_index]){
                end_loop = true
            }
        }
        if(random_shape_index == 5){
            number_of_dark_tri += 1
        }
        var randomIndex = 0
        green_drag_tri.alpha = 0
        orange_drag_tri.alpha = 0
        light_brown_drag_tri.alpha = 0
        if(position_index == 0){
            green_drag_tri.image = generator_array[random_shape_index]
            green_drag_tri.sizeToFit()
            green_drag_tri_orig_rec = green_drag_tri.frame
            shape_type_index[0] = random_shape_index
            
            randomIndex = randomShape_for_Difficulty_Level ()
            if(random_shape_index == 0 || random_shape_index == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random()
            }

            //Int(arc4random_uniform(UInt32(generator_array.count)))
            if(randomIndex == 5){
                number_of_dark_tri += 1
            }
            orange_drag_tri.image = generator_array[randomIndex]
            orange_drag_tri.sizeToFit()
            orange_drag_tri_orig_rec = orange_drag_tri.frame
            shape_type_index[1] = randomIndex
            
            //force_recenter_drag_tris( tri: orange_drag_tri,tri_img: generator_array[randomIndex] )
            //randomIndex is previous index at this instance
            if(randomIndex == 0 || randomIndex == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random()
            }else{
            randomIndex = randomShape_for_Difficulty_Level ()
            }
            if(randomIndex == 5 && number_of_dark_tri == 2 && random_shape_index == 0 || random_shape_index == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random_or_dark_tri()
            }else if(randomIndex == 5 && number_of_dark_tri == 2 && random_shape_index != 0 && random_shape_index != 3){
                randomIndex = generate_a_non_dark_green_dri_random()
            }
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            light_brown_drag_tri.image = generator_array[randomIndex]
            light_brown_drag_tri.sizeToFit()
            light_brown_drag_tri_orig_rec = light_brown_drag_tri.frame
            //force_recenter_drag_tris( tri: light_brown_drag_tri,tri_img: generator_array[randomIndex] )
            shape_type_index[2] = randomIndex
            
            

            
        }
        else if(position_index == 1){
            orange_drag_tri.image = generator_array[random_shape_index]
            orange_drag_tri.sizeToFit()
            orange_drag_tri_orig_rec = orange_drag_tri.frame
            shape_type_index[1] = random_shape_index
            
            if(random_shape_index == 0 || random_shape_index == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random()
            }else{
                randomIndex = randomShape_for_Difficulty_Level ()
            }
            if(randomIndex == 5){
                number_of_dark_tri += 1
            }
            green_drag_tri.image = generator_array[randomIndex]
            green_drag_tri.sizeToFit()
            green_drag_tri_orig_rec = green_drag_tri.frame
            shape_type_index[0] = randomIndex
            
            if(random_shape_index == 0 || random_shape_index == 3){
               randomIndex = generate_a_non_green_or_brown_downwards_tri_random()
            }else{
            randomIndex = randomShape_for_Difficulty_Level ()
            }
            if(randomIndex == 5 && number_of_dark_tri == 2 && random_shape_index == 0 || random_shape_index == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random_or_dark_tri()
            }else if(randomIndex == 5 && number_of_dark_tri == 2 && random_shape_index != 0 && random_shape_index != 3){
                randomIndex = generate_a_non_dark_green_dri_random()
            }
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            light_brown_drag_tri.image = generator_array[randomIndex]
            light_brown_drag_tri.sizeToFit()
            light_brown_drag_tri_orig_rec = light_brown_drag_tri.frame
            //force_recenter_drag_tris( tri: light_brown_drag_tri,tri_img: generator_array[randomIndex] )
            shape_type_index[2] = randomIndex
            
        }
        
        else if(position_index == 2){
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            light_brown_drag_tri.image = generator_array[random_shape_index]
            light_brown_drag_tri.sizeToFit()
            //force_recenter_drag_tris( tri: light_brown_drag_tri,tri_img: generator_array[randomIndex] )
            shape_type_index[2] = random_shape_index
            
             randomIndex = randomShape_for_Difficulty_Level ()
            if(randomIndex == 5){
                number_of_dark_tri += 1
            }
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            green_drag_tri.image = generator_array[randomIndex]
            green_drag_tri.sizeToFit()
            green_drag_tri_orig_rec = green_drag_tri.frame
            shape_type_index[0] = randomIndex
            
            if(random_shape_index == 0 || random_shape_index == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random()
            }else{
            randomIndex = randomShape_for_Difficulty_Level ()
            }
            if(randomIndex == 5 && number_of_dark_tri == 2 && random_shape_index == 0 || random_shape_index == 3){
                randomIndex = generate_a_non_green_or_brown_downwards_tri_random_or_dark_tri()
            }else if(randomIndex == 5 && number_of_dark_tri == 2 && random_shape_index != 0 && random_shape_index != 3){
                randomIndex = generate_a_non_dark_green_dri_random()
            }
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            orange_drag_tri.image = generator_array[randomIndex]
            orange_drag_tri.sizeToFit()
            orange_drag_tri_orig_rec = orange_drag_tri.frame
            shape_type_index[1] = randomIndex

        }

        else{ randomIndex = randomShape_for_Difficulty_Level ()
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            green_drag_tri.image = generator_array[randomIndex]
            green_drag_tri.sizeToFit()
            green_drag_tri_orig_rec = green_drag_tri.frame
            shape_type_index[0] = randomIndex
            // force_recenter_drag_tris( tri: green_drag_tri,tri_img: generator_array[randomIndex] )
        
        
            randomIndex = randomShape_for_Difficulty_Level ()
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            orange_drag_tri.image = generator_array[randomIndex]
            orange_drag_tri.sizeToFit()
            orange_drag_tri_orig_rec = orange_drag_tri.frame
            shape_type_index[1] = randomIndex
        
            //force_recenter_drag_tris( tri: orange_drag_tri,tri_img: generator_array[randomIndex] )
        
            randomIndex = randomShape_for_Difficulty_Level ()
            //Int(arc4random_uniform(UInt32(generator_array.count)))
            light_brown_drag_tri.image = generator_array[randomIndex]
            light_brown_drag_tri.sizeToFit()
            light_brown_drag_tri_orig_rec = light_brown_drag_tri.frame
           //force_recenter_drag_tris( tri: light_brown_drag_tri,tri_img: generator_array[randomIndex] )
            shape_type_index[2] = randomIndex
            
        }
        green_drag_tri.fadeInWithDisplacement()
        orange_drag_tri.fadeInWithDisplacement()
        light_brown_drag_tri.fadeInWithDisplacement()
        exist1 = true
        exist2 = true
        exist3 = true
    }
    
    func Duplicate_Tri_Animate(i: Int, j: Int) ->Void {
        //row NO 0
        if (i == 0 && j == 0){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 0)
                self.tri_0_0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
                    }
        else if(i == 0 && j == 1) {
            UIView.animate(withDuration: 0.2, animations: {
               self.tri_0_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 1)
                self.tri_0_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })

        }
        else if (i == 0 && j == 2){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 2)
                self.tri_0_2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 0 && j == 3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 3)
                self.tri_0_3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else  if (i == 0 && j == 4){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 4)
                self.tri_0_4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 0 && j == 5) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 5)
                self.tri_0_5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
    
        }
        else if (i == 0 && j == 6){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_0_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 0, j: 6)
                self.tri_0_6.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
            //row NO 1
        else  if (i == 1 && j == 0){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 0)
                self.tri_1_0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else  if(i == 1 && j == 1) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 1)
                self.tri_1_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else  if (i == 1 && j == 2){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 2)
                self.tri_1_2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else  if(i == 1 && j == 3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 3)
                self.tri_1_3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else  if (i == 1 && j == 4){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 4)
                self.tri_1_4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })

        }
        else if(i == 1 && j == 5) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 5)
                self.tri_1_5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })

        }
        else if (i == 1 && j == 6){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 6)
                self.tri_1_6.transform = CGAffineTransform(scaleX: 1, y: 1)
            })        }
        else if(i == 1 && j == 7) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 7)
                self.tri_1_7.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
                  }
        else if (i == 1 && j == 8){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_1_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 1, j: 8)
                self.tri_1_8.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
          
        }
            //row NO 2
        else if(i == 2 && j == 0) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 0)
                self.tri_2_0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 1) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 1)
                self.tri_2_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 2) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 2)
                self.tri_2_2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 3)
                self.tri_2_3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 4) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 4)
                self.tri_2_4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 5) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 5)
                self.tri_2_5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 6) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 6)
                self.tri_2_6.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 7) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 7)
                self.tri_2_7.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 8) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 8)
                self.tri_2_8.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 9) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_9.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 9)
                self.tri_2_9.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 2 && j == 10) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_2_10.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 2, j: 10)
                self.tri_2_10.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
            //row NO 3
        else if(i == 3 && j == 0) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 0)
                self.tri_3_0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 1) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 1)
                self.tri_3_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 2) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 2)
                self.tri_3_2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 3)
                self.tri_3_3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 4) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 4)
                self.tri_3_4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 5) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 5)
                self.tri_3_5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 6) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 6)
                self.tri_3_6.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 7) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 7)
                self.tri_3_7.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 8) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 8)
                self.tri_3_8.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 9) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_9.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 9)
                self.tri_3_9.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 3 && j == 10) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_3_10.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 3, j: 10)
                self.tri_3_10.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
            //row NO 4
            
        else if (i == 4 && j == 0){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 0)
                self.tri_4_0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 4 && j == 1) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 1)
                self.tri_4_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if (i == 4 && j == 2){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 2)
                self.tri_4_2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })        }
        else if(i == 4 && j == 3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 3)
                self.tri_4_3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })        }
        else if (i == 4 && j == 4){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 4)
                self.tri_4_4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 4 && j == 5) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 5)
                self.tri_4_5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })

        }
        else if (i == 4 && j == 6){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 6)
                self.tri_4_6.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 4 && j == 7) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 7)
                self.tri_4_7.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if (i == 4 && j == 8){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_4_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 4, j: 8)
                self.tri_4_8.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
            //row NO 5
        else if (i == 5 && j == 0){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 0)
                self.tri_5_0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 5 && j == 1) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 1)
                self.tri_5_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if (i == 5 && j == 2){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 2)
                self.tri_5_2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 5 && j == 3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 3)
                self.tri_5_3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if (i == 5 && j == 4){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 4)
                self.tri_5_4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else if(i == 5 && j == 5) {
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 5)
                self.tri_5_5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })        }
        else if (i == 5 && j == 6){
            UIView.animate(withDuration: 0.2, animations: {
                self.tri_5_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
            }, completion: {
                (finished) -> Void in
                self.Restore_A_Grey_Tri(i: 5, j: 6)
                self.tri_5_1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        
    }
    //situation for cancel
    var situation0 = false
    var situation1 = false
    var situation2 = false
    var situation3 = false
    var situation4 = false
    var situation5 = false
    var situation6 = false
    var situation7 = false
    var situation8 = false
    var situation9 = false
    var situation10 = false
    var situation11 = false
    var situation12 = false
    var situation13 = false
    var situation14 = false
    var situation15 = false
    var situation16 = false
    var situation17 = false

    func Check_and_Erase_Create_Array() -> Array<(row: Int, column: Int)> {
        var eliminate_array = [(row: Int, column: Int)]()

        if(filled[0][0]&&filled[0][1]&&filled[0][2]&&filled[0][3]&&filled[0][4]&&filled[0][5]&&filled[0][6]){
            eliminate_array.append((row: 0, column: 0))
            eliminate_array.append((row: 0, column: 1))
            eliminate_array.append((row: 0, column: 2))
            eliminate_array.append((row: 0, column: 3))
            eliminate_array.append((row: 0, column: 4))
            eliminate_array.append((row: 0, column: 5))
            eliminate_array.append((row: 0, column: 6))
        }
          if(filled[1][0]&&filled[1][1]&&filled[1][2]&&filled[1][3]&&filled[1][4]&&filled[1][5]&&filled[1][6]&&filled[1][7]&&filled[1][8]){
            eliminate_array.append((row: 1, column: 0))
            eliminate_array.append((row: 1, column: 1))
            eliminate_array.append((row: 1, column: 2))
            eliminate_array.append((row: 1, column: 3))
            eliminate_array.append((row: 1, column: 4))
            eliminate_array.append((row: 1, column: 5))
            eliminate_array.append((row: 1, column: 6))
            eliminate_array.append((row: 1, column: 7))
            eliminate_array.append((row: 1, column: 8))
        }
        
        if(filled[2][0]&&filled[2][1]&&filled[2][2]&&filled[2][3]&&filled[2][4]&&filled[2][5]&&filled[2][6]&&filled[2][7]&&filled[2][8]&&filled[2][9]&&filled[2][10]){
            eliminate_array.append((row: 2, column: 0))
            eliminate_array.append((row: 2, column: 1))
            eliminate_array.append((row: 2, column: 2))
            eliminate_array.append((row: 2, column: 3))
            eliminate_array.append((row: 2, column: 4))
            eliminate_array.append((row: 2, column: 5))
            eliminate_array.append((row: 2, column: 6))
            eliminate_array.append((row: 2, column: 7))
            eliminate_array.append((row: 2, column: 8))
            eliminate_array.append((row: 2, column: 9))
            eliminate_array.append((row: 2, column: 10))
        }
        
       if(filled[3][0]&&filled[3][1]&&filled[3][2]&&filled[3][3]&&filled[3][4]&&filled[3][5]&&filled[3][6]&&filled[3][7]&&filled[3][8]&&filled[3][9]&&filled[3][10]){
        eliminate_array.append((row: 3, column: 0))
        eliminate_array.append((row: 3, column: 1))
        eliminate_array.append((row: 3, column: 2))
        eliminate_array.append((row: 3, column: 3))
        eliminate_array.append((row: 3, column: 4))
        eliminate_array.append((row: 3, column: 5))
        eliminate_array.append((row: 3, column: 6))
        eliminate_array.append((row: 3, column: 7))
        eliminate_array.append((row: 3, column: 8))
        eliminate_array.append((row: 3, column: 9))
        eliminate_array.append((row: 3, column: 10))
        }

        //eliminate fifth row
        if(filled[4][0]&&filled[4][1]&&filled[4][2]&&filled[4][3]&&filled[4][4]&&filled[4][5]&&filled[4][6]&&filled[4][7]&&filled[4][8]){
            
            eliminate_array.append((row: 4, column: 0))
            eliminate_array.append((row: 4, column: 1))
            eliminate_array.append((row: 4, column: 2))
            eliminate_array.append((row: 4, column: 3))
            eliminate_array.append((row: 4, column: 4))
            eliminate_array.append((row: 4, column: 5))
            eliminate_array.append((row: 4, column: 6))
            eliminate_array.append((row: 4, column: 7))
            eliminate_array.append((row: 4, column: 8))

            
        }
        ////eliminate sixth row
        if(filled[5][0]&&filled[5][1]&&filled[5][2]&&filled[5][3]&&filled[5][4]&&filled[5][5]&&filled[5][6]){

            eliminate_array.append((row: 5, column: 0))
            eliminate_array.append((row: 5, column: 1))
            eliminate_array.append((row: 5, column: 2))
            eliminate_array.append((row: 5, column: 3))
            eliminate_array.append((row: 5, column: 4))
            eliminate_array.append((row: 5, column: 5))
            eliminate_array.append((row: 5, column: 6))
            
            
        }
        
        
        //situation two - 右下斜
        if(filled[2][0]&&filled[3][0]&&filled[3][1]&&filled[4][0]&&filled[4][1]&&filled[5][0]&&filled[5][1]){

            eliminate_array.append((row: 2, column: 0))
            eliminate_array.append((row: 3, column: 0))
            eliminate_array.append((row: 3, column: 1))
            eliminate_array.append((row: 4, column: 0))
            eliminate_array.append((row: 4, column: 1))
            eliminate_array.append((row: 5, column: 0))
            eliminate_array.append((row: 5, column: 1))

            
        }
        
        
        if(filled[1][0]&&filled[2][1]&&filled[2][2]&&filled[3][2]&&filled[3][3]&&filled[4][2]&&filled[4][3]&&filled[5][2]&&filled[5][3]){
            eliminate_array.append((row: 1, column: 0))
            eliminate_array.append((row: 2, column: 1))
            eliminate_array.append((row: 2, column: 2))
            eliminate_array.append((row: 3, column: 2))
            eliminate_array.append((row: 3, column: 3))
            eliminate_array.append((row: 4, column: 2))
            eliminate_array.append((row: 4, column: 3))
            eliminate_array.append((row: 5, column: 2))
            eliminate_array.append((row: 5, column: 3))
            
        }
        if(filled[0][0]&&filled[1][1]&&filled[1][2]&&filled[2][3]&&filled[2][4]&&filled[3][4]&&filled[3][5]&&filled[4][4]&&filled[4][5]&&filled[5][4]&&filled[5][5]){
            eliminate_array.append((row: 0, column: 0))
            eliminate_array.append((row: 1, column: 1))
            eliminate_array.append((row: 1, column: 2))
            eliminate_array.append((row: 2, column: 3))
            eliminate_array.append((row: 2, column: 4))
            eliminate_array.append((row: 3, column: 4))
            eliminate_array.append((row: 3, column: 5))
            eliminate_array.append((row: 4, column: 4))
            eliminate_array.append((row: 4, column: 5))
            eliminate_array.append((row: 5, column: 4))
            eliminate_array.append((row: 5, column: 5))
            
        }
        
        
        
        
        if(filled[0][1]&&filled[0][2]&&filled[1][3]&&filled[1][4]&&filled[2][5]&&filled[2][6]&&filled[3][6]&&filled[3][7]&&filled[4][6]&&filled[4][7]&&filled[5][6]){
            eliminate_array.append((row: 0, column: 1))
            eliminate_array.append((row: 0, column: 2))
            eliminate_array.append((row: 1, column: 3))
            eliminate_array.append((row: 1, column: 4))
            eliminate_array.append((row: 2, column: 5))
            eliminate_array.append((row: 2, column: 6))
            eliminate_array.append((row: 3, column: 6))
            eliminate_array.append((row: 3, column: 7))
            eliminate_array.append((row: 4, column: 6))
            eliminate_array.append((row: 4, column: 7))
            eliminate_array.append((row: 5, column: 6))
            
        }
        
        
        if(filled[0][3]&&filled[0][4]&&filled[1][5]&&filled[1][6]&&filled[2][7]&&filled[2][8]&&filled[3][8]&&filled[3][9]&&filled[4][8]){
          
            eliminate_array.append((row: 0, column: 3))
            eliminate_array.append((row: 0, column: 4))
            eliminate_array.append((row: 1, column: 5))
            eliminate_array.append((row: 1, column: 6))
            eliminate_array.append((row: 2, column: 7))
            eliminate_array.append((row: 2, column: 8))
            eliminate_array.append((row: 3, column: 8))
            eliminate_array.append((row: 3, column: 9))
            eliminate_array.append((row: 4, column: 8))

        
        }
        if(filled[0][5]&&filled[0][6]&&filled[1][7]&&filled[1][8]&&filled[2][9]&&filled[2][10]&&filled[3][10]){

            eliminate_array.append((row: 0, column: 5))
            eliminate_array.append((row: 0, column: 6))
            eliminate_array.append((row: 1, column: 7))
            eliminate_array.append((row: 1, column: 8))
            eliminate_array.append((row: 2, column: 9))
            eliminate_array.append((row: 2, column: 10))
            eliminate_array.append((row: 3, column: 10))

            
            
        }
        
        
        //situation three - 左下斜
        if(filled[0][0]&&filled[0][1]&&filled[1][0]&&filled[1][1]&&filled[2][0]&&filled[2][1]&&filled[3][0]){
            eliminate_array.append((row: 0, column: 0))
            eliminate_array.append((row: 0, column: 1))
            eliminate_array.append((row: 1, column: 0))
            eliminate_array.append((row: 1, column: 1))
            eliminate_array.append((row: 2, column: 0))
            eliminate_array.append((row: 2, column: 1))
            eliminate_array.append((row: 3, column: 0))
        
            
            
        }
        
        
        if(filled[0][2]&&filled[0][3]&&filled[1][2]&&filled[1][3]&&filled[2][2]&&filled[2][3]&&filled[3][1]&&filled[3][2]&&filled[4][0]){
            eliminate_array.append((row: 0, column: 2))
            eliminate_array.append((row: 0, column: 3))
            eliminate_array.append((row: 1, column: 2))
            eliminate_array.append((row: 1, column: 3))
            eliminate_array.append((row: 2, column: 2))
            eliminate_array.append((row: 2, column: 3))
            eliminate_array.append((row: 3, column: 1))
            eliminate_array.append((row: 3, column: 2))
            eliminate_array.append((row: 4, column: 0))

            
            
        }
        
        if(filled[0][4]&&filled[0][5]&&filled[1][4]&&filled[1][5]&&filled[2][4]&&filled[2][5]&&filled[3][3]&&filled[3][4]&&filled[4][1]&&filled[4][2]&&filled[5][0]){
            eliminate_array.append((row: 0, column: 4))
            eliminate_array.append((row: 0, column: 5))
            eliminate_array.append((row: 1, column: 4))
            eliminate_array.append((row: 1, column: 5))
            eliminate_array.append((row: 2, column: 4))
            eliminate_array.append((row: 2, column: 5))
            eliminate_array.append((row: 3, column: 3))
            eliminate_array.append((row: 3, column: 4))
            eliminate_array.append((row: 4, column: 1))
            eliminate_array.append((row: 4, column: 2))
            eliminate_array.append((row: 5, column: 0))

        }
        if(filled[0][6]&&filled[1][6]&&filled[1][7]&&filled[2][6]&&filled[2][7]&&filled[3][5]&&filled[3][6]&&filled[4][3]&&filled[4][4]&&filled[5][1]&&filled[5][2]){
            
            eliminate_array.append((row: 0, column: 6))
            eliminate_array.append((row: 1, column: 6))
            eliminate_array.append((row: 1, column: 7))
            eliminate_array.append((row: 2, column: 6))
            eliminate_array.append((row: 2, column: 7))
            eliminate_array.append((row: 3, column: 5))
            eliminate_array.append((row: 3, column: 6))
            eliminate_array.append((row: 4, column: 3))
            eliminate_array.append((row: 4, column: 4))
            eliminate_array.append((row: 5, column: 1))
            eliminate_array.append((row: 5, column: 2))

            
        }
        
        
        
        if(filled[1][8]&&filled[2][8]&&filled[2][9]&&filled[3][7]&&filled[3][8]&&filled[4][5]&&filled[4][6]&&filled[5][3]&&filled[5][4]){
            eliminate_array.append((row: 1, column: 8))
            eliminate_array.append((row: 2, column: 8))
            eliminate_array.append((row: 2, column: 9))
            eliminate_array.append((row: 3, column: 7))
            eliminate_array.append((row: 3, column: 8))
            eliminate_array.append((row: 4, column: 5))
            eliminate_array.append((row: 4, column: 6))
            eliminate_array.append((row: 5, column: 3))
            eliminate_array.append((row: 5, column: 4))
        }
        
        
        if(filled[2][10]&&filled[3][9]&&filled[3][10]&&filled[4][7]&&filled[4][8]&&filled[5][5]&&filled[5][6]){
            eliminate_array.append((row: 2, column: 10))
            eliminate_array.append((row: 3, column: 9))
            eliminate_array.append((row: 3, column: 10))
            eliminate_array.append((row: 4, column: 7))
            eliminate_array.append((row: 4, column: 8))
            eliminate_array.append((row: 5, column: 5))
            eliminate_array.append((row: 5, column: 6))

        }
  
       
        //get the duplicate array

        let sorted_array = eliminate_array.sorted(by: {$0.row < $1.row && $0.column < $1.column})
        
        var previous_element : (row: Int , column: Int) = (row: -1, column: -1)
        var i = 0
        var duplicates_array = [(row: Int, column: Int)]()
        for pair in eliminate_array{
            let current_element = eliminate_array[i]
            if(current_element.column == previous_element.column && current_element.row == previous_element.row){
            duplicates_array.append(previous_element)
            } else{
                previous_element = current_element
            }
            i += 1
        }
        
        
        return duplicates_array
        }
    
    var duplicates_array = [(row: Int, column: Int)]()
    func Check_Element_In_Duplicate_Array(row: Int, column: Int) -> Bool{
        for every_element in duplicates_array{
            if(every_element.column == column && every_element.row == row){
                return true
            }
        }
     return false
    }

    
    func erase_animation_by_row_col(row: Int, col: Int) -> Void{
        if (row == 0 && col == 0){
            self.tri_0_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 0 && col == 1){
            self.tri_0_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }else if (row == 0 && col == 2){
            self.tri_0_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 0 && col == 3){
            self.tri_0_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 0 && col == 4){
            self.tri_0_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 0 && col == 5){
            self.tri_0_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 0 && col == 6){
            self.tri_0_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }
        
        else if (row == 1 && col == 0){
            self.tri_1_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 1){
            self.tri_1_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 2){
            self.tri_1_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 3){
            self.tri_1_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 4){
            self.tri_1_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 5){
            self.tri_1_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 6){
            self.tri_1_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 7){
            self.tri_1_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 1 && col == 8){
            self.tri_1_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }
        
        else if (row == 2 && col == 0){
            self.tri_2_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 1){
            self.tri_2_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 2){
            self.tri_2_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 3){
            self.tri_2_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 4){
            self.tri_2_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 5){
            self.tri_2_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 6){
            self.tri_2_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 7){
            self.tri_2_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 8){
            self.tri_2_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 9){
            self.tri_2_9.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 2 && col == 10){
            self.tri_2_10.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }
        
        else if (row == 3 && col == 0){
            self.tri_3_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 1){
            self.tri_3_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 2){
            self.tri_3_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 3){
            self.tri_3_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 4){
            self.tri_3_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 5){
            self.tri_3_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 6){
            self.tri_3_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 7){
            self.tri_3_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 8){
            self.tri_3_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 9){
            self.tri_3_9.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 3 && col == 10){
            self.tri_3_10.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }
        
        else if (row == 4 && col == 0){
            self.tri_4_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 1){
            self.tri_4_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 2){
            self.tri_4_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 3){
            self.tri_4_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 4){
            self.tri_4_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 5){
            self.tri_4_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 6){
            self.tri_4_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 7){
            self.tri_4_7.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 4 && col == 8){
            self.tri_4_8.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }
        
        else if (row == 5 && col == 0){
            self.tri_5_0.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 5 && col == 1){
            self.tri_5_1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }else if (row == 5 && col == 2){
            self.tri_5_2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 5 && col == 3){
            self.tri_5_3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 5 && col == 4){
            self.tri_5_4.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 5 && col == 5){
            self.tri_5_5.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        } else if (row == 5 && col == 6){
            self.tri_5_6.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 360)
        }
    }
    
    func erase_animation_with_grey_tri_restore_by_row_col(row: Int, col: Int) -> Void{
        if (row == 0 && col == 0){
            self.Restore_A_Grey_Tri(i: 0, j: 0)
            self.tri_0_0.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 0 && col == 1){
            self.Restore_A_Grey_Tri(i: 0, j: 1)
            self.tri_0_1.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 0 && col == 2){
            self.Restore_A_Grey_Tri(i: 0, j: 2)
            self.tri_0_2.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 0 && col == 3){
            self.Restore_A_Grey_Tri(i: 0, j: 3)
            self.tri_0_3.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 0 && col == 4){
            self.Restore_A_Grey_Tri(i: 0, j: 4)
            self.tri_0_4.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 0 && col == 5){
            self.Restore_A_Grey_Tri(i: 0, j: 5)
            self.tri_0_5.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 0 && col == 6){
            self.Restore_A_Grey_Tri(i: 0, j: 6)
            self.tri_0_6.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        else if (row == 1 && col == 0){
            self.Restore_A_Grey_Tri(i: 1, j: 0)
            self.tri_1_0.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 1){
            self.Restore_A_Grey_Tri(i: 1, j: 1)
            self.tri_1_1.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 2){
            self.Restore_A_Grey_Tri(i: 1, j: 2)
            self.tri_1_2.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 3){
            self.Restore_A_Grey_Tri(i: 1, j: 3)
            self.tri_1_3.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 4){
            self.Restore_A_Grey_Tri(i: 1, j: 4)
            self.tri_1_4.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 5){
            self.Restore_A_Grey_Tri(i: 1, j: 5)
            self.tri_1_5.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 6){
            self.Restore_A_Grey_Tri(i: 1, j: 6)
            self.tri_1_6.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 7){
            self.Restore_A_Grey_Tri(i: 1, j: 7)
            self.tri_1_7.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 1 && col == 8){
            self.Restore_A_Grey_Tri(i: 1, j: 8)
            self.tri_1_8.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        else if (row == 2 && col == 0){
            self.Restore_A_Grey_Tri(i: 2, j: 0)
            self.tri_2_0.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 2 && col == 1){
            self.Restore_A_Grey_Tri(i: 2, j: 1)
            self.tri_2_1.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 2){
            self.Restore_A_Grey_Tri(i: 2, j: 2)
            self.tri_2_2.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 3){
            self.Restore_A_Grey_Tri(i: 2, j: 3)
            self.tri_2_3.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 4){
            self.Restore_A_Grey_Tri(i: 2, j: 4)
            self.tri_2_4.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 5){
            self.Restore_A_Grey_Tri(i: 2, j: 5)
            self.tri_2_5.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 6){
            self.Restore_A_Grey_Tri(i: 2, j: 6)
            self.tri_2_6.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 7){
            self.Restore_A_Grey_Tri(i: 2, j: 7)
            self.tri_2_7.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 8){
            self.Restore_A_Grey_Tri(i: 2, j: 8)
            self.tri_2_8.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 9){
            self.Restore_A_Grey_Tri(i: 2, j: 9)
            self.tri_2_9.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 2 && col == 10){
            self.Restore_A_Grey_Tri(i: 2, j: 10)
            self.tri_2_10.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        else if (row == 3 && col == 0){
            self.Restore_A_Grey_Tri(i: 3, j: 0)
            self.tri_3_0.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 3 && col == 1){
            self.Restore_A_Grey_Tri(i: 3, j: 1)
            self.tri_3_1.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 2){
            self.Restore_A_Grey_Tri(i: 3, j: 2)
            self.tri_3_2.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 3){
            self.Restore_A_Grey_Tri(i: 3, j: 3)
            self.tri_3_3.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 4){
            self.Restore_A_Grey_Tri(i: 3, j: 4)
            self.tri_3_4.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 5){
            self.Restore_A_Grey_Tri(i: 3, j: 5)
            self.tri_3_5.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 6){
            self.Restore_A_Grey_Tri(i: 3, j: 6)
            self.tri_3_6.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 7){
            self.Restore_A_Grey_Tri(i: 3, j: 7)
            self.tri_3_7.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 8){
            self.Restore_A_Grey_Tri(i: 3, j: 8)
            self.tri_3_8.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 9){
            self.Restore_A_Grey_Tri(i: 3, j: 9)
            self.tri_3_9.transform = CGAffineTransform(scaleX: 1, y: 1)
        }else if (row == 3 && col == 10){
            self.Restore_A_Grey_Tri(i: 3, j: 10)
            self.tri_3_10.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        else if (row == 4 && col == 0){
            self.Restore_A_Grey_Tri(i: 4, j: 0)
            self.tri_4_0.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 1){
            self.Restore_A_Grey_Tri(i: 4, j: 1)
            self.tri_4_1.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 2){
            self.Restore_A_Grey_Tri(i: 4, j: 2)
            self.tri_4_2.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 3){
            self.Restore_A_Grey_Tri(i: 4, j: 3)
            self.tri_4_3.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 4){
            self.Restore_A_Grey_Tri(i: 4, j: 4)
            self.tri_4_4.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 5){
            self.Restore_A_Grey_Tri(i: 4, j: 5)
            self.tri_4_5.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 6){
            self.Restore_A_Grey_Tri(i: 4, j: 6)
            self.tri_4_6.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 7){
            self.Restore_A_Grey_Tri(i: 4, j: 7)
            self.tri_4_7.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 4 && col == 8){
            self.Restore_A_Grey_Tri(i: 4, j: 8)
            self.tri_4_8.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        else if (row == 5 && col == 0){
            self.Restore_A_Grey_Tri(i: 5, j: 0)
            self.tri_5_0.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 5 && col == 1){
            self.Restore_A_Grey_Tri(i: 5, j: 1)
            self.tri_5_1.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 5 && col == 2){
            self.Restore_A_Grey_Tri(i: 5, j: 2)
            self.tri_5_2.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 5 && col == 3){
            self.Restore_A_Grey_Tri(i: 5, j: 3)
            self.tri_5_3.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 5 && col == 4){
            self.Restore_A_Grey_Tri(i: 5, j: 4)
            self.tri_5_4.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 5 && col == 5){
            self.Restore_A_Grey_Tri(i: 5, j: 5)
            self.tri_5_5.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else if (row == 5 && col == 6){
            self.Restore_A_Grey_Tri(i: 5, j: 6)
            self.tri_5_6.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    
    
    func get_center_tri(index: Int) -> (row: Int, col: Int){
        if index == 0{
            for pair in default_erase_situation_0{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        } else if index == 1{
            for pair in default_erase_situation_1{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        } else if index == 2{
            for pair in default_erase_situation_2{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 3{
            for pair in default_erase_situation_3{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 4{
            for pair in default_erase_situation_4{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 5{
            for pair in default_erase_situation_5{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 6{
            for pair in default_erase_situation_6{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 7{
            for pair in default_erase_situation_7{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 8{
            for pair in default_erase_situation_8{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 9{
            for pair in default_erase_situation_9{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 10{
            for pair in default_erase_situation_10{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 11{
            for pair in default_erase_situation_11{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 12{
            for pair in default_erase_situation_12{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 13{
            for pair in default_erase_situation_13{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 14{
            for pair in default_erase_situation_14{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 15{
            for pair in default_erase_situation_15{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 16{
            for pair in default_erase_situation_16{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }else if index == 17{
            for pair in default_erase_situation_17{
                for tri in cur_shape_tri{
                    if (tri[0] == pair[0] && tri[1] == pair[1]){
                        let cur_x = tri[0]
                        let cur_y = tri[1]
                        return (cur_x, cur_y)
                    }
                }
            }
        }
        return (0,0)
    }
    
    
    func reorder(loc: (row: Int, col: Int), index: Int) -> Void{
        if index == 0{
            var i = 0
            for pair in default_erase_situation_0{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_0.append(default_erase_situation_0[i])
                    while (i + j <= default_erase_situation_0.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_0.count - 1){
                            erase_situation_0.append(default_erase_situation_0[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_0.append(default_erase_situation_0[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 1{
            var i = 0
            for pair in default_erase_situation_1{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_1.append(default_erase_situation_1[i])
                    while (i + j <= default_erase_situation_1.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_1.count - 1){
                            erase_situation_1.append(default_erase_situation_1[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_1.append(default_erase_situation_1[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        } else if index == 2{
            var i = 0
            for pair in default_erase_situation_2{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_2.append(default_erase_situation_2[i])
                    while (i + j <= default_erase_situation_2.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_2.count - 1){
                            erase_situation_2.append(default_erase_situation_2[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_2.append(default_erase_situation_2[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 3{
            var i = 0
            for pair in default_erase_situation_3{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_3.append(default_erase_situation_3[i])
                    while (i + j <= default_erase_situation_3.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_3.count - 1){
                            erase_situation_3.append(default_erase_situation_3[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_3.append(default_erase_situation_3[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 4{
            var i = 0
            for pair in default_erase_situation_4{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_4.append(default_erase_situation_4[i])
                    while (i + j <= default_erase_situation_4.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_4.count - 1){
                            erase_situation_4.append(default_erase_situation_4[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_4.append(default_erase_situation_4[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 5{
            var i = 0
            for pair in default_erase_situation_5{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_5.append(default_erase_situation_5[i])
                    while (i + j <= default_erase_situation_5.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_5.count - 1){
                            erase_situation_5.append(default_erase_situation_5[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_5.append(default_erase_situation_5[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 6{
            var i = 0
            for pair in default_erase_situation_6{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_6.append(default_erase_situation_6[i])
                    while (i + j <= default_erase_situation_6.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_6.count - 1){
                            erase_situation_6.append(default_erase_situation_6[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_6.append(default_erase_situation_6[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 7{
            var i = 0
            for pair in default_erase_situation_7{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_7.append(default_erase_situation_7[i])
                    while (i + j <= default_erase_situation_7.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_7.count - 1){
                            erase_situation_7.append(default_erase_situation_7[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_7.append(default_erase_situation_7[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 8{
            var i = 0
            for pair in default_erase_situation_8{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_8.append(default_erase_situation_8[i])
                    while (i + j <= default_erase_situation_8.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_8.count - 1){
                            erase_situation_8.append(default_erase_situation_8[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_8.append(default_erase_situation_8[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 9{
            var i = 0
            for pair in default_erase_situation_9{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_9.append(default_erase_situation_9[i])
                    while (i + j <= default_erase_situation_9.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_9.count - 1){
                            erase_situation_9.append(default_erase_situation_9[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_9.append(default_erase_situation_9[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 10{
            var i = 0
            for pair in default_erase_situation_10{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_10.append(default_erase_situation_10[i])
                    while (i + j <= default_erase_situation_10.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_10.count - 1){
                            erase_situation_10.append(default_erase_situation_10[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_10.append(default_erase_situation_10[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 11{
            var i = 0
            for pair in default_erase_situation_11{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_11.append(default_erase_situation_11[i])
                    while (i + j <= default_erase_situation_11.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_11.count - 1){
                            erase_situation_11.append(default_erase_situation_11[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_11.append(default_erase_situation_11[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 12{
            var i = 0
            for pair in default_erase_situation_12{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_12.append(default_erase_situation_12[i])
                    while (i + j <= default_erase_situation_12.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_12.count - 1){
                            erase_situation_12.append(default_erase_situation_12[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_12.append(default_erase_situation_12[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 13{
            var i = 0
            for pair in default_erase_situation_13{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_13.append(default_erase_situation_13[i])
                    while (i + j <= default_erase_situation_13.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_13.count - 1){
                            erase_situation_13.append(default_erase_situation_13[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_13.append(default_erase_situation_13[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 14{
            var i = 0
            for pair in default_erase_situation_14{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_14.append(default_erase_situation_14[i])
                    while (i + j <= default_erase_situation_14.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_14.count - 1){
                            erase_situation_14.append(default_erase_situation_14[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_14.append(default_erase_situation_14[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 15{
            var i = 0
            for pair in default_erase_situation_15{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_15.append(default_erase_situation_15[i])
                    while (i + j <= default_erase_situation_15.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_15.count - 1){
                            erase_situation_15.append(default_erase_situation_15[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_15.append(default_erase_situation_15[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 16{
            var i = 0
            for pair in default_erase_situation_16{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_16.append(default_erase_situation_16[i])
                    while (i + j <= default_erase_situation_16.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_16.count - 1){
                            erase_situation_16.append(default_erase_situation_16[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_16.append(default_erase_situation_16[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }else if index == 17{
            var i = 0
            for pair in default_erase_situation_17{
                if (loc.row == pair[0] && loc.col == pair[1]){
                    var j = 1
                    erase_situation_17.append(default_erase_situation_17[i])
                    while (i + j <= default_erase_situation_17.count - 1 || i - j >= 0){
                        if (i + j <= default_erase_situation_17.count - 1){
                            erase_situation_17.append(default_erase_situation_17[i + j])
                        }
                        if (i - j >= 0){
                            erase_situation_17.append(default_erase_situation_17[i - j])
                        }
                        j += 1
                    }
                    return
                }
                i += 1
            }
        }
    }
    
    func Check_and_Erase() -> Void {
      //duplicates_array = Check_and_Erase_Create_Array()
        //situation one - row
        //eliminate first row
         situation0 = false
        situation1 = false
         situation2 = false
        situation3 = false
       situation4 = false
         situation5 = false
         situation6 = false
        situation7 = false
         situation8 = false
       situation9 = false
        situation10 = false
        situation11 = false
       situation12 = false
         situation13 = false
         situation14 = false
         situation15 = false
         situation16 = false
          situation17 = false
        
        erase_situation_0 = []
        erase_situation_1 = []
        erase_situation_2 = []
        erase_situation_3 = []
        erase_situation_4 = []
        erase_situation_5 = []
        erase_situation_6 = []
        erase_situation_7 = []
        erase_situation_8 = []
        erase_situation_9 = []
        erase_situation_10 = []
        erase_situation_11 = []
        erase_situation_12 = []
        erase_situation_13 = []
        erase_situation_14 = []
        erase_situation_15 = []
        erase_situation_16 = []
        erase_situation_17 = []
        
        number_of_lines_erased = 0
        if(filled[0][0]&&filled[0][1]&&filled[0][2]&&filled[0][3]&&filled[0][4]&&filled[0][5]&&filled[0][6]){
          situation0 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 0)
            reorder(loc: center_loc, index: 0)
            UIView.animate(withDuration: 0.1, animations: {
               self.erase_animation_by_row_col(row: self.erase_situation_0[0][0], col: self.erase_situation_0[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[0][0], col: self.erase_situation_0[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_0[1][0], col: self.erase_situation_0[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[1][0], col: self.erase_situation_0[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_0[2][0], col: self.erase_situation_0[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[2][0], col: self.erase_situation_0[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_0[3][0], col: self.erase_situation_0[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[3][0], col: self.erase_situation_0[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                              self.erase_animation_by_row_col(row: self.erase_situation_0[4][0], col: self.erase_situation_0[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[4][0], col: self.erase_situation_0[4][1])

                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_0[5][0], col: self.erase_situation_0[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[5][0], col: self.erase_situation_0[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                         self.erase_animation_by_row_col(row: self.erase_situation_0[6][0], col: self.erase_situation_0[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_0[6][0], col: self.erase_situation_0[6][1])
                                    
                                    })
                                })
                            })
                        })
                    })
                    
 
                })
        })
            
        }
        
        //eliminate second row
        if(filled[1][0]&&filled[1][1]&&filled[1][2]&&filled[1][3]&&filled[1][4]&&filled[1][5]&&filled[1][6]&&filled[1][7]&&filled[1][8]){
 
         situation1 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 1)
            reorder(loc: center_loc, index: 1)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_1[0][0], col: self.erase_situation_1[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[0][0], col: self.erase_situation_1[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_1[1][0], col: self.erase_situation_1[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[1][0], col: self.erase_situation_1[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_1[2][0], col: self.erase_situation_1[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[2][0], col: self.erase_situation_1[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_1[3][0], col: self.erase_situation_1[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[3][0], col: self.erase_situation_1[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_1[4][0], col: self.erase_situation_1[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[4][0], col: self.erase_situation_1[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_1[5][0], col: self.erase_situation_1[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[5][0], col: self.erase_situation_1[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_1[6][0], col: self.erase_situation_1[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[6][0], col: self.erase_situation_1[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_1[7][0], col: self.erase_situation_1[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[7][0], col: self.erase_situation_1[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_1[8][0], col: self.erase_situation_1[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_1[8][0], col: self.erase_situation_1[8][1])
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })

        }
        //eliminate third row
        if(filled[2][0]&&filled[2][1]&&filled[2][2]&&filled[2][3]&&filled[2][4]&&filled[2][5]&&filled[2][6]&&filled[2][7]&&filled[2][8]&&filled[2][9]&&filled[2][10]){


            
            
            situation2 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 2)
            reorder(loc: center_loc, index: 2)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_2[0][0], col: self.erase_situation_2[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[0][0], col: self.erase_situation_2[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_2[1][0], col: self.erase_situation_2[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[1][0], col: self.erase_situation_2[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_2[2][0], col: self.erase_situation_2[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[2][0], col: self.erase_situation_2[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_2[3][0], col: self.erase_situation_2[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[3][0], col: self.erase_situation_2[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_2[4][0], col: self.erase_situation_2[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[4][0], col: self.erase_situation_2[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_2[5][0], col: self.erase_situation_2[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[5][0], col: self.erase_situation_2[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_2[6][0], col: self.erase_situation_2[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[6][0], col: self.erase_situation_2[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_2[7][0], col: self.erase_situation_2[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[7][0], col: self.erase_situation_2[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_2[8][0], col: self.erase_situation_2[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[8][0], col: self.erase_situation_2[8][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_2[9][0], col: self.erase_situation_2[9][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[9][0], col: self.erase_situation_2[9][1])
                                                    UIView.animate(withDuration: 0.1, animations: {
                                                        self.erase_animation_by_row_col(row: self.erase_situation_2[10][0], col: self.erase_situation_2[10][1])
                                                    }, completion: {
                                                        (finished) -> Void in
                                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_2[10][0], col: self.erase_situation_2[10][1])
                                                    })
                                                })
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })

        }
        
        //eliminate fourth row
        if(filled[3][0]&&filled[3][1]&&filled[3][2]&&filled[3][3]&&filled[3][4]&&filled[3][5]&&filled[3][6]&&filled[3][7]&&filled[3][8]&&filled[3][9]&&filled[3][10]){

            situation3 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 3)
            reorder(loc: center_loc, index: 3)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_3[0][0], col: self.erase_situation_3[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[0][0], col: self.erase_situation_3[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_3[1][0], col: self.erase_situation_3[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[1][0], col: self.erase_situation_3[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_3[2][0], col: self.erase_situation_3[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[2][0], col: self.erase_situation_3[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_3[3][0], col: self.erase_situation_3[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[3][0], col: self.erase_situation_3[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_3[4][0], col: self.erase_situation_3[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[4][0], col: self.erase_situation_3[4][1])
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_3[5][0], col: self.erase_situation_3[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[5][0], col: self.erase_situation_3[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_3[6][0], col: self.erase_situation_3[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[6][0], col: self.erase_situation_3[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_3[7][0], col: self.erase_situation_3[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[7][0], col: self.erase_situation_3[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_3[8][0], col: self.erase_situation_3[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[8][0], col: self.erase_situation_3[8][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_3[9][0], col: self.erase_situation_3[9][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[9][0], col: self.erase_situation_3[9][1])
                                                    UIView.animate(withDuration: 0.1, animations: {
                                                        self.erase_animation_by_row_col(row: self.erase_situation_3[10][0], col: self.erase_situation_3[10][1])
                                                    }, completion: {
                                                        (finished) -> Void in
                                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_3[10][0], col: self.erase_situation_3[10][1])
                                                    })
                                                })
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })

        }
        //eliminate fifth row
        if(filled[4][0]&&filled[4][1]&&filled[4][2]&&filled[4][3]&&filled[4][4]&&filled[4][5]&&filled[4][6]&&filled[4][7]&&filled[4][8]){

            

           situation4 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 4)
            reorder(loc: center_loc, index: 4)
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_4[0][0], col: self.erase_situation_4[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[0][0], col: self.erase_situation_4[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_4[1][0], col: self.erase_situation_4[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[1][0], col: self.erase_situation_4[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_4[2][0], col: self.erase_situation_4[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[2][0], col: self.erase_situation_4[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_4[3][0], col: self.erase_situation_4[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[3][0], col: self.erase_situation_4[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_4[4][0], col: self.erase_situation_4[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[4][0], col: self.erase_situation_4[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_4[5][0], col: self.erase_situation_4[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[5][0], col: self.erase_situation_4[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_4[6][0], col: self.erase_situation_4[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[6][0], col: self.erase_situation_4[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_4[7][0], col: self.erase_situation_4[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[7][0], col: self.erase_situation_4[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_4[8][0], col: self.erase_situation_4[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_4[8][0], col: self.erase_situation_4[8][1])
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })

        }
        ////eliminate sixth row
        if(filled[5][0]&&filled[5][1]&&filled[5][2]&&filled[5][3]&&filled[5][4]&&filled[5][5]&&filled[5][6]){

 
            situation5 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 5)
            reorder(loc: center_loc, index: 5)
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_5[0][0], col: self.erase_situation_5[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[0][0], col: self.erase_situation_5[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_5[1][0], col: self.erase_situation_5[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[1][0], col: self.erase_situation_5[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_5[2][0], col: self.erase_situation_5[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[2][0], col: self.erase_situation_5[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_5[3][0], col: self.erase_situation_5[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[3][0], col: self.erase_situation_5[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_5[4][0], col: self.erase_situation_5[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[4][0], col: self.erase_situation_5[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_5[5][0], col: self.erase_situation_5[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[5][0], col: self.erase_situation_5[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_5[6][0], col: self.erase_situation_5[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_5[6][0], col: self.erase_situation_5[6][1])
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            
        }
        
        
        //situation two - 右下斜
        if(filled[2][0]&&filled[3][0]&&filled[3][1]&&filled[4][0]&&filled[4][1]&&filled[5][0]&&filled[5][1]){


            situation6 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 6)
            reorder(loc: center_loc, index: 6)
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_6[0][0], col: self.erase_situation_6[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[0][0], col: self.erase_situation_6[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_6[1][0], col: self.erase_situation_6[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[1][0], col: self.erase_situation_6[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_6[2][0], col: self.erase_situation_6[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[2][0], col: self.erase_situation_6[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_6[3][0], col: self.erase_situation_6[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[3][0], col: self.erase_situation_6[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_6[4][0], col: self.erase_situation_6[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[4][0], col: self.erase_situation_6[4][1])
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_6[5][0], col: self.erase_situation_6[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[5][0], col: self.erase_situation_6[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_6[6][0], col: self.erase_situation_6[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_6[6][0], col: self.erase_situation_6[6][1])
                                    })
                                })
                            })
  
                        })
                    })
                })
            })
            
        }
        
        
        if(filled[1][0]&&filled[2][1]&&filled[2][2]&&filled[3][2]&&filled[3][3]&&filled[4][2]&&filled[4][3]&&filled[5][2]&&filled[5][3]){


 situation7 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 7)
            reorder(loc: center_loc, index: 7)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_7[0][0], col: self.erase_situation_7[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[0][0], col: self.erase_situation_7[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_7[1][0], col: self.erase_situation_7[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[1][0], col: self.erase_situation_7[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_7[2][0], col: self.erase_situation_7[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[2][0], col: self.erase_situation_7[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_7[3][0], col: self.erase_situation_7[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[3][0], col: self.erase_situation_7[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_7[4][0], col: self.erase_situation_7[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[4][0], col: self.erase_situation_7[4][1])
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_7[5][0], col: self.erase_situation_7[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[5][0], col: self.erase_situation_7[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_7[6][0], col: self.erase_situation_7[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[6][0], col: self.erase_situation_7[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_7[7][0], col: self.erase_situation_7[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[7][0], col: self.erase_situation_7[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_7[8][0], col: self.erase_situation_7[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_7[8][0], col: self.erase_situation_7[8][1])
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            

            
            
            
            
            
            
        }
        if(filled[0][0]&&filled[1][1]&&filled[1][2]&&filled[2][3]&&filled[2][4]&&filled[3][4]&&filled[3][5]&&filled[4][4]&&filled[4][5]&&filled[5][4]&&filled[5][5]){
 situation8 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 8)
            reorder(loc: center_loc, index: 8)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_8[0][0], col: self.erase_situation_8[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[0][0], col: self.erase_situation_8[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_8[1][0], col: self.erase_situation_8[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[1][0], col: self.erase_situation_8[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_8[2][0], col: self.erase_situation_8[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[2][0], col: self.erase_situation_8[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_8[3][0], col: self.erase_situation_8[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[3][0], col: self.erase_situation_8[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_8[4][0], col: self.erase_situation_8[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[4][0], col: self.erase_situation_8[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_8[5][0], col: self.erase_situation_8[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[5][0], col: self.erase_situation_8[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_8[6][0], col: self.erase_situation_8[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[6][0], col: self.erase_situation_8[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_8[7][0], col: self.erase_situation_8[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[7][0], col: self.erase_situation_8[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_8[8][0], col: self.erase_situation_8[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[8][0], col: self.erase_situation_8[8][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_8[9][0], col: self.erase_situation_8[9][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[9][0], col: self.erase_situation_8[9][1])
                                                    UIView.animate(withDuration: 0.1, animations: {
                                                        self.erase_animation_by_row_col(row: self.erase_situation_8[10][0], col: self.erase_situation_8[10][1])
                                                    }, completion: {
                                                        (finished) -> Void in
                                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_8[10][0], col: self.erase_situation_8[10][1])
                                                    })
                                                })
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            
            
            
            
            
        }
        
        
        
        
        if(filled[0][1]&&filled[0][2]&&filled[1][3]&&filled[1][4]&&filled[2][5]&&filled[2][6]&&filled[3][6]&&filled[3][7]&&filled[4][6]&&filled[4][7]&&filled[5][6]){

             situation9 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 9)
            reorder(loc: center_loc, index: 9)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_9[0][0], col: self.erase_situation_9[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[0][0], col: self.erase_situation_9[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_9[1][0], col: self.erase_situation_9[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[1][0], col: self.erase_situation_9[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_9[2][0], col: self.erase_situation_9[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[2][0], col: self.erase_situation_9[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_9[3][0], col: self.erase_situation_9[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[3][0], col: self.erase_situation_9[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_9[4][0], col: self.erase_situation_9[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[4][0], col: self.erase_situation_9[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_9[5][0], col: self.erase_situation_9[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[5][0], col: self.erase_situation_9[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_9[6][0], col: self.erase_situation_9[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[6][0], col: self.erase_situation_9[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_9[7][0], col: self.erase_situation_9[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[7][0], col: self.erase_situation_9[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_9[8][0], col: self.erase_situation_9[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[8][0], col: self.erase_situation_9[8][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_9[9][0], col: self.erase_situation_9[9][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[9][0], col: self.erase_situation_9[9][1])
                                                    UIView.animate(withDuration: 0.1, animations: {
                                                        self.erase_animation_by_row_col(row: self.erase_situation_9[10][0], col: self.erase_situation_9[10][1])
                                                    }, completion: {
                                                        (finished) -> Void in
                                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_9[10][0], col: self.erase_situation_9[10][1])
                                                    })
                                                })
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            
            
        }
        
        
        if(filled[0][3]&&filled[0][4]&&filled[1][5]&&filled[1][6]&&filled[2][7]&&filled[2][8]&&filled[3][8]&&filled[3][9]&&filled[4][8]){
            



             situation10 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 10)
            reorder(loc: center_loc, index: 10)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_10[0][0], col: self.erase_situation_10[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[0][0], col: self.erase_situation_10[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_10[1][0], col: self.erase_situation_10[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[1][0], col: self.erase_situation_10[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_10[2][0], col: self.erase_situation_10[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[2][0], col: self.erase_situation_10[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_10[3][0], col: self.erase_situation_10[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[3][0], col: self.erase_situation_10[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_10[4][0], col: self.erase_situation_10[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[4][0], col: self.erase_situation_10[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_10[5][0], col: self.erase_situation_10[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[5][0], col: self.erase_situation_10[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_10[6][0], col: self.erase_situation_10[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[6][0], col: self.erase_situation_10[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_10[7][0], col: self.erase_situation_10[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[7][0], col: self.erase_situation_10[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_10[8][0], col: self.erase_situation_10[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_10[8][0], col: self.erase_situation_10[8][1])
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            

        }
        if(filled[0][5]&&filled[0][6]&&filled[1][7]&&filled[1][8]&&filled[2][9]&&filled[2][10]&&filled[3][10]){


 situation11 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 11)
            reorder(loc: center_loc, index: 11)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_11[0][0], col: self.erase_situation_11[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[0][0], col: self.erase_situation_11[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_11[1][0], col: self.erase_situation_11[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[1][0], col: self.erase_situation_11[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_11[2][0], col: self.erase_situation_11[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[2][0], col: self.erase_situation_11[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_11[3][0], col: self.erase_situation_11[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[3][0], col: self.erase_situation_11[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_11[4][0], col: self.erase_situation_11[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[4][0], col: self.erase_situation_11[4][1])
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_11[5][0], col: self.erase_situation_11[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[5][0], col: self.erase_situation_11[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_11[6][0], col: self.erase_situation_11[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_11[6][0], col: self.erase_situation_11[6][1])
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            

        }
        
        
        //situation three - 左下斜
        if(filled[0][0]&&filled[0][1]&&filled[1][0]&&filled[1][1]&&filled[2][0]&&filled[2][1]&&filled[3][0]){

 situation12 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 12)
            reorder(loc: center_loc, index: 12)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_12[0][0], col: self.erase_situation_12[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[0][0], col: self.erase_situation_12[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_12[1][0], col: self.erase_situation_12[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[1][0], col: self.erase_situation_12[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_12[2][0], col: self.erase_situation_12[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[2][0], col: self.erase_situation_12[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_12[3][0], col: self.erase_situation_12[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[3][0], col: self.erase_situation_12[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_12[4][0], col: self.erase_situation_12[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[4][0], col: self.erase_situation_12[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_12[5][0], col: self.erase_situation_12[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[5][0], col: self.erase_situation_12[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_12[6][0], col: self.erase_situation_12[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_12[6][0], col: self.erase_situation_12[6][1])
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            

        }
        
        
        if(filled[0][2]&&filled[0][3]&&filled[1][2]&&filled[1][3]&&filled[2][2]&&filled[2][3]&&filled[3][1]&&filled[3][2]&&filled[4][0]){
 situation13 = true
number_of_lines_erased += 1
            //animation
            let center_loc = get_center_tri(index: 13)
            reorder(loc: center_loc, index: 13)
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_13[0][0], col: self.erase_situation_13[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[0][0], col: self.erase_situation_13[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_13[1][0], col: self.erase_situation_13[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[1][0], col: self.erase_situation_13[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_13[2][0], col: self.erase_situation_13[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[2][0], col: self.erase_situation_13[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_13[3][0], col: self.erase_situation_13[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[3][0], col: self.erase_situation_13[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_13[4][0], col: self.erase_situation_13[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[4][0], col: self.erase_situation_13[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_13[5][0], col: self.erase_situation_13[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[5][0], col: self.erase_situation_13[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_13[6][0], col: self.erase_situation_13[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[6][0], col: self.erase_situation_13[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_13[7][0], col: self.erase_situation_13[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[7][0], col: self.erase_situation_13[7][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_13[8][0], col: self.erase_situation_13[8][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_13[8][0], col: self.erase_situation_13[8][1])
                                                })
                                            
                                        })
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
            

        }
        
        if(filled[0][4]&&filled[0][5]&&filled[1][4]&&filled[1][5]&&filled[2][4]&&filled[2][5]&&filled[3][3]&&filled[3][4]&&filled[4][1]&&filled[4][2]&&filled[5][0]){

 situation14 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 14)
            reorder(loc: center_loc, index: 14)
        
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_14[0][0], col: self.erase_situation_14[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[0][0], col: self.erase_situation_14[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_14[1][0], col: self.erase_situation_14[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[1][0], col: self.erase_situation_14[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_14[2][0], col: self.erase_situation_14[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[2][0], col: self.erase_situation_14[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_14[3][0], col: self.erase_situation_14[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[3][0], col: self.erase_situation_14[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_14[4][0], col: self.erase_situation_14[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[4][0], col: self.erase_situation_14[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_14[5][0], col: self.erase_situation_14[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[5][0], col: self.erase_situation_14[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_14[6][0], col: self.erase_situation_14[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[6][0], col: self.erase_situation_14[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_14[7][0], col: self.erase_situation_14[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[7][0], col: self.erase_situation_14[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_14[8][0], col: self.erase_situation_14[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[8][0], col: self.erase_situation_14[8][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_14[9][0], col: self.erase_situation_14[9][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[9][0], col: self.erase_situation_14[9][1])
                                                    UIView.animate(withDuration: 0.1, animations: {
                                                        self.erase_animation_by_row_col(row: self.erase_situation_14[10][0], col: self.erase_situation_14[10][1])
                                                    }, completion: {
                                                        (finished) -> Void in
                                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_14[10][0], col: self.erase_situation_14[10][1])
                                                    })
                                                })
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })

        }
        if(filled[0][6]&&filled[1][6]&&filled[1][7]&&filled[2][6]&&filled[2][7]&&filled[3][5]&&filled[3][6]&&filled[4][3]&&filled[4][4]&&filled[5][1]&&filled[5][2]){

 situation15 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 15)
            reorder(loc: center_loc, index: 15)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_15[0][0], col: self.erase_situation_15[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[0][0], col: self.erase_situation_15[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_15[1][0], col: self.erase_situation_15[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[1][0], col: self.erase_situation_15[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_15[2][0], col: self.erase_situation_15[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[2][0], col: self.erase_situation_15[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_15[3][0], col: self.erase_situation_15[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[3][0], col: self.erase_situation_15[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_15[4][0], col: self.erase_situation_15[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[4][0], col: self.erase_situation_15[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_15[5][0], col: self.erase_situation_15[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[5][0], col: self.erase_situation_15[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_15[6][0], col: self.erase_situation_15[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[6][0], col: self.erase_situation_15[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_15[7][0], col: self.erase_situation_15[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[7][0], col: self.erase_situation_15[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_15[8][0], col: self.erase_situation_15[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[8][0], col: self.erase_situation_15[8][1])
                                                UIView.animate(withDuration: 0.1, animations: {
                                                    self.erase_animation_by_row_col(row: self.erase_situation_15[9][0], col: self.erase_situation_15[9][1])
                                                }, completion: {
                                                    (finished) -> Void in
                                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[9][0], col: self.erase_situation_15[9][1])
                                                    UIView.animate(withDuration: 0.1, animations: {
                                                        self.erase_animation_by_row_col(row: self.erase_situation_15[10][0], col: self.erase_situation_15[10][1])
                                                    }, completion: {
                                                        (finished) -> Void in
                                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_15[10][0], col: self.erase_situation_15[10][1])
                                                    })
                                                })
                                            })
                                        })
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })


        }
        
        
        
        if(filled[1][8]&&filled[2][8]&&filled[2][9]&&filled[3][7]&&filled[3][8]&&filled[4][5]&&filled[4][6]&&filled[5][3]&&filled[5][4]){

 situation16 = true
            number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 16)
            reorder(loc: center_loc, index: 16)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_16[0][0], col: self.erase_situation_16[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[0][0], col: self.erase_situation_16[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_16[1][0], col: self.erase_situation_16[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[1][0], col: self.erase_situation_16[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_16[2][0], col: self.erase_situation_16[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[2][0], col: self.erase_situation_16[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_16[3][0], col: self.erase_situation_16[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[3][0], col: self.erase_situation_16[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_16[4][0], col: self.erase_situation_16[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[4][0], col: self.erase_situation_16[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_16[5][0], col: self.erase_situation_16[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[5][0], col: self.erase_situation_16[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_16[6][0], col: self.erase_situation_16[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[6][0], col: self.erase_situation_16[6][1])
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.erase_animation_by_row_col(row: self.erase_situation_16[7][0], col: self.erase_situation_16[7][1])
                                        }, completion: {
                                            (finished) -> Void in
                                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[7][0], col: self.erase_situation_16[7][1])
                                            UIView.animate(withDuration: 0.1, animations: {
                                                self.erase_animation_by_row_col(row: self.erase_situation_16[8][0], col: self.erase_situation_16[8][1])
                                            }, completion: {
                                                (finished) -> Void in
                                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_16[8][0], col: self.erase_situation_16[8][1])
                                            })
                                            
                                        })
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
        }
        
        
        if(filled[2][10]&&filled[3][9]&&filled[3][10]&&filled[4][7]&&filled[4][8]&&filled[5][5]&&filled[5][6]){
 situation17 = true
number_of_lines_erased += 1
            let center_loc = get_center_tri(index: 17)
            reorder(loc: center_loc, index: 17)
            //animation
            UIView.animate(withDuration: 0.1, animations: {
                self.erase_animation_by_row_col(row: self.erase_situation_17[0][0], col: self.erase_situation_17[0][1])
            }, completion: {
                (finished) -> Void in
                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[0][0], col: self.erase_situation_17[0][1])
                UIView.animate(withDuration: 0.1, animations: {
                    self.erase_animation_by_row_col(row: self.erase_situation_17[1][0], col: self.erase_situation_17[1][1])
                }, completion: {
                    (finished) -> Void in
                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[1][0], col: self.erase_situation_17[1][1])
                    UIView.animate(withDuration: 0.1, animations: {
                        self.erase_animation_by_row_col(row: self.erase_situation_17[2][0], col: self.erase_situation_17[2][1])
                    }, completion: {
                        (finished) -> Void in
                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[2][0], col: self.erase_situation_17[2][1])
                        UIView.animate(withDuration: 0.1, animations: {
                            self.erase_animation_by_row_col(row: self.erase_situation_17[3][0], col: self.erase_situation_17[3][1])
                        }, completion: {
                            (finished) -> Void in
                            self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[3][0], col: self.erase_situation_17[3][1])
                            UIView.animate(withDuration: 0.1, animations: {
                                self.erase_animation_by_row_col(row: self.erase_situation_17[4][0], col: self.erase_situation_17[4][1])
                            }, completion: {
                                (finished) -> Void in
                                self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[4][0], col: self.erase_situation_17[4][1])
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.erase_animation_by_row_col(row: self.erase_situation_17[5][0], col: self.erase_situation_17[5][1])
                                }, completion: {
                                    (finished) -> Void in
                                    self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[5][0], col: self.erase_situation_17[5][1])
                                    UIView.animate(withDuration: 0.1, animations: {
                                        self.erase_animation_by_row_col(row: self.erase_situation_17[6][0], col: self.erase_situation_17[6][1])
                                    }, completion: {
                                        (finished) -> Void in
                                        self.erase_animation_with_grey_tri_restore_by_row_col(row: self.erase_situation_17[6][0], col: self.erase_situation_17[6][1])
                                        
                                    })
                                })
                            })
                        })
                    })
                    
                    
                })
            })
        }
        Check_And_Erase_Fix_Filled()

    }
    
    
    func Check_And_Erase_Fix_Filled() -> Void {
        

        if(situation0){
           // erase_player.play()
            filled[0][0] = false
            filled[0][1] = false
            filled[0][2] = false
            filled[0][3] = false
            filled[0][4] = false
            filled[0][5] = false
            filled[0][6] = false
            
            single_tri_stored_type_index[0][0] = -1
            single_tri_stored_type_index[0][1] = -1
            single_tri_stored_type_index[0][2] = -1
            single_tri_stored_type_index[0][3] = -1
            single_tri_stored_type_index[0][4] = -1
            single_tri_stored_type_index[0][5] = -1
            single_tri_stored_type_index[0][6] = -1
        }
        
        //eliminate second row
        if(situation1){
            //erase_player.play()
            filled[1][0] = false
            filled[1][1] = false
            filled[1][2] = false
            filled[1][3] = false
            filled[1][4] = false
            filled[1][5] = false
            filled[1][6] = false
            filled[1][7] = false
            filled[1][8] = false
            single_tri_stored_type_index[1][0] = -1
            single_tri_stored_type_index[1][1] = -1
            single_tri_stored_type_index[1][2] = -1
            single_tri_stored_type_index[1][3] = -1
            single_tri_stored_type_index[1][4] = -1
            single_tri_stored_type_index[1][5] = -1
            single_tri_stored_type_index[1][6] = -1
            single_tri_stored_type_index[1][7] = -1
            single_tri_stored_type_index[1][8] = -1
            
        }
        //eliminate third row
        if( situation2){
            //erase_player.play()
            filled[2][0] = false
            filled[2][1] = false
            filled[2][2] = false
            filled[2][3] = false
            filled[2][4] = false
            filled[2][5] = false
            filled[2][6] = false
            filled[2][7] = false
            filled[2][8] = false
            filled[2][9] = false
            filled[2][10] = false
            single_tri_stored_type_index[2][0] = -1
            single_tri_stored_type_index[2][1] = -1
            single_tri_stored_type_index[2][2] = -1
            single_tri_stored_type_index[2][3] = -1
            single_tri_stored_type_index[2][4] = -1
            single_tri_stored_type_index[2][5] = -1
            single_tri_stored_type_index[2][6] = -1
            single_tri_stored_type_index[2][7] = -1
            single_tri_stored_type_index[2][8] = -1
            single_tri_stored_type_index[2][9] = -1
            single_tri_stored_type_index[2][10] = -1
        }
        
        //eliminate fourth row
        if( situation3){
            //erase_player.play()
            filled[3][0] = false
            filled[3][1] = false
            filled[3][2] = false
            filled[3][3] = false
            filled[3][4] = false
            filled[3][5] = false
            filled[3][6] = false
            filled[3][7] = false
            filled[3][8] = false
            filled[3][9] = false
            filled[3][10] = false
            
            single_tri_stored_type_index[3][0] = -1
            single_tri_stored_type_index[3][1] = -1
            single_tri_stored_type_index[3][2] = -1
            single_tri_stored_type_index[3][3] = -1
            single_tri_stored_type_index[3][4] = -1
            single_tri_stored_type_index[3][5] = -1
            single_tri_stored_type_index[3][6] = -1
            single_tri_stored_type_index[3][7] = -1
            single_tri_stored_type_index[3][8] = -1
            single_tri_stored_type_index[3][9] = -1
            single_tri_stored_type_index[3][10] = -1
            
        }
        //eliminate fifth row
        if( situation4){
            //erase_player.play()
            filled[4][0] = false
            filled[4][1] = false
            filled[4][2] = false
            filled[4][3] = false
            filled[4][4] = false
            filled[4][5] = false
            filled[4][6] = false
            filled[4][7] = false
            filled[4][8] = false
            
            single_tri_stored_type_index[4][0] = -1
            single_tri_stored_type_index[4][1] = -1
            single_tri_stored_type_index[4][2] = -1
            single_tri_stored_type_index[4][3] = -1
            single_tri_stored_type_index[4][4] = -1
            single_tri_stored_type_index[4][5] = -1
            single_tri_stored_type_index[4][6] = -1
            single_tri_stored_type_index[4][7] = -1
            single_tri_stored_type_index[4][8] = -1
        }
        ////eliminate sixth row
        if( situation5){
            //erase_player.play()
            filled[5][0] = false
            filled[5][1] = false
            filled[5][2] = false
            filled[5][3] = false
            filled[5][4] = false
            filled[5][5] = false
            filled[5][6] = false
            
            single_tri_stored_type_index[5][0] = -1
            single_tri_stored_type_index[5][1] = -1
            single_tri_stored_type_index[5][2] = -1
            single_tri_stored_type_index[5][3] = -1
            single_tri_stored_type_index[5][4] = -1
            single_tri_stored_type_index[5][5] = -1
            single_tri_stored_type_index[5][6] = -1
            
        }
        
        
        //situation two - 右下斜
        if(situation6){
            //erase_player.play()
            filled[2][0] = false
            filled[3][0] = false
            filled[3][1] = false
            filled[4][0] = false
            filled[4][1] = false
            filled[5][0] = false
            filled[5][1] = false
            
            single_tri_stored_type_index[2][0] = -1
            single_tri_stored_type_index[3][0] = -1
            single_tri_stored_type_index[3][1] = -1
            single_tri_stored_type_index[4][0] = -1
            single_tri_stored_type_index[4][1] = -1
            single_tri_stored_type_index[5][0] = -1
            single_tri_stored_type_index[5][1] = -1
            
        }
        
        
        if(situation7){
            //erase_player.play()
            filled[1][0] = false
            filled[2][1] = false
            filled[2][2] = false
            filled[3][2] = false
            filled[3][3] = false
            filled[4][2] = false
            filled[4][3] = false
            filled[5][2] = false
            filled[5][3] = false
            
            single_tri_stored_type_index[1][0] = -1
            single_tri_stored_type_index[2][1] = -1
            single_tri_stored_type_index[2][2] = -1
            single_tri_stored_type_index[3][2] = -1
            single_tri_stored_type_index[3][3] = -1
            single_tri_stored_type_index[4][2] = -1
            single_tri_stored_type_index[4][3] = -1
            single_tri_stored_type_index[5][2] = -1
            single_tri_stored_type_index[5][3] = -1
            
            
        }
        if(situation8){
            //erase_player.play()
            filled[0][0] = false
            filled[1][1] = false
            filled[1][2] = false
            filled[2][3] = false
            filled[2][4] = false
            filled[3][4] = false
            filled[3][5] = false
            filled[4][4] = false
            filled[4][5] = false
            filled[5][4] = false
            filled[5][5] = false

            
            single_tri_stored_type_index[0][0] = -1
            single_tri_stored_type_index[1][1] = -1
            single_tri_stored_type_index[1][2] = -1
            single_tri_stored_type_index[2][3] = -1
            single_tri_stored_type_index[2][4] = -1
            single_tri_stored_type_index[3][4] = -1
            single_tri_stored_type_index[3][5] = -1
            single_tri_stored_type_index[4][4] = -1
            single_tri_stored_type_index[4][5] = -1
            single_tri_stored_type_index[5][4] = -1
            single_tri_stored_type_index[5][5] = -1
            
        }
        
        
        
        
        if(situation9){
            //erase_player.play()
            filled[0][1] = false
            filled[0][2] = false
            filled[1][3] = false
            filled[1][4] = false
            filled[2][5] = false
            filled[2][6] = false
            filled[3][6] = false
            filled[3][7] = false
            filled[4][6] = false
            filled[4][7] = false
            filled[5][6] = false
            
            single_tri_stored_type_index[0][1] = -1
            single_tri_stored_type_index[0][2] = -1
            single_tri_stored_type_index[1][3] = -1
            single_tri_stored_type_index[1][4] = -1
            single_tri_stored_type_index[2][5] = -1
            single_tri_stored_type_index[2][6] = -1
            single_tri_stored_type_index[3][6] = -1
            single_tri_stored_type_index[3][7] = -1
            single_tri_stored_type_index[4][6] = -1
            single_tri_stored_type_index[4][7] = -1
            single_tri_stored_type_index[5][6] = -1
            
            
        }
        
        
        if(situation10){
            //erase_player.play()
            
            filled[0][3] = false
            filled[0][4] = false
            filled[1][5] = false
            filled[1][6] = false
            filled[2][7] = false
            filled[2][8] = false
            filled[3][8] = false
            filled[3][9] = false
            filled[4][8] = false
            
            single_tri_stored_type_index[0][3] = -1
            single_tri_stored_type_index[0][4] = -1
            single_tri_stored_type_index[1][5] = -1
            single_tri_stored_type_index[1][6] = -1
            single_tri_stored_type_index[2][7] = -1
            single_tri_stored_type_index[2][8] = -1
            single_tri_stored_type_index[3][8] = -1
            single_tri_stored_type_index[3][9] = -1
            single_tri_stored_type_index[4][8] = -1
            
        }
        if(situation11){
            //erase_player.play()
            filled[0][5] = false
            filled[0][6] = false
            filled[1][7] = false
            filled[1][8] = false
            filled[2][9] = false
            filled[2][10] = false
            filled[3][10] = false
            single_tri_stored_type_index[0][5] = -1
            single_tri_stored_type_index[0][6] = -1
            single_tri_stored_type_index[1][7] = -1
            single_tri_stored_type_index[1][8] = -1
            single_tri_stored_type_index[2][9] = -1
            single_tri_stored_type_index[2][10] = -1
            single_tri_stored_type_index[3][10] = -1
            
            
        }
        
        
        //situation three - 左下斜
        if(situation12){
            //erase_player.play()
            filled[0][0] = false
            filled[0][1] = false
            filled[1][0] = false
            filled[1][1] = false
            filled[2][0] = false
            filled[2][1] = false
            filled[3][0] = false
            single_tri_stored_type_index[0][0] = -1
            single_tri_stored_type_index[0][1] = -1
            single_tri_stored_type_index[1][0] = -1
            single_tri_stored_type_index[1][1] = -1
            single_tri_stored_type_index[2][0] = -1
            single_tri_stored_type_index[2][1] = -1
            single_tri_stored_type_index[3][0] = -1
            
            
        }
        
        
        if(situation13){
            //erase_player.play()
            filled[0][2] = false
            filled[0][3] = false
            filled[1][2] = false
            filled[1][3] = false
            filled[2][2] = false
            filled[2][3] = false
            filled[3][1] = false
            filled[3][2] = false
            filled[4][0] = false
            single_tri_stored_type_index[0][2] = -1
            single_tri_stored_type_index[0][3] = -1
            single_tri_stored_type_index[1][2] = -1
            single_tri_stored_type_index[1][3] = -1
            single_tri_stored_type_index[2][2] = -1
            single_tri_stored_type_index[2][3] = -1
            single_tri_stored_type_index[3][1] = -1
            single_tri_stored_type_index[3][2] = -1
            single_tri_stored_type_index[4][0] = -1
            
        }
        
        if(situation14){
            //erase_player.play()
            filled[0][4] = false
            filled[0][5] = false
            filled[1][4] = false
            filled[1][5] = false
            filled[2][4] = false
            filled[2][5] = false
            filled[3][3] = false
            filled[3][4] = false
            filled[4][1] = false
            filled[4][2] = false
            filled[5][0] = false
            
            single_tri_stored_type_index[0][4] = -1
            single_tri_stored_type_index[0][5] = -1
            single_tri_stored_type_index[1][4] = -1
            single_tri_stored_type_index[1][5] = -1
            single_tri_stored_type_index[2][4] = -1
            single_tri_stored_type_index[2][5] = -1
            single_tri_stored_type_index[3][3] = -1
            single_tri_stored_type_index[3][4] = -1
            single_tri_stored_type_index[4][1] = -1
            single_tri_stored_type_index[4][2] = -1
            single_tri_stored_type_index[5][0] = -1
        }
        if(situation15){
            //erase_player.play()
            filled[0][6] = false
            filled[1][6] = false
            filled[1][7] = false
            filled[2][6] = false
            filled[2][7] = false
            filled[3][5] = false
            filled[3][6] = false
            filled[4][3] = false
            filled[4][4] = false
            filled[5][1] = false
            filled[5][2] = false

            single_tri_stored_type_index[0][6] = -1
            single_tri_stored_type_index[1][6] = -1
            single_tri_stored_type_index[1][7] = -1
            single_tri_stored_type_index[2][6] = -1
            single_tri_stored_type_index[2][7] = -1
            single_tri_stored_type_index[3][5] = -1
            single_tri_stored_type_index[3][6] = -1
            single_tri_stored_type_index[4][3] = -1
            single_tri_stored_type_index[4][4] = -1
            single_tri_stored_type_index[5][1] = -1
            single_tri_stored_type_index[5][2] = -1
        }
        
        
        
        if(situation16){
            //erase_player.play()
            filled[1][8] = false
            filled[2][8] = false
            filled[2][9] = false
            filled[3][7] = false
            filled[3][8] = false
            filled[4][5] = false
            filled[4][6] = false
            filled[5][3] = false
            filled[5][4] = false
            single_tri_stored_type_index[1][8] = -1
            single_tri_stored_type_index[2][8] = -1
            single_tri_stored_type_index[2][9] = -1
            single_tri_stored_type_index[3][7] = -1
            single_tri_stored_type_index[3][8] = -1
            single_tri_stored_type_index[4][5] = -1
            single_tri_stored_type_index[4][6] = -1
            single_tri_stored_type_index[5][3] = -1
            single_tri_stored_type_index[5][4] = -1
        }
        
        
        if(situation17){
            //erase_player.play()
            filled[2][10] = false
            filled[3][9] = false
            filled[3][10] = false
            filled[4][7] = false
            filled[4][8] = false
            filled[5][5] = false
            filled[5][6] = false
            single_tri_stored_type_index[2][10] = -1
            single_tri_stored_type_index[3][9] = -1
            single_tri_stored_type_index[3][10] = -1
            single_tri_stored_type_index[4][7] = -1
            single_tri_stored_type_index[4][8] = -1
            single_tri_stored_type_index[5][5] = -1
            single_tri_stored_type_index[5][6] = -1
        }

        
    }
    
    
   /////////////////////////////////////////////////////////////////////////////////////////////////////////
    var bool_any_green_tri = true
    var bool_any_orange_tri = true
    var bool_any_light_brown_tri = true
    var bool_any_brown_left_tri = true
    var bool_any_brown_downwards_tri = true
    var bool_any_dark_green_tri = true
    var bool_any_pink_right_tri = true
    var bool_any_purple_upwards_tri = true
    var bool_any_purple_downwards_tri = true
    var bool_any_brown_left_downwards_tri = true
    var bool_any_brown_right_downwards_tri = true
    var bool_pos0_shape_available = true
    var bool_pos1_shape_available = true
    var bool_pos2_shape_available = true
    var green_result = false
    var orange_result = false
    var light_brown_result = false
    var brown_left_result = false
    var brown_downwards_result = false
    var dark_green_result  = false
    var pink_right_result = false
    var purple_upwards_result = false
    var purple_downwards_result = false
    var shape_placable_array : Array<Bool> = [false, false, false, false, false,false,false,false,false, false, false]
    
    //the funciton to find available space and autogenerate
    func Check_for_Placable_Shape_And_Generate () -> Void {
         green_result = false
         orange_result = false
         light_brown_result = false
         brown_left_result = false
         brown_downwards_result = false
         dark_green_result  = false
         pink_right_result = false
         purple_upwards_result = false
         purple_downwards_result = false
        var k = 0
        for result in shape_placable_array{
            shape_placable_array[k] = false
            k += 1
        }
        var i = 0
        for tri_row in filled{
            var j = 0
            for _ in tri_row{
                bool_any_green_tri = Find_Any_Available_Green_Tri(row: i, column: j)
                if(bool_any_green_tri){
                    green_result = true
                    shape_placable_array[0] = true
                }
                //print("whether green tri available: \(bool_any_green_tri)")
                bool_any_orange_tri = Find_Any_Available_Orange_Tri(row: i, column: j)
                if(bool_any_orange_tri){
                    orange_result = true
                    shape_placable_array[1] = true

                }
               // print("whether orange tri available: \(bool_any_orange_tri)")
                bool_any_light_brown_tri = Find_Any_Available_Light_Brown_Tri(row: i, column: j)
                if(bool_any_light_brown_tri){
                    light_brown_result = true
                    shape_placable_array[2] = true

                }
               // print("whether light_brown tri available: \(bool_any_light_brown_tri)")
                
                //print("whether brown left tri available: \(bool_any_brown_left_tri)")
                bool_any_brown_downwards_tri = Find_Any_Available_Brown_Downwards_Tri(row: i, column: j)
                if(bool_any_brown_downwards_tri){
                    brown_downwards_result = true
                    shape_placable_array[3] = true
                    
                }
                bool_any_brown_left_tri = Find_Any_Available_Brown_Left_Tri(row: i, column: j)
                if(bool_any_brown_left_tri){
                    brown_left_result = true
                    shape_placable_array[4] = true

                }

                //print("whether brown downwards tri available: \(bool_any_brown_downwards_tri)")
                bool_any_dark_green_tri = Find_Any_Dark_Green_Tri(row: i, column: j)
                if(bool_any_dark_green_tri){
                dark_green_result = true
                    shape_placable_array[5] = true

                }
               // print("whether dark green tri available: \(bool_any_dark_green_tri)")
                bool_any_pink_right_tri = Find_Any_Pink_Right_Tri(row: i, column: j)
                if(bool_any_pink_right_tri){
                    pink_right_result = true
                    shape_placable_array[6] = true

                }
                bool_any_purple_upwards_tri = Find_Any_Purple_Upwards_Tri(row: i, column: j)
                if(bool_any_purple_upwards_tri){
                    purple_upwards_result = true
                    shape_placable_array[7] = true

                }
                bool_any_purple_downwards_tri = Find_Any_Purple_Downwards_Tri(row: i, column: j)
                if(bool_any_purple_downwards_tri){
                    purple_downwards_result = true
                    shape_placable_array[8] = true

                }
                
                bool_any_brown_left_downwards_tri = Find_Any_Available_Brown_Left_Downwards_Tri(row: i, column: j)
                if(bool_any_brown_left_downwards_tri){
                shape_placable_array[9] = true
                
                }
                
                bool_any_brown_right_downwards_tri = Find_Any_Available_Brown_Right_Downwards_Tri(row: i, column: j)
                if(bool_any_brown_right_downwards_tri){
                    shape_placable_array[10] = true
                }
                
                j += 1
                
    }
                i += 1
        }

    }
    
    
     //the function to check for gameover (if gameover return true, else return false)
        func Check_for_Gameover () -> Bool {
            var i = 0
            for tri_row in filled{
            var j = 0
            for _ in tri_row{
                bool_any_green_tri = Find_Any_Available_Green_Tri(row: i, column: j)
               // print("whether green tri available: \(bool_any_green_tri)")
                bool_any_orange_tri = Find_Any_Available_Orange_Tri(row: i, column: j)
               // print("whether orange tri available: \(bool_any_orange_tri)")
                bool_any_light_brown_tri = Find_Any_Available_Light_Brown_Tri(row: i, column: j)
               // print("whether light_brown tri available: \(bool_any_light_brown_tri)")
                bool_any_brown_left_tri = Find_Any_Available_Brown_Left_Tri(row: i, column: j)
                //print("whether brown left tri available: \(bool_any_brown_left_tri)")
                bool_any_brown_downwards_tri = Find_Any_Available_Brown_Downwards_Tri(row: i, column: j)
                if(bool_any_brown_downwards_tri){
                    print("brown downwards tri available at \(i), \(j)")
                }
                print("whether brown downwards tri available: \(bool_any_brown_downwards_tri)")
                bool_any_dark_green_tri = Find_Any_Dark_Green_Tri(row: i, column: j)
                // print("whether dark green tri available: \(bool_any_dark_green_tri)")
                bool_any_pink_right_tri = Find_Any_Pink_Right_Tri(row: i, column: j)
                bool_any_purple_upwards_tri = Find_Any_Purple_Upwards_Tri(row: i, column: j)
                bool_any_purple_downwards_tri = Find_Any_Purple_Downwards_Tri(row: i, column: j)
                bool_any_brown_left_downwards_tri = Find_Any_Available_Brown_Left_Downwards_Tri(row: i, column: j)
                bool_any_brown_right_downwards_tri = Find_Any_Available_Brown_Right_Downwards_Tri(row: i, column: j)
                if(bool_any_dark_green_tri){
                 print("dark green available at \(i) , \(j)")
                }
                if(exist1){
                if(shape_type_index[0] == 0){
                    bool_pos0_shape_available = bool_any_green_tri
                }else if(shape_type_index[0] == 1){
                    bool_pos0_shape_available = bool_any_orange_tri
                }else if(shape_type_index[0] == 2){
                    bool_pos0_shape_available = bool_any_light_brown_tri
                }else if(shape_type_index[0] == 3){
                    bool_pos0_shape_available =  bool_any_brown_downwards_tri
                }else if(shape_type_index[0] == 4){
                    bool_pos0_shape_available = bool_any_brown_left_tri
                }else if(shape_type_index[0] == 5){
                    bool_pos0_shape_available = bool_any_dark_green_tri
                }else if(shape_type_index[0] == 6){
                    bool_pos0_shape_available = bool_any_pink_right_tri
                }else if(shape_type_index[0] == 7){
                    bool_pos0_shape_available = bool_any_purple_upwards_tri
                }else if(shape_type_index[0] == 8){
                    bool_pos0_shape_available = bool_any_purple_downwards_tri
                }else if(shape_type_index[0] == 9){
                     bool_pos0_shape_available = bool_any_brown_left_downwards_tri
                }else if(shape_type_index[0] == 10){
                    bool_pos0_shape_available = bool_any_brown_right_downwards_tri
                }
                
                }else{
                    bool_pos0_shape_available = false
                }
                print("po0 bool: \(bool_pos0_shape_available)")
                if(exist2){
                if(shape_type_index[1] == 0){
                    bool_pos1_shape_available = bool_any_green_tri
                }else if(shape_type_index[1] == 1){
                    bool_pos1_shape_available = bool_any_orange_tri
                }else if(shape_type_index[1] == 2){
                    bool_pos1_shape_available = bool_any_light_brown_tri
                }else if(shape_type_index[1] == 3){
                    bool_pos1_shape_available =  bool_any_brown_downwards_tri
                }else if(shape_type_index[1] == 4){
                    bool_pos1_shape_available = bool_any_brown_left_tri
                }else if(shape_type_index[1] == 5){
                    bool_pos1_shape_available = bool_any_dark_green_tri
                }else if(shape_type_index[1] == 6){
                    bool_pos1_shape_available = bool_any_pink_right_tri
                }else if(shape_type_index[1] == 7){
                    bool_pos1_shape_available = bool_any_purple_upwards_tri
                }else if(shape_type_index[1] == 8){
                    bool_pos1_shape_available = bool_any_purple_downwards_tri
                }else if(shape_type_index[1] == 9){
                    bool_pos1_shape_available = bool_any_brown_left_downwards_tri
                }else if(shape_type_index[1] == 10){
                    bool_pos1_shape_available = bool_any_brown_right_downwards_tri
                    }

                }else{
                    bool_pos1_shape_available = false
                }
                
                if(exist3){
                if(shape_type_index[2] == 0){
                    bool_pos2_shape_available = bool_any_green_tri
                }else if(shape_type_index[2] == 1){
                    bool_pos2_shape_available = bool_any_orange_tri
                }else if(shape_type_index[2] == 2){
                    bool_pos2_shape_available = bool_any_light_brown_tri
                }else if(shape_type_index[2] == 3){
                    bool_pos2_shape_available =  bool_any_brown_downwards_tri
                }else if(shape_type_index[2] == 4){
                    bool_pos2_shape_available = bool_any_brown_left_tri
                }else if(shape_type_index[2] == 5){
                    bool_pos2_shape_available = bool_any_dark_green_tri
                }else if(shape_type_index[2] == 6){
                    bool_pos2_shape_available = bool_any_pink_right_tri
                }else if(shape_type_index[2] == 7){
                    bool_pos2_shape_available = bool_any_purple_upwards_tri
                }else if(shape_type_index[2] == 8){
                    bool_pos2_shape_available = bool_any_purple_downwards_tri
                }else if(shape_type_index[2] == 9){
                    bool_pos2_shape_available = bool_any_brown_left_downwards_tri
                }else if(shape_type_index[2] == 10){
                    bool_pos2_shape_available = bool_any_brown_right_downwards_tri
                    }

                }else{
                    bool_pos2_shape_available = false
                }
                
                print("po2 bool: \(bool_pos2_shape_available)")
                if(bool_pos0_shape_available || bool_pos1_shape_available || bool_pos2_shape_available){
                    return false
                }
                j += 1
                }
                i += 1
                   }
            return true

        }
    

    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Available_Green_Tri(row: Int, column: Int) -> Bool {
        //upper row
        if(row == 0 || row == 1 || row == 2){
            //upwards tri (pos0 or pos2)
            if(column % 2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2]){
                    return true
                }
                if(column != 0 && !filled[row][column-2] && !filled[row][column-1] && !filled[row][column]){
                    return true
                }
            }
                //downwards tri (pos1)
                else{
                if(!filled[row][column] && !filled[row][column-1] && !filled[row][column+1]){
                    return true
                }
                
                }
            
            

        }
        else if(row == 3 || row == 4 || row == 5    ){
            //upwards tri (pos0 and pos2)
            if(column % 2 != 0){
                if(column != 1 && !filled[row][column-2] && !filled[row][column-1] && !filled[row][column]){
                    return true
                }
                else if(column != filled[row].count-2 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2]){
                    return true
                }
            }
            
            
            
        }
        
        return false
        
        
    }
   /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Available_Orange_Tri (row: Int, column:Int) -> Bool{
        if(row == 0 || row == 1){
            //upwards tri
            if(column % 2 == 0){
                if(!filled[row][column] && !filled[row+1][column+1]){
                    return true
                }
            }
                    //downwards tri
            else{
                if(row == 1 && !filled[row][column] && !filled[row-1][column-1]){
                    return true
                }
                }
            
        }
        
        else if(row == 2){
            //upwards tri
            if(column%2 == 0){
                if(!filled[row][column] && !filled[row+1][column]){
                    return true
                }
            }
            //downwards tri
            else{
                if(!filled[row][column] && !filled[row-1][column-1]){
                    return true
                }
                
            }
        }
        else if(row == 3){
            //downwards tri
            if(column%2 == 0){
                if(!filled[row][column] && !filled[row-1][column]){
                    return true
                }
            }
            //upwards tri
            else{
                if(!filled[row][column] && !filled[row+1][column-1]){
                    return true
                }
                
            }
        }
        else if(row == 4 || row == 5){
         //downwards tri
            if(column%2 == 0){
            if(!filled[row][column] && !filled[row-1][column+1]){
                        return true
                    }
                }
        //upwards tri
            else{
                if(row == 4 && !filled[row][column] && !filled[row+1][column-1]){
                    return true
                }
                
                
            }
        }
        
        return false
    }
        
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Available_Light_Brown_Tri (row: Int, column:Int) -> Bool{
        if(row == 0){
            //upwards tri
            if(column%2 == 0 && !filled[row][column] && !filled[row+1][column] && !filled[row+1][column+1]){
                return true
            }
        }
        else if(row == 1){
            //upwards tri
            if(column%2 == 0){
                if(!filled[row][column] && !filled[row+1][column] && !filled[row+1][column+1]){
                    return true
                }
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row-1][column]){
                    return true
                }
            }
            //downwards tri
            else{
                if(!filled[row][column] && !filled[row][column-1] && !filled[row-1][column-1]){
                    return true
                }
            }
        }
        else if(row == 2){
            //upwards tri
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row-1][column]){
                    return true
                }
                if(column != 0 && !filled[row][column] && !filled[row+1][column] && !filled[row+1][column-1]){
                    return true
                }
            }
            //downwards tri
            else{
                if(!filled[row][column] && !filled[row][column-1] && !filled[row-1][column-1]){
                    return true
                }
            }
        }
        
        else if(row == 3){
            //downwards tri
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row-1][column]){
                    return true
                }
            }
            //upwards tri
            else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row-1][column+1]){
                    return true
                }
                if(column != 1 && !filled[row][column] && !filled[row+1][column-1] && !filled[row+1][column-2]){
                    return true
                }
            }
        }
        else if(row == 4){
            //downwards tri
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row-1][column+1]){
                    return true
            }
        }
                //upwards tri
            else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row-1][column+2]){
                    return true
                }
                if(column != 1 && !filled[row][column] && !filled[row+1][column-1] && !filled[row+1][column-2]){
                    return true
                }
            }
        }
        else if(row == 5 ){
            //downwards tri
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row-1][column+1]){
                    return true
                }
            }
            //upwards tri
            else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row-1][column+2]){
                    return true
                }
            }
        }
    
    return false
    }
        
   /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func Find_Any_Available_Brown_Left_Tri (row: Int, column:Int) -> Bool{
        if(row == 0 || row == 1 || row == 2){
            //upwards tri
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1]){
                    return true
                }
            }
                //downwards tri
            else{
                if(!filled[row][column] && !filled[row][column+1]){
                    return true
                }
            }
        }
        else if(row == 3 || row == 4 || row == 5){
            //downwards tri
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1]){
                    return true
                }
            }
            //upwards tri
            else{
                if(!filled[row][column] && !filled[row][column-1]){
                    return true
                    }
            }
        }
        
        return false
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func Find_Any_Available_Brown_Downwards_Tri (row: Int, column:Int) -> Bool{
        if(row == 0 || row == 1 || row == 2){
            //upwards tri
            if(column%2 == 0){
                if(column != 0 && column != filled[row].count-1 && !filled[row][column] && !filled[row][column-1] && !filled[row][column+1]){
                    return true
                }
            }
            //downwards tri
            else{
                if(column != 1 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2]){
                    return true
                }
                if(column != filled[row].count-2 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2]){
                    return true
                }
            }
        }
        else if(row == 3 || row == 4 || row == 5){
        //downwards tri
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2]){
                    return true
                }
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2]){
                    return true
                }
            }
            //upwards tri
            else{
                if(!filled[row][column-1] && !filled[row][column] && !filled[row][column+1]){
                    return true
                }
            }
        }
        return false
    }

     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Dark_Green_Tri (row: Int, column:Int) -> Bool{
        
        if(row == 0){
            //upwards tri
            if(column%2 == 0){
                
              //left to right
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+2] && !filled[row+1][column+1] && !filled[row+1][column+2] && !filled[row+1][column+3]){
                    return true
                }
              //right to left
                if(column != 0 && !filled[row][column] && !filled[row][column-2] && !filled[row+1][column] && !filled[row+1][column-1] && !filled[row+1][column+1]){
                    return true
                }
                //center not possible
               
            }
            //downwards tri not possible
            else{
                return false
            }
        }
        else if(row == 1){
         //upwards tri
            if(column%2 == 0){
                //left to right
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+2] && !filled[row+1][column+1] && !filled[row+1][column+2] && !filled[row+1][column+3]){
                    return true
                }
                //right to left
                if(column != 0 && !filled[row][column] && !filled[row][column-2] && !filled[row+1][column] && !filled[row+1][column-1] && !filled[row+1][column+1]){
                    return true
                }
                //as center
                if(column != 0 && column != filled[row].count-1 && !filled[row][column] && !filled[row][column-1] && !filled[row][column+1] && !filled[row-1][column-2] && !filled[row-1][column]){
                    return true
                }
            }
            //downwards tri
            else{
                //bottom left to right
                if(column != filled[row].count-2 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2] && !filled[row-1][column-1] && !filled[row-1][column+1]){
                    return true
                }
                //bottom right to left
                if(column != 1 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2] && !filled[row-1][column-1] && !filled[row-1][column-3]){
                    return true
                }
            }
        }
        
        else if(row == 2){
        //upwards tri
            if(column%2 == 0){
                //left to right
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+2] && !filled[row+1][column] && !filled[row+1][column+1] && !filled[row+1][column+2] ){
                    return true
                }
                //right to left
                if(column != 0 && !filled[row][column] && !filled[row][column-2] && !filled[row+1][column] && !filled[row+1][column-1] && !filled[row+1][column-2]){
                    return true
                }
                //as center 
                if(column != 0 && column != filled[row].count-1 && !filled[row][column] && !filled[row][column-1] && !filled[row][column+1] && !filled[row-1][column-2] && !filled[row-1][column]){
                    return true
                }
            }
            //downwards tri
            else{
                //bottom left to right
                if(column != filled[row].count-2 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2]  && !filled[row-1][column-1] && !filled[row-1][column+1]){
                    return true
                }
                //bottom right to left
                if(column != 1 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2] && !filled[row-1][column-1] && !filled[row-1][column-3]){
                    return true
                }

            }
        }
        else if(row == 3){
            //downwards tri
            if(column%2 == 0){
                //bottom left to right
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2] && !filled[row-1][column] && !filled[row-1][column+2]){
                    return true
                }
                //bottom right to left
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2] && !filled[row-1][column] && !filled[row-1][column-2]){
                    return true
                }
            }
            //upwards tri
            else{
             //left to right
                if(column != filled[row].count-2 && !filled[row][column] && !filled[row][column+2] && !filled[row+1][column-1] && !filled[row+1][column] && !filled[row+1][column+1]){
                    return true
                }
                //right to left
                if(column != 1 && !filled[row][column] && !filled[row][column-2] && !filled[row+1][column-1] && !filled[row+1][column-2] && !filled[row+1][column-3]){
                    return true
                }
                //as center
                if(!filled[row][column] && !filled[row][column-1] && !filled[row][column+1] && !filled[row-1][column-1] && !filled[row-1][column+1]){
                    return true
                }
            }
        }
        else if(row == 4){
        //downwards tri
        if(column%2 == 0){
        //bottom left to right
            if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2] && !filled[row-1][column+1] && !filled[row-1][column+3]){
                return true
            }
        //bottom right to left
            if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2] && !filled[row-1][column-1] && !filled[row-1][column+1]){
                return true
            }
        }
        //upwards tri
        else{
            //left to right 
            if(column != filled[row].count-2 && !filled[row][column] && !filled[row][column+2] && !filled[row+1][column-1] && !filled[row+1][column] && !filled[row+1][column+1]){
                return true
            }
            //right to left
            if(column != 1 && !filled[row][column] && !filled[row][column-2] && !filled[row+1][column-1] && !filled[row+1][column-2] && !filled[row+1][column-3]){
                return true
            }
            //as center
            if(!filled[row][column] && !filled[row][column-1] && !filled[row][column+1] && !filled[row-1][column] && !filled[row-1][column+2]){
                return true
            }
        
        }
        }
        else if(row == 5){
        //downwards tri
            if(column%2 == 0){
                //bottom left to right
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row][column+2] && !filled[row-1][column+1] && !filled[row-1][column+3]){
                    return true
                }
                //bottom right to left
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row][column-2] && !filled[row-1][column-1] && !filled[row-1][column+1]){
                    return true
                }
   
            }
            //upwards tri
            else{
            //left to right & right to left not possible
            //as center
                if(!filled[row][column] && !filled[row][column-1] && !filled[row][column+1] && !filled[row-1][column] && !filled[row-1][column+2]){
                    return true
                }
                
            }
        }
    return false
    }
   /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Pink_Right_Tri (row: Int, column:Int) -> Bool{
        if(row == 0 || row == 1 || row == 2){
            //upwards tri
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] ){
                    return true
                }
            }//downwards tri
            else{
                if(!filled[row][column] && !filled[row][column-1]){
                    return true
                }
            }
        }else if( row == 3 || row == 4 || row == 5 ){
         //downwards tri
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1]){
              return true
            }
            }
         //upwards tri
            else{
                if(!filled[row][column] && !filled[row][column+1]){
                    return true
                }
            }
        }
        
        return false
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Purple_Upwards_Tri (row: Int, column:Int) -> Bool{
        if(row == 0 || row == 1 || row == 2){
            //upwards tri
            if(column%2 == 0 && !filled[row][column]){
                return true
            }
        }else if(row == 3 || row == 4 || row == 5){
            //upwards tri
            if(column%2 != 0 && !filled[row][column]){
                return true
            }
        }
        
        
        return false
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Find_Any_Purple_Downwards_Tri (row: Int, column:Int) -> Bool{
        if(row == 0 || row == 1 || row == 2){
            //downwards
            if(column%2 != 0 && !filled[row][column]){
                return true
            }
            
        }else if(row == 3 || row == 4 || row == 5 ){
            if(column%2 == 0 && !filled[row][column]){
                return true
            }
        }
        
     return false
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    func Find_Any_Available_Brown_Left_Downwards_Tri (row: Int, column:Int) -> Bool{
        if(row == 0){
            //upwards tri
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row+1][column+1]){
                    return true
                }
            }else{
                if(!filled[row][column] && !filled[row][column-1] && !filled[row+1][column]){
                    return true
                }
            }
        }
        else if (row == 1){
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row+1][column+1]){
                    return true
                }
            }else{
                //up to down
                if(!filled[row][column] && !filled[row][column-1] && !filled[row+1][column]){
                    return true
                }
                //down to up
                if(column != filled[row].count-2 && !filled[row][column] && !filled[row-1][column-1] && !filled[row-1][column]){
                    return true
                }
                
                
            }
        }
        else if (row == 2){
            if(column%2 == 0){
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row+1][column]){
                    return true
                }
            }else{
                //up to down
                if(!filled[row][column] && !filled[row][column-1] && !filled[row+1][column-1]){
                    return true
                }
                if(column != filled[row].count-2 && !filled[row][column] && !filled[row-1][column-1] && !filled[row-1][column]){
                    return true
                }
                
            }
            
            
        }
        else if (row == 3){
            //downwards tri
            if(column%2 == 0){
                //up to down
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row+1][column-2]){
                    return true
                }
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row-1][column] && !filled[row-1][column+1]){
                    return true
                }
            }else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row+1][column-1]){
                    return true
                }
                
            }
        }
        else if (row == 4){
            if(column%2 == 0){
                //up to down
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row+1][column-2]){
                    return true
                }
                if(!filled[row][column] && !filled[row-1][column+1] && !filled[row-1][column+2]){
                    return true
                }
                
                
            }else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row+1][column-1]){
                    return true
                }
                
            }
            
            
        }
        else if (row == 5){
            if(column%2 == 0 ){
                if(!filled[row][column] && !filled[row-1][column+1] && !filled[row-1][column+2]){
                    return true
                }
            }
        }
        return false
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
     func Find_Any_Available_Brown_Right_Downwards_Tri (row: Int, column:Int) -> Bool{
        if(row == 0){
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row+1][column+1]){
                    return true
                }
            }else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row+1][column+2]){
                    return true
                }
            }
        }
        else if (row == 1){
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row+1][column+1]){
                    return true
                }
            }else{
                //up to down
                if(!filled[row][column] && !filled[row][column+1] && !filled[row+1][column+2]){
                    return true
                }
                if(column != 1 && !filled[row][column] && !filled[row-1][column-2] && !filled[row-1][column-1]){
                    return true
                }
                
        }
        }
        else if(row == 2){
            if(column%2 == 0){
                if(column != 0 && !filled[row][column] && !filled[row][column-1] && !filled[row+1][column]){
                    return true
                }
            }else{
                if(!filled[row][column] && !filled[row][column+1] && !filled[row+1][column+1]){
                    return true
                }
                if(column != 1 && !filled[row][column] && !filled[row-1][column-2] && !filled[row-1][column-1]){
                    return true
                }
            }
        }
        else if(row == 3){
            //downwards tri
            if(column%2 == 0){
             //up to down
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row+1][column]){
                    return true
                }
             //down to up
                if(column != 0 && !filled[row][column] && !filled[row-1][column-1] && !filled[row-1][column]){
                    return true
                }
            }else{
                if(!filled[row][column] && !filled[row][column-1] && !filled[row+1][column-1]){
                    return true
                }
            }
            
        }
        else if(row == 4){
            //upwards 
            if(column%2 == 0){
                //up to down
                if(column != filled[row].count-1 && !filled[row][column] && !filled[row][column+1] && !filled[row+1][column]){
                    return true
                }
                //down to up
                if(!filled[row][column] && !filled[row-1][column] && !filled[row-1][column+1]){
                    return true
                }
                
            }else{
                if(!filled[row][column] && !filled[row][column-1] && !filled[row+1][column-1]){
                    return true
                }
                
            }
        }
        else if(row == 5){
            //upwards
            if(column%2 == 0){
                //down to up
                if(!filled[row][column] && !filled[row-1][column] && !filled[row-1][column+1]){
                    return true
                }
            }
            
            
        }
        
        
        
        
        
     return false
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    func Jump_to_Game_Over () -> Void {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GameOverViewController") as! GameOverViewController
        nextViewController.final_score = MarkBoard.text!
        nextViewController.ThemeType = self.ThemeType
        nextViewController.modalTransitionStyle = .crossDissolve
        if (Int(MarkBoard.text!) == HighestScore){
            nextViewController.is_high_score = true
        } else {
            nextViewController.is_high_score = false
        }
        self.present(nextViewController, animated: true, completion: nil)
        //self.audioPlayer.stop()
        self.timer.invalidate()
        do{game_over_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "game over", ofType: "wav")!))
            game_over_player.prepareToPlay()
        }
        catch{
            
        }
        game_over_player.play()
        
        
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    var score = 0
    var last_score = 0
    var current_score = 0
    func modify_counter(before: Array<Array<Bool>>, after: Array<Array<Bool>>) -> Void{
        cur_shape_tri = []
        var current_str = MarkBoard.text!
        var current_int = Int(current_str)!
        var i = 0
        for eachRow in before{
            var j = 0
            for _ in eachRow{
                if before[i][j] != after[i][j]{
                    
                    cur_shape_tri.append([i,j])
                    current_int += 1
                }
                j+=1
            }
            i+=1
        }
        score = current_int
        current_str = String(current_int)
        MarkBoard.text = current_str
        //add animation

            UIView.animate(withDuration: 0.2, animations: {
            self.MarkBoard.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: {
                (finished) -> Void in
                UIView.animate(withDuration: 0.1, animations: {
                    self.MarkBoard.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: nil)
            })
        
        if(current_int > HighestScore){
            HighestScore = current_int
            HightestScoreBoard.text = String(HighestScore)
            var HighScoreDefault = UserDefaults.standard
            HighScoreDefault.set(HighestScore, forKey: "tritri_HighestScore")
            HighScoreDefault.synchronize()
            
        }
        
    
    }
    func modify_counter_after_erase(before: Array<Array<Bool>>, after: Array<Array<Bool>>) -> Void{
        if  number_of_lines_erased  == 0{
            return
        }
        var current_str = MarkBoard.text!
        var current_int = Int(current_str)!
        var increment = 0
        var i = 0
        for eachRow in before{
            var j = 0
            for _ in eachRow{
                if before[i][j] != after[i][j]{
                    increment += 1
                }
                j+=1
            }
            i+=1
        }
        increment *= number_of_lines_erased
        current_int += increment
        score = current_int
        current_str = String(current_int)
        MarkBoard.text = current_str
        //add animation
        multiple_marker.frame = CGRect(x: MarkBoard.frame.minX + 80, y: MarkBoard.frame.midY, width: 30, height: 21)
        multiple_marker.text = "x\(number_of_lines_erased)"
        multiple_marker.alpha = 1
        self.view.addSubview(multiple_marker)
        if (number_of_lines_erased == 1){
            do{erase_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "1_time_erase", ofType: "mp3")!))
                erase_player.prepareToPlay()
            }
            catch{
                
            }
            erase_player.play()
            multiple_marker.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            UIView.animate(withDuration: 0.2, animations: {
                self.multiple_marker.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            }, completion: {
                (finished) -> Void in
                UIView.animate(withDuration: 0.1, animations: {
                    self.multiple_marker.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {
                    (finished) -> Void in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.multiple_marker.alpha = 0
                    })
                })
            })
        } else if (number_of_lines_erased == 2){
            do{erase_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "erase", ofType: "wav")!))
                erase_player.prepareToPlay()
            }
            catch{
                
            }
            erase_player.play()
            multiple_marker.textColor = .orange
            UIView.animate(withDuration: 0.2, animations: {
                self.multiple_marker.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            }, completion: {
                (finished) -> Void in
                UIView.animate(withDuration: 0.1, animations: {
                    self.multiple_marker.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: {
                    (finished) -> Void in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.multiple_marker.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    },completion: {
                        (finished) -> Void in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.multiple_marker.alpha = 0
                    })
                })
            })
        })
        }else {
            do{erase_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "3_times_erase", ofType: "wav")!))
                erase_player.prepareToPlay()
            }
            catch{
                
            }
            erase_player.play()
            multiple_marker.textColor = .red
            UIView.animate(withDuration: 0.4, animations: {
                self.multiple_marker.transform = CGAffineTransform(scaleX: 4.0, y: 4.0)
            }, completion: {
                (finished) -> Void in
                UIView.animate(withDuration: 0.2, animations: {
                    self.multiple_marker.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: {
                    (finished) -> Void in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.multiple_marker.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    },completion: {
                        (finished) -> Void in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.multiple_marker.alpha = 0
                        })
                    })
                })
            })

        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.MarkBoard.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        }, completion: {
            (finished) -> Void in
            UIView.animate(withDuration: 0.1, animations: {
                self.MarkBoard.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        })
        
        if(current_int > HighestScore){
            HighestScore = current_int
            HightestScoreBoard.text = String(HighestScore)
            var HighScoreDefault = UserDefaults.standard
            HighScoreDefault.set(HighestScore, forKey: "tritri_HighestScore")
            HighScoreDefault.synchronize()
            
        }
        
    }

func randomNumber(probabilities: [Double]) -> Int {
            
            // Sum of all probabilities (so that we don't have to require that the sum is 1.0):
            let sum = probabilities.reduce(0, +)
            // Random number in the range 0.0 <= rnd < sum :
            let rnd = sum * Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
            // Find the first interval of accumulated probabilities into which `rnd` falls:
            var accum = 0.0
            for (i, p) in probabilities.enumerated() {
                accum += p
                if rnd < accum {
                    return i
                }
            }
            // This point might be reached due to floating point inaccuracies:
            return (probabilities.count - 1)
}
    
    func randomShape_for_Difficulty_Level () -> Int{
        if(score <= 500){
        // 0: 1/10 1: 1/10 2:1/10 3:1/10 4:1/8 5:1/20 6:1/8 7:3/20 8:3/20
          return randomNumber(probabilities: [0.09, 0.09 , 0.09 , 0.09, 0.09, 0.01, 0.09, 0.13, 0.13, 0.09 , 0.09])
        }
        else if(score > 500 && score <= 2000){
          return randomNumber(probabilities: [0.09, 0.09 , 0.09 , 0.09, 0.09, 0.02, 0.09, 0.125, 0.125, 0.09, 0.09])
        }else if(score > 2000 && score <= 3000){
           return randomNumber(probabilities: [0.09, 0.09 , 0.09 , 0.09, 0.09, 0.04, 0.09, 0.105, 0.105, 0.1, 0.1])
        }else if(score > 3000 && score <= 4000){
            return randomNumber(probabilities: [0.09, 0.09 , 0.09 , 0.09, 0.09, 0.06, 0.09, 0.095, 0.095, 0.1, 0.1])
        }else{
            return randomNumber(probabilities: [0.09, 0.09 , 0.09 , 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09])
        }
        
    }
    
    func coordiante_transform (point_in_ip7: CGPoint) -> CGPoint {
    //ip7: width 375 height:667
    let x_proportion_const = Double(point_in_ip7.x)/Double(375)
    let y_proportion_const = Double(point_in_ip7.y)/Double(667)
    let new_CGPoint = CGPoint(x: CGFloat(Double(screen_width) * x_proportion_const), y: CGFloat(Double(screen_height)*y_proportion_const))
        return new_CGPoint
        
    }
    
    func change_current_shapes_according_to_theme(){
        let left_shape_index = shape_type_index[0]
        let mid_shape_index = shape_type_index[1]
        let right_shape_index = shape_type_index[2]
        if (exist1 == true){
            green_drag_tri.image = generator_array[left_shape_index]
        }
        if (exist2 == true){
            orange_drag_tri.image = generator_array[mid_shape_index]
        }
        if (exist3 == true){
            light_brown_drag_tri.image = generator_array[right_shape_index]
        }
        
        
    }

    func change_current_board_according_to_theme(){
        //default set as themetype 1
        var shape_color_up = [UIImage(named:"super_light_green_up")!,UIImage(named:"pink_upwards")!,UIImage(named:"light_brown_up")!,UIImage(named:"light_brown_up")!,UIImage(named:"super_light_green_up")!,UIImage(named:"green_up")!,UIImage(named:"pink_upwards")!,UIImage(named:"purple_upwards")!,UIImage(named:"purple_upwards")!, UIImage(named:"light_brown_up")!, UIImage(named: "light_brown_up")!]
        var shape_color_down = [UIImage(named:"super_light_green_down")!,UIImage(named:"pink_downwards")!,UIImage(named:"light_brown_down")!,UIImage(named:"light_brown_down")!,UIImage(named:"super_light_green_down")!,UIImage(named:"green_down")!,UIImage(named:"pink_downwards")!,UIImage(named:"purple_downwards")!,UIImage(named:"purple_downwards")!, UIImage(named:"light_brown_down")!, UIImage(named: "light_brown_down")!]
        //if Themetype == 1 doesnt change
        if (ThemeType == 2){
            shape_color_up[5] = UIImage(named: "小肉 up")!
            shape_color_down[5] = UIImage(named: "小肉 down")!
        }else if(ThemeType == 3){
            shape_color_up[0] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[1] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[2] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[3] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[4] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[5] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[6] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[7] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[8] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[9] = UIImage(named: "BW_black_tri_up")!
            shape_color_up[10] = UIImage(named: "BW_black_tri_up")!
            
            
            shape_color_down[0] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[1] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[2] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[3] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[4] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[5] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[6] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[7] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[8] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[9] = UIImage(named: "BW_black_tri_down")!
            shape_color_down[10] = UIImage(named: "BW_black_tri_down")!
        }else if(ThemeType == 4){
            shape_color_up[0] = UIImage(named: "chaos_up")!
            shape_color_up[1] = UIImage(named: "chaos_up")!
            shape_color_up[2] = UIImage(named: "chaos_up_5")!
            shape_color_up[3] = UIImage(named: "chaos_up_right")!
            shape_color_up[4] = UIImage(named: "chaos_up_3")!
            shape_color_up[5] = UIImage(named: "chaos_up_right")!
            shape_color_up[6] = UIImage(named: "chaos_up")!
            shape_color_up[7] = UIImage(named: "chaos_up")!
            shape_color_up[8] = UIImage(named: "chaos_up")!
            shape_color_up[9] = UIImage(named: "chaos_up_right")!
            shape_color_up[10] = UIImage(named: "chaos_up_5")!
            
            
            shape_color_down[0] = UIImage(named: "chaos_down")!
            shape_color_down[1] = UIImage(named: "chaos_down")!
            shape_color_down[2] = UIImage(named: "chaos_down")!
            shape_color_down[3] = UIImage(named: "chaos_down")!
            shape_color_down[4] = UIImage(named: "chaos_down")!
            shape_color_down[5] = UIImage(named: "chaos_down")!
            shape_color_down[6] = UIImage(named: "chaos_down")!
            shape_color_down[7] = UIImage(named: "chaos_down")!
            shape_color_down[8] = UIImage(named: "chaos_down")!
            shape_color_down[9] = UIImage(named: "chaos_down")!
            shape_color_down[10] = UIImage(named: "chaos_down")!

        }else if(ThemeType == 5){
            shape_color_up[0] = UIImage(named: "school_up")!
            shape_color_up[1] = UIImage(named: "school_up")!
            shape_color_up[2] = UIImage(named: "school_up-right")!
            shape_color_up[3] = UIImage(named: "school_up-right")!
            shape_color_up[4] = UIImage(named: "school_up")!
            shape_color_up[5] = UIImage(named: "school_up-left")!
            shape_color_up[6] = UIImage(named: "school_up")!
            shape_color_up[7] = UIImage(named: "school_up")!
            shape_color_up[8] = UIImage(named: "school_up")!
            shape_color_up[9] = UIImage(named: "school_up-right")!
            shape_color_up[10] = UIImage(named: "school_up-right")!
            
            
            shape_color_down[0] = UIImage(named: "school_down")!
            shape_color_down[1] = UIImage(named: "school_down")!
            shape_color_down[2] = UIImage(named: "school_down")!
            shape_color_down[3] = UIImage(named: "school_down")!
            shape_color_down[4] = UIImage(named: "school_down")!
            shape_color_down[5] = UIImage(named: "school_down")!
            shape_color_down[6] = UIImage(named: "school_down")!
            shape_color_down[7] = UIImage(named: "school_down")!
            shape_color_down[8] = UIImage(named: "school_down")!
            shape_color_down[9] = UIImage(named: "school_down")!
            shape_color_down[10] = UIImage(named: "school_down")!

        }else if(ThemeType == 6){
            shape_color_up[0] = UIImage(named: "colors_green_up")!
            shape_color_up[1] = UIImage(named: "colors_green_up")!
            shape_color_up[2] = UIImage(named: "colors_gold_up")!
            shape_color_up[3] = UIImage(named: "colors_green_up")!
            shape_color_up[4] = UIImage(named: "colors_blue_up")!
            shape_color_up[5] = UIImage(named: "colors_blue_up")!
            shape_color_up[6] = UIImage(named: "colors_blue_up")!
            shape_color_up[7] = UIImage(named: "colors_pink_up")!
            shape_color_up[8] = UIImage(named: "colors_pink_up")!
            shape_color_up[9] = UIImage(named: "colors_gold_up")!
            shape_color_up[10] = UIImage(named: "colors_gold_up")!
            
            
            shape_color_down[0] = UIImage(named: "colors_green_down")!
            shape_color_down[1] = UIImage(named: "colors_green_down")!
            shape_color_down[2] = UIImage(named: "colors_gold_down")!
            shape_color_down[3] = UIImage(named: "colors_green_down")!
            shape_color_down[4] = UIImage(named: "colors_blue_down")!
            shape_color_down[5] = UIImage(named: "colors_blue_down")!
            shape_color_down[6] = UIImage(named: "colors_blue_down")!
            shape_color_down[7] = UIImage(named: "colors_pink_down")!
            shape_color_down[8] = UIImage(named: "colors_pink_down")!
            shape_color_down[9] = UIImage(named: "colors_gold_down")!
            shape_color_down[10] = UIImage(named: "colors_gold_down")!
            
        }
        var i = 0
        for row in single_tri_stored_type_index{
            var j = 0
            for type in row{
                if (type == -1){
                    //doesnot change
                }
                else if (true_if_up(i: i, j: j)){
                    Change_Corresponding_Color_With_Image(x: i, y: j, image: shape_color_up[type])
                }
                else{
                    Change_Corresponding_Color_With_Image(x: i, y: j, image: shape_color_down[type])
                }
                
                j += 1
            }
            i += 1
        }
        
    }
    
    
    //return true if upward triangle
    func true_if_up(i: Int, j: Int) -> Bool{
        if (i == 0 || i == 2 || i == 3 || i == 5){
            if((i + j)%2 == 0){
                return true
            }
            else {
                return false
            }
        }
        else {
            if((i + j)%2 == 1){
                return true
            }
            else {
                return false
            }
        }
    }
    
    func change_shape_in_generate_array() -> Void{
        if (ThemeType == 1){
            generator_array = [UIImage(named:"绿色tri.png")!,UIImage(named:"橙色tri.png")!,UIImage(named:"棕色tri.png")!,UIImage(named:"brown_downwards.png")!,UIImage(named:"brown_left_direction.png")!,UIImage(named:"dark_green_tri.png")!,UIImage(named:"pink_right_direction.png")!,UIImage(named:"purple_upwards_as_shape.png")!,UIImage(named:"purple_downwards_as_shape")!, UIImage(named:"brown_left_downwards.png")!, UIImage(named: "brown_right_downwards.png")!]
            
        } else if (ThemeType == 2){
            generator_array = [UIImage(named:"绿色tri.png")!,UIImage(named:"橙色tri.png")!,UIImage(named:"棕色tri.png")!,UIImage(named:"brown_downwards.png")!,UIImage(named:"brown_left_direction.png")!,UIImage(named:"六角大王小肉")!,UIImage(named:"pink_right_direction.png")!,UIImage(named:"purple_upwards_as_shape.png")!,UIImage(named:"purple_downwards_as_shape")!, UIImage(named:"brown_left_downwards.png")!, UIImage(named: "brown_right_downwards.png")!]
        } else if(ThemeType == 3){
            generator_array = [UIImage(named:"BW_shape_0")!,UIImage(named:"BW_shape_1")!,UIImage(named:"BW_shape_2")!,UIImage(named:"BW_shape_3")!,UIImage(named:"BW_shape_4")!,UIImage(named:"BW_shape_5")!,UIImage(named:"BW_shape_6")!,UIImage(named:"BW_shape_7")!,UIImage(named:"BW_shape_8")!, UIImage(named:"BW_shape_9")!, UIImage(named: "BW_shape_10")!]
        } else if(ThemeType == 4){
            generator_array = [UIImage(named:"chaos_shape_0")!,UIImage(named:"chaos_shape_1")!,UIImage(named:"chaos_shape_2")!,UIImage(named:"chaos_shape_3")!,UIImage(named:"chaos_shape_4")!,UIImage(named:"chaos_shape_5")!,UIImage(named:"chaos_shape_6")!,UIImage(named:"chaos_shape_7")!,UIImage(named:"chaos_shape_8")!, UIImage(named:"chaos_shape_9")!, UIImage(named: "chaos_shape_10")!]

        } else if(ThemeType == 5){
            generator_array = [UIImage(named:"school_shape_0")!,UIImage(named:"school_shape_1")!,UIImage(named:"school_shape_2")!,UIImage(named:"school_shape_3")!,UIImage(named:"school_shape_4")!,UIImage(named:"school_shape_5")!,UIImage(named:"school_shape_6")!,UIImage(named:"school_shape_7")!,UIImage(named:"school_shape_8")!, UIImage(named:"school_shape_9")!, UIImage(named: "school_shape_10")!]
        } else if(ThemeType == 6){
            generator_array = [UIImage(named:"colors_shape_0")!,UIImage(named:"colors_shape_1")!,UIImage(named:"colors_shape_2")!,UIImage(named:"colors_shape_3")!,UIImage(named:"colors_shape_4")!,UIImage(named:"colors_shape_5")!,UIImage(named:"colors_shape_6")!,UIImage(named:"colors_shape_7")!,UIImage(named:"colors_shape_8")!, UIImage(named:"colors_shape_9")!, UIImage(named: "colors_shape_10")!]
            
        }
    }
    
    
    
    func star_score_increment() -> Void {
    let current_times = Int(current_score / 20)
    let last_times = Int(last_score / 20 )
    star_score += (current_times - last_times)
    starBoard.text = String(star_score)
    defaults.set(star_score, forKey: "tritri_star_score")
    defaults.synchronize()
        if((current_times - last_times) != 0){
            star_animation()
        }
    }
    
    var moving_star = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    func star_animation() -> Void {
        moving_star = UIImageView(frame: CGRect(x: screen_width/2, y: screen_height/2, width: pause_screen_x_transform(29), height: pause_screen_y_transform(34)))
        moving_star.image = UIImage(named:"day_mode_moving_star")
        moving_star.transform = CGAffineTransform(scaleX: CGFloat(3), y: CGFloat(3))
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = customPath().cgPath
        animation.duration = 1
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        moving_star.layer.add(animation, forKey: nil)
        self.view.addSubview(moving_star)
        UIView.animate(withDuration: 1.3, animations: {
            self.moving_star.transform = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))

        }, completion: {
            (finished) -> Void in
            self.moving_star.removeFromSuperview()
        })
        
    
    }
       
    func customPath() -> UIBezierPath {
    let path = UIBezierPath()
        path.move(to: CGPoint(x: screen_width/2 , y: screen_height/2))
        let endPoint = CGPoint(x: star_counter.frame.origin.x + CGFloat(28), y:  star_counter.frame.origin.y + CGFloat(20))
        let cp1 = CGPoint(x: 100, y: 300)
        let cp2 = CGPoint(x: 100, y: 300)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        return path
    }
}






















