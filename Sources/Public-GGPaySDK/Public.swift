//
//  Public.swift
//  
//
//  Created by 张行 on 2019/12/5.
//

import Foundation
import SwiftShell
import Mustache

struct Public {
    let version:String
    let branch:String
    let sourceURL:String
    let sdkURL:String
    let reposURL:String
    var isSource:String = "0"
    func publicVersion() throws {
        // 获取用户的路径
        guard let user = CustomContext(main).env["USER"] else {
            print("❌获取不到本机用户名")
            return
        }
        let sourcePath = "/Users/\(user)/Public-GGPaySDK"
        if !FileManager.default.fileExists(atPath: sourcePath) {
            // 路径是否存在
            try FileManager.default.createDirectory(atPath: sourcePath, withIntermediateDirectories: true, attributes: nil)
        }
        main.currentdirectory = sourcePath
        let branchPath = "\(sourcePath)/\(self.branch)"
        if !FileManager.default.fileExists(atPath: branchPath) {
            // 如果不存在 则需要Clone
            try runAndPrint("git", "clone", "\(self.sourceURL)", "\(self.branch)")
        } else {
            // 如果存在就更新
            main.currentdirectory = branchPath
            try runAndPrint("git", "reset", "--hard")
            try runAndPrint("git", "pull", "origin")
        }
        main.currentdirectory = branchPath
        try runAndPrint("git", "checkout", "\(self.branch)")
        let SDKLibPath = "\(branchPath)/GearBest/PrivatePods/PodLib/GGPaySDK"
        let developerPath = "\(SDKLibPath)/GGPaySDK-developer"
        main.currentdirectory = developerPath
        let carthagePath = "\(developerPath)/Carthage"
        if self.isSource == "0" {
            if FileManager.default.fileExists(atPath: carthagePath) {
                try FileManager.default.removeItem(atPath: carthagePath)
            }
            try runAndPrint("carthage", "build", "--no-skip-current", "--verbose")
        }
        let SDKPath = "\(sourcePath)/GGPaySDK"
        if !FileManager.default.fileExists(atPath: SDKPath) {
            main.currentdirectory = sourcePath
            try runAndPrint("git", "clone", self.sdkURL, "GGPaySDK")
        } else {
            main.currentdirectory = SDKPath
            try runAndPrint("git", "reset", "--hard")
            try runAndPrint("git", "pull", "origin")
        }
        main.currentdirectory = SDKPath
        if self.isSource == "0" {
            let sdkBuildPath = "\(carthagePath)/Build/iOS/GGPaySDK.framework"
            let frameworkPath = "\(SDKPath)/Frameworks"
            if !FileManager.default.fileExists(atPath: frameworkPath) {
                try FileManager.default.createDirectory(atPath: frameworkPath, withIntermediateDirectories: true, attributes: nil)
            }
            let copySDKPath = "\(frameworkPath)/GGPaySDK.framework"
            try moveFile(movePath: sdkBuildPath, toPath: copySDKPath)
        } else {
            let sourceFrom = "\(SDKLibPath)/GGPaySDK-developer"
            let sourceTo = "\(SDKPath)/GGPaySDK-developer"
            try moveFile(movePath: sourceFrom, toPath: sourceTo)
        }
        
        let bundlePath = "\(SDKLibPath)/GGPaySDK.bundle"
        let copyBundlePath = "\(SDKPath)/GGPaySDK.bundle"
        try moveFile(movePath: bundlePath, toPath: copyBundlePath)
        
        /** 修改版本号 */
        let infoPlistPath = "\(copyBundlePath)/InfoVersion.plist"
        guard let dic = NSDictionary(contentsOfFile: infoPlistPath) else {
            print("❌获取\(infoPlistPath)内容失败")
            return
        }
        dic.setValue(self.version, forKey: "CFBundleShortVersionString")
        dic.write(toFile: infoPlistPath, atomically: true)
        
        let podspecMovePath:String
        if self.isSource == "0" {
            podspecMovePath = "\(SDKLibPath)/GGPaySDK_Framework.podspec"
        } else {
             podspecMovePath = "\(SDKLibPath)/GGPaySDK.podspec"
        }
        let podspecToPath = "\(SDKPath)/GGPaySDK.podspec"
        try moveFile(movePath: podspecMovePath, toPath: podspecToPath)
        
        let podspecContext = try String(contentsOfFile: podspecToPath)
        let expression = try NSRegularExpression(pattern: #"spec\.version[ ]*= \"[\d\.\-\w]*\""#, options: [])
        guard let result = expression.firstMatch(in: podspecContext, options: [], range: NSRange(podspecContext.startIndex..., in: podspecContext)) else {
            print("❌Podspec解析出错")
            return
        }
        
        var resultPodSpec = podspecContext as NSString
        let versionString = "spec.version      = \"\(self.version)\""
        resultPodSpec = resultPodSpec.replacingCharacters(in: result.range, with: versionString) as NSString
        try resultPodSpec.write(toFile: podspecToPath, atomically: true, encoding: String.Encoding.utf8.rawValue)
        
        try runAndPrint("git", "add", ".")
        try runAndPrint("git", "commit", "-m", "public \(self.version)")
        try runAndPrint("git", "push", "origin", "-f")
        try runAndPrint("git", "tag", "\(self.version)")
        try runAndPrint("git", "pull", "--tag", "-f")
        try runAndPrint("git", "push", "origin", "--tag")
        

//        try runAndPrint("/usr/local/bin/pod", "repo", "push", "GGRepos", "--verbose", "--use-libraries", "--allow-warnings", "--sources=\"\(self.reposURL),https://cdn.cocoapods.org/\"")

    }
    
    func moveFile(movePath:String, toPath:String) throws {
        if FileManager.default.fileExists(atPath: toPath) {
//            try FileManager.default.removeItem(atPath: toPath)
        }
        try FileManager.default.copyItem(atPath: movePath, toPath: toPath)
    }
}
