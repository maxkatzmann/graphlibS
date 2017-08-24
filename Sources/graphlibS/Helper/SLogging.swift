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
    
    
    /// Uses GNUplot to plot the passed values to a png file int the specified directory.
    ///
    /// - Note: Every x-value has to have a corresponding y-value, meaning the lengths of the x and y arrays have to be equal.
    ///
    /// - Parameters:
    ///   - x: An array containing the x-values of the data to be plotted.
    ///   - y: An array containing the corresponding y-values of the data to be plotted.
    ///   - xmin: Where the x-axis should start.
    ///   - xmax: Where the x-axis should end.
    ///   - ymin: Where the y-axis should start.
    ///   - ymax: Where the y-axis should end.
    ///   - directoryPath: The path to the directory where the file is supposed to be saved.
    ///   - fileName: The name of the file (including the ".png" suffix) where the plot should be saved.
    public static func plotValues(x: [Double],
                                  y: [Double],
                                  xmin: Double,
                                  xmax: Double,
                                  ymin: Double,
                                  ymax: Double,
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
            "set xrange [\(xmin):\(xmax)]\n" +
            "set yrange [\(ymin):\(ymax)]\n" +
            "set output \"\(fileName)\"\n" +
            "plot '-' using 1:2 with lines\n"
        for i in 0..<x.count {
            gnuplotCommand += "\(x[i]) \(y[i])\n"
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
