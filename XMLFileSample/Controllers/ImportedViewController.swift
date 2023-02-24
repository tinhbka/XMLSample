//
//  ImportedViewController.swift
//  XMLFileSample
//
//  Created by Tinh Vu on 2/23/23.
//

import UIKit

class ImportedCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func updateData(_ imported: Imported) {
        titleLabel.text = imported.id
        detailLabel.text = imported.name
    }
}

class ImportedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var items: [Imported] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Imported Files"
        
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: Notification.Name.importedChange, object: nil)
    }
    
    @objc func getData() {
        items = SQLiteService.shared.fetchAllData()
    }

}

extension ImportedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "importedCell") as? ImportedCell else {
            return UITableViewCell()
        }
        
        cell.updateData(items[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        vc.imported = items[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
