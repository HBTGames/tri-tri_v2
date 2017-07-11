//
//  GameOverViewController.swift
//  tri-tri
//
//  Created by Feiran Hu on 2017-05-14.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import Social
import AVKit
import AVFoundation

class GameOverViewController: UIViewController {
    var language = String()
    let home_pic = UIImage(named:"home")
    let night_home_pic = UIImage(named:"night mode home")
    let BW_home_pic = UIImage(named:"BW_home")
    let chaos_home_pic = UIImage(named:"chaos_home_icon")
    let school_home_pic = UIImage(named:"school_home-icon")
    let colors_home_pic = UIImage(named:"colors_home-icon")
    @IBOutlet weak var High_score_marker: UILabel!

    @IBOutlet weak var background_image: UIImageView!
    @IBOutlet weak var score_board: UILabel!
    
    @IBOutlet weak var gameover_title: UIImageView!
    
    @IBOutlet weak var trophy: UIImageView!
    var restart_player = AVAudioPlayer()
    var button_player = AVAudioPlayer()
    @IBOutlet weak var restart_button: UIButton!
    @IBOutlet weak var home_button: UIButton!
    
   
    @IBOutlet weak var shopping_button: UIButton!
    
    @IBOutlet weak var share_button: UIButton!

    @IBAction func Share_Button_Action(_ sender: UIButton) {
        
        do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            self.button_player.prepareToPlay()
        }
        catch{
            
        }
        self.button_player.play()
     let alert = UIAlertController(title: "Share", message: "Share Your Record!", preferredStyle: .actionSheet)
        //first action
        let action_one = UIAlertAction(title: "Share on Facebook", style: .default) { (action) in
            //check whether user has facebook
            if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)){
                let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
                post.setInitialText("I have played tri-tri !")
                post.add(UIImage(named: "share_pic"))
                self.present(post, animated: true, completion: nil)
            }else{
            self.showAlert(service: "Facebook")
            }
        }
    
        //second action
        let action_two = UIAlertAction(title: "Share on Twitter", style: .default) { (action) in
            //check whether user has facebook
            if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)){
                let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
                post.setInitialText("I have played tri-tri !")
                post.add(UIImage(named: "share_pic"))
                self.present(post, animated: true, completion: nil)
            }else{
                self.showAlert(service: "Twitter")
            }
        }
        
        //third action
        let action_three = UIAlertAction(title: "Share on Weibo", style: .default) { (action) in
            //check whether user has facebook
            if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTencentWeibo)){
                let post = SLComposeViewController(forServiceType: SLServiceTypeTencentWeibo)!
                post.setInitialText("I have played tri-tri !")
                post.add(UIImage(named: "share_pic"))
                self.present(post, animated: true, completion: nil)
            }else{
                self.showAlert(service: "Weibo")
            }
        }
        
        //fourth action
        let action_four = UIAlertAction(title: "I have changed my mind", style: .cancel){ (action) in
         //self.dismiss(animated: true, completion: nil)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GameOverViewController") as! GameOverViewController
            nextViewController.final_score = self.final_score
            nextViewController.ThemeType = self.ThemeType
            nextViewController.is_high_score = self.is_high_score
        self.present(nextViewController, animated: false, completion: nil)
        }
        
        
        //add action to action sheet
        alert.addAction(action_one)
        alert.addAction(action_two)
        alert.addAction(action_three)
        alert.addAction(action_four)
        
        //present alert 
        self.present(alert, animated: true, completion: nil)
    }

    var screen_width : CGFloat = 0
    var screen_height : CGFloat = 0
    //two vars value passed from game board
    var final_score = String()
    var star_score = 0
    var is_high_score = Bool()
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        language = defaults.value(forKey: "language") as! String
        screen_width = view.frame.width
        screen_height = view.frame.height
        gameover_title.frame = CGRect(x: pause_screen_x_transform(Double(gameover_title.frame.origin.x)), y: pause_screen_y_transform(Double(gameover_title.frame.origin.y)), width: pause_screen_x_transform(Double(gameover_title.frame.width)), height: pause_screen_y_transform(Double(gameover_title.frame.height)))
        share_button.frame = CGRect(x: pause_screen_x_transform(Double(share_button.frame.origin.x)), y: pause_screen_y_transform(Double(share_button.frame.origin.y)), width: pause_screen_x_transform(Double(share_button.frame.width)), height: pause_screen_y_transform(Double(share_button.frame.height)))
        restart_button.frame = CGRect(x: pause_screen_x_transform(Double(restart_button.frame.origin.x)), y: pause_screen_y_transform(Double(restart_button.frame.origin.y)), width: pause_screen_x_transform(Double(restart_button.frame.width)), height: pause_screen_y_transform(Double(restart_button.frame.height)))
        shopping_button.frame = CGRect(x: pause_screen_x_transform(Double(shopping_button.frame.origin.x)), y: pause_screen_y_transform(Double(shopping_button.frame.origin.y)), width: pause_screen_x_transform(Double(shopping_button.frame.width)), height: pause_screen_y_transform(Double(shopping_button.frame.height)))
        home_button.frame = CGRect(x: pause_screen_x_transform(Double(home_button.frame.origin.x)), y: pause_screen_y_transform(Double(home_button.frame.origin.y)), width: pause_screen_x_transform(Double(home_button.frame.width)), height: pause_screen_y_transform(Double(home_button.frame.height)))
        trophy.frame = CGRect(x: pause_screen_x_transform(Double(trophy.frame.origin.x)), y: pause_screen_y_transform(Double(trophy.frame.origin.y)), width: pause_screen_x_transform(Double(trophy.frame.width)), height: pause_screen_y_transform(Double(trophy.frame.height)))
        score_board.frame = CGRect(x: pause_screen_x_transform(Double(score_board.frame.origin.x)), y: pause_screen_y_transform(Double(score_board.frame.origin.y)), width: pause_screen_x_transform(Double(score_board.frame.width)), height: pause_screen_y_transform(Double(score_board.frame.height)))

        High_score_marker.frame = CGRect(x: pause_screen_x_transform(Double(High_score_marker.frame.origin.x)), y: pause_screen_y_transform(Double(High_score_marker.frame.origin.y)), width: pause_screen_x_transform(Double(High_score_marker.frame.width)), height: pause_screen_y_transform(Double(High_score_marker.frame.height)))
        
        restart_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(40), bottom: pause_screen_y_transform(40), right: pause_screen_x_transform(40))
        background_image.frame = CGRect(x: 0, y: 0, width: screen_width, height: screen_height)
       

        if (ThemeType == 1){
            home_button.setBackgroundImage(home_pic, for: .normal)
        } else if (ThemeType == 2){
            home_button.setBackgroundImage(night_home_pic, for: .normal)
        } else if(ThemeType == 3){
            home_button.setBackgroundImage(BW_home_pic, for: .normal)
        } else if(ThemeType == 4){
            home_button.setBackgroundImage(chaos_home_pic, for: .normal)
        } else if(ThemeType == 5){
            home_button.setBackgroundImage(school_home_pic, for: .normal)
        } else if(ThemeType == 6){
            home_button.setBackgroundImage(colors_home_pic, for: .normal)
        }
        home_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(25), bottom: 0, right: pause_screen_x_transform(25))
        shopping_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(25), bottom: 0, right: pause_screen_x_transform(25))
        share_button.touchAreaEdgeInsets = UIEdgeInsets(top: pause_screen_y_transform(10), left: pause_screen_x_transform(15), bottom: pause_screen_y_transform(0), right: pause_screen_x_transform(15))
        score_board.text = final_score
        do{restart_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "restart_soundeffect", ofType: "wav")!))
            restart_player.prepareToPlay()
        }
        catch{
            
        }
        if is_high_score{
            High_score_marker.textColor = UIColor(red:CGFloat(100.0/255.0), green:CGFloat(20.0/255.0), blue:CGFloat(150.0/255.0), alpha:CGFloat(1))
            High_score_marker.text = "New Record!"
        }
        if(defaults.value(forKey: "tritri_star_score") != nil ){
            star_score = defaults.value(forKey: "tritri_star_score") as! NSInteger
        }else{
            defaults.set(0, forKey: "tritri_star_score")
        }
        // Do any additional setup after loading the view.
        gameover_title_image_decider()
        if ThemeType == 1{
            self.view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
            background_image.alpha = 0
            self.trophy.image = UIImage(named:"trophy_new")
            self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            
            self.restart_button.setImage(UIImage(named:"restart_big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"shopping_cart"), for: .normal)
            self.share_button.setImage(UIImage(named:"link"), for: .normal)
        } else if ThemeType == 2{
            self.view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
            background_image.alpha = 0
            self.trophy.image = UIImage(named:"night mode 奖杯")
            self.score_board.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            
            self.restart_button.setImage(UIImage(named:"restart_big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"shopping_cart"), for: .normal)
            self.share_button.setImage(UIImage(named:"link"), for: .normal)
        }else if ThemeType == 3{
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BW_background")!)
            background_image.alpha = 1
            background_image.image = #imageLiteral(resourceName: "BW_background")
            self.trophy.image = UIImage(named: "BW_trophy")
            self.score_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
            
            self.restart_button.setImage(UIImage(named:"BW_restart_version2"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"BW_shopping"), for: .normal)
            self.share_button.setImage(UIImage(named:"BW_share"), for: .normal)
            //self.home_button.setImage(UIImage(named:"BW_home"), for: .normal)
            
        }else if ThemeType == 4{
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chaos_background")!)
            background_image.alpha = 1
            background_image.image = #imageLiteral(resourceName: "chaos_background")
            self.trophy.image = UIImage(named: "chaos_j_icon")
            self.score_board.textColor = UIColor(red: 236.0/255, green: 232.0/255, blue: 187.0/255, alpha: 1.0)
            
            self.restart_button.setImage(UIImage(named:"chaos_restart_big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"chaos_theme_button"), for: .normal)
            self.share_button.setImage(UIImage(named:"chaos_share_icon"), for: .normal)
            //self.home_button.setImage(UIImage(named:"BW_home"), for: .normal)
            
        }
        else if ThemeType == 5{
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "school_background")!)
            background_image.alpha = 1
            background_image.image = #imageLiteral(resourceName: "school_background")
            self.trophy.image = UIImage(named: "school_j-icon")
            self.score_board.textColor = UIColor(red: 113.0/255, green: 113.0/255, blue: 142.0/255, alpha: 1.0)
           
            self.restart_button.setImage(UIImage(named:"school_restart-big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"school_theme-button"), for: .normal)
            self.share_button.setImage(UIImage(named:"school_share-icon"), for: .normal)
            //self.home_button.setImage(UIImage(named:"BW_home"), for: .normal)
            
        }
        else if ThemeType == 6{
           //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "colors_background")!)
            background_image.image = #imageLiteral(resourceName: "colors_background")
            background_image.alpha = 1
            self.trophy.image = UIImage(named: "colors_j-icon")
            self.score_board.textColor = UIColor(red: 79.0/255, green: 168.0/255, blue: 248.0/255, alpha: 1.0)
            
            self.restart_button.setImage(UIImage(named:"colors_restart-big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"colors_theme-button"), for: .normal)
            self.share_button.setImage(UIImage(named:"colors_share-icon"), for: .normal)
            
        }
        trophy.sizeToFit()
        
        //add pangesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(service: String){
        let alert = UIAlertController(title: "Error", message: "You are not connected to \(service)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func Restart_Sound_Action(_ sender: UIButton) {
        
       restart_player.play()
        
    }
    
    @IBAction func like_action(_ sender: UIButton) {
        do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            self.button_player.prepareToPlay()
        }
        catch{
            
        }
        self.button_player.play()
    }
    @IBAction func home_button_action(_ sender: UIButton) {
        do{self.button_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "general_button", ofType: "wav")!))
            self.button_player.prepareToPlay()
        }
        catch{
            
        }
        self.button_player.play()
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
    @IBAction func theme_menu_action(_ sender: UIButton) {
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
            
            self.ThemeType = 1
            defaults.set(1, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
            self.background_image.alpha = 0
            self.trophy.image = UIImage(named:"trophy_new")
            self.score_board.textColor = UIColor(red: 59/255, green: 76/255, blue: 65/255, alpha: 1.0)
            self.gameover_title_image_decider()
            self.home_button.setBackgroundImage(self.home_pic, for: .normal)
            self.restart_button.setImage(UIImage(named:"restart_big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"shopping_cart"), for: .normal)
            self.share_button.setImage(UIImage(named:"link"), for: .normal)
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.theme_star_counter.image = UIImage(named:"day_mode_star")
            self.theme_star_board.textColor = UIColor(red: 46.0/255, green: 62.0/255, blue: 59.0/255, alpha: 1.0)
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
            defaults.set(2, forKey:"tritri_Theme")
            self.view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
            self.background_image.alpha = 0
            self.trophy.image = UIImage(named:"night mode 奖杯")
            self.score_board.textColor = UIColor(red: 255.0/255, green: 254.0/255, blue: 243.0/255, alpha: 1.0)
            self.gameover_title_image_decider()
            self.home_button.setBackgroundImage(self.night_home_pic, for: .normal)
            self.restart_button.setImage(UIImage(named:"restart_big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"shopping_cart"), for: .normal)
            self.share_button.setImage(UIImage(named:"link"), for: .normal)
            theme_menu.backgroundColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(255.0/255.0), blue:CGFloat(255.0/255.0), alpha:CGFloat(0))
            self.theme_star_counter.image = UIImage(named:"night_mode_star")
            self.theme_star_board.textColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
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
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BW_background")!)
            self.background_image.alpha = 1
            self.background_image.image = #imageLiteral(resourceName: "BW_background")
            self.trophy.image = UIImage(named:"BW_trophy")
            self.gameover_title_image_decider()
            self.score_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1)
            self.shopping_button.setImage(UIImage(named:"BW_shopping"), for: .normal)
            self.restart_button.setImage(UIImage(named:"BW_restart_version2"), for: .normal)
            self.share_button.setImage(UIImage(named:"BW_share"), for: .normal)
            self.home_button.setBackgroundImage(self.BW_home_pic, for: .normal)
            self.theme_star_counter.image = UIImage(named:"BW_mode_star")
            self.theme_star_board.textColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 1.0/255, alpha: 1.0)
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
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chaos_background")!)
            self.background_image.alpha = 1
            self.background_image.image = #imageLiteral(resourceName: "chaos_background")
            self.trophy.image = UIImage(named:"chaos_j_icon")
            self.gameover_title.image = UIImage(named: "night mode gameover title")
            self.score_board.textColor = UIColor(red: 236.0/255, green: 232.0/255, blue: 187.0/255, alpha: 1.0)
            self.restart_button.setImage(UIImage(named:"chaos_restart_big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"chaos_theme_button"), for: .normal)
            self.share_button.setImage(UIImage(named:"chaos_share_icon"), for: .normal)
            self.home_button.setBackgroundImage(self.chaos_home_pic, for: .normal)
            
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
        
        
        school_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(206), y: pause_screen_y_transform(319), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
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
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "school_background")!)
            self.background_image.alpha = 1
            self.background_image.image = #imageLiteral(resourceName: "school_background")
            self.trophy.image = UIImage(named:"school_j-icon")
            self.gameover_title_image_decider()
            self.score_board.textColor = UIColor(red: 113.0/255, green: 113.0/255, blue: 142.0/255, alpha: 1.0)
            self.restart_button.setImage(UIImage(named:"school_restart-big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"school_theme-button"), for: .normal)
            self.share_button.setImage(UIImage(named:"school_share-icon"), for: .normal)
            self.home_button.setBackgroundImage(self.school_home_pic, for: .normal)
            self.theme_star_counter.image = UIImage(named:"school_mode_star")
            self.theme_star_board.textColor = UIColor(red: 68.0/255, green: 84.0/255, blue: 140.0/255, alpha: 1.0)
            
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
        
        colors_theme_button = MyButton(frame: CGRect(x: pause_screen_x_transform(20), y: pause_screen_y_transform(493), width: pause_screen_x_transform(144), height: pause_screen_y_transform(144)))
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
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "colors_background")!)
            self.background_image.alpha = 1
            self.background_image.image = #imageLiteral(resourceName: "colors_background")
            self.trophy.image = UIImage(named:"colors_j-icon")
            self.gameover_title_image_decider()
            self.score_board.textColor = UIColor(red: 79.0/255, green: 168.0/255, blue: 248.0/255, alpha: 1.00)
            self.restart_button.setImage(UIImage(named:"colors_restart-big"), for: .normal)
            self.shopping_button.setImage(UIImage(named:"colors_theme-button"), for: .normal)
            self.share_button.setImage(UIImage(named:"colors_share-icon"), for: .normal)
            self.home_button.setBackgroundImage(self.colors_home_pic, for: .normal)
            self.theme_star_counter.image = UIImage(named:"colors_mode_star")
            self.theme_star_board.textColor = UIColor(red: 81.0/255, green: 195.0/255, blue: 247.0/255, alpha: 1.0)
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
        if (language == "English"){
            triangle_text.image = UIImage(named: "day mode triangle title")
        }
        else {
            triangle_text.image = UIImage(named: "san_title_day")

        }
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
        
        return_button.alpha = 0
        self.view.addSubview(return_button)
        return_button.fadeInWithDisplacement()
    
    }
    
    
    
    func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
        let transition0 = gesture.translation(in: day_theme_button)
        //上1/3和下1/3的空间
        if(day_theme_button.frame.origin.y < (pause_screen_y_transform(145)+day_theme_button.frame.height/3) && colors_theme_button.frame.origin.y > pause_screen_y_transform(493+144) - colors_theme_button.frame.height/3 - colors_theme_button.frame.height){
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
                //chaos_theme_origin.y = pause_screen_y_transform(319)
                school_theme_origin.y = pause_screen_y_transform(319)
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
    
    func gameover_title_image_decider() -> Void{
        if (ThemeType == 1){
            if (language == "English"){
                self.gameover_title.image = UIImage(named:"day mode gameover title")
            } else {
                self.gameover_title.image = UIImage(named:"shibai_title_day")
            }
        } else if (ThemeType == 2){
            if (language == "English"){
                self.gameover_title.image = UIImage(named:"night mode gameover title")
            } else {
                self.gameover_title.image = UIImage(named:"shibai_title_night")
            }
        } else if (ThemeType == 3){
            if (language == "English"){
                self.gameover_title.image = UIImage(named:"day mode gameover title")
            } else {
                self.gameover_title.image = UIImage(named:"shibai_title_day")
            }
        } else if (ThemeType == 4){
            //chaos
        }
        else if (ThemeType == 5){
            if (language == "English"){
                self.gameover_title.image = UIImage(named:"school_gameover")
            } else {
                self.gameover_title.image = UIImage(named:"shibai_title_school")
            }
        } else if (ThemeType == 6){
            if (language == "English"){
                self.gameover_title.image = UIImage(named:"night mode gameover title")
            } else {
                self.gameover_title.image = UIImage(named:"shibai_title_night")
            }
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

}



class MyButton: UIButton {
    var action: (()->())?
    var highlight_action: (()->())?
    func whenButtonIsClicked(action: @escaping ()->()) {
        self.action = action
        self.addTarget(self, action: #selector(MyButton.clicked), for: .touchUpInside)
    }
    func whenButtonIsHighlighted(action: @escaping () -> () ) {
        self.highlight_action = action
        self.addTarget(self, action: #selector(MyButton.highlighted), for: .touchDown)
        
    }
    
    func clicked() {
        action?()
    }
    
    func highlighted() {
        highlight_action?()
    }
}
