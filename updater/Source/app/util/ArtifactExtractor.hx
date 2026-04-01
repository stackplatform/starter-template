package app.util;

import sys.io.File;
import sys.FileSystem;
import haxe.zip.Reader;
import haxe.zip.Entry;

class ArtifactExtractor {
    public static function extractZip(zipFilePath:String, targetDir:String):Bool {
        trace('Extracting $zipFilePath to $targetDir...');
        
        try {
            if (!FileSystem.exists(targetDir)) {
                FileSystem.createDirectory(targetDir);
            }

            var fileInput = File.read(zipFilePath, true);
            var entries = Reader.readZip(fileInput);
            fileInput.close();

            for (entry in entries) {
                var fileName = entry.fileName;
                var targetPath = targetDir + "\\" + fileName;
                
                // Convert forward slashes to backslashes if Windows MVP
                targetPath = StringTools.replace(targetPath, "/", "\\");

                // If it's a directory (ends with / or \)
                if (StringTools.endsWith(fileName, "/") || StringTools.endsWith(fileName, "\\")) {
                    if (!FileSystem.exists(targetPath)) {
                        FileSystem.createDirectory(targetPath);
                    }
                } else {
                    // It's a file. Make sure parent directory exists.
                    var parentDir = haxe.io.Path.directory(targetPath);
                    if (!FileSystem.exists(parentDir)) {
                        FileSystem.createDirectory(parentDir);
                    }

                    // Extract data based on compression
                    var data = haxe.zip.Reader.unzip(entry);
                    var fileOutput = File.write(targetPath, true);
                    fileOutput.write(data);
                    fileOutput.close();
                }
            }

            trace("Extraction completed successfully.");
            return true;
        } catch (e:Dynamic) {
            trace('Exception during zip extraction: $e');
            return false;
        }
    }
}
