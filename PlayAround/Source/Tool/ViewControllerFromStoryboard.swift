//
//  ViewControllerFromStoryboard.swift
//  coffit
//
//  Created by Picturesque on 2022/01/08.
//

import Foundation
import UIKit

protocol ViewControllerFromStoryboard {}

//자기 자신을 생성한다. Self = UIViewController type.
extension ViewControllerFromStoryboard where Self: UIViewController {
    
    static func viewController(storyBoardName: String) -> Self {
        guard let viewController = UIStoryboard(name: storyBoardName, bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: Self.self)) as? Self //Self.self = 해당 클래스네임이 스트링으로 들어감.
            else { return Self() }
        return viewController
    }
}
