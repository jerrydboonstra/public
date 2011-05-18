includeTargets << new File("${batchLauncherPluginDir}/scripts/_BatchWar.groovy")
includeTargets << grailsScript("_GrailsSettings")    // this must be 2nd to not override scriptEnv

target(default: "Creates a Grails batch application as a single zip artifact") {
    depends(_batchWar)
    
    def appNameAndVersion = "${grailsAppName}-${grailsAppVersion}"
    def baseDir = "target"
    def dirToZipName = "${baseDir}/${appNameAndVersion}"
    def zipfile = "${appNameAndVersion}.zip"
    def destfile = "${baseDir}/${zipfile}"
    
    def startupScriptSource = "${grailsAppName}.sh"
    def startupScriptTarget = "${dirToZipName}/${startupScriptSource}"
    
    def dirToZip = new File(dirToZipName)
    if (!dirToZip.exists()) {
        def message = "Directory ${dirToZip.absolutePath} does not exist. Exiting."
        System.out.println(message)
        System.exit(1)
    }
    if (!dirToZip.canRead()) {
        def message = "Directory ${dirToZip.absolutePath} cannot be read. Exiting."
        System.out.println(message)
        System.exit(2)
    }
    
    def ant = new AntBuilder()
    ant.sequential {
		ant.copy(file:startupScriptSource, tofile:startupScriptTarget)
        ant.zip(basedir:dirToZip, destfile:destfile)
    }
}
