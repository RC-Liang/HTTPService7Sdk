import HandyJSON
import Moya
import RxSwift
import UIKit

extension ObservableType where Element == Response {
    
    func mapModel<T: HTTPResultCodable>(_ type: T.Type) -> Observable<T> {
        flatMap { Observable.just($0.mapModel(T.self)) }
    }
}

extension Response {
    
    func mapModel<T: HTTPResultCodable>(_ type: T.Type) -> T {
        let jsonString = String(data: data, encoding: .utf8)
        #if DEBUG
            print("==============服务器请求结果:===============\(jsonString!)")
        #endif

        if let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) {
            return model
        }

        let errorData: [String: Any] = ["message": "数据格式化失败", "code": ResponseCode.decodeFailure.rawValue]
        return JSONDeserializer<T>.deserializeFrom(dict: errorData, designatedPath: nil)!
    }
}

protocol HTTPTargetType: TargetType {
    /// 是否显示HUD
    var showLoading: Bool { get }
    var showErrorMsg: Bool { get }
}

extension HTTPTargetType {
    public var showLoading: Bool { return false }
    public var showErrorMsg: Bool { return true }
}
