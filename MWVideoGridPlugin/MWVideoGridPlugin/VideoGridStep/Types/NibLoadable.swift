//
//  NibLoadable.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 28/10/2020.
//

import UIKit

public protocol NibLoadable: class {
    static var nibName: String { get }
    static var nib: UINib { get }
    static func nib(bundle: Bundle?) -> UINib
    
    static func loadFromNib() -> Self
    static func loadFromNib(bundle: Bundle?) -> Self
}

public extension NibLoadable {
    
    static var nibName: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return self.nib(bundle: Bundle(for: self))
    }
    
    static func nib(bundle: Bundle?) -> UINib {
        return UINib(nibName: self.nibName, bundle: bundle)
    }
}

public extension NibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        return self.nib.instantiate(withOwner: self, options: nil).first as! Self
    }
    
    static func loadFromNib(bundle: Bundle?) -> Self {
        return self.nib(bundle: bundle).instantiate(withOwner: self, options: nil).first as! Self
    }
}

public extension NibLoadable where Self: UIViewController {
    static func loadFromNib() -> Self {
        return self.nib.instantiate(withOwner: self, options: nil).first as! Self
    }
    
    static func loadFromNib(bundle: Bundle?) -> Self {
        return self.nib(bundle: bundle).instantiate(withOwner: self, options: nil).first as! Self
    }
}
