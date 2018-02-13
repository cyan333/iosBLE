//
//  NSDataExtensions.swift
//  MAPO
//
//  Created by Hugues Bernet-Rollande on 21/3/16.
//  Copyright © 2016 WB Technologies. All rights reserved.
//
import Foundation

// https://gist.github.com/tannernelson/73d0923efdee50e6c38f
extension NSData {
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.getBytes(&number, length: MemoryLayout<UInt8>.size)
            return number
        }
    }
}

extension NSData {
    var uint16: UInt16 {
        get {
            var number: UInt16 = 0
            self.getBytes(&number, length: MemoryLayout<UInt16>.size)
            return number
        }
    }
}

extension NSData {
    var uint32: Int32 {
        get {
            var number: Int32 = 0
            self.getBytes(&number, length: MemoryLayout<Int32>.size)
            return number
        }
    }
}

extension NSData {
    var stringASCII: String? {
        get {
            return NSString(data: self as Data, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
}

extension NSData {
    var stringUTF8: String? {
        get {
            return NSString(data: self as Data, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }
}

extension Int {
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: MemoryLayout<Int>.size)
    }
}

extension UInt8 {
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: MemoryLayout<UInt16>.size)
    }
}


