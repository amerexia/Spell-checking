//
//  ContentView.swift
//  SpellChecking
//
//  Created by Dounia Belannab on 09/12/2022.
//

import SwiftUI
import Dispatch
import AppKit

struct ContentView: View {
    // Create a DispatchSource for monitoring the directory where the text files are stored
    let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: 0,
                                                           eventMask: .write,
                                                           queue: DispatchQueue.main)
    
    // Create a state variable to store the selected file
    @State var selectedFile: URL?
    
    // Create a state variable to store the spelling errors
    @State var spellingErrors: [String] = []
    
    // Create a state variable to store the spell-checking progress
    @State var spellCheckingProgress = 0.0
    
    var body: some View {
        VStack {
            // Display a button that allows the user to select a file
            Button("Select File") {
                self.selectedFile = self.chooseFile()
            }
            
            // If a file is selected, display its name
            if let file = selectedFile {
                Text("Selected File: \(file.lastPathComponent)")
            }
            
            // If the spell-checking is in progress, display a progress indicator
            progressViewIfNeeded()
            
            // If the spell-checking is complete, display the spelling errors
            
            listOfErrorsIfFound()
            // Configure the DispatchSource to run the spell-checking program on the selected file when it is modified
            source.setEventHandler {
                self.runSpellChecker(on: self.selectedFile)
            }
            source.resume()
        }
    }
    
    @ViewBuilder
    func progressViewIfNeeded() -> some View {
        if spellCheckingProgress > 0 && spellCheckingProgress < 1 {
            ProgressView("Spell Checking...", value: spellCheckingProgress)
        }
    }
    
    @ViewBuilder
    func listOfErrorsIfFound() -> some View {
        if !spellingErrors.isEmpty {
            Text("Spelling Errors:")
            List {
                ForEach(spellingErrors, id: \.self) { error in
                    Text(error)
                }
            }
        }
    }
    
    // Prompts the user to select a file and returns the selected file's URL
    func chooseFile() -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }
    
    // Runs the spell-checking program on the specified file
    // Runs the spell-checking program on the specified file using the 'swift-spell' library
    func runSpellChecker(on file: URL?) {
        guard let filePath = file?.absoluteString else { return }
        let errors = checkWords(in: filePath)
        spellingErrors = errors
    }
    
    func checkWords(in firstFile: String) -> [String] {
        do {
            // Read the contents of the first file
            let firstText = try String(contentsOfFile: firstFile)
            
            // Read the contents of the second file
            let secondText = try String(contentsOfFile: "Resources/Words.txt")
            
            // Split the text of the first file into words
            let firstWords = firstText.split(separator: " ")
            
            // Split the text of the second file into words
            let secondWords = secondText.split(separator: " ")
            
            // Initialize an array to store the words that do not exist in the second file
            var missingWords: [String] = []
            
            // Iterate over the words in the first file and check if they exist in the second file
            for word in firstWords {
                if !secondWords.contains(word) {
                    // If the word does not exist in the second file, add it to the missingWords array
                    missingWords.append(String(word))
                }
            }
            
            // Return the missing words
            return missingWords
        } catch {
            // If there was an error reading the files, return an empty array
            return []
        }
    }
    
}
