/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Class

internal class SurveyTableViewCell: UITableViewCell {
    
    // MARK: - Variable
    
    /// A variable to save the selected button. Every time this changes it also deselects the old button
    private var selectedButton: Int = 0 {
        
        didSet {
            
            self.disableButtonAt(index: oldValue)
        }
    }
    
    /// An array to hold reference of every button in View
    private var buttons: [UIButton] = []
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the question label
    @IBOutlet private weak var questionLabel: UILabel!
    
    /// An IBOutlet for handling the first, 1, button
    @IBOutlet private weak var firstButton: UIButton!
    /// An IBOutlet for handling the second, 2, button
    @IBOutlet private weak var secondButton: UIButton!
    /// An IBOutlet for handling the third, 3, button
    @IBOutlet private weak var thirdButton: UIButton!
    /// An IBOutlet for handling the fourth, 4, button
    @IBOutlet private weak var fourthButton: UIButton!
    /// An IBOutlet for handling the fifth, 5, button
    @IBOutlet private weak var fifthButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     A function called everytime the first button has been tapped
     
     - parameter sender: The object that called this function
     */
    @IBAction func firstButtonAction(_ sender: Any) {
        
        self.selectedButton = 1
        self.enableButtonAt(index: 1)
    }
    
    /**
     A function called everytime the second button has been tapped
     
     - parameter sender: The object that called this function
     */
    @IBAction func secondButtonAction(_ sender: Any) {
        
        self.selectedButton = 2
        self.enableButtonAt(index: 2)
    }
    
    /**
     A function called everytime the third button has been tapped
     
     - parameter sender: The object that called this function
     */
    @IBAction func thirdButtonAction(_ sender: Any) {
        
        self.selectedButton = 3
        self.enableButtonAt(index: 3)
    }
    
    /**
     A function called everytime the fourth button has been tapped
     
     - parameter sender: The object that called this function
     */
    @IBAction func fourthButtonAction(_ sender: Any) {
        
        self.selectedButton = 4
        self.enableButtonAt(index: 4)
    }
    
    /**
     A function called everytime the fifth button has been tapped
     
     - parameter sender: The object that called this function
     */
    @IBAction func fifthButtonAction(_ sender: Any) {
        
        self.selectedButton = 5
        self.enableButtonAt(index: 5)
    }
    
    // MARK: - Auto generated methods

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.buttons = [firstButton, secondButton, thirdButton, fourthButton, fifthButton]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Handle buttons
    
    /**
     Disables the button of that index
     
     - parameter index: The index of the button to disable
     */
    private func disableButtonAt(index: Int) {
        
        if index > 0 && index < 6 {

            let realIndex = index - 1
            self.buttons[realIndex].setImage(UIImage(named: Constants.ImageNames.cirle), for: .normal)
        }
    }
    
    /**
     Enables the button of that index
     
     - parameter index: The index of the button to enable
     */
    private func enableButtonAt(index: Int) {
        
        if index > 0 && index < 6 {

            let realIndex = index - 1
            DispatchQueue.main.async { [weak self] in
                
                if self != nil {
                    
                    self!.buttons[realIndex].setImage(UIImage(named: Constants.ImageNames.circleFilled), for: .normal)
                }
            }
        }
    }
    
    // MARK: - Get selected answer
    
    /**
     Returns the number of the selected button
     
     - returns: The number of the selected button
     */
    func getSelectedAnswer() -> Int {
        
        return self.selectedButton
    }
    
    // MARK: - Get question
    
    /**
     Returns the number of the selected button
     
     - returns: The number of the selected button
     */
    func getQuestion() -> String {
        
        return self.questionLabel.text!
    }
    
    // MARK: - Set question in label
    
    /**
     Shows the question in the wanted label
     
     - parameter question: The question to show in the label
     */
    func setQuestionInLabel(question: String) {
        
        self.questionLabel.text = question
    }
    
    // MARK: - Set selected answer
    
    /**
     Set's that button as selected
     
     - parameter index: The button order
     */
    func setSelectedAnswer(_ index: Int) {
        
        if index > 0 && index < 6 {
            
            self.enableButtonAt(index: index)
            self.selectedButton = index
        }
    }
    
    /**
     Set's that button as selected
     */
    func setNoAnswer() {
        
        self.disableButtonAt(index: 1)
        self.disableButtonAt(index: 2)
        self.disableButtonAt(index: 3)
        self.disableButtonAt(index: 4)
        self.disableButtonAt(index: 5)
        self.selectedButton = 0
    }

}
