//
//  AdvertisementDetailVC.swift
//  PlayAround
//
//  Created by haon on 2022/08/12.
//

import UIKit

extension UIStackView {
  func removeAllArrangedSubviews() {
    arrangedSubviews.forEach {
      self.removeArrangedSubview($0)
      NSLayoutConstraint.deactivate($0.constraints)
      $0.removeFromSuperview()
    }
  }
}


class AdvertisementDetailVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var imageStackView: UIStackView!
  
  var images: [Image] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initImageStackView(images: images)
  }
  
  static func viewController() -> AdvertisementDetailVC {
    let viewController = AdvertisementDetailVC.viewController(storyBoardName: "Common")
    return viewController
  }
  
  func initImageStackView(images: [Image]) {
    imageStackView.removeAllArrangedSubviews()
    
    for i in 0..<(images.count) {
      let dict = images[i]
      let data = try! Data(contentsOf: URL(string: dict.name)!)
      let uiImage = UIImage(data: data)!
      let newWidth = APP_WIDTH()
      let image = uiImage.resizeToWidth(newWidth: newWidth)
      
      let view = UIView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height))
      
      view.translatesAutoresizingMaskIntoConstraints = false
      view.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
      view.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
      
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
      imageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
      
      imageView.contentMode = .scaleToFill
      imageView.clipsToBounds = true
      imageView.image = image
      
      view.addSubview(imageView)
      
      let showButton = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      
      showButton.translatesAutoresizingMaskIntoConstraints = false
      showButton.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
      showButton.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
      
      showButton.setTitle("", for: .normal)
      showButton.tag = i + 1
      //      showButton.addTarget(self, action: #selector(self.tapDetailImage(_ :)), for: .touchUpInside)
      
      view.addSubview(showButton)
      
      self.imageStackView.addArrangedSubview(view)
    }
  }
  
}
