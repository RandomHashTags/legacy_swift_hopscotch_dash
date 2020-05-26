//
//  ConstraintsAPI.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 5/26/20.
//  Copyright © 2020 RandomHashTags. All rights reserved.
//

import Foundation
import UIKit

protocol ConstraintsAPI {
}

extension ConstraintsAPI {
    public func getConstraint(item: Any, _ attribute: NSLayoutConstraint.Attribute, toItem: Any?) -> NSLayoutConstraint {
        return getConstraint(item: item, attribute, toItem: toItem, attribute)
    }
    public func getConstraint(item: Any, _ attribute: NSLayoutConstraint.Attribute, toItem: Any?, _ attribute2: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return getConstraint(item: item, attribute, toItem: toItem, attribute2, multiplier: 1)
    }
    public func getConstraint(item: Any, _ attribute: NSLayoutConstraint.Attribute, toItem: Any?, _ attribute2: NSLayoutConstraint.Attribute, multiplier: CGFloat) -> NSLayoutConstraint {
        return getConstraint(item: item, attribute, toItem: toItem, attribute2, multiplier: multiplier, constant: 0)
    }
    public func getConstraint(item: Any, _ attribute: NSLayoutConstraint.Attribute, toItem: Any?, _ attribute2: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: toItem, attribute: attribute2, multiplier: multiplier, constant: constant)
    }
    public func getConstraint(constraintHolder: UIView, forView: UIView, _ attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        for constraint in constraintHolder.constraints {
            if constraint.firstAttribute == attribute && constraint.firstItem as? UIView == forView {
                return constraint
            }
        }
        return nil
    }
}
