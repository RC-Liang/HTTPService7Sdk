import Foundation
import RxSwift

public struct NetHTTPService {
    /// token过期监听
    public static let tokenExpired = PublishSubject<Void>()
}
