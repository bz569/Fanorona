//
//  AlphaBeta55.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/29.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class AlphaBeta55: NSObject {
    
    var side:Int
    var initBoard:Board55
    
    var startTime:NSDate?
    let depthLimit:Int = 15
    
    //information need to be displayed
    var isCutOff:Bool = false
    var maximumDepth:Int = 0
    var totalNumberOfNodes:Int = 0
    var numberOfPruningInMAX:Int = 0
    var numberOfPruningInMIN:Int = 0
    
    init(side:Int, initBoard:Board55, depthLimit:Int){
        self.side = side
        self.initBoard = initBoard
        self.depthLimit = depthLimit
        super.init()
    }
    
    func getPossibleBoardStates(board:Board55, curSide:Int) -> SharedDictionary<String, Board55>{
        var states:SharedDictionary<String, Board55> = SharedDictionary<String, Board55>()
        var move:String = ""
        for i in 0..<25 {
            if board.status[i] == curSide {
                getAllPossibleMoves(PriorMoves:move, states: states, board: board, pos: i, curSide: curSide)
            }
        }
        
        return states
    }

    func getAllPossibleMoves(PriorMoves priorMoves:String, states:SharedDictionary<String, Board55>, board:Board55, pos:Int, curSide:Int){
        
        let posMoveList:[Int] = board.moveRules[pos]!
        for to in posMoveList{
            for type in ["M", "A", "W"] {
                let move:String = "\(type)-\(pos)-\(to)"
                var newBoard:Board55 = Board55(board: board)
                var newMove:String
                if priorMoves == "" {
                    newMove = move
                }else {
                    newMove = priorMoves + "||" + move
                }
                
                if newBoard.processMove(newMove, side: curSide) == Board55.MoveCondition.Success {
                    //                    println(newMove)
                    states.put(newMove, value: newBoard)
                    getAllPossibleMoves(PriorMoves: newMove, states: states, board: board, pos: to, curSide: curSide)
                }else {
                    //                    print(newBoard.processMove(newMove, side: curSide))
                }
            }
        }
        
    }
    
    func alphaBetaSearch(board:Board55) -> String {
        
        self.startTime = NSDate()
        
        //init information
        self.isCutOff = false
        self.maximumDepth = 0
        self.totalNumberOfNodes = 0
        self.numberOfPruningInMAX = 0
        self.numberOfPruningInMIN = 0
        
        let bestMove:SharedDictionary = maxValue(Board: self.initBoard, currentDepth: 0, alpha: (0 - Float.infinity), beta: Float.infinity, move: "")
        let keys = Array(bestMove.dict.keys)
        let bestMoveStr:String = "\(keys[0])"
        
        println("BestMove=\(bestMoveStr)\nCutOff:\(self.isCutOff)\nMax depth:\(self.maximumDepth)\nTotal number of nodes generated:\(self.totalNumberOfNodes)\nNumber of times pruning occurred within the MAX-VALUE function:\(self.numberOfPruningInMAX)\nNumber of times pruning occurred within the MIN-VALUE function:\(self.numberOfPruningInMIN)\n-------------------------------------------\n")
        return bestMoveStr
    }
    
    func maxValue(Board board:Board55, currentDepth:Int, var alpha:Float, var beta:Float, move:String) -> SharedDictionary<String, Float> {
        var hash:SharedDictionary<String, Float> = SharedDictionary<String, Float>()
        
        //record max depth
        self.maximumDepth = max(self.maximumDepth, currentDepth)

        //needed vars
        var myState:Board55 = Board55(board: board)
        var bestMove:String
        var value:Float = 0 - Float.infinity
        
        //termination condition
//        if myState.win() != 0 || isTimeOut() || currentDepth >= self.depthLimit {
//            hash.put(move, value: getHeuristic(Board: myState, side: self.side))
//            return hash
//        }
        
        //reach the teminate state
        if myState.win() != 0 {
            hash.put(move, value: getHeuristic(Board: myState, side: self.side))
            
            self.isCutOff = false
            
            return hash
        }
        
        //timeout
        if isTimeOut() {
            hash.put(move, value: getHeuristic(Board: myState, side: self.side))
            
            self.isCutOff = true
            return hash
        }
        
        //over depth limit
        if currentDepth >= self.depthLimit {
            hash.put(move, value: getHeuristic(Board: myState, side: self.side))
            
            self.isCutOff = true
            return hash
        }

        
        //generate a list of possible moves
        let possibleMoves:SharedDictionary<String, Board55> = getPossibleBoardStates(Board55(board: myState), curSide:self.side)
        let moves = Array(possibleMoves.dict.keys)
        bestMove = "\(moves[0])"
        self.totalNumberOfNodes += moves.count
        
        for curMove in moves {
            let curMoveStr = "\(curMove)"
            var tmpState:Board55 = Board55(board: myState)
            
            //process the current move
            if tmpState.processMove(curMoveStr, side: self.side) != Board55.MoveCondition.Success {
                //                print(tmpState.processMove(curMoveStr, side: self.side))
            }
            
            let resultOfMinValue = minValue(Board: Board55(board:tmpState), currentDepth: currentDepth + 1, alpha: alpha, beta: beta)
            
            if resultOfMinValue > value{
                value = resultOfMinValue
                bestMove = curMove
            }
            //            value = max(value, resultOfMinValue)
            
            if value >= beta {
                
                self.numberOfPruningInMAX += 1
                
                hash.put(bestMove, value: value)
                return hash
            }
            
            alpha = max(alpha, value)
        }
        
        hash.put(bestMove, value: value)
        
        return hash
    }
    
    
    
    func minValue(Board board:Board55, currentDepth:Int, var alpha:Float, var beta:Float) -> Float {
        
        //record max depth
        self.maximumDepth = max(self.maximumDepth, currentDepth)

        
        //needed var
        var theirState:Board55 = Board55(board: board)
        var bestMove:String
        var value:Float = Float.infinity
        
        //termination condition
//        if theirState.win() != 0 || isTimeOut() || currentDepth >= self.depthLimit {
//            return getHeuristic(Board: theirState, side: self.side)
//        }

        //reach terminate state
        if theirState.win() != 0{
            
            self.isCutOff = false
            return getHeuristic(Board: theirState, side: self.side)
        }
        
        //timeout
        if isTimeOut() {
            
            self.isCutOff = true
            
            return getHeuristic(Board: theirState, side: self.side)
        }
        
        //over depth limit
        if currentDepth >= self.depthLimit {
            
            self.isCutOff = true
            
            return getHeuristic(Board: theirState, side: self.side)
        }
        
        //generate a list of possible moves
        let possibleMoves:SharedDictionary<String, Board55> = getPossibleBoardStates(Board55(board: theirState), curSide: 0 - self.side)
        let moves = Array(possibleMoves.dict.keys)
        self.totalNumberOfNodes += moves.count
        
        for curMove in moves {
            let curMoveStr = "\(curMove)"
            var tmpState:Board55 = Board55(board: theirState)
            
            //process the current move
            if tmpState.processMove(curMoveStr, side: 0 - self.side) != Board55.MoveCondition.Success {
                //                print(tmpState.processMove(curMoveStr, side: 0 - self.side))
            }
            
            let result:SharedDictionary<String, Float> = maxValue(Board: tmpState, currentDepth: currentDepth + 1, alpha: alpha, beta: beta, move: curMoveStr)
            let keys = Array(result.dict.keys)
            let valueOfResult:Float = result.dict["\(keys[0])"]!
            
            value = min(value, valueOfResult)
            
            if value <= alpha {
                
                self.numberOfPruningInMIN += 1
                
                return value
            }
            
            beta = min(beta, value)
            
        }
        
        
        return value
    }
    
    func isTimeOut() -> Bool {
        if self.startTime?.timeIntervalSinceNow < -10.0 {
//            println("timeout")
            return true
        }else {
            return false
        }
    }
    
    func getHeuristic(Board board:Board55, side:Int) -> Float {
//        if side == 1 {              //for black side
//            if board.win() == 1 {
//                return 1.0
//            }else if board.win() == -1 {
//                return -1.0
//            }else {
//                var h:Float = 0
//                for i:Int in board.status {
//                    h += Float(i)
//                    return h/12
//                }
//            }
//        }else if side == -1 {       //for white side
//            if board.win() == 1 {
//                return -1.0
//            }else if board.win() == -1 {
//                return 1.0
//            }else {
//                var h:Float = 0
//                for i:Int in board.status {
//                    h += Float(i)
//                    return 0.0 - h/12
//                }
//            }
//        }
//        
//        return 0.0
        
        let oppsiteSide = 0 - side
        var opCount:Int = 0
        var myCount:Int = 0
        
        for i in 0..<25 {
            if board.status[i] == oppsiteSide {
                opCount += 1
            }else if board.status[i] == side {
                myCount += 1
            }
        }
        
        return Float((13 - opCount) + myCount)
        
    }
}

