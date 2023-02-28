import UIKit

public enum RequestError: Error, LocalizedError {
    
    /// 请求超时
    case timeout

    /// 请求错误/参数错误
    case requestError

    /// 服务器错误
    case internalError

    /// token过期
    case tokenExpired

    /// 格式化失败
    case decodeFailure

    /// 未知错误
    case unknow

    /// 是好友
    case isFriend

    static func requestError(code: ResponseCode) throws {
       
        switch code {
        
        case .tokenExpired:
            throw RequestError.tokenExpired
        case .decodeFailure:
            throw RequestError.decodeFailure
        case .unknow:
            throw RequestError.unknow
        case .success:
            break
        case .requestError:
            throw RequestError.requestError
        case .internalError:
            throw RequestError.internalError
        case .timeout:
            throw RequestError.timeout
        case .isFriend:
            throw RequestError.isFriend
        case .friendDelete:
            throw RequestError.requestError
        case .friendError:
            throw RequestError.requestError
        }
    }

    var errorDescription: String! {
        switch self {
        case .timeout:
            return "请求超时，请稍后重试"
        case .internalError:
            return "服务器错误"
        case .decodeFailure:
            return "数据格式化失败，请稍后重试"
        case .tokenExpired:
            return "登录过期，请重新登录"
        case .unknow:
            return "未知错误"
        case .requestError:
            return "参数错误"
        case .isFriend:
            return "NO Error"
        }
    }
}
