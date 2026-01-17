//
//  UIApplication+SafeArea.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 17/01/26.
//

import UIKit

extension UIApplication {
    var safeAreaTop: CGFloat {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .safeAreaInsets.top ?? 0
    }
}
