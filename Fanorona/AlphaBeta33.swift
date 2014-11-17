//
//  AlphaBeta.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/14.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
}

class AlphaBeta33: NSObject {
    
    var side:Int
    var initBoard:Board33
    
    init(side:Int, initBoard:Board33){
        self.side = side
        self.initBoard = initBoard
        super.init()
    }
    
    func action(board:Board33) -> [String] {
        
        var actionList:[String] = []
        
        for i in 0..<9 {
            if board.status[i] == self.side {
                var stepCache:[Int] = []
                let from = i
                let nextPos = board.moveRules[from]
                for to in nextPos! {
                    if board.canMove(From: from, To: to) {
                        let actStr:String = "\(from)\(to)"
                        actionList.append(actStr)
                    }
                }
            }
        }
        
        return actionList
    }
    
    func alphaBetaSearch(state:[Int]) -> String {
        
        var (v, action):(Float, String) = (0.0, "")
        
        if self.side == 1{
            (v, action) = maxValue(self.initBoard, alpha: Float.infinity, beta: (0 - Float.infinity))
        }else if self.side == -1 {
            (v, action ) = minValue(self.initBoard, alpha: Float.infinity, beta: (0 - Float.infinity))
        }
        
        return action

    }
    
    func maxValue(board:Board33, var alpha:Float, var beta:Float) -> (Float, String){
        if board.win() != 0 {
            return (Float(board.win()), "end")
        }
        
        var v:Float = 0 - Float.infinity
        var actionV:String = ""
        let actions = self.action(board)
        
        for action:String in actions {
            
            let boardAfterAction:Board33 = result(OfBoard: board, AfterMove: action)
            let (tmpV, tmpAction) = minValue(board.copy() as Board33, alpha: alpha, beta: beta)
            if (tmpV > v){
                v = tmpV
                actionV = action
            }
            if v > beta {
                return (v, "")
            }
            alpha = min(alpha, v)
        }
        
        return (v, actionV)
    }
    
    func minValue(board:Board33, var alpha:Float, var beta:Float) -> (Float, String) {
        
        if board.win() != 0 {
            return (Float(board.win()), "end")
        }
        
        var v:Float = Float.infinity
        var actionV:String = ""
        let actions = self.action(board)
        
        for action:String in actions {
            
            let boardAfterAction:Board33 = result(OfBoard: board, AfterMove: action)
            let (tmpV, tmpAction) = maxValue(board.copy() as Board33, alpha: alpha, beta: beta)
            if (tmpV < v){
                v = tmpV
                actionV = action
            }
            if v < alpha {
                return (v, "")
            }
            beta = max(beta, v)
        }
        
        return (v, actionV)
    }
    
    func result(OfBoard board:Board33, AfterMove action:String) -> Board33 {
        
        var actionNSString:NSString = NSString(string: action)
        
        while actionNSString.length > 1 {
            let fromString:String = actionNSString.substringToIndex(1)
            let from:Int = fromString.toInt()!
            actionNSString = actionNSString.substringFromIndex(1)
            let toString:String = actionNSString.substringToIndex(1)
            let to:Int = toString.toInt()!
            

        }
        
        
        return Board33()
    }
    
   
}



















