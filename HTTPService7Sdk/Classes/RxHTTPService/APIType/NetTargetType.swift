import Foundation
import RxSwift
import Moya

public enum NetHTTPMethod {
    case get, post, put, delete
}

public protocol NetTargetType: TargetType {
    /// api地址
    var host: String { get }
    /// 请求路径
    var path: String { get }
    /// 请求方法
    var method: NetHTTPMethod { get }
    /// 请求参数
    var params: [String: Any]? { get }
    /// header
    var headers: [String: String]? { get }
    /// 超时时间, 默认15秒
    var timeout: TimeInterval { get }
    /// 自定义插件
    /// 目前框架已有封装完成的
    /// NetLoadingPlugin: 网络请求指示器
    /// NetErrorToastPlugin: 请求失败错误展示
    var plugins: [PluginProtocol]? { get }
}

// MARk: 默认实现
public extension NetTargetType {
    var baseURL: URL {
        return URL(string: host) ?? URL(string: "http://s.qoe.com/")!
    }
    var method: Moya.Method {
        switch method {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var task: Task {
        let params = params ?? [:]
        if method == .get {
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
        
        return .requestParameters(parameters: params, encoding: JSONEncoding.default)
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var plugins: [PluginProtocol]? {
        return nil
    }
    
    var timeout: TimeInterval {
        return 15
    }
}
