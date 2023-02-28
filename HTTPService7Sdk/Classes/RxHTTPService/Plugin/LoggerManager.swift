import Foundation
import SSZipArchive

public struct LoggerManager {
    
    /// 登录ID
    static var loginUID: Int!
    
    public static func setup(loginUID: Int) {
        LoggerManager.loginUID = loginUID
    }
    
    /// 每隔一小时分文件夹存储
    /// - Parameter homePath: 主目录
    /// - Parameter content: 内容
    public static func saveLog(content: String) {
        DispatchQueue.global().async {
            // 按天存储文件夹
            let dayFolderPath = NSDate().timeIntervalSince1970.formatDate("yyyy-MM-dd")
            // 按小时存储文件
            let hourTxtName = NSDate().timeIntervalSince1970.formatDate("yyyy-MM-dd===HH")
            
            // 当前时间
            let currentDate = NSDate().timeIntervalSince1970.formatDate("yyyy-MM-dd HH:mm:ss")
            
            guard let txtPath = getLogPath(paths: "\(Self.loginUID ?? -100)", dayFolderPath, txtName: hourTxtName),
                let textData = "[Time]\(currentDate)--[Content]\(content)\n".data(using: .utf8) else {
                return
            }
            
            //写日志
            let fileHandle = FileHandle(forUpdatingAtPath: txtPath)
            fileHandle?.seekToEndOfFile()
            fileHandle?.write(textData)
            fileHandle?.closeFile()
        }
    }
    
    public static func archiveLogs() -> String? {
        guard let weekZipPaths = archiveWeekLogs(loginUID),
              let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first else {
            return nil
        }
        let updateDate = NSDate().timeIntervalSince1970.formatDate("yyyy-MM-dd HH:mm:ss")
        let logZipPath = "\(documentDir)/\(updateDate).zip"
        
        // 结果
        if SSZipArchive.createZipFile(atPath: logZipPath, withFilesAtPaths: weekZipPaths) {
            return logZipPath
        }else {
            return nil
        }
    }
}

extension LoggerManager {
    static func getLogPath(paths: String..., txtName: String) -> String? {
        guard let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first else {
            return nil
        }
        
        var folderPath = "\(documentDir)"
        
        for path in paths {
            folderPath += "/\(path)"
            // 文件夹不存在则创建
            if !FileManager.default.fileExists(atPath: folderPath) {
                do {
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
                }catch {
                    return nil
                }
            }
        }
        
        let txtPath = folderPath + "/\(txtName).txt"
        
        //文件不存在存在
        if !FileManager.default.fileExists(atPath: txtPath) {
            do {
                try "日志记录创建\n".write(toFile: txtPath, atomically: true, encoding: .utf8)
            }catch {
                return nil
            }
        }
        return txtPath
    }
    
    /// 压缩一周的日志
    /// - Parameter uuidPath: 唯一地址
    /// - Returns: 路径
    static func archiveWeekLogs(_ loginUID: Int) -> [String]? {
        guard let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first else {
            return nil
        }
        
        var logsZipPaths = [String]()
        
        // 时间
        let daySeconds = 60 * 60 * 24
        let currentTime = Date().timeIntervalSince1970
        
        for day in 0..<7 {
            let dayTime: TimeInterval = currentTime - Double(daySeconds * day)
            let dayFolderPath = dayTime.formatDate("yyyy-MM-dd")
            
            let path = "\(documentDir)/\(loginUID)/\(dayFolderPath)"
            let zipPath = "\(path).zip"

            // 先对文件夹压缩
            if SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: path) {
                logsZipPaths.append(zipPath)
            }
        }
        
        return logsZipPaths
    }
}

extension TimeInterval {
    /// 时间转字符串
    /// - Parameter format: 格式化
    /// - Returns: 结果
    func formatDate(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: self))
    }
}
