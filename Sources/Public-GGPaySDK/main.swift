import Commander

let versionCommand = command { (version:String, branch:String, sourceURL:String, sdkURL:String, reposURL:String) in
    let publicVersion = Public(version:version, branch:branch, sourceURL:sourceURL, sdkURL:sdkURL, reposURL:reposURL)
    do {
        try publicVersion.publicVersion()
    } catch let error {
        print(error.localizedDescription)
    }
}
versionCommand.run()
