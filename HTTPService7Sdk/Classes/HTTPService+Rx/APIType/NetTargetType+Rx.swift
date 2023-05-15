import Foundation
import Moya
import RxSwift
import Alamofire

public extension NetTargetType {
   
    /// 网络请求，next中一定是请求成功的数据。如果请求失败则会发出error信息
    /// - Parameters:
    /// - type: 需要转换的类型
    /// - cancel: 取消请求
    /// - Returns: 请求结果
    func request<T: NetHTTPResultCodable>(type: T.Type, cancel: Observable<Void>? = nil) -> Observable<T> {
        let result = PublishSubject<T>()
        
        // 请求
        let provider = MoyaProvider<Self>(endpointClosure: endPointClosure, requestClosure: requestClosure, plugins: getPlugins())
        var request = provider.rx
            .request(self)
            .asObservable()
            .mapModel(NetResultModel<T>.self)
        if let cancel = cancel {
            request = request.take(until: cancel)
        }
        _ = request.subscribe { element in
                do {
                    try NetRequestError.requestError(code: element.code)
                    if let data = element.data {
                        result.onNext(data)
                    }else {
                        // data返回为null的情况, 同样是成功
                        result.onNext(T())
                    }
                }catch {
                    result.onError(error)
                    // token过期
                    if let customError = error as? NetRequestError, customError == .tokenExpired {
                        NetHTTPService.tokenExpired.onNext(())
                    }
                }
            } onError: { error in
                result.onError(error)
            } onCompleted: {
                result.onCompleted()
            }
        return result
    }
    
    /// 自定义请求类型。注意：需要自己处理所有的情况，包括token过期的情况
    /// - Parameters:
    /// - type: 自定义请求
    /// - cancel: 取消请求
    /// - Returns: 请求结果
    func customType<T: NetHTTPResultCodable>(type: T.Type, cancel: Observable<Void>? = nil) -> Observable<T> {
        let result = PublishSubject<T>()
        let provider = MoyaProvider<Self>(endpointClosure: endPointClosure, requestClosure: requestClosure, plugins: getPlugins())
        var request = provider.rx
            .request(self)
            .asObservable()
            .mapModel(T.self)
        if let cancel = cancel {
            request = request.take(until: cancel)
        }
        _ = request.subscribe { element in
                result.onNext(element)
            } onError: { error in
                result.onError(error)
            } onCompleted: {
                result.onCompleted()
            }
        return result
    }
    
    /// 当我们只需要知道接口请求成功，不关心Reponse时，可调用此方法
    /// - Returns: 请求结果
    func emptyRequest(cancel: Observable<Void>? = nil) -> Observable<Void> {
        request(type: NetEmptyModel.self, cancel: cancel).map { _ in return () }
    }
}

extension NetTargetType {
    /// 获取插件
    /// - Returns: 插件组
    func getPlugins() -> [PluginProtocol] {
        var plugins = plugins ?? [PluginProtocol]()
        // 添加debug打印插件
        plugins.append(PrintPlugin())
        
        return plugins
    }
}
