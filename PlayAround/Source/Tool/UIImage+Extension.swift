//
//  UIImage+Extension.swift
//  sircle
//
//  Created by SuHan Kim on 09/11/2017.
//  Copyright © 2017 Sircle. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
  class var profilePlaceHolder: UIImage{
    return UIImage(named: "placeHolder")!
  }
  class var imagePlaceHolder: UIImage{
    return UIImage(named: "noImage")!
  }
  class var expiredPlaceHolder: UIImage{
    return UIImage(named: "expired")!
  }
  class var wallpaperPlaceHolder: UIImage{
    return UIImage(named: "wallpaperPlaceholder")!
  }
  
  func resize(to size: CGSize) -> UIImage? {
    // Actually do the resizing to the rect using the ImageContext stuff
    let aspect = self.size.width / self.size.height
    var rect = CGRect.zero
    if (size.width / aspect) > size.height{
      let height = size.width / aspect
      rect = CGRect(
        x: 0,
        y: size.height - height,
        width: size.width,
        height: height
      )
    } else {
      let width = size.height * aspect
      rect = CGRect(
        x: size.width - width,
        y: 0,
        width: width,
        height: size.height
      )
    }
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    UIGraphicsGetCurrentContext()?.clip(to: CGRect(origin: CGPoint.zero, size: size))
    UIGraphicsGetCurrentContext()?.setFillColor(UIColor.black.cgColor)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func resizeToWidth(newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / self.size.width
    let newHeight = self.size.height * scale
    //      UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 3.0)
    self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
    func resizeToFloat(newWidth: CGFloat) -> CGFloat {
      
      let scale = newWidth / self.size.width
      let newHeight = self.size.height * scale
      
      return newHeight
    }

  
  func asBase64() -> String?{
    let data = self.jpegData(compressionQuality: 0.9)
    
    return data?.base64EncodedString()
  }
  
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)){
    let rect = CGRect(origin: .zero, size: size)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else{ return nil }
    self.init(cgImage: cgImage)
  }
  public class func gifImageWithData(_ data: Data) -> UIImage? {
      guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
          print("image doesn't exist")
          return nil
      }
      
      return UIImage.animatedImageWithSource(source)
  }
  
  public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
    guard let bundleURL:URL = URL(string: gifUrl)
          else {
              print("image named \"\(gifUrl)\" doesn't exist")
              return nil
      }
    guard let imageData = try? Data(contentsOf: bundleURL) else {
          print("image named \"\(gifUrl)\" into NSData")
          return nil
      }
      
      return gifImageWithData(imageData)
  }
  
  public class func gifImageWithName(_ name: String) -> UIImage? {
      guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
              print("SwiftGif: This image named \"\(name)\" does not exist")
              return nil
      }
      guard let imageData = try? Data(contentsOf: bundleURL) else {
          print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
          return nil
      }
      
      return gifImageWithData(imageData)
  }
  
  class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
      var delay = 0.1
      
      let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
      let gifProperties: CFDictionary = unsafeBitCast(
          CFDictionaryGetValue(cfProperties,
              Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
          to: CFDictionary.self)
      
      var delayObject: AnyObject = unsafeBitCast(
          CFDictionaryGetValue(gifProperties,
              Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
          to: AnyObject.self)
      if delayObject.doubleValue == 0 {
          delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
              Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
      }
      
      delay = delayObject as! Double
      
      if delay < 0.1 {
          delay = 0.1
      }
      
      return delay
  }
  
  class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
      var a = a
      var b = b
      if b == nil || a == nil {
          if b != nil {
              return b!
          } else if a != nil {
              return a!
          } else {
              return 0
          }
      }
      
      if a < b {
          let c = a
          a = b
          b = c
      }
      
      var rest: Int
      while true {
          rest = a! % b!
          
          if rest == 0 {
              return b!
          } else {
              a = b
              b = rest
          }
      }
  }
  
  class func gcdForArray(_ array: Array<Int>) -> Int {
      if array.isEmpty {
          return 1
      }
      
      var gcd = array[0]
      
      for val in array {
          gcd = UIImage.gcdForPair(val, gcd)
      }
      
      return gcd
  }
  
  class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
      let count = CGImageSourceGetCount(source)
      var images = [CGImage]()
      var delays = [Int]()
      
      for i in 0..<count {
          if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
              images.append(image)
          }
          
          let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
              source: source)
          delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
      }
      
      let duration: Int = {
          var sum = 0
          
          for val: Int in delays {
              sum += val
          }
          
          return sum
      }()
      
      let gcd = gcdForArray(delays)
      var frames = [UIImage]()
      
      var frame: UIImage
      var frameCount: Int
      for i in 0..<count {
          frame = UIImage(cgImage: images[Int(i)])
          frameCount = Int(delays[Int(i)] / gcd)
          
          for _ in 0..<frameCount {
              frames.append(frame)
          }
      }
      
      let animation = UIImage.animatedImage(with: frames,
          duration: Double(duration) / 2000.0)
      
      return animation
  }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

