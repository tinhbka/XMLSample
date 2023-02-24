//
//  DataService.swift
//  XMLFileSample
//
//  Created by Tinh Vu on 2/23/23.
//

import Foundation

class DataService: NSObject {
    
    static let shared = DataService()
    
    private let dataFolder: String = "data"
    private let officialDataFolder: String = "official-data"
    private let rootPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    
    private let fileManager = FileManager.default
    
    lazy var dataPath: URL? = {
        let documentsDirectory = rootPaths[0]
        return URL(string: documentsDirectory)?.appending(path: dataFolder)
    }()
    
    lazy var officialDataPath: URL? = {
        let documentsDirectory = rootPaths[0]
        return URL(string: documentsDirectory)?.appending(path: officialDataFolder)
    }()
    
    override init() {
        
    }
    
    func getData() -> [String] {
        guard let dataPath = dataPath else { return [] }
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: dataPath.path())

            return items
        } catch {
            print("Fail to get data")
        }
        
        return []
    }
    
    func getFileUrl(_ fileName: String) -> URL? {
        guard let dataPath = dataPath else { return nil }
        let fullPath = dataPath.appending(path: fileName)
        return URL(filePath: fullPath.path())
    }
    
    func getImportedFileUrl(_ fileName: String) -> URL? {
        guard let dataPath = officialDataPath else { return nil }
        let fullPath = dataPath.appending(path: fileName)
        return URL(filePath: fullPath.path())
    }
    
    func importFile(_ fileName: String, completion: (URL?) -> Void) {
        let source = dataPath?.appending(path: fileName)
        let des = officialDataPath?.appending(path: fileName)
        
        guard let sourcePath = source?.path(), let desPath = des?.path() else {
            completion(nil)
            return
        }
        
        do {
            try fileManager.copyItem(atPath: sourcePath, toPath: desPath)
            completion(des)
        } catch {
            print("Can't import file")
            completion(nil)
        }
    }
    
    func copyResourcesIfNeeded() {
        
        guard let dataPath = dataPath else { return }
        
        print(dataPath.absoluteString)
        
        if !fileManager.fileExists(atPath: dataPath.path) {
            do {
                try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                
                try fileManager.createDirectory(atPath: officialDataPath?.path ?? "", withIntermediateDirectories: true, attributes: nil)
                
                let url = Bundle.main.url(forResource: "xmls", withExtension: "plist")!
                let listData = try Data(contentsOf: url)
                if let list = try PropertyListSerialization.propertyList(from: listData, options: [], format: nil) as? Array<String> {
                    list.forEach { fileName in
                        copyFileToDocumentsFolder(fileName)
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func copyFileToDocumentsFolder(_ name: String) {
        print("Copy file: " + name)
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: dataFolder) else {
            return
        }
        
        let destURL = documentsURL.appendingPathComponent(name).appendingPathExtension("xml")
        guard let sourceURL = Bundle.main.url(forResource: name, withExtension: "xml")
            else {
                print("Source File not found.")
                return
        }
        
        do {
            try fileManager.copyItem(at: sourceURL, to: destURL)
        } catch {
            print("Unable to copy file")
        }
    }
    
}
