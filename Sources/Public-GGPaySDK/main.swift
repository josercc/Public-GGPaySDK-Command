import Commander

let versionCommand = command { (version:String, branch:String, sourceURL:String, sdkURL:String, reposURL:String) in
    let list = branch.components(separatedBy: "/")
    let publicVersion = Public(version:version, branch:list.last!, sourceURL:sourceURL, sdkURL:sdkURL, reposURL:reposURL)
    do {
        try publicVersion.publicVersion()
    } catch let error {
        print(error.localizedDescription)
    }
}
versionCommand.run()
