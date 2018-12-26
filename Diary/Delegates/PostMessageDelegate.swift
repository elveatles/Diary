//
//  PostMessageDelegate.swift
//  Diary
//
//  Created by Erik Carlson on 12/26/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Delegate for a post message text view.
/// Manages placeholder text behavior.
class PostMessageDelegate: NSObject, UITextViewDelegate {
    /// The message text view that this is a delegate for.
    let messageTextView: UITextView
    /// Shows the number of characters for the text.
    let textCountLabel: UILabel
    /// The maximum number of characters allowed.
    var maxCharCount = 200
    /// Text to use as a placeholder when text view is empty.
    var placeholderText = ""
    /// Flag to check if text is placeholder or regular text.
    private(set) var usingPlaceholder = false
    
    /// Get the text count of the message view.
    /// Considers placeholder.
    var textCount: Int {
        if usingPlaceholder {
            return 0
        }
        
        return messageTextView.text.count
    }
    
    /// Get the text count of the message view without whitespace or newline characters.
    var textCountStripped: Int {
        if usingPlaceholder {
            return 0
        }
        
        let stripped = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return stripped.count
    }
    
    init(messageTextView: UITextView, textCountLabel: UILabel) {
        self.messageTextView = messageTextView
        self.textCountLabel = textCountLabel
        
        super.init()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if usingPlaceholder {
            textView.text = ""
            usingPlaceholder = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Check if the number of characters exceeds the max character count
        let nsText = textView.text as NSString
        let newText = nsText.replacingCharacters(in: range, with: text)
        return newText.count < maxCharCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateTextCount()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        usingPlaceholder = textView.text.isEmpty
        
        if textView.text.isEmpty {
            textView.text = placeholderText
        }
    }
    
    /// Update the label that shows the message text count.
    /// Should look something like 100/200.
    func updateTextCount() {
        var font = UIFont(name: "HelveticaNeue-Bold", size: 13)!
        var color = #colorLiteral(red: 0.4941176471, green: 0.6078431373, blue: 0.368627451, alpha: 1)
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedText = NSMutableAttributedString(string: "\(textCount)", attributes: attributes)
        font = UIFont(name: "HelveticaNeue", size: 13)!
        color = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        attributes = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedPart = NSAttributedString(string: "/\(maxCharCount)", attributes: attributes)
        attributedText.append(attributedPart)
        textCountLabel.attributedText = attributedText
    }
}
