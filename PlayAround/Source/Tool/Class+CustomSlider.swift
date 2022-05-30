//
//  Class+CustomSlider.swift
//  coffit
//
//  Created by hoon Kim on 2022/02/07.
//

import UIKit

class CustomSlider: UISlider {
  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    let point = CGPoint(x: bounds.minX, y: bounds.midY)
    return CGRect(origin: point, size: CGSize(width: bounds.width, height: 8))
  }
}
