//
//  DetailsViewController.swift
//  Notes
//
//  Created by user149331 on 5/11/19.
//  Copyright © 2019 Ostap. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    private var row: Int!
    
    private var backViewController: NotesListViewController {
        return self.backViewController() as! NotesListViewController
    }
    
    private var currrentNote: Note {
        if backViewController.isFiltering {
            return backViewController.filteredNotes[row]
        } else {
            return backViewController.database[row]!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        scrollDownIfTextCrossOverKeyboard()
        
        textView.isEditable = false
        textView.text = currrentNote.text
    }
    
    static func instance(forRow row: Int) -> DetailsViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! DetailsViewController
        vc.row = row
        return vc
    }
    
    private func setupNavigationBar() {
        self.navigationItem.largeTitleDisplayMode = .never
        
        let editIcon = makeEditButton()
        let shareIcon = makeShareButton()
        self.navigationItem.rightBarButtonItems = [editIcon, shareIcon]
    }
    
    deinit {
        removeScrollDownIfTextCrossOverKeyboard()
    }
}

extension DetailsViewController {
    private func makeShareButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    @objc private func shareTapped() {
        let activityView = UIActivityViewController(activityItems: [currrentNote.text], applicationActivities: [])
        present(activityView, animated: true)
        
    }
}

extension DetailsViewController {
    private func makeEditButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(editTapped))
    }
    
    @objc private func editTapped() {
        self.navigationItem.rightBarButtonItem = makeDoneButton()
        textView.isEditable = true
        textView.becomeFirstResponder()
    }
}

extension DetailsViewController {
    private func makeDoneButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneTapped))
    }
    
    @objc private func doneTapped() {
        self.navigationItem.rightBarButtonItem = makeEditButton()
        textView.isEditable = false
        
        backViewController.database.updateNote(text: textView.text, forNote: currrentNote)
        
        backViewController.tableView.reloadData()
    }
}

extension DetailsViewController {
    
    private func scrollDownIfTextCrossOverKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    private func removeScrollDownIfTextCrossOverKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
