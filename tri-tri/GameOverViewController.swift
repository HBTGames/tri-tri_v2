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
    @IBOutlet weak var High_score_marker: UILabel!

    @IBOutlet weak var score_board: UILabel!
    
    var restart_player = AVAudioPlayer()
    var button_player = AVAudioPlayer()
    @IBOutlet weak var restart_button: UIButton!
    @IBOutlet weak var home_button: UIButton!
    
    @IBOutlet weak var like_button: UIButton!
    
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
        screen_width = view.frame.width
        screen_height = view.frame.height
        restart_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(40), bottom: pause_screen_y_transform(40), right: pause_screen_x_transform(40))
        home_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(25), bottom: 0, right: pause_screen_x_transform(25))
        like_button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: pause_screen_x_transform(25), bottom: 0, right: pause_screen_x_transform(25))
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
        // Do any additional setup after loading the view.
        if ThemeType == 1{
            self.view.backgroundColor = UIColor(red: 254.0/255, green: 253.0/255, blue: 252.0/255, alpha: 1.0)
        } else if ThemeType == 2{
            self.view.backgroundColor = UIColor(red: 23.0/255, green: 53.0/255, blue: 52.0/255, alpha: 1.0)
        }
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
    

}
