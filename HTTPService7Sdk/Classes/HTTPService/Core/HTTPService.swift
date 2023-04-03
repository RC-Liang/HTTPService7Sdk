import Alamofire
import HandyJSON
import Moya
import RxSwift
// import Common7Sdk

struct HTTPService {
   
    private static let disposeBag = DisposeBag()

    public static let ErrorObservable = PublishSubject<RequestError>()

    public typealias RequestSingleResult<T: HTTPResultCodable> = (Result<T, RequestError>) -> Void
    public typealias RequestListResult<T: HTTPResultCodable> = (Result<[T], RequestError>) -> Void

    public static func singleDataRequest<T: HTTPResultCodable, U: HTTPTargetType>(target: U, modelType: T.Type, _ result: @escaping RequestSingleResult<T>) {
        
        let provider = MoyaProvider<U>(endpointClosure: endPointClosure(), requestClosure: requestClosure, plugins: plugins)

        provider.rx
            .request(target)
            .asObservable()
            .mapModel(ResultModel<T>.self)
            .subscribe(onNext: { element in

                do {
                    var newElement = element
                    if newElement.code == nil {
                        newElement.code = newElement.status
                    }

                    if newElement.data == nil {
                        newElement.data = newElement.result
                    }

                    try RequestError.requestError(code: newElement.code ?? .unknow)

                    if let data = newElement.data {
                        result(.success(data))
                    } else {
                        // data返回为null的情况
                        result(.success(T()))
                    }
                } catch {
                    let requestError = error as! RequestError

                    if requestError == .tokenExpired {
                        HTTPService.tokenExpired.onNext(())
                    }

                    // TODO: 后期做为可配置

                    // 好友201 不需要提示
                    if requestError == .isFriend && (T.self == EmptyModel.self) {
                        // 返回成功
                        result(.success(T()))
                    }
//                    // 群公告 400 不需要提示  查找客服、拉取群信息
//                    else if !(requestError == .requestError && (T.self == ChatGroupInfoModel.self || T.self == GroupNoticeModel.self || T.self == SearchCustomerModel.self)) {
//                        /// 展示错误信息
//                        if target.showErrorMsg {
//                            UIKitCommon.showText(element.message)
//                        }
//                    }

                    ErrorObservable.onNext(requestError)

                    result(.failure(requestError))
                }
            }, onError: { error in

                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case let .underlying(error, _):
                        if let afError = error as? AFError {
                            switch afError {
                            case .sessionTaskFailed(URLError.timedOut):
                                // 超时
                                if target.showErrorMsg {
                                    
                                    Hud.showText("请求超时，请检查网络")
                                }
                                result(.failure(.timeout))
                            case .sessionTaskFailed(URLError.notConnectedToInternet):
                                if target.showErrorMsg {
                                    Hud.showText("无连接网络，请检查当前网络")
                                }
                                result(.failure(.timeout))
                            default:
                                // TODO: 后期做为可配置
                                /// 展示错误信息
                                if target.showErrorMsg {
                                    Hud.showText("服务器错误, 请稍后重试")
                                }
                                result(.failure(.internalError))
                            }
                        }
                    default:
                        result(.failure(.internalError))
                    }
                }
            }).disposed(by: disposeBag)
    }

    public static func listDataRequest<T: HTTPResultCodable, U: HTTPTargetType>(target: U, modelType: T.Type, _ result: @escaping RequestListResult<T>) {
        
        let provider = MoyaProvider<U>(endpointClosure: endPointClosure(), requestClosure: requestClosure, plugins: plugins)

        provider.rx.request(target)
            .asObservable()
            .mapModel(ResultListModel<T>.self)
            .subscribe(onNext: { element in

                do {
                    var newElement = element
                    if newElement.code == nil {
                        newElement.code = newElement.status
                    }

                    if newElement.data == nil {
                        newElement.data = newElement.result
                    }

                    try RequestError.requestError(code: newElement.code ?? .unknow)
                    if let data = newElement.data {
                        result(.success(data))
                    } else {
                        // data返回为null的情况
                        result(.success([T]()))
                    }
                } catch {
                    let requestError = error as! RequestError

                    if requestError == .tokenExpired {
                        HTTPService.tokenExpired.onNext(())
                    }

                    // TODO: 后期做为可配置
                    /// 展示错误信息
                    Hud.showText(element.message)
                    ErrorObservable.onNext(requestError)
                    result(.failure(.requestError))
                }
            }, onError: { error in

                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case let .underlying(error, _):
                        if let afError = error as? AFError {
                            switch afError {
                            case .sessionTaskFailed(URLError.timedOut):
                                // 超时
                                if target.showErrorMsg {
                                    Hud.showText("请求超时，请检查网络")
                                }
                                result(.failure(.timeout))
                            default:
                                // TODO: 后期做为可配置
                                /// 展示错误信息
                                if target.showErrorMsg {
                                    Hud.showText("服务器错误, 请稍后重试")
                                }
                                result(.failure(.internalError))
                            }
                        }
                    default:
                        result(.failure(.internalError))
                    }
                }

            }).disposed(by: disposeBag)
    }
}

extension HTTPService {
   
    static func endPointClosure<T: TargetType>() -> (T) -> Endpoint {
        
        return { target in
            Endpoint(
                url: target.baseURL.absoluteString + target.path,
                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
    }

    static let requestClosure = { (endPoint: Endpoint, done: MoyaProvider.RequestResultClosure) in

        do {
            var request = try endPoint.urlRequest()
            request.timeoutInterval = 15
            // 打印请求参数
            if let requestData = request.httpBody {
                debugPrint("请求地址===========" + "\(request.url!)")
                debugPrint("\(request.httpMethod ?? "")" + "发送参数" + "\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
                debugPrint(request.allHTTPHeaderFields as Any)
            } else {
                debugPrint(request.allHTTPHeaderFields as Any)
                debugPrint("请求地址===========" + "\(request.url!)" + "============\(String(describing: request.httpMethod!))")
            }
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }

    static var plugins: [PluginType] {
       
        let activityPlugin = NetworkActivityPlugin { change, target in

            if let tnTarget = target as? HTTPTargetType {
                switch change {
                case .began:
                    if tnTarget.showLoading {
                        Hud.showLoading()
                    }
                case .ended:
                    if tnTarget.showLoading {
                        Hud.hide()
                    }
                }
            }
        }
        return [activityPlugin]
    }
}

extension HTTPService {
    /// token过期监听
    public static let tokenExpired = PublishSubject<Void>()
}
