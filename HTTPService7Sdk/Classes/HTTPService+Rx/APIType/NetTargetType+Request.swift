import Foundation
import Moya

extension NetTargetType {
    var endPointClosure: (Self) -> Endpoint {
        return { `self` in
            Endpoint(
                url: baseURL.absoluteString + path,
                sampleResponseClosure: { .networkResponse(200, sampleData) },
                method: method,
                task: task,
                httpHeaderFields: headers
            )
        }
    }
    
    var requestClosure: (Endpoint, (Result<URLRequest, MoyaError>) -> Void) -> () {
        return { (endPoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
                var request = try endPoint.urlRequest()
                request.cachePolicy = .reloadIgnoringLocalCacheData
                request.timeoutInterval = timeout
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }
    }
}
