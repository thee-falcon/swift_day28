//
//  ViewController.swift
//  Project5
//
//  Created by Omar Makran on 3/24/24.
//  Copyright © 2024 Omar Makran. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // to hold all the words in the input file.
    var allWords = [String]()
    // will hold all the words the player.
    var useWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        /*
         => Bundle.main: Accesses the main bundle of the application,
                      which contains all the resources bundled with the app.
         
         => try?: This is a Swift error-handling mechanism. It tries to perform an operation that might throw an error.
                If an error is thrown, try? returns nil; otherwise, it returns the result of the operation.
         */

        // for searching of the filw 'start.txt' in the Bundle.
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            // Tries to read the entire content of the file at startWordsURL and creates a String from it.
            if let startWord = try? String(contentsOf: startWordsURL) {
                // splits the string into an array of substrings using the newline.
                allWords = startWord.components(separatedBy: "\n")
            }
        }

        // for protection.
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }

    func startGame() {
        title = allWords.randomElement()
        useWords.removeAll(keepingCapacity: true)
        // telling the table view to refresh its data and update its display.
        tableView.reloadData()
    }
    
    // returns an Int. It specifies the number of rows in a given section of the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useWords.count
    }
    
    // to fill each row in a UITableView with a configured cell containing the appropriate data from an array (useWords in this case).
    /* cellForRowAt: method will configure each card (cell) with a word name from the useWords array. */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // as pre-made cards or templates designed to fit into each row of the UITableView.
        /*
         As you scroll down, the top-most cell scrolls off the screen.
         Instead of destroying this cell, the system keeps it in a pool of reusable cells.
         When a new row comes into view at the bottom, the system dequeues one of the previously used cells from the pool, reconfigures it with new data, and displays it as the new bottom row.
         */
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        /* is responsible for setting the text of the textLabel property of the dequeued cell based on the data from the useWords array. */
        cell.textLabel?.text = useWords[indexPath.row]
        
        // returns the configured cell to be displayed.
        return cell
    }
    
    @objc func  promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)

        // allowing the user to input text to the allert controller, we make it default.
        ac.addTextField()
        
        // we use weak on self and ac, because both the allert controller, and the view controller are Reference inside our closure.
        // UIAlertAction: An action that can be taken when the user taps a button in an alert.
        /*
         weak self: Creates a weak reference to the current view controller instance (self).
         weak ac: Creates a weak reference to the UIAlertController instance (ac).
         */
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            // here we can try and read it out in index[0], it's the first text field in our allert controller text.
            // guard let answer = ac?.textFields?[0].text else { return }: Safely unwraps the text entered in the text field of the alert.
            // Using ac? checks if the UIAlertController still exists (is not deallocated).
            guard let answer = ac?.textFields?[0].text else { return }

            // Calls the submit(_:) method of the current view controller instance (self) with the entered answer.
            // Using self? ensures that self (the view controller) might be deallocated at the time this closure is executed, preventing a potential crash.
            self?.submit(answer)
        }
        // adds action to the allert controller.
        ac.addAction(submitAction)
        present(ac, animated:  true)
    }
    
    func submit(_ answer: String) {
        // lowercased the answer.
        let lowAnswer = answer.lowercased()
        
        // checks the answers before insert in the row.
        if isPossible(word: lowAnswer) {
            if isOriginal(word: lowAnswer) {
                if isReal(word: lowAnswer) {
                    useWords.insert(answer, at: 0)
                    
                    // the answer will be the first one.
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !useWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missplledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missplledRange.location == NSNotFound
    }

}

