//
//  SQLiteService.swift
//  XMLFileSample
//
//  Created by Tinh Vu on 2/24/23.
//

import Foundation
import SQLite

class SQLiteService: NSObject {
    
    static let shared = SQLiteService()
    
    // Table name
    let table = Table("imported")

    // Fields of table
    let id = Expression<String>("id")
    let url = Expression<String>("url")
    let name = Expression<String>("name")
    
    let db: Connection
    
    override init() {
        let dbUrl = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("_db.sqlite3") ?? "")
        db = try! Connection(dbUrl?.path() ?? "")
        super.init()
        createTable()
    }
    
    func createTable() {
        do {
            let existed = UserDefaults.standard.bool(forKey: "CreatedTable")
            if existed {
                return
            }
            
            try db.run(table.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(url)
            })
            UserDefaults.standard.set(true, forKey: "CreatedTable")
        } catch {
            //doesn't
        }
    }
    
    func addImported(_ data: Imported) {
        let insert = table.insert(id <- data.id, name <- data.name, url <- data.path)
        try! db.run(insert)
    }
    
    func fetchAllData() -> [Imported] {
        do {
            var results: [Imported] = []
            for item in try db.prepare(table) {
                results.append(Imported(id: item[id], name: item[name], path: item[url]))
            }
            return results
        } catch {
            return []
        }
    }

}
