//
//  Board.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/13.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class Board: NSObject {
    
    var status:[Int] = []
    var size:Int?
    var moveRules:Dictionary<Int, [Int]> = Dictionary<Int, [Int]>()

}
