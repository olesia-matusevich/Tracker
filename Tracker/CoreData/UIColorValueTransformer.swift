//
//  UIColorValueTransformer.swift
//  Tracker
//
//  Created by Alesia Matusevich on 29/05/2025.
//

import UIKit

@objc(UIColorValueTransformer)
final class UIColorValueTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            print("Failed to transform UIColor to Data: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
            return color
        } catch {
            print("Failed to transform Data to UIColor: \(error)")
            return nil
        }
    }
}
