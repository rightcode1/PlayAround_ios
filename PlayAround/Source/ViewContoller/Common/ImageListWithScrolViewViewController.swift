//
//  ImageListWithScrolViewViewController.swift
//  damda
//
//  Created by hoonKim on 2021/03/24.
//

import UIKit

class ImageListWithScrolViewViewController: UIViewController {
  open override var shouldAutorotate: Bool {
    return true
  }
  
  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .all
  }
  
  @IBOutlet var infoView1: UIView!
  @IBOutlet var infoView2: UIView!
  @IBOutlet var closeButton: UIButton!
  @IBOutlet var imageCountLabel: UILabel!
  
  var imageList: [UIImage] = []
  
  var indexRow: Int?
  
  var infoViewisHidden: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initImageList()
    
  }
  
  @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
    if infoViewisHidden {
      infoViewisHidden = false
      infoView1.isHidden = infoViewisHidden
      infoView2.isHidden = infoViewisHidden
      
    } else {
      infoViewisHidden = true
      infoView1.isHidden = infoViewisHidden
      infoView2.isHidden = infoViewisHidden
  
    }
  }
  
  func initImageList() {
    let viewHeight: CGFloat = self.view.frame.size.height
    let viewWidth: CGFloat = self.view.frame.size.width
    
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
    scrollView.isPagingEnabled = true
    scrollView.delegate = self
    var xPostion: CGFloat = 0
    
    for image in imageList {
      let view = UIView(frame: CGRect(x: xPostion, y: 0, width: viewWidth, height: viewHeight))
      xPostion += viewWidth
      let imageView = ImageViewZoom(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
      
      imageView.setup()
      imageView.imageScrollViewDelegate = self
      imageView.imageContentMode = .aspectFit
      imageView.initialOffset = .center
      imageView.display(image: image)
      
      view.addSubview(imageView)
      
      scrollView.addSubview(view)
    }
    
    scrollView.contentSize = CGSize(width: xPostion, height: viewHeight)
    
    self.view.addSubview(scrollView)
    self.view.bringSubviewToFront(infoView1)
    self.view.bringSubviewToFront(infoView2)
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    scrollView.addGestureRecognizer(tap)
    imageCountLabel.text = "  \(indexRow == nil ? 1 : ((indexRow ?? 0) + 1) )/\(imageList.count)  "
    scrollView.setContentOffset(CGPoint(x: (viewWidth * CGFloat(indexRow ?? 0)), y: 0), animated: false)
    
  }
  
  
}
extension ImageListWithScrolViewViewController: ImageViewZoomDelegate {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
      let page = Int(targetContentOffset.pointee.x / (self.view.frame.width))
      print("page: \(page)")
      self.imageCountLabel.text = "  \(page + 1)/\(imageList.count)  "
  }
  
  func imageScrollViewDidChangeOrientation(imageViewZoom: ImageViewZoom) {
    print("Did change orientation")
  }
  
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    print("scrollViewDidEndZooming at scale \(scale)")
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
  }
}

