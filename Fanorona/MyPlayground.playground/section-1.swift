// Playground - noun: a place where people can play

import UIKit

var str:NSString = "Hello, playground"

class SharedDictionary<K:Hashable, V> {
    var dict : Dictionary<K, V>?
    
    // add the methods you need, including overloading operators
    func put(key:K, value:V){
        dict![key] = value
    }
    
}


let date = NSDate()

let i:NSTimeInterval = date.timeIntervalSinceNow


