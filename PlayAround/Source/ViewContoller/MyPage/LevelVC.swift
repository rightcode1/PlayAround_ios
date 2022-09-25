//
//  levelVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/09/25.
//

import Foundation
import UIKit

class LevelVC:BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var levelImageView: UIImageView!
  
  static func viewController() -> LevelVC {
    let viewController = LevelVC.viewController(storyBoardName: "MyPage")
    return viewController
  }
  override func viewDidLoad() {
    levelImageView.image = UIImage(named: "level")?.aspectFitImage(inRect: levelImageView.frame)
    levelImageView.contentMode = .top
  }
  
  
}
extension UIImage {
    func aspectFitImage(inRect rect: CGRect) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        let aspectWidth = rect.width / width
        let aspectHeight = rect.height / height
        let scaleFactor = aspectWidth > aspectHeight ? rect.size.height / height : rect.size.width / width

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width * scaleFactor, height: height * scaleFactor), false, 0.0)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: width * scaleFactor, height: height * scaleFactor))

        defer {
            UIGraphicsEndImageContext()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
