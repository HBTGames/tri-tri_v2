//
//  TutorialViewController.swift
//  tri-tri
//
//  Created by mac on 2017-07-03.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {

    var pageCount = Int()
    
    func pause_screen_x_transform(_ x: Double) -> CGFloat {
        let const = x/Double(375)
        let new_x = Double(view.frame.width)*const
        return CGFloat(new_x)
        
    }
    func pause_screen_y_transform(_ y: Double) -> CGFloat {
        let const = y/Double(667)
        let new_y = Double(view.frame.height)*const
        return CGFloat(new_y)
    }
    
    @IBOutlet var exit_button: UIButton!
    @IBAction func exit(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        nextViewController.modalTransitionStyle = .crossDissolve
        self.present(nextViewController, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet var tuto_page_con: UIPageControl!
    
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainScrollView.delegate = self
        
        exit_button.setTitle("", for: .normal)
        exit_button.setImage(UIImage(named:"tuto_exit"), for: .normal)
        exit_button.frame = CGRect(x:0, y: pause_screen_y_transform(537), width: pause_screen_x_transform(130), height: pause_screen_y_transform(130))
        tuto_page_con.frame = CGRect(x:pause_screen_x_transform(168), y: pause_screen_y_transform(520), width: pause_screen_x_transform(39), height: 37)
        self.view.bringSubview(toFront: exit_button)
        
        self.view.bringSubview(toFront: tuto_page_con)
        
        let tuto_text = UIImageView()
        tuto_text.image = UIImage(named:"tuto_text")
        tuto_text.frame = CGRect(x:0, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        let tuto_case_1 = UIImageView()
        tuto_case_1.image = UIImage(named:"tuto_case_1")
        tuto_case_1.frame = CGRect(x:0, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        let tuto_case_2 = UIImageView()
        tuto_case_2.image = UIImage(named:"tuto_case_2")
        tuto_case_2.frame = CGRect(x:mainScrollView.frame.width, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        let tuto_case_3 = UIImageView()
        tuto_case_3.image = UIImage(named:"tuto_case_3")
        tuto_case_3.frame = CGRect(x:2*mainScrollView.frame.width, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        let tuto_case_4 = UIImageView()
        tuto_case_4.image = UIImage(named:"tuto_case_4")
        tuto_case_4.frame = CGRect(x:3*mainScrollView.frame.width, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        let tuto_reward = UIImageView()
        tuto_reward.image = UIImage(named:"tuto_reward")
        tuto_reward.frame = CGRect(x:4*mainScrollView.frame.width, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        let tuto_reward_text = UIImageView()
        tuto_reward_text.image = UIImage(named:"tuto_reward_text")
        tuto_reward_text.frame = CGRect(x:4*mainScrollView.frame.width, y:0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
        
        mainScrollView.contentSize.width = mainScrollView.frame.width * 5
        mainScrollView.addSubview(tuto_case_1)
        mainScrollView.addSubview(tuto_case_2)
        mainScrollView.addSubview(tuto_case_3)
        mainScrollView.addSubview(tuto_case_4)
        mainScrollView.addSubview(tuto_reward)
        mainScrollView.addSubview(tuto_reward_text)
        mainScrollView.addSubview(tuto_text)
        
        pageCount = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
        
    }
    
    func swipeGestureRecognizerAction(_ gesture: UISwipeGestureRecognizer){
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        tuto_page_con.currentPage = Int(pageIndex)
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
