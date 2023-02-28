import Foundation

public enum NetRequestError: Error, LocalizedError {
    ///请求超时
    case timeout
    
    /// token过期
    case tokenExpired
    /// 请求错误
    case requestParamError
    /// 服务器错误
    case serviceError
    
    /// 格式化失败
    case decodeFailure
    /// 服务器数据库错误
    case databaseError

    /// 群聊不存在
    case groupNotExist
    /// 未加入群聊
    case groupNotIn
    
    case friendApplyExpire
    /// 申请记录等待审核
    case friendApplyAudit
    /// 好友申请已通过
    case friendApplyPass
    /// 好友关系不存在
    case friendDelete
    
    
    static func requestError(code: NetResponseCode) throws -> Void {
        switch code {
        case .success:
            break
        case .tokenExpire:
            throw NetRequestError.tokenExpired
        case .service:
            throw NetRequestError.serviceError
        case .decodeFailure:
            throw NetRequestError.decodeFailure
        case .databaseError:
            throw NetRequestError.databaseError
        case .friendApplyExpire:
            throw NetRequestError.friendApplyExpire
        case .friendApplyAudit:
            throw NetRequestError.friendApplyAudit
        case .friendApplyPass:
            throw NetRequestError.friendApplyPass
        case .friendDelete:
            throw NetRequestError.friendDelete
        case .requestParamError:
            throw NetRequestError.requestParamError
        case .groupNotExist:
            throw NetRequestError.groupNotExist
        case .groupNotIn:
            throw NetRequestError.groupNotIn
        }
    }
    
    var errorDescription: String! {
        switch self {
        case .timeout:
            return "请求超时，请稍后重试"
        case .serviceError:
            return "服务器错误"
        case .decodeFailure:
            return "数据格式化失败"
        case .tokenExpired:
            return "登录过期，请重新登录"
        default:
            return "请求错误"
        }
    }
}
