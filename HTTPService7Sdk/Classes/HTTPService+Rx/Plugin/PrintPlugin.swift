import Foundation
import Moya
import Alamofire

/// 网络请求打印插件
struct PrintPlugin {
    init() {}
}

extension PrintPlugin: PluginProtocol {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        guard let target = target as? NetTargetType else {
            return
        }
        printRequest(target: target)
        #endif
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        guard let target = target as? NetTargetType else {
            return
        }
        printResponse(result: result, target: target)
        #endif
    }
    
    private func printRequest(target: NetTargetType) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        let date = formatter.string(from: Date())
        var parameters: [String: Any]?
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        
        print("""
              ------- 🐼 开始请求 🐼 -------
              请求时间: \(date)
              请求方式: \(target.method.rawValue)
              请求地址: \(fullRequestLink(target: target))
              请求参数: \((parameters ?? [:]).isEmpty ? "无" : "\(parameters!)")
              请求头: \(target.headers ?? [:])
              ------- 🐼 开始请求 🐼 -------
              """)
    }
    
    private func printResponse(result: Result<Response, MoyaError>, target: NetTargetType) {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        let date = formatter.string(from: Date())
        
        var parameters: [String: Any]?
        
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        var success = false
        var json: String!
        
        switch result {
        
        case .success(let reponse):
            success = true
            json = String(data: reponse.data, encoding: .utf8) ?? ""
        case .failure(let error):
            switch error {
            case .underlying(let afError, _):
                switch afError.asAFError {
                case .explicitlyCancelled:
                    // 取消请求
                    print("""
                          ------- ❌ 请求取消 ❌ -------
                          请求地址: \(fullRequestLink(target: target))
                          ------- ❌ 请求取消 ❌ -------
                          """)
                    return
                default:
                    break
                }
            default:
                break
            }
            success = false
        }
        
        let resut = """
              ------- ✈️ 请求结束 ✈️ -------
              请求时间: \(date)
              请求方式: \(target.method.rawValue)
              请求地址: \(fullRequestLink(target: target))
              请求参数: \((parameters ?? [:]).isEmpty ? "无" : "\(parameters!)")
              请求头: \(target.headers ?? [:])
              是否成功: \(success ? "成功" : "失败")
              请求结果: \(json ?? "解析失败")
              ------- ✈️ 请求结束 ✈️ -------
              """
        print(resut)
        // 存Log
        LoggerManager.saveLog(content: resut)
    }
    
    private func fullRequestLink(target: NetTargetType) -> String {
        
        var parameters: [String: Any]? = nil
        
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        
        guard let parameters = parameters, !parameters.isEmpty else {
            return target.baseURL.absoluteString + target.path
        }
        
        let sortedParameters = parameters.sorted(by: { $0.key > $1.key })
        var paramString = "?"
        
        for index in sortedParameters.indices {
            paramString.append("\(sortedParameters[index].key)=\(sortedParameters[index].value)")
            if index != sortedParameters.count - 1 { paramString.append("&") }
        }
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
}
