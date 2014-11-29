//
//  Board33ViewController.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/13.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class Board33ViewController: UIViewController, UIAlertViewDelegate {
    
    enum GameState {
        case BeforeFirstStep, AfterCapturing, EndTurn
    }

    @IBOutlet var btns_pieces: [UIButton]!
    @IBOutlet weak var btn_finish: UIButton!
    
    var board:Board33 = Board33()
    var selectedPiece:UIButton?
    
    var turn:Int = -1 //-1 for white; 1 for black
    var gameState:GameState = GameState.BeforeFirstStep
    var stepsCache:[Int] = []
    
    var playerSide:Int = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //order the buttons by their tags
        self.btns_pieces.sort { (btn1:UIButton, btn2:UIButton) -> Bool in
            return btn1.tag < btn2.tag
        }
        
        //set the shape of btn
        for btn:UIButton in self.btns_pieces {
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = 20
        }
        
        
        
        //!!! test for alphabeta, need to be remove
//        let alphaBeta:AlphaBeta33 = AlphaBeta33(side: 1, initBoard: self.board)
//        alphaBeta.alphaBetaSearch(self.board)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.refreshBoardUI()
        self.startGame()
    }
    
    func startGame() {
        self.turn = -1
        self.gameState = GameState.BeforeFirstStep
        self.btn_finish.backgroundColor = UIColor.grayColor()
        self.btn_finish.enabled = false
        self.stepsCache = []
        self.board.resetBoard()
        self.refreshBoardUI()
        
        if self.playerSide == 1 {
            aiPlayer()
        }
    }
    
    func refreshBoardUI(){
        for i in 0..<(self.board.size! * self.board.size!){
            if self.board.status[i] == 1 {
                self.btns_pieces[i].backgroundColor = UIColor.blackColor()
            }else if self.board.status[i] == -1 {
                self.btns_pieces[i].backgroundColor = UIColor.whiteColor()
            }else{
                self.btns_pieces[i].backgroundColor = nil
            }
        }
    }
    
    @IBAction func onClickPiece(sender: UIButton) {
        if self.gameState == GameState.BeforeFirstStep {
            if self.selectedPiece == nil {
                if (self.board.status[sender.tag] == self.turn) {
                    self.selectPiece(sender)
                }
            }else {
                if sender != selectedPiece {
                    let from = selectedPiece!.tag
                    let to = sender.tag
                    
                    if(self.board.status[to] == 0){
                        let captureType = self.board.getCaptureCondition(From: from, To: to)
                        
                        //move the piece
                        if self.board.movePiece(From: from, To: to) {
                            //add the original pos to steps cache
                            self.stepsCache.append(from)
                            
                            //capture after move
                            self.board.captureAfterMove(From: from, To: to, ByType: captureType)
                            self.refreshBoardUI()
                            
                            if self.board.win() != 0 {
                                self.gameDidEnd()
                            }
                            
                            if captureType == Board33.CaptureCondition.None{         //move without capturing, forward to End state
                                self.gameState = GameState.EndTurn
                                self.btn_finish.enabled = true
                                self.btn_finish.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
                                self.unselectPiece()
                            }else {                                                 //after capturing, player can choose continue or end the turn
                                self.gameState = GameState.AfterCapturing
                                self.btn_finish.enabled = true
                                self.btn_finish.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
                                self.unselectPiece()
                                self.selectPiece(self.btns_pieces[to])
                            }

                    }
                        
                    }else {
                        println("move failed")
                        self.unselectPiece()
                    }
                    
                }else {
                    self.unselectPiece()
                }
            }
        }else if self.gameState == GameState.AfterCapturing {
            let from = selectedPiece?.tag
            let to = sender.tag
            
            if self.board.status[to] == 0 {
                let captureType = self.board.getCaptureCondition(From: from!, To: to)
                
                if self.board.continueMovePiece(From: from!, To: to, LastPos: self.stepsCache.last!, StepCache: self.stepsCache) {
                    self.stepsCache.append(from!)
                    self.board.captureAfterMove(From: from!, To: to, ByType: captureType)
                    self.refreshBoardUI()
                    
                    if self.board.win() != 0 {
                        self.gameDidEnd()
                    }
                    
                    self.unselectPiece()
                    self.selectPiece(self.btns_pieces[to])
                    
                }else {
                    println("move failed")
                }
            }
           
        }
        
    }
    
    @IBAction func onClickFinishButton(sender: UIButton) {
        if self.gameState != GameState.BeforeFirstStep {
            self.changeSide()
            self.aiPlayer()
        }
    }
    
    func aiPlayer(){
        //make sure it is ai's turn
        if self.turn != self.playerSide {
            let ai:AlphaBeta33 = AlphaBeta33(side: self.turn, initBoard: self.board)
            let bestMove:String = ai.alphaBetaSearch(ai.initBoard)
            self.board.processMove(bestMove, side: self.turn)
            self.refreshBoardUI()
            
            if self.board.win() != 0 {
                self.gameDidEnd()
            }
            
            self.changeSide()
        }
    }
    
    
    func changeSide() {
        self.gameState = GameState.BeforeFirstStep
        self.stepsCache.removeAll(keepCapacity: true)
        self.unselectPiece()
        if self.turn == 1 {
            self.turn = -1
        }else if self.turn == -1{
            self.turn = 1
        }
    }
    
    func gameDidEnd(){
        var winner:NSString = ""
        if self.board.win() == -1 {
            winner = "white"
        }else if self.board.win() == 1{
            winner = "black"
        }
        
        let alert:UIAlertView = UIAlertView(title: nil, message: "\(winner) win!", delegate: self, cancelButtonTitle: "Restart")
        alert.show()
    }
    
    
    func selectPiece(piece:UIButton) {
        self.selectedPiece = piece
        self.selectedPiece!.setImage(UIImage(named: "selectedPiece"), forState: UIControlState.Normal)
    }
    
    func unselectPiece() {
        if(self.selectedPiece != nil){
            self.selectedPiece!.setImage(UIImage(), forState: UIControlState.Normal)
            self.selectedPiece = nil
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.startGame()
    }

}
























