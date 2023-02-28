import Foundation
import Moya

public protocol PluginProtocol: PluginType {
    
}

extension PluginProtocol {
    
    func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first { $0 is UIWindowScene }
                .flatMap { $0 as? UIWindowScene }?.windows
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    func topViewController() -> UIViewController? {
        var rootVC = keyWindow()?.rootViewController
        if let tabbbar = rootVC as? UITabBarController {
            rootVC = tabbbar.selectedViewController
        }

        while let vc = rootVC?.presentedViewController {
            if let tabbar = vc as? UITabBarController {
                rootVC = tabbar.selectedViewController
            } else {
                rootVC = vc
            }
        }

        if let navi = rootVC as? UINavigationController {
            rootVC = navi.visibleViewController
        }

        return rootVC
    }
}
