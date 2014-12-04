//
//  GameSettingViewController.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/24.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class GameSettingViewController: UIViewController {
    
    @IBOutlet weak var btn_whiteSide: UIButton!
    @IBOutlet weak var btn_blackSide: UIButton!
    @IBOutlet weak var btn_size33: UIButton!
    @IBOutlet weak var btn_size55: UIButton!
    @IBOutlet weak var btn_easy: UIButton!
    @IBOutlet weak var btn_normal: UIButton!
    @IBOutlet weak var btn_hard: UIButton!
    @IBOutlet weak var btn_start: UIButton!
    
    
    var side:Int?
    var boardSize:Int?
    var difficulty:Int?
    
    let selectedColor:UIColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    let unselectedColor:UIColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //default game settings
        self.side = -1
        self.btn_whiteSide.backgroundColor = self.selectedColor
        self.btn_blackSide.backgroundColor = self.unselectedColor
        
        self.boardSize = 3
        self.btn_size33.backgroundColor = self.selectedColor
        self.btn_size55.backgroundColor = self.unselectedColor
        
        self.difficulty = 15
        self.btn_hard.backgroundColor = self.selectedColor
        self.btn_normal.backgroundColor = self.unselectedColor
        self.btn_easy.backgroundColor = self.unselectedColor
    }

    
    @IBAction func onTouchWhiteSideButton(sender: UIButton) {
        self.side = -1
        self.btn_whiteSide.backgroundColor = self.selectedColor
        self.btn_blackSide.backgroundColor = self.unselectedColor
    }
    
    @IBAction func onTouchBlackSideButton(sender: UIButton) {
        self.side = 1
        self.btn_whiteSide.backgroundColor = self.unselectedColor
        self.btn_blackSide.backgroundColor = self.selectedColor
    }
    
    @IBAction func onTouchSize33Button(sender: UIButton) {
        self.boardSize = 3
        self.btn_size33.backgroundColor = self.selectedColor
        self.btn_size55.backgroundColor = self.unselectedColor
    }
    
    @IBAction func onTouchSize55Button(sender: UIButton) {
        self.boardSize = 5
        self.btn_size33.backgroundColor = self.unselectedColor
        self.btn_size55.backgroundColor = self.selectedColor
    }
    
    @IBAction func onTouchEasyButton(sender: UIButton) {
        self.difficulty = 5
        self.btn_hard.backgroundColor = self.unselectedColor
        self.btn_normal.backgroundColor = self.unselectedColor
        self.btn_easy.backgroundColor = self.selectedColor
    }
    
    @IBAction func onTouchNormalButton(sender: UIButton) {
        self.difficulty = 10
        self.btn_hard.backgroundColor = self.unselectedColor
        self.btn_normal.backgroundColor = self.selectedColor
        self.btn_easy.backgroundColor = self.unselectedColor
    }
    
    @IBAction func onTouchHardButton(sender: UIButton) {
        
        self.difficulty = 15
        self.btn_hard.backgroundColor = self.selectedColor
        self.btn_normal.backgroundColor = self.unselectedColor
        self.btn_easy.backgroundColor = self.unselectedColor
    }
    
    @IBAction func onTouchStartButton(sender: UIButton) {
        if self.boardSize == 3 {
            self.performSegueWithIdentifier("segue_settingToGame33", sender: self)
        }else if self.boardSize == 5 {
            self.performSegueWithIdentifier("segue_settingToGame55", sender: self)
        }
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_settingToGame33" {
            let dstVC:Board33ViewController = segue.destinationViewController as Board33ViewController
            dstVC.setValue(self.difficulty, forKey: "gameDifficulty")
            dstVC.setValue(self.side, forKey: "playerSide")
        }else if segue.identifier == "segue_settingToGame55" {
            let dstVC:Board55ViewController = segue.destinationViewController as Board55ViewController
            dstVC.setValue(self.difficulty, forKey: "gameDifficulty")
            dstVC.setValue(self.side, forKey: "playerSide")
        }
    }

}
