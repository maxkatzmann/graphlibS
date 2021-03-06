#!/usr/bin/env xcrun swift

import Foundation

func shell(arguments: [String]) -> String
{
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: String.Encoding.utf8)!

    return output
}

if CommandLine.arguments.count > 1 {

    let currentVersionString = shell(arguments: ["git", "describe", "--tags"]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

    print("Current Version is: \(currentVersionString)")

    var versionComponents = currentVersionString.components(separatedBy: ".")

    if let currentBuildNumberString = versionComponents.last,
       let currentBuildNumber = Int(currentBuildNumberString) {

        let newBuildNumber = currentBuildNumber + 1
        versionComponents[versionComponents.count - 1] = String(newBuildNumber)
        let newVersionString = versionComponents.joined(separator: ".")
        print("New version will be: \(newVersionString)")

        /**
         * Now we update the readme to contain a badge showing the correct version.
         */
        let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("README.md")
        let readmeContent = try String(contentsOf: path)
        var newReadme = ""
        let lines = readmeContent.components(separatedBy: "\n")
        for line in lines {
            if line.range(of: "[GitHub tag]") != nil {
                let newTagLine = "[![GitHub tag](https://img.shields.io/badge/Version-\(newVersionString)-brightgreen.svg)](https://github.com/maxkatzmann/graphlibS/releases/tag/\(newVersionString))"
                newReadme.append(newTagLine + "\n")
            } else {
                newReadme.append(line + "\n")
            }
        }

        try newReadme.write(to: path, atomically: false,
                                encoding: .utf8)

        let commitMessage = CommandLine.arguments[1]
        print("Commiting with message: \(commitMessage)")

        let _ = shell(arguments: ["git", "add", "."])

        let gitCommitResult = shell(arguments: ["git", "commit", "-m", "\(commitMessage)"])
        print("Commited: \(gitCommitResult)")

        let gitTagResult = shell(arguments: ["git", "tag", "\(newVersionString)"])
        print("Tagged: \(gitTagResult)")

        let _ = shell(arguments: ["git", "push", "origin", "master", "--tags"])

        print("Pushed.")
    }
} else {
    print("Usage: \(CommandLine.arguments[0]) \"commit message\"")
}
