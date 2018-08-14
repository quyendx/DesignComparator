//
//  UIViewControllerExtensions.swift
//  UITestKit
//
//  Created by Quyen Xuan on 8/14/18.
//  Copyright © 2018 Innovatube. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    private var windowTag: Int {
        return 9009
    }

    open var effectsWindow: UIWindow? {
        var window = UIApplication.shared.windows.first(where: { String(describing: type(of: $0)) == "UITextEffectsWindow" })
        if window == nil {
            window = UIApplication.shared.keyWindow
        }

        return window
    }

    open func showOverlayWindow() {
        guard let effectsWindow = effectsWindow else { return }

        guard effectsWindow.tag != windowTag else {
            effectsWindow.isHidden = !effectsWindow.isHidden
            return
        }

        var subWindow = effectsWindow.subviews.first(where: { $0.tag == windowTag })
        if subWindow == nil {
            let window = UIWindow(frame: effectsWindow.frame)
            window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.backgroundColor = .clear
            window.tag = windowTag

            effectsWindow.addSubview(window)
            subWindow = window

            let actionsViewController = ActionsViewController()
            window.rootViewController = actionsViewController
        }

        subWindow?.isHidden = !(subWindow?.isHidden ?? false)
    }

    open func hideOverlayWindow() {
        let subWindow = effectsWindow?.subviews.first(where: { $0.tag == windowTag })
        subWindow?.removeFromSuperview()
    }
}
