import UIKit
import MBProgressHUD

struct Hud {
    
    public typealias Completion = (() -> Void)?
    
    /// 获取  keyWindow
    
    public static func keyWindow() -> UIWindow? {
       
        let windows = UIApplication.shared.windows
        
        if windows.count == 1 { return windows.first }
        
        for window in UIApplication.shared.windows {
            if window.windowLevel == UIWindow.Level.normal {
                return window
            }
        }
        return nil
    }
    
    public static func showText(_ text: String, completion: Completion = nil) {
        DispatchQueue.main.async {
            self.showText(text, time: 2, completion: completion)
        }
    }
    
    public static func showText(_ text: String, time: Double, completion: Completion = nil) {
       
        DispatchQueue.main.async {
            guard let containerView = keyWindow() else {
                return
            }
            
            let hud = MBProgressHUD.showAdded(to: containerView, animated: true)
            hud.label.text = text
            hud.label.numberOfLines = 0
            hud.mode = .text
            hud.contentColor = .white
            hud.bezelView.style = .solidColor
            hud.bezelView.layer.cornerRadius = 20
            hud.bezelView.layer.masksToBounds = true
            hud.bezelView.backgroundColor = #colorLiteral(red: 0.2605186105, green: 0.2605186105, blue: 0.2605186105, alpha: 1)
            hud.removeFromSuperViewOnHide = true
            hud.show(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                hud.hide(animated: true)
                completion?()
            }
        }
    }
    
    public static func hide() {
        
        DispatchQueue.main.async {
            guard let containerView = keyWindow() else {
                return
            }
            
            MBProgressHUD.hide(for: containerView, animated: true)
        }
    }
    
    public static func showLoading(text: String? = nil, inWindow: Bool = false) {
        DispatchQueue.main.async {
            guard let container = self.keyWindow() else {
                return
            }
            
            if let _ = MBProgressHUD.forView(container) {
                return
            }
            
            let indicator = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
            indicator.color = .white
            
            let hud = MBProgressHUD.showAdded(to: container, animated: true)
            hud.mode = MBProgressHUDMode.indeterminate
            hud.animationType = .zoom
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.layer.cornerRadius = 14
            hud.bezelView.style = .solidColor
            hud.bezelView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            hud.detailsLabel.text = text
            hud.detailsLabel.numberOfLines = 0
            hud.detailsLabel.textColor = .white
        }
    }

}

