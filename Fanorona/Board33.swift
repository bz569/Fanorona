//
//  Board33.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/13.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class Board33: Board {
    
    let moveDir = [-3, 3, -1, 1, -4, -2, 2, 4]  //Up, down, left, right, upleft, upright, downleft, downright
    
    enum CaptureCondidion {
        case None, Apprach, Withdrawal, Both
    }
    
    override init() {
        super.init()
        self.status = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        self.size = 3
        
        self.moveRules = [
            0: [1, 3, 4],
            1: [0, 2, 4],
            2: [1, 4, 5],
            3: [0, 4, 6],
            4: [0, 1, 2, 3, 5, 6, 7, 8],
            5: [2, 4, 8],
            6: [3, 4, 7],
            7: [4, 6, 8],
            8: [4, 5, 7]
        ]
    }
   
    func resetBoard() {
//        //For test
//        self.status = [-1, 0, 0, 0 ,0, 0, 0, 1, 1]
        
        self.status = [1, 1, 1, 1, 0, -1, -1, -1, -1]       //1 for black, and -1 for white
    }
    
    func setBoardStatus(status:[Int]) {
        self.status = status
    }
    
    //rules of the game
    
    /**
    Judge if a piece can move to a pos
    
    :param: from move form this pos
    :param: to   move to this pos
    
    :returns: true if a piece can move to a pos; otherwise false
    */
    func canMove(From from:Int, To to:Int) -> Bool {
        
        //if to not in the next to from
        let posList:[Int] = self.moveRules[from]!
        if !contains(posList, to) {
            return false
        }
        
        //the dst position is not blank
        if self.status[to] != 0 {
            println("the dst position is not blank")
            return false
        }
        
        //if has at least one capture, must move to capture
        if self.hasAnyCaptureFor(Side: status[from]){
            if self.getCaptureCondition(From: from, To: to) == CaptureCondidion.None {
                println("must move to capture")
                return false
            }
        }
        
        return true
    }
    
    
    /**
    Judge the type of capture may occur when move a piece to a pos
    
    :param: from move from this pos
    :param: to   move to this pos
    
    :returns: the type of capture: Both, None, Approach, Withdrawal
    */
    func getCaptureCondition(From from:Int, To to:Int) -> CaptureCondidion {
        let dir:Int = to - from
        var hasApproach:Bool = false
        var hasWithdrawal:Bool = false
        
        //approach condition
        let approachPos:Int = to + dir
        let posApproachList = self.moveRules[to]!
        if contains(posApproachList, approachPos) {
            let sameSide:Int = self.status[from] + self.status[approachPos]
            if (self.status[approachPos] != 0) && (sameSide == 0){
                hasApproach = true
            }
        }
        
        //withdrawal condition
        let withdrawalPos:Int = from -  dir
        let posWithdrawalList = self.moveRules[from]!
        if contains(posWithdrawalList, withdrawalPos) {
            if self.status[withdrawalPos] != 0 && (self.status[from] + self.status[withdrawalPos] == 0){
                hasWithdrawal = true
            }
        }
        
        if hasApproach && hasWithdrawal {
            return CaptureCondidion.Both
        }else if hasApproach {
            return CaptureCondidion.Apprach
        }else if hasWithdrawal {
            return CaptureCondidion.Withdrawal
        }else {
            return CaptureCondidion.None
        }
    }
    
    /**
    Judge if there is any capture condition for this side
    
    :param: side 1 for black and -1 for white
    
    :returns: ture if there is any capture;otherwise, false
    */
    func hasAnyCaptureFor(Side side:Int) -> Bool {
        for i in 0..<9 {
            if self.status[i] == side {
                let from = i
                let toList = self.moveRules[from]!
                for to:Int in toList {
                    if (self.status[to] == 0) {
                        if self.getCaptureCondition(From: from, To: to) != CaptureCondidion.None {
                            println("has capture form \(from) to \(to):")
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    
    /**
    Move a piece
    
    :param: from move from this pos
    :param: to   to this pos
    
    :returns: ture if move successfully; otherwise false
    */
    func movePiece(From from:Int, To to:Int) -> Bool {
        if self.canMove(From: from, To: to) {
            self.status[to] = self.status[from]
            self.status[from] = 0
            
            return true
        }else {
            return false
        }
    }
    
    /**
    execute capture after move
    
    :param: from the pos before move
    :param: to   the pos after move
    :param: type the type of capture
    */
    func captureAfterMove(From from:Int, To to:Int, ByType type:CaptureCondidion){
        let dir = to - from
        if type == CaptureCondidion.Apprach {
            let approachPos = to + dir
            self.status[approachPos] = 0
        }else if type == CaptureCondidion.Withdrawal {
            let withdrawalPos = from - dir
            self.status[withdrawalPos] = 0
        }
        
    }
    
    /**
    get if someone win at the current state
    
    :returns: -1 for white win; 1 for black; 0 for not ending
    */
    func win() -> Int {
        if !contains(self.status, 1){
            return -1
        }else if !contains(self.status, -1){
            return 1
        }else {
            return 0
        }
    }
    
    
    /**
    if player can continue move after a capture
    
    :param: from    move from this pos
    :param: lastPos the pos before the last move
    
    :returns: true if can continue move; otherwise false
    */
    func canContinueCapture(From from:Int, LastPos lastPos:Int) -> Bool {
        
        let lastDir = from - lastPos
        let nextPosList = self.moveRules[from]
        
        for nextPos:Int in nextPosList! {
            if self.getCaptureCondition(From: from, To: nextPos) != CaptureCondidion.None {
                if nextPos - from != lastDir {
                    return true
                }
            }
        }
        return false
    }
    
    /**
    judge if player can move from a pos to another pos after the first step
    
    :param: from      move from pos
    :param: to        move to pos
    :param: stepCache stepCache
    
    :returns: ture if can continue move; otherwise false
    */
    func canContinueMove(From from:Int, To to:Int, LastPos lastPos:Int, StepCache stepCache:[Int]) -> Bool {
        let lastDir = from - lastPos
        
        let posList:[Int] = self.moveRules[from]!
        if !contains(posList, to) {
            return false
        }
        
        if to - from == lastDir {
            return false
        }
        
        if contains(stepCache, to) {
            return false
        }
        
        if getCaptureCondition(From: from, To: to) == CaptureCondidion.None {
            return false
        }
        
        return true
    }
    
    /**
    Move a piece
    
    :param: from move from this pos
    :param: to   to this pos
    
    :returns: ture if move successfully; otherwise false
    */
    func continueMovePiece(From from:Int, To to:Int, LastPos lastPos:Int, StepCache stepCache:[Int]) -> Bool {
        if self.canContinueMove(From: from, To: to, LastPos: lastPos, StepCache: stepCache) {
            self.status[to] = self.status[from]
            self.status[from] = 0
            
            return true
        }else {
            return false
        }
    }
    
}




















