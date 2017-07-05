//
//  MenuViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-05-15.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
class MenuViewController: UIViewController {

    var language = String()
    
    
    
    @IBOutlet weak var star_counter: UIImageView!
    
    @IBOutlet weak var star_board: UILabel!
    @IBOutlet weak var continue_button: UIButton!
    var button_player = AVAudioPlayer()
    var opening_player = AVAudioPlayer()
    var star_score = 0
    
    @IBOutlet var tutorial_button: UIButton!
    @IBOutlet weak var gift_button: UIButton!
    
    @IBAction func gift_sound_effect(_ sender: UIButton) {
        do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            self.button_player.prepareToPlay()
        }
        catch{
            
        }
        self.button_player.play()

    }
    
    
    @IBAction func tutorial_button_sound(_ sender: Any) {
        do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            self.button_player.prepareToPlay()
        }
        catch{
            
        }
        self.button_player.play()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (defaults.value(forKey: "language") == nil){
            language = "English"
            defaults.set("English", forKey: "language")
            print("System language initializes to English")
            
        }
        
        if (defaults.value(forKey: "language") as! String == "English"){
            language = "English"
        }
        else {
            language = "Chinese"
        }
        
        
        
        screen_width = view.frame.width
        screen_height = view.frame.height
        //add pangesture
        //triangle_title = UIImageView(frame: CGRect(x: pause_screen_x_transform(40), y: pause_screen_y_transform(20), width: pause_screen_x_transform(120), height: pause_screen_y_transform(50)))
        triangle_title.frame = CGRect(x: pause_screen_x_transform(Double(triangle_title.frame.origin.x)), y: pause_screen_y_transform(Double(triangle_title.frame.origin.y)), width: pause_screen_x_transform(Double(triangle_title.frame.width)), height: pause_screen_y_transform(Double(triangle_title.frame.height)))
        shopping_cart.frame = CGRect(x: pause_screen_x_transform(Double(shopping_cart.frame.origin.x)), y: pause_screen_y_transform(Double(shopping_cart.frame.origin.y)), width: pause_screen_x_transform(Double(shopping_cart.frame.width)), height: pause_screen_y_transform(Double(shopping_cart.frame.height)))
        like_button.frame =  CGRect(x: pause_screen_x_transform(Double(like_button.frame.origin.x)), y: pause_screen_y_transform(Double(like_button.frame.origin.y)), width: pause_screen_x_transform(Double(like_button.frame.width)), height: pause_screen_y_transform(Double(like_button.frame.height)))
        continue_button.frame = CGRect(x: pause_screen_x_transform(Double(continue_button.frame.origin.x)), y: pause_screen_y_transform(Double(continue_button.frame.origin.y)), width: pause_screen_x_transform(Double(continue_button.frame.width)), height: pause_screen_y_transform(Double(continue_button.frame.height)))
        star_counter.frame = CGRect(x: pause_screen_x_transform(Double(star_counter.frame.origin.x)), y: pause_screen_y_transform(Double(star_counter.frame.origin.y)), width: pause_screen_x_transform(Double(star_counter.frame.width)), height: pause_screen_y_transform(Double(star_counter.frame.height)))
        trophy.frame = CGRect(x: pause_screen_x_transform(Double(trophy.frame.origin.x)), y: pause_screen_y_transform(Double(trophy.frame.origin.y)), width: pause_screen_x_transform(Double(trophy.frame.width)), height: pause_screen_y_transform(Double(trophy.frame.height)))
        star_board.frame = CGRect(x: pause_screen_x_transform(Double(star_board.frame.origin.x)), y: pause_screen_y_transform(Double(star_board.frame.origin.y)), width: pause_screen_x_transform(Double(star_board.frame.width)), height: pause_screen_y_transform(Double(star_board.frame.height)))
        highest_score.frame = CGRect(x: pause_screen_x_transform(Double(highest_score.frame.origin.x)), y: pause_screen_y_transform(Double(highest_score.frame.origin.y)), width: pause_screen_x_transform(Double(highest_score.frame.width)), height: pause_screen_y_transform(Double(highest_score.frame.height)))
        gift_button.frame = CGRect(x: pause_screen_x_transform(Double(gift_button.frame.origin.x)), y: pause_screen_y_transform(Double(gift_button.frame.origin.y)), width: pause_screen_x_transform(Double(gift_button.frame.width)), height: pause_screen_y_transform(Double(gift_button.frame.height)))
        tutorial_button.frame = CGRect(x: pause_screen_x_transform(0), y: pause_screen_y_transform(538), width: pause_screen_x_transform(128), height: pause_screen_y_transform(129))
        tutorial_button.contentMode = .scaleAspectFit
        treasure_box_icon.frame = CGRect(x: pause_screen_x_transform(Double(treasure_box_icon.frame.origin.x)), y: pause_screen_y_transform(Double(treasure_box_icon.frame.origin.y)), width: pause_screen_x_transform(Double(treasure_box_icon.frame.width)), height: pause_screen_y_transform(Double(treasure_box_icon.frame.height)))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        var HighestScore = 0
        // Do any additional setup after loading the view.
        if(defaults.value(forKey: "tritri_HighestScore") != nil ){
            HighestScore = defaults.value(forKey: "tritri_HighestScore") as! NSInteger
            print("Highest Score is \(HighestScore)")
        }else{
            defaults.set(0, forKey: "tritri_HighestScore")
            HighestScore = 0
        }
        highest_score.text = String(HighestScore)
        if(defaults.value(forKey: "tritri_star_score") != nil ){
            star_score = defaults.value(forKey: "tritri_star_score") as! NSInteger
        }else{
            defaults.set(0, forKey: "tritri_star_score")
            star_score = 0
        }
        star_board.text = String(star_score)
        
        //tool box default 
        //get tool box quantity array
        if(defaults.value(forKey: "tritri_tool_quantity_array") != nil){
            tool_quantity_array = defaults.value(forKey: "tritri_tool_quantity_array") as! Array
        }else{
            defaults.set([0,0,0,0,0], forKey: "tritri_tool_quantity_array")
        }
        
        
        
        if (defaults.value(forKey: "tritri_Theme") == nil){
            ThemeType = 1
            defaults.set(1, forKey: "tritri_Theme")
        }
        else {
            ThemeType = defaults.integer(forKey: "tritri_Theme")
        }
        
        language_button_image_decider()
        if(ThemeType == 1){
            trophy.image = UIImage(named:"trophy_new")
            view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
            
            like_button.setBackgroundImage(UIImage(named: "day mode like"), for: .normal)
            highest_score.textColor = UIColor(red: 26.0/255, green: 58.0/255, blue: 49.0/255, alpha: 1)
            shopping_cart.setImage(UIImage(named:"shopping_cart"), for: .normal)
            continue_button.setImage(UIImage(named:"continue"), for: .normal)
            star_board.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
            star_counter.image = UIImage(named:"day_mode_star")
            gift_button.setImage(#imageLiteral(resourceName: "gift_day_mode"), for: .normal)
            tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_day_night"), for: .normal)
            treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_day_mode"), for: .normal)
        }else if(ThemeType == 2){
            trophy.image = UIImage(named:"night mode 奖杯")
            view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
            
            triangle_title.image = UIImage(named:"night mode triangle title")
            like_button.setBackgroundImage(UIImage(named: "night mode like button"), for: .normal)
             highest_score.textColor = UIColor(red: 167.0/255, green: 157.0/255, blue: 124.0/255, alpha: 1)
            shopping_cart.setImage(UIImage(named:"shopping_cart"), for: .normal)
            continue_button.setImage(UIImage(named:"continue"), for: .normal)
            star_board.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            star_counter.image = UIImage(named:"night_mode_star")
            gift_button.setImage(#imageLiteral(resourceName: "gift_night_mode"), for: .normal)
            tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_day_night"), for: .normal)
            treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_night_mode"), for: .normal)
        }else if(ThemeType == 3){
            like_button.setBackgroundImage(UIImage(named: "BW_like"), for: .normal)
            shopping_cart.setImage(UIImage(named:"BW_shopping"), for: .normal)
            trophy.image = UIImage(named:"BW_trophy")
            highest_score.textColor =  UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1)
            self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BW_background")!)
            continue_button.setImage(UIImage(named:"BW_continue"), for: .normal)
            star_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            star_counter.image = UIImage(named:"BW_mode_star")
            gift_button.setImage(#imageLiteral(resourceName: "gift_BW_mode"), for: .normal)
            tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_B&W"), for: .normal)
            treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_bw_mode"), for: .normal)
        }else if(ThemeType == 4){
            triangle_title.image = UIImage(named: "night mode triangle title")
            like_button.setBackgroundImage(UIImage(named: "chaos_like_icon"), for: .normal)
            shopping_cart.setImage(UIImage(named:"chaos_theme_button"), for: .normal)
            trophy.image = UIImage(named:"chaos_j_icon")
            highest_score.textColor = UIColor(red: 236.0/255, green: 232.0/255, blue: 187.0/255, alpha: 1.0)
            view.backgroundColor = UIColor(patternImage: UIImage(named: "chaos_background")!)
            continue_button.setImage(UIImage(named:"chaos_start_icon"), for: .normal)
            
        }else if(ThemeType == 5){
            like_button.setBackgroundImage(UIImage(named: "school_like-icon"), for: .normal)
            shopping_cart.setImage(UIImage(named:"school_theme-button"), for: .normal)
            trophy.image = UIImage(named:"school_j-icon")
            highest_score.textColor = UIColor(red: 34.0/255, green: 61.0/255, blue: 128.0/255, alpha: 1.0)
            view.backgroundColor = UIColor(patternImage: UIImage(named: "school_background")!)
            continue_button.setImage(UIImage(named:"school_start-icon"), for: .normal)
            star_board.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
            star_counter.image = UIImage(named:"school_mode_star")
            gift_button.setImage(#imageLiteral(resourceName: "gift_school_mode"), for: .normal)
            tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_school"), for: .normal)
            treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_school_mode"), for: .normal)
        }
        else if(ThemeType == 6){

            like_button.setBackgroundImage(UIImage(named:"colors_like-icon"), for: .normal)
            shopping_cart.setImage(UIImage(named:"colors_theme-button"), for: .normal)
            trophy.image = UIImage(named:"colors_j-icon")
            highest_score.textColor = UIColor(red: 255.0/255, green: 195.0/255, blue: 1.0/255, alpha: 1.0)
            continue_button.setImage(UIImage(named:"colors_start"), for: .normal)
            view.backgroundColor = UIColor(patternImage: UIImage(named: "colors_background")!)
            star_board.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
            star_counter.image = UIImage(named:"colors_mode_star")
            gift_button.setImage(#imageLiteral(resourceName: "gift_color_mode"), for: .normal)
            tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_color"), for: .normal)
            treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_color_mode"), for: .normal)
            
        }
        triangle_title_image_decider()
      star_counter.sizeToFit()
      trophy.sizeToFit()
    
    
    
    
    }

    @IBOutlet weak var like_button: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var screen_width : CGFloat = 0
    var screen_height : CGFloat = 0

    
    //theme type
    var ThemeType = Int()
    
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

    @IBAction func start_action(_ sender: UIButton) {
        do{self.opening_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "opening", ofType: "wav")!))
            self.opening_player.prepareToPlay()
        }
        catch{
            
        }
        self.opening_player.play()
    }

    @IBOutlet weak var triangle_title: UIImageView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBOutlet var language_button: UIButton!
    
    
    @IBAction func language_changing(_ sender: Any) {
        if (defaults.value(forKey: "language") as! String == "English"){
            language = "Chinese"
            defaults.set("Chinese", forKey: "language")
            print("System language change to Chinese")
            self.language_button_image_decider()
            triangle_title_image_decider()
        } else {
            language = "English"
            defaults.set("English", forKey: "language")
            print("System language change to English")
            self.language_button_image_decider()
            triangle_title_image_decider()
        }
    }
    
    
    
    
    
    
    @IBOutlet weak var shopping_cart: UIButton!
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
    
    
    
    
    @IBAction func theme_menu_action(_ sender: UIButton) {
        do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            self.button_player.prepareToPlay()
        }
        catch{
            
        }
        self.button_player.play()
        let theme_menu: UIView = UIView(frame: CGRect(origin: CGPoint(x: 0, y:0),size: CGSize(width: screen_width, height: screen_height)))
        theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(1))
 
        theme_menu.alpha = 0
        theme_menu.tag = 100
        super.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(theme_menu)
        theme_menu.fadeIn()
        let white_cover = UIView(frame: CGRect(x: pause_screen_x_transform(0), y: pause_screen_y_transform(0), width: pause_screen_x_transform(400), height: pause_screen_y_transform(120)))
        let triangle_text = UIImageView(frame: CGRect(x: pause_screen_x_transform(110), y: pause_screen_y_transform(40), width: pause_screen_x_transform(155), height: pause_screen_y_transform(35)))
        
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
            
            self.ThemeType = 1
            defaults.set(1, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
            self.trophy.image = UIImage(named:"trophy_new")
            if (self.language == "English"){
                self.triangle_title.image = UIImage(named: "day mode triangle title")
            }
            else {
                self.triangle_title.image = UIImage(named: "san_title_day")
            }
            self.language_button_image_decider()
            self.like_button.setBackgroundImage(UIImage(named: "day mode like"), for: .normal)
            self.highest_score.textColor = UIColor(red: 26.0/255, green: 58.0/255, blue: 49.0/255, alpha: 1)
            self.continue_button.setImage(UIImage(named:"continue"), for: .normal)
            self.shopping_cart.setImage(UIImage(named:"shopping_cart"), for: .normal)
            self.star_board.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
            self.star_counter.image = UIImage(named:"day_mode_star")
            self.theme_star_counter.image = UIImage(named:"day_mode_star")
            self.theme_star_board.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
            self.gift_button.setImage(#imageLiteral(resourceName: "gift_day_mode"), for: .normal)
            self.tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_day_night"), for: .normal)
            self.treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_day_mode"), for: .normal)
            //self.trophy.image = UIImage(named:"trophy_new")
            //self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
           // self.gameover_title.image = UIImage(named:"day mode gameover title")
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            //self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            //self.chaos_theme_button.removeFromSuperview()
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
            
            self.ThemeType = 2
            self.trophy.image = UIImage(named:"night mode 奖杯")
            self.like_button.setBackgroundImage(UIImage(named: "night mode like button"), for: .normal)
            defaults.set(2, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
            if (self.language == "English"){
                self.triangle_title.image = UIImage(named: "night mode triangle title")
            }
            else {
                self.triangle_title.image = UIImage(named: "san_title_night")
            }
            self.language_button_image_decider()
            self.highest_score.textColor = UIColor(red: 167.0/255, green: 157.0/255, blue: 124.0/255, alpha: 1)
            self.continue_button.setImage(UIImage(named:"continue"), for: .normal)
            self.shopping_cart.setImage(UIImage(named:"shopping_cart"), for: .normal)
            self.star_board.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            self.star_counter.image = UIImage(named:"night_mode_star")
            self.theme_star_counter.image = UIImage(named:"night_mode_star")
            self.theme_star_board.textColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            self.gift_button.setImage(#imageLiteral(resourceName: "gift_night_mode"), for: .normal)
            self.tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_day_night"), for: .normal)
            self.treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_night_mode"), for: .normal)
           // self.trophy.image = UIImage(named:"night mode 奖杯")
           // self.score_board.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
           // self.gameover_title.image = UIImage(named:"night mode gameover title")
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            //self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            //self.chaos_theme_button.removeFromSuperview()
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
            self.ThemeType = 3
            defaults.set(3, forKey:"tritri_Theme")
           self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BW_background")!)
            self.trophy.image = UIImage(named:"BW_trophy")
            if (self.language == "English"){
                self.triangle_title.image = UIImage(named: "day mode triangle title")
            }
            else {
                self.triangle_title.image = UIImage(named: "san_title_day")
            }
            self.language_button_image_decider()
            self.like_button.setBackgroundImage(UIImage(named: "BW_like"), for: .normal)
            self.highest_score.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1)
            self.shopping_cart.setImage(UIImage(named:"BW_shopping"), for: .normal)
            self.continue_button.setImage(UIImage(named:"BW_continue"), for: .normal)
            self.star_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            self.star_counter.image = UIImage(named:"BW_mode_star")
            self.theme_star_counter.image = UIImage(named:"BW_mode_star")
            self.theme_star_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            self.gift_button.setImage(#imageLiteral(resourceName: "gift_BW_mode"), for: .normal)
            self.tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_B&W"), for: .normal)
            self.treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_bw_mode"), for: .normal)
            //self.trophy.image = UIImage(named:"trophy_new")
            //self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            // self.gameover_title.image = UIImage(named:"day mode gameover title")
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
        
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            //self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            //self.chaos_theme_button.removeFromSuperview()
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
            self.ThemeType = 4
            defaults.set(4, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chaos_background")!)
            self.trophy.image = UIImage(named:"chaos_j_icon")
            self.triangle_title.image = UIImage(named: "night mode triangle title")
            self.like_button.setBackgroundImage(UIImage(named: "chaos_like_icon"), for: .normal)
            self.highest_score.textColor = UIColor(red: 236.0/255, green: 232.0/255, blue: 187.0/255, alpha: 1.0)
            self.shopping_cart.setImage(UIImage(named:"chaos_theme_button"), for: .normal)
            self.continue_button.setImage(UIImage(named:"chaos_start_icon"), for: .normal)
            //self.trophy.image = UIImage(named:"trophy_new")
            //self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            // self.gameover_title.image = UIImage(named:"day mode gameover title")
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
        //self.view.addSubview(chaos_theme_button)
        //chaos_theme_button.fadeInWithDisplacement()
        
        
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
            self.ThemeType = 5
            defaults.set(5, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "school_background")!)
            self.trophy.image = UIImage(named:"school_j-icon")
            if (self.language == "English"){
                self.triangle_title.image = UIImage(named: "school_triangle_title")
            }
            else {
                self.triangle_title.image = UIImage(named: "san_title_school")
            }
            self.language_button_image_decider()
            self.like_button.setBackgroundImage(UIImage(named: "school_like-icon"), for: .normal)
            self.highest_score.textColor = UIColor(red: 34.0/255, green: 61.0/255, blue: 128.0/255, alpha: 1.0)
            self.shopping_cart.setImage(UIImage(named:"school_theme-button"), for: .normal)
            self.continue_button.setImage(UIImage(named:"school_start-icon"), for: .normal)
            self.star_board.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
            self.star_counter.image = UIImage(named:"school_mode_star")
            self.theme_star_counter.image = UIImage(named:"school_mode_star")
            self.theme_star_board.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
            self.gift_button.setImage(#imageLiteral(resourceName: "gift_school_mode"), for: .normal)
            self.tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_school"), for: .normal)
            self.treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_school_mode"), for: .normal)
            //self.trophy.image = UIImage(named:"trophy_new")
            //self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            // self.gameover_title.image = UIImage(named:"day mode gameover title")
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            
            
            
            
            
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            //self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            //self.chaos_theme_button.removeFromSuperview()
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
            self.ThemeType = 6
            defaults.set(6, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "colors_background")!)
            self.trophy.image = UIImage(named:"colors_j-icon")
            if (self.language == "English"){
                self.triangle_title.image = UIImage(named: "night mode triangle title")
            }
            else {
                self.triangle_title.image = UIImage(named: "san_title_night")
            }
            self.language_button_image_decider()
            self.like_button.setBackgroundImage(UIImage(named: "colors_like-icon"), for: .normal)
            self.highest_score.textColor = UIColor(red: 255.0/255, green: 195.0/255, blue: 1.0/255, alpha: 1.0)
            self.shopping_cart.setImage(UIImage(named:"colors_theme-button"), for: .normal)
            self.continue_button.setImage(UIImage(named:"colors_start"), for: .normal)
            self.star_board.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
            self.star_counter.image = UIImage(named:"colors_mode_star")
            self.theme_star_counter.image = UIImage(named:"colors_mode_star")
            self.theme_star_board.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
            self.gift_button.setImage(#imageLiteral(resourceName: "gift_color_mode"), for: .normal)
            self.tutorial_button.setBackgroundImage(#imageLiteral(resourceName: "tuto_icon_color"), for: .normal)
            self.treasure_box_icon.setImage(#imageLiteral(resourceName: "treasure_color_mode"), for: .normal)
            //self.trophy.image = UIImage(named:"trophy_new")
            //self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            // self.gameover_title.image = UIImage(named:"day mode gameover title")
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.day_theme_button.fadeOut()
            self.night_theme_button.fadeOut()
            self.BW_theme_button.fadeOut()
            //self.chaos_theme_button.fadeOut()
            self.school_theme_button.fadeOut()
            self.colors_theme_button.fadeOut()
            triangle_text.fadeOut()
            return_button.fadeOut()
            white_cover.fadeOut()
            theme_menu.fadeOut()
            
            self.day_theme_button.removeFromSuperview()
            self.night_theme_button.removeFromSuperview()
            self.BW_theme_button.removeFromSuperview()
            //self.chaos_theme_button.removeFromSuperview()
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
        if (self.language == "English"){
            triangle_text.image = UIImage(named: "day mode triangle title")
        }
        else {
            triangle_text.image = UIImage(named: "san_title_day")
        }
        
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
    
    
    
    func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
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
        
    @IBOutlet weak var trophy: UIImageView!
        
    @IBOutlet weak var highest_score: UILabel!
    

    func triangle_title_image_decider() -> Void{
        if (ThemeType == 1){
            if (language == "English"){
                self.triangle_title.image = UIImage(named:"day mode triangle title")
            } else {
                self.triangle_title.image = UIImage(named:"san_title_day")
            }
        } else if (ThemeType == 2){
            if (language == "English"){
                self.triangle_title.image = UIImage(named:"night mode triangle title")
            } else {
                self.triangle_title.image = UIImage(named:"san_title_night")
            }
        } else if (ThemeType == 3){
            if (language == "English"){
                self.triangle_title.image = UIImage(named:"day mode triangle title")
            } else {
                self.triangle_title.image = UIImage(named:"san_title_day")
            }
        } else if (ThemeType == 4){
            //chaos
        }
        else if (ThemeType == 5){
            if (language == "English"){
                self.triangle_title.image = UIImage(named:"school_triangle_title")
            } else {
                self.triangle_title.image = UIImage(named:"san_title_school")
            }
        } else if (ThemeType == 6){
            if (language == "English"){
                self.triangle_title.image = UIImage(named:"night mode triangle title")
            } else {
                self.triangle_title.image = UIImage(named:"san_title_night")
            }
        }


    }

    
    func treasure_box_function() -> Void {
    let treasure_menu = UIImageView(frame: CGRect(x: 0, y: 0, width: screen_width, height: screen_height))
    treasure_menu.image = #imageLiteral(resourceName: "treasure_background")
    treasure_menu.alpha = 0
    self.view.addSubview(treasure_menu)
    treasure_menu.fadeIn()
    let treasure_cancel = MyButton(frame: CGRect(x: treasure_menu.frame.origin.x, y: treasure_menu.frame.origin.y, width: pause_screen_x_transform(125), height: pause_screen_y_transform(125)))
    treasure_cancel.setImage(#imageLiteral(resourceName: "treasure_box_cancel"), for: .normal)
    treasure_cancel.contentMode = .scaleAspectFit
    treasure_cancel.alpha = 0
    self.view.addSubview(treasure_cancel)
    treasure_cancel.fadeIn()
        
//new  life button
    let new_life_button = MyButton(frame: CGRect(x: pause_screen_x_transform(30), y: pause_screen_y_transform(100), width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
    new_life_button.setImage(#imageLiteral(resourceName: "new_life"), for: .normal)
    new_life_button.alpha = 0
    self.view.addSubview(new_life_button)
    new_life_button.fadeIn()
        new_life_button.whenButtonIsClicked(action: {
            self.tool_selected = 0
            self.tool_selected_scene()
        })
        
//new life text
        let new_life_text = UIImageView(frame: CGRect(x: pause_screen_x_transform(30), y: pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
        new_life_text.image = #imageLiteral(resourceName: "new_life_text")
        new_life_text.alpha = 0
        self.view.addSubview(new_life_text)
        new_life_text.fadeIn()
    
//same color eliminator button
    let same_color_eliminator = MyButton(frame: CGRect(x: new_life_button.frame.origin.x + new_life_button.frame.width + pause_screen_x_transform(50), y: pause_screen_y_transform(100), width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
    same_color_eliminator.setImage(#imageLiteral(resourceName: "same_color_eliminator"), for: .normal)
    same_color_eliminator.alpha = 0
    self.view.addSubview(same_color_eliminator)
    same_color_eliminator.fadeIn()
        same_color_eliminator.whenButtonIsClicked(action: {
            self.tool_selected = 1
            self.tool_selected_scene()
        })
    
    //same color eliminator text
       let same_color_eliminator_text = UIImageView(frame: CGRect(x: same_color_eliminator.frame.origin.x, y: pause_screen_y_transform(45), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
        same_color_eliminator_text.alpha = 0
        same_color_eliminator_text.image = #imageLiteral(resourceName: "same_color_eliminator_text")
        self.view.addSubview(same_color_eliminator_text)
        same_color_eliminator_text.fadeIn()

    //shape bomb button
    let shape_bomb = MyButton(frame: CGRect(x: new_life_button.frame.origin.x, y: new_life_button.frame.origin.y + new_life_button.frame.height + pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
    shape_bomb.setImage(#imageLiteral(resourceName: "shape_bomb"), for: .normal)
    shape_bomb.alpha = 0
    self.view.addSubview(shape_bomb)
    shape_bomb.fadeIn()
        shape_bomb.whenButtonIsClicked(action: {
            self.tool_selected = 2
            self.tool_selected_scene()
        })
    //shape bomb text
    let shape_bomb_text = UIImageView(frame: CGRect(x: shape_bomb.frame.origin.x, y: shape_bomb.frame.origin.y - pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
    shape_bomb_text.alpha = 0
    shape_bomb_text.image = #imageLiteral(resourceName: "shape_bomb_text")
    self.view.addSubview(shape_bomb_text)
    shape_bomb_text.fadeIn()
        
        
    //times two button
    let times_two = MyButton(frame: CGRect(x: same_color_eliminator.frame.origin.x, y: shape_bomb.frame.origin.y, width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
    times_two.setImage(#imageLiteral(resourceName: "times_two"), for: .normal)
    times_two.alpha = 0
    self.view.addSubview(times_two)
    times_two.fadeIn()
        times_two.whenButtonIsClicked(action: {
            self.tool_selected = 3
            self.tool_selected_scene()
        })
   //times two text
        let times_two_text = UIImageView(frame: CGRect(x: times_two.frame.origin.x, y: times_two.frame.origin.y - pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
        times_two_text.image = #imageLiteral(resourceName: "double_score_text")
        times_two_text.alpha = 0
        self.view.addSubview(times_two_text)
        times_two_text.fadeIn()
        
        
    //three triangles button
    let three_triangles = MyButton(frame: CGRect(x: shape_bomb.frame.origin.x, y: shape_bomb.frame.origin.y + shape_bomb.frame.height + pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
    three_triangles.setImage(#imageLiteral(resourceName: "three_triangle"), for: .normal)
    three_triangles.alpha = 0
    self.view.addSubview(three_triangles)
    three_triangles.fadeIn()
        three_triangles.whenButtonIsClicked(action: {
            self.tool_selected = 4
            self.tool_selected_scene()
        })
    
    //three triangle text
    let three_triangles_text = UIImageView(frame: CGRect(x: three_triangles.frame.origin.x, y: three_triangles.frame.origin.y - pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
    three_triangles_text.image = #imageLiteral(resourceName: "three_tri_text")
    three_triangles_text.alpha = 0
    self.view.addSubview(three_triangles_text)
    three_triangles_text.fadeIn()
    
        
    //clear all button
    let clear_all = MyButton(frame: CGRect(x: times_two.frame.origin.x, y: three_triangles.frame.origin.y, width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
    clear_all.setImage(#imageLiteral(resourceName: "clear_all"), for: .normal)
    clear_all.alpha = 0
    self.view.addSubview(clear_all)
    clear_all.fadeIn()
        clear_all.whenButtonIsClicked(action: {
            self.tool_selected = 5
            self.tool_selected_scene()
        })
    
    //clear all text
        let clear_all_text = UIImageView(frame: CGRect(x: clear_all.frame.origin.x, y: clear_all.frame.origin.y - pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
        clear_all_text.image = #imageLiteral(resourceName: "clear_all_text")
        clear_all_text.alpha = 0
        self.view.addSubview(clear_all_text)
        clear_all_text.fadeIn()

        
        
        
    //treasure cancel action
    treasure_cancel.whenButtonIsClicked(action: {
            do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
                self.button_player.prepareToPlay()
            }
            catch{
                
            }
            self.button_player.play()
            treasure_cancel.fadeOutandRemove()
            treasure_menu.fadeOutandRemove()
            new_life_button.fadeOutandRemove()
            same_color_eliminator.fadeOutandRemove()
            shape_bomb.fadeOutandRemove()
            times_two.fadeOutandRemove()
            three_triangles.fadeOutandRemove()
            clear_all.fadeOutandRemove()
            new_life_text.fadeOutandRemove()
            same_color_eliminator_text.fadeOutandRemove()
            shape_bomb_text.fadeOutandRemove()
            times_two_text.fadeOutandRemove()
            three_triangles_text.fadeOutandRemove()
            clear_all_text.fadeOutandRemove()
        
        })
    }
   
    @IBOutlet weak var treasure_box_icon: UIButton!
    @IBAction func treasure_box_action(_ sender: UIButton) {
        treasure_box_function()
    }

    
    func language_button_image_decider() -> Void{
        if (ThemeType == 1){
            if (language == "English"){
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_english_day_night"), for: .normal)
            } else {
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_chinese_day_night"), for: .normal)
            }
        } else if (ThemeType == 2){
            if (language == "English"){
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_english_day_night"), for: .normal)
            } else {
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_chinese_day_night"), for: .normal)
            }
        } else if (ThemeType == 3){
            if (language == "English"){
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_english_B&W"), for: .normal)
            } else {
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_chinese_B&W"), for: .normal)
            }
        } else if (ThemeType == 4){
            //chaos
        }
        else if (ThemeType == 5){
            if (language == "English"){
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_english_school"), for: .normal)
            } else {
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_chinese_school"), for: .normal)
            }
        } else if (ThemeType == 6){
            if (language == "English"){
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_english_color"), for: .normal)
            } else {
                self.language_button.setBackgroundImage(UIImage(named:"lang_icon_chinese_color"), for: .normal)
            }
        }
    }

    //tool selected:
    // 0 - new life  1 - same color eliminator 2 - shape bomb 3 - score*2 4 - three triangles 5 - clear all
    var tool_selected = -1
    
    //tool quantity array
    //index : 0 - new life 1 - same color eliminator 2 - shape bomb 3 - score*2 4 - three triangles 5 - clear all
    var tool_quantity_array = [0,0,0,0,0,0]
    
    func tool_selected_scene() -> Void {
    let selected_scene_background = UIView(frame: CGRect(x: 0, y: 0, width: screen_width, height: screen_height))
    selected_scene_background.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    selected_scene_background.alpha = 0
    self.view.addSubview(selected_scene_background)
    selected_scene_background.fadeInTrans()
    let selected_scene = UIView(frame: CGRect(x: 0, y: screen_height/2 - pause_screen_y_transform(150), width: screen_width, height: pause_screen_y_transform(300)))
    selected_scene.backgroundColor = UIColor(red: 228.0/255, green: 229.0/255, blue: 224.0/255, alpha: 1.0)
    selected_scene.alpha = 0
    self.view.addSubview(selected_scene)
    selected_scene.fadeIn()
    let selected_cancel = MyButton(frame: CGRect(x: screen_width - pause_screen_x_transform(100), y: selected_scene.frame.origin.y, width: pause_screen_x_transform(100), height: pause_screen_y_transform(100)))
    selected_cancel.setImage(#imageLiteral(resourceName: "selected_scene_cancel"), for: .normal)
    selected_cancel.alpha = 0
    self.view.addSubview(selected_cancel)
    selected_cancel.fadeIn()
    let treasure_icon_selected = UIImageView(frame: CGRect(x: pause_screen_x_transform(30), y:   selected_scene.frame.origin.y+pause_screen_y_transform(70), width: pause_screen_x_transform(140), height: pause_screen_y_transform(140)))
        let treasure_text = UIImageView(frame: CGRect(x: treasure_icon_selected.frame.origin.x, y: treasure_icon_selected.frame.origin.y - pause_screen_y_transform(50), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70)))
        if(tool_selected == 1){
            treasure_text.frame = CGRect(x: treasure_icon_selected.frame.origin.x, y: treasure_icon_selected.frame.origin.y - pause_screen_y_transform(55), width: pause_screen_x_transform(140), height: pause_screen_y_transform(70))
        }
    
        if(tool_selected == 0){
            treasure_icon_selected.image = #imageLiteral(resourceName: "new_life")
            treasure_text.image = #imageLiteral(resourceName: "new_life_text")
        }else if(tool_selected == 1){
            treasure_icon_selected.image = #imageLiteral(resourceName: "same_color_eliminator")
            treasure_text.image = #imageLiteral(resourceName: "same_color_eliminator_text")
        }else if(tool_selected == 2){
            treasure_icon_selected.image = #imageLiteral(resourceName: "shape_bomb")
            treasure_text.image = #imageLiteral(resourceName: "shape_bomb_text")
        }else if(tool_selected == 3){
            treasure_icon_selected.image = #imageLiteral(resourceName: "times_two")
            treasure_text.image = #imageLiteral(resourceName: "double_score_text")
        }else if(tool_selected == 4){
            treasure_icon_selected.image =  #imageLiteral(resourceName: "three_triangle")
            treasure_text.image = #imageLiteral(resourceName: "three_tri_text")
        }else if(tool_selected == 5){
            treasure_icon_selected.image = #imageLiteral(resourceName: "clear_all")
            treasure_text.image = #imageLiteral(resourceName: "clear_all_text")
        }
        
        //fade in
        treasure_icon_selected.alpha = 0
        self.view.addSubview(treasure_icon_selected)
        treasure_icon_selected.fadeIn()
        
        treasure_text.alpha = 0
        self.view.addSubview(treasure_text)
        treasure_text.fadeIn()

        
        
        
        selected_cancel.whenButtonIsClicked(action: {
            selected_scene_background.fadeOutandRemove()
            selected_scene.fadeOutandRemove()
            selected_cancel.fadeOutandRemove()
            treasure_icon_selected.fadeOutandRemove()
            treasure_text.fadeOutandRemove()
            
        })
    
        
    }
    
    
    

}
    
    



    






/**class MyButton: UIButton {
    var action: (()->())?
    
    func whenButtonIsClicked(action: @escaping ()->()) {
        self.action = action
        self.addTarget(self, action: #selector(MyButton.clicked), for: .touchUpInside)
    }
    
    func clicked() {
        action?()
    }
}**/
