import Foundation
import HandyJSON
import MBProgressHUD
import Moya

public struct NetErrorToastPlugin {
    
    /// 初始化方法
    /// - Parameters:
    ///   - message: 自定义错误提示，优先展示自定义信息
    ///   - inWindow: 是否展示到window上，否则展示在当前ViewController
    public init(message: String? = nil, inWindow: Bool = false) {
        self.message = message
        self.inWindow = inWindow
    }

    private var message: String?
    private var inWindow: Bool = false
}

extension NetErrorToastPlugin: PluginProtocol {
   
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
       
        if let message = message, case .failure = result {
            showError(message: message, inWindow: inWindow)
            return
        }

        var errorMessage = "服务器错误，请稍后重试"

        switch result {
            
        case let .success(response):

            if let model = JSONDeserializer<NetResultModel<NetEmptyModel>>.deserializeFrom(json: String(data: response.data, encoding: .utf8)) {
                do {
                    try NetRequestError.requestError(code: model.code)
                    return
                } catch {
                    if model.message.isEmpty {
                        if let customError = error as? NetRequestError {
                            errorMessage = customError.errorDescription
                        }
                    } else {
                        errorMessage = model.message
                    }
                }
            } else {
                errorMessage = String(data: response.data, encoding: .utf8) ?? "未知错误"
            }
            
        case let .failure(error):
           
            if case let .underlying(underlyError, _) = error, let afError = underlyError.asAFError {
              
                switch afError {
                
                case let .sessionTaskFailed(taskError):
                    if let taskError = taskError as? URLError {
                        switch taskError {
                        case URLError.Code.timedOut:
                            errorMessage = "请求超时"
                        case URLError.Code.notConnectedToInternet:
                            errorMessage = "无法连接到网络, 请检查当前网络状态"
                        default: break
                        }
                    }
                case .explicitlyCancelled:
                    // 请求取消
                    return
                default:
                    break
                }
            }
        }

        showError(message: errorMessage, inWindow: inWindow)
    }
}

extension NetErrorToastPlugin {
    
    func showError(message: String? = nil, inWindow: Bool = false) {
        
        DispatchQueue.main.async {
            guard let container = inWindow ? keyWindow() : topViewController()?.view else {
                return
            }

            if let _ = MBProgressHUD.forView(container) {
                return
            }

            let indicator = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
            indicator.color = .white

            let hud = MBProgressHUD.showAdded(to: container, animated: true)
            hud.mode = .text
            hud.animationType = .zoom
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.layer.cornerRadius = 16
            hud.bezelView.style = .solidColor
            hud.bezelView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            hud.detailsLabel.text = message
            hud.detailsLabel.numberOfLines = 0
            hud.detailsLabel.textColor = .white
            // 2秒后隐藏
            hud.hide(animated: true, afterDelay: 2)
        }
    }
}
