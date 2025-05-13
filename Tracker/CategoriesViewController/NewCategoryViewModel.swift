//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Alesia Matusevich on 11/05/2025.
//

import Foundation

final class NewCategoryViewModel {
    var isButtonEnabled: Binding<Bool>?
    var categoryTitleIsChanged: Binding<String>?
    
    private(set) var categoryTitle: String = "" {
        didSet {
            isButtonEnabled?(!categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            categoryTitleIsChanged?(categoryTitle)
        }
    }
    
    func updateCategoryTitle(_ text: String) {
        categoryTitle = text
    }
    
    func clearCategoryTitle() {
        categoryTitle = ""
    }
}
