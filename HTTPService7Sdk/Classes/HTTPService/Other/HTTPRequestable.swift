import UIKit

/// 枚举类型
protocol HTTPRequestableEnum {
    func rawValue() -> Any
}

extension HTTPRequestableEnum where Self: RawRepresentable {
    func rawValue() -> Any {
        return rawValue
    }
}

/// 可用于网络请求参数
protocol HTTPRequestable {
    func toParams() -> [String: Any]
}

extension HTTPRequestable {
   
    func toParams() -> [String: Any] {
        return reflectingValue(value: self)
    }

    func reflectingValue(value: Any) -> [String: Any] {
       
        var params = [String: Any]()

        Mirror(reflecting: value).children.forEach { child in

            if let key = child.label {
                let mi = Mirror(reflecting: child.value)

                switch mi.displayStyle {
                case .optional:
                    // 存在值的情况
                    if mi.children.count > 0 {
                        let value = unwrap(child.value)

                        if let array = value as? [Any] {
                            // TODO: 目前只有数组，需要对集合判断
                            var arrayValues = [Any]()
                            array.forEach {
                                // 额。优化一下哈
                                if let rawEnum = $0 as? HTTPRequestableEnum {
                                    arrayValues.append(rawEnum.rawValue())
                                } else {
                                    arrayValues.append($0)
                                }
                            }
                            params[key] = arrayValues
                        } else if let rawEnum = value as? HTTPRequestableEnum {
                            params[key] = rawEnum.rawValue()
                        } else {
                            params[key] = value
                        }
                    }

                case .enum:
                    if let rawEnum = child.value as? HTTPRequestableEnum {
                        params[key] = rawEnum.rawValue()
                    }

                case .collection:
                    params[key] = reflectingValue(value: child.value)

                default:
                    params[key] = child.value
                }
            }
        }
        return params
    }

    /// 可选类型拆包
    /// - Parameter any: 值
    /// - Returns: 拆包值
    func unwrap(_ value: Any) -> Any {
        let mi = Mirror(reflecting: value)

        if mi.displayStyle != .optional {
            return value
        }

        if let (_, some) = mi.children.first {
            return some
        }

        return NSNull()
    }
}
