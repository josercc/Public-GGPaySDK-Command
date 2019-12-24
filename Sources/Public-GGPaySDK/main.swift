import Commander

let versionCommand = command { (
    version:String,
    branch:String,
    sourceURL:String,
    sdkURL:String,
    reposURL:String,
    isSource:String
    ) in
    let list = branch.components(separatedBy: "/")
    var publicVersion = Public(version:version, branch:list.last!, sourceURL:sourceURL, sdkURL:sdkURL, reposURL:reposURL)
    publicVersion.isSource = isSource
    do {
        try publicVersion.publicVersion()
    } catch let error {
        print(error.localizedDescription)
    }
}
versionCommand.run()
