import Foundation
import Moya
import MBProgressHUD

/// 指示器插件
public class NetLoadingPlugin {
    /// 初始化方法
    /// - Parameters:
    ///   - text: 文本内容
    ///   - inWindow: 是否展示到window上，否则展示在当前ViewController
    public init(text: String? = nil, inWindow: Bool = false) {
        self.text = text
        self.inWindow = inWindow
    }
    
    private var text: String?
    private var inWindow: Bool = false
    private var hud: MBProgressHUD!
}

extension NetLoadingPlugin: PluginProtocol {
    public func willSend(_ request: RequestType, target: TargetType) {
        showLoading(text: text, inWindow: inWindow)
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        hideLoading()
    }
}

extension NetLoadingPlugin {
    func showLoading(text: String? = nil, inWindow: Bool = false) {
        DispatchQueue.main.async {
            guard let container = inWindow ? self.keyWindow() : self.topViewController()?.view else {
                return
            }
            
            if let _ = MBProgressHUD.forView(container) {
                return
            }
            
            let indicator = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
            indicator.color = .white
            
            self.hud = MBProgressHUD.showAdded(to: container, animated: true)
            self.hud.mode = MBProgressHUDMode.indeterminate
            self.hud.animationType = .zoom
            self.hud.removeFromSuperViewOnHide = true
            self.hud.bezelView.layer.cornerRadius = 14
            self.hud.bezelView.style = .solidColor
            self.hud.bezelView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            self.hud.detailsLabel.text = text
            self.hud.detailsLabel.numberOfLines = 0
            self.hud.detailsLabel.textColor = .white
        }
    }
    
    func hideLoading() {
        if self.hud == nil {
            return
        }
        DispatchQueue.main.async {
            self.hud.hide(animated: true)
        }
    }
}
