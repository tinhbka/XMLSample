//
//  DetailViewController.swift
//  XMLFileSample
//
//  Created by Tinh Vu on 2/24/23.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var imported: Imported!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = imported.id
        
        if let url = DataService.shared.getImportedFileUrl(imported.name) {
            do {
                let content = try String(contentsOf: url)
                textView.text = content
            } catch {
                print("Can't read this file")
            }
        }
    }
}
