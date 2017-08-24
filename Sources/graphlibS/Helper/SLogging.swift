//
//  SLogging.swift
//  graphS
//
//  Created by Maximilian Katzmann on 22.08.17.
//  Copyright © 2017 Maximilian Katzmann. All rights reserved.
//

import Foundation

public class SLogging {
    
    /**
     *  Logging messages
     */
    public static func error(message: String) {
        print("[ERROR]: " + message)
    }
    
    public static func info(message: String) {
        print("[Info]: " + message)
    }
    
    public static func debug(message: String) {
        print("[DEBUG]: " + message)
    }
    
    /**
     *  Logging time
     */
    
    /// Performs the passed task and return the number of seconds it took to
    /// finish it.
    ///
    /// - Parameter task: The task whos time should be measured.
    /// - Returns: The duration of the time the task took to finish.
    public static func measureTimeForTask(task: () -> Void) -> Double {
        let startTime = DispatchTime.now()
        task()
        let endTime = DispatchTime.now()
        return Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
    }
    
    public static func plotValues(x: [Double],
                           y: [Double],
                           toDirectory directoryPath: String,
                           withFileName fileName: String) {
        guard x.count == y.count else {
            SLogging.error(message: "Could not plot the passed values as the number of x values and y values did not match.")
            return
        }
        /**
         *  Putting together the gnuplot command used to generate the plot.
         */
        var gnuplotCommand = "set term png\n" +
            "set output \"\(fileName)\"\n" +
            "plot '-' using 1:2 with lines\n"
        for i in 0..<x.count {
            gnuplotCommand += "\(y[i]) \(x[i])\n"
        }
        gnuplotCommand += "e\n" +
            "q\n"
        
        /**
         *  Executing the plot command.
         */
        let task = Process()
        task.launchPath = "/usr/local/bin/gnuplot"
        task.currentDirectoryPath = directoryPath
        
        let pipeIn = Pipe()
        task.standardInput = pipeIn
        task.launch()
        
        pipeIn.fileHandleForWriting.write(gnuplotCommand.data(using: String.Encoding.utf8)!)
    }
    
}
