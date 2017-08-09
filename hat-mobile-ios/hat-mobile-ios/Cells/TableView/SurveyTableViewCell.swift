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
    
    private var selectedButton: Int = 0 {
        
        didSet {
            
            self.disableButtonAt(index: oldValue)
        }
    }
    
    private var buttons: [UIButton] = []
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
    @IBOutlet private weak var thirdButton: UIButton!
    @IBOutlet private weak var fourthButton: UIButton!
    @IBOutlet private weak var fifthButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func firstButtonAction(_ sender: Any) {
        
        self.selectedButton = 1
        self.enableButtonAt(index: 1)
    }
    
    @IBAction func secondButtonAction(_ sender: Any) {
        
        self.selectedButton = 2
        self.enableButtonAt(index: 2)
    }
    
    @IBAction func thirdButtonAction(_ sender: Any) {
        
        self.selectedButton = 3
        self.enableButtonAt(index: 3)
    }
    
    @IBAction func fourthButtonAction(_ sender: Any) {
        
        self.selectedButton = 4
        self.enableButtonAt(index: 4)
    }
    
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
    
    private func disableButtonAt(index: Int) {
        
        if index > 0 && index < 6 {

            let realIndex = index - 1
            self.buttons[realIndex].setImage(UIImage(named: Constants.ImageNames.cirle), for: .normal)
        }
    }
    
    private func enableButtonAt(index: Int) {
        
        if index > 0 && index < 6 {

            let realIndex = index - 1
            self.buttons[realIndex].setImage(UIImage(named: Constants.ImageNames.circleFilled), for: .normal)
        }
    }
    
    func getSelectedAnswer() -> Int {
        
        return self.selectedButton
    }
    
    func setQuestionInLabel(question: String) {
        
        self.questionLabel.text = question
    }
    
    func setSelectedAnswer(_ index: Int) {
        
        if index > 0 && index < 6 {
            
            self.enableButtonAt(index: index)
            self.selectedButton = index
        }
    }

}
