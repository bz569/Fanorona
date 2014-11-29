//
//  GameSettingViewController.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/24.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class GameSettingViewController: UIViewController {
    
    var side:Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func onTouchWhiteSideButton(sender: UIButton) {
        self.side = -1
        self.performSegueWithIdentifier("segue_settingToGame", sender: self)
        
    }
    
    @IBAction func onTouchBlackSideButton(sender: UIButton) {
        self.side = 1
        self.performSegueWithIdentifier("segue_settingToGame", sender: self)
    }
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dstVC:Board33ViewController = segue.destinationViewController as Board33ViewController
        dstVC.setValue(self.side!, forKey: "playerSide")
    }

}
