import Foundation
import RxSwift
import Moya
import HandyJSON

public protocol NetHTTPResultCodable: HandyJSON {}
public protocol NetHTTPResultEnumCodable: HandyJSONEnum {}

public enum NetResponseCode: Int, NetHTTPResultEnumCodable {
    /// 请求成功
    case success = 200
    /// 请求错误
    case requestParamError = 100002
    /// token过期
    case tokenExpire = 100003
    /// 服务器错误
    case service = 100001
    /// 服务器数据库错误
    case databaseError = 100005
    
    // MARK: - 好友相关
    /// 好友申请记录不存在
    case friendApplyExpire = 300000
    /// 申请记录等待审核
    case friendApplyAudit = 300001
    /// 好友申请已通过
    case friendApplyPass = 300003
    /// 好友关系不存在
    case friendDelete = 300011
    
    /// 群聊不存在
    case groupNotExist = 400001
    /// 未加入群聊
    case groupNotIn = 400002
    
    /// 格式化失败
    case decodeFailure = -1
}

public struct NetResultModel<T: NetHTTPResultCodable>: NetHTTPResultCodable {
    
    public var code: NetResponseCode = .decodeFailure
    
    public var message: String = ""
    
    public var data: T?
    
    public init() {
        
    }
}

public struct NetEmptyModel: NetHTTPResultCodable {
    public init() {
        
    }
}

extension ObservableType where Element == Response {
    func mapModel<T: NetHTTPResultCodable>(_ type: T.Type) -> Observable<T> {
        flatMap { return Observable.just($0.mapModel(T.self)) }
    }
}

extension Response {
    func mapModel<T: NetHTTPResultCodable>(_ type: T.Type) -> T {
        guard let jsonDic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
            let message = String(data: data, encoding: .utf8) ?? "服务器错误,请稍后重试"
            return JSONDeserializer<T>.deserializeFrom(dict: ["message": message, "code": "\(NetResponseCode.decodeFailure.rawValue)"])!
        }
        
        if let model = JSONDeserializer<T>.deserializeFrom(dict: jsonDic) {
            return model
        }
        var errorData = ["message": "服务器错误,请稍后重试", "code": "\(NetResponseCode.decodeFailure.rawValue)"]
        if let errorMsg = jsonDic["message"] as? String {
            errorData["message"] = errorMsg
        }
        return JSONDeserializer<T>.deserializeFrom(dict: errorData, designatedPath: nil)!
    }
}

//extension Array: HandyJSON {}
extension Array: NetHTTPResultCodable {}
