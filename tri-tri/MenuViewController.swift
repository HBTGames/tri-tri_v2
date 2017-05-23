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

    var opening_player = AVAudioPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func start_action(_ sender: UIButton) {
        do{self.opening_player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "opening", ofType: "wav")!))
            self.opening_player.prepareToPlay()
        }
        catch{
            
        }
        self.opening_player.play()
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
