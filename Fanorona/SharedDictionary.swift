//
//  SharedDictionary.swift
//  Fanorona
//
//  Created by ZhangBoxuan on 14/11/29.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class SharedDictionary<K:Hashable, V> {
    var dict : Dictionary<K, V> = Dictionary<K, V>()
    
    func put(key:K, value:V){
        dict[key] = value
    }
    
}

