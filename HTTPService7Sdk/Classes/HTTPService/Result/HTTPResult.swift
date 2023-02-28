import HandyJSON
import Moya
import RxSwift

protocol HTTPResultCodable: HandyJSON {}
protocol HTTPResultEnumCodable: HandyJSONEnum {}

extension HTTPResultCodable {
    
    func convertModel<T: HandyJSON>() -> T? {
        guard let jsonString = toJSONString() else {
            return nil
        }

        return JSONDeserializer<T>.deserializeFrom(json: jsonString)
    }
}

enum ResponseCode: Int, HTTPResultEnumCodable {
    /// 成功
    case success = 200
    // 是好友
    case isFriend = 201
    // 对方不是好友的错误
    case friendError = 202
    case friendDelete = 203

    /// 请求错误/参数错误
    case requestError = 400
    /// token过期
    case tokenExpired = 401
    /// 服务器内部错误
    case internalError = 500
    /// 格式化失败
    case decodeFailure = 1000
    /// 超时
    case timeout = 1001
    /// 未知状态
    case unknow = -1000
}

struct ResultModel<T: HTTPResultCodable>: HTTPResultCodable {
    var status: ResponseCode?
    var code: ResponseCode?

    var message: String = ""
    var data: T?
    var result: T?

    public init() {
    }
}

struct ResultListModel<T: HTTPResultCodable>: HTTPResultCodable {
    var status: ResponseCode?
    var code: ResponseCode?

    var message: String = ""

    var data: [T]?
    var result: [T]?

    public init() {
    }
}

// List
struct ListModel<T: HTTPResultCodable>: HTTPResultCodable {
    var list = [T]()
}

struct EmptyModel: HTTPResultCodable {
}

//
// struct OriginalModel: HTTPResultCodable {
//    var code: Int = 0
//    var message: String = ""
//    var result: String?
//
//    public init() {
//
//    }
// }
