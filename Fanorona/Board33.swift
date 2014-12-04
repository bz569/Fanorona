//
//  Board33.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/13.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class Board33: Board {
    
    
    enum CaptureCondition {
        case None, Apprach, Withdrawal, Both
    }
    
    enum MoveCondition {
        case    Success,
                ERROR_NoAction,
                ERROR_MoveAfterNoCapture,
                ERROR_FromIndexIllegal,
                ERROR_NotSameSide,
                ERROR_CannotReach,
                ERROR_DestPosNotBlank,
                ERROR_SameDirection,
                ERROR_PosVisited,
                ERROR_MoveWithoutCapWhenCapAvailable,
                ERROR_MoveWithoutCapInContinueMove,
                ERROR_ApproachPositionNotAvailable,
                ERROR_ApprachPositionIsSameSideOrEmpty,
                ERROR_WithdrawalPositionNotAvailable,
                ERROR_WithdrawalPositionIsSameSideOrEmpty,
                ERROR_moveTypeWrong
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
    
    init(board:Board33) {
        super.init()
        
        self.status = board.status
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
        //For test
//        self.status = [1, 0, 1, 1 ,-1, -1, -1, 0, -1]
        
        self.status = [1, 1, 1, 1, 0, -1, -1, -1, -1]       //1 for black, and -1 for white
    }
    
    func setBoardStatus(status:[Int]) {
        self.status = status
    }
    
    //rules of the game
    
    /**
    Judge if a piece can move to a pos for the first move
    
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
            if self.getCaptureCondition(From: from, To: to) == CaptureCondition.None {
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
    func getCaptureCondition(From from:Int, To to:Int) -> CaptureCondition {
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
            return CaptureCondition.Both
        }else if hasApproach {
            return CaptureCondition.Apprach
        }else if hasWithdrawal {
            return CaptureCondition.Withdrawal
        }else {
            return CaptureCondition.None
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
                        if self.getCaptureCondition(From: from, To: to) != CaptureCondition.None {
//                            println("has capture form \(from) to \(to):")
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
    func captureAfterMove(From from:Int, To to:Int, ByType type:CaptureCondition){
        let dir = to - from
        if type == CaptureCondition.Apprach {
            let approachPos = to + dir
            self.status[approachPos] = 0
        }else if type == CaptureCondition.Withdrawal {
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
            if self.getCaptureCondition(From: from, To: nextPos) != CaptureCondition.None {
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
        
        if getCaptureCondition(From: from, To: to) == CaptureCondition.None {
            return false
        }
        
        return true
    }
    
    /**
    Move a piece after capturing
    
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
    
    
    // rules for ai player
    func processMove(var moveString:NSString, side:Int) -> MoveCondition{
        
        if countElements(moveString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) == 0 {
            return MoveCondition.ERROR_NoAction
        }
        
        var moveIndex:Int = 0
        var noCapMove:Bool = false
        var endPosition:Int = -1
        
        let movesArray:[String] = moveString.componentsSeparatedByString("||") as [String]
        var visitedPos:[Int]  = []
        
        for i in 0..<movesArray.count {
            
            //if we made a non-capturing move and are trying to make another move, throw and error as it is not allowed
            if(noCapMove){
                return MoveCondition.ERROR_MoveAfterNoCapture
            }
            
            let curMove:String = movesArray[i]
            let moveArray  = Array(curMove)
            let type:String = String(moveArray[0])
            let from:Int = String(moveArray[1]).toInt()!
            let to:Int = String(moveArray[2]).toInt()!
            
            //check rules of fanorona
            
            //Check the from index is legal
            if (from > 8 || from < 0) {
                return MoveCondition.ERROR_FromIndexIllegal
            }
            
            //make sure the moving piece is the same color as cur side
            if (self.status[from] != side) {
                return MoveCondition.ERROR_NotSameSide
            }
            
            //make sure destination postion is reachable
            let neighborList:[Int] = self.moveRules[from]!
            if !contains(neighborList, to) {
                return MoveCondition.ERROR_CannotReach
            }
            
            //see if there is a piece in the dst position
            if self.status[to] != 0 {
                return MoveCondition.ERROR_DestPosNotBlank
            }
            
            //check to make sure there are not 2 move in the same direction on the same line...
            if moveIndex > 0 {
                let lastMove:String = movesArray[i - 1]
                let lastMoveArray = Array(lastMove)
                let lastFrom:Int = String(lastMoveArray[1]).toInt()!
                let lastTo:Int = String(lastMoveArray[2]).toInt()!
                
                let lastDir = lastTo - lastFrom
                let dir = to - from
                
                if lastDir == dir {
                    return MoveCondition.ERROR_SameDirection
                }
            }
            
            //check if the position has been visited before
            if contains(visitedPos, to) {
                return MoveCondition.ERROR_PosVisited
            }
            
            //Check the rules done
            //Process the move will be done
            
            
            //check for move without capturing
            if type == "M" {
                noCapMove = true
                
                if (moveIndex == 0){
                    if hasAnyCaptureFor(Side: side) {
                        return MoveCondition.ERROR_MoveWithoutCapWhenCapAvailable
                    }
                }else {
                    return MoveCondition.ERROR_MoveWithoutCapInContinueMove
                }
            }
            //check for approach capture
            else if type == "A"{
                let dir:Int = to - from
                var approachPos:Int = to + dir
                
                //check if the approach position is available
                if !contains(self.moveRules[to] as [Int]!, approachPos) {
                    return MoveCondition.ERROR_ApproachPositionNotAvailable
                }
                
                //check to make sure the next peice is opposite of the current mover
                if self.status[approachPos] == side || self.status[approachPos] == 0{
                    return MoveCondition.ERROR_ApprachPositionIsSameSideOrEmpty
                }
                
                //loop through the rest of the pieces being captured, and capture them
                while (true) {
                    self.status[approachPos] = 0
                    
                    let tmpPos = approachPos
                    approachPos += dir
                    
                    if !contains(self.moveRules[tmpPos] as [Int]!, approachPos) {
                        break;
                    }
                    
                    if self.status[approachPos] == side {
                        break;
                    }
                }
            }
            //check for withdrawal capture
            else if type == "W" {
                let dir:Int = to - from
                var withdrawalPos:Int = from - dir
                
                //check if the withdrawal position is available
                if !contains(self.moveRules[from] as [Int]!, withdrawalPos) {
                    return MoveCondition.ERROR_WithdrawalPositionNotAvailable
                }
                
                //check to make sure the next peice is opposite of the current mover
                if self.status[withdrawalPos] == side || self.status[withdrawalPos] == 0{
                    return MoveCondition.ERROR_WithdrawalPositionIsSameSideOrEmpty
                }
                
                //loop through the rest of the pieces being captured, and capture them
                while (true) {
                    self.status[withdrawalPos] = 0
                    
                    let tmpPos = withdrawalPos
                    withdrawalPos -= dir
                    
                    if !contains(self.moveRules[tmpPos] as [Int]!, withdrawalPos) {
                        break;
                    }
                    
                    if self.status[withdrawalPos] == side {
                        break;
                    }
                }
            }
            else {
                return MoveCondition.ERROR_moveTypeWrong
            }
            
            //Move the piece
            self.status[to] = self.status[from]
            self.status[from] = 0
            visitedPos.append(from)
            moveIndex++
            
        }
        return MoveCondition.Success
    }
    
}




















