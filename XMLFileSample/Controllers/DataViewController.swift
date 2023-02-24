//
//  DataViewController.swift
//  XMLFileSample
//
//  Created by Tinh Vu on 2/23/23.
//

import UIKit
import MBProgressHUD
import SwiftyXMLParser

class DataCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var importButton: UIButton!
    
    private var imported: Bool = false
    
    var importHandler: ((String) -> Void)?
    
    func updateData(_ name: String, imported: Bool) {
        titleLabel.text = name
        self.imported = imported
        
        importButton.setTitle(imported ? "Imported" : "Import", for: .normal)
    }
    
    @IBAction func importTapped(_ sender: Any) {
        if imported {
            return
        }
        importHandler?(titleLabel.text ?? "")
    }
    
}

class DataViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [String] = []
    private var importedData: [Imported] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = DataService.shared.getData()
        fetchImporteds()
        setupViews()
    }

    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsSelection = false
        
        navigationItem.title = "XML Files"
    }
    
    private func fetchImporteds() {
        importedData = SQLiteService.shared.fetchAllData()
    }
    
    private func getInstanceId(_ fileName: String) {
        guard let url = DataService.shared.getFileUrl(fileName) else {
            return
        }
                
        do {
            let xml = try XML.parse(Data(contentsOf: url))
            if let text = xml["All_in_One_GEN007", "meta", "instanceID"].text {
                if !text.isEmpty {
                    importFile(fileName, id: text)
                }
            }
        } catch {
            print("Can't parse")
        }
    }
    
    private func importFile(_ name: String, id: String) {
        DataService.shared.importFile(name) { [weak self] url in
            if let url = url {
                SQLiteService.shared.addImported(Imported(id: id, name: name, path: url.path()))
                print("Import success")
                self?.fetchImporteds()
                NotificationCenter.default.post(name: Notification.Name.importedChange, object: nil)
            }
        }
    }

}

extension DataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell") as? DataCell else {
            return UITableViewCell()
        }
        
        cell.updateData(items[indexPath.row], imported: importedData.contains(where: {$0.name == items[indexPath.row]}))
        cell.importHandler = { [weak self] name in
            self?.getInstanceId(name)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
