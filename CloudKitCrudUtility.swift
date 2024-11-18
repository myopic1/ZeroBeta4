//
//  CloudKitCrudUtility.swift
//  ZeroBeta4
//
//

import CloudKit
import os.log

protocol CloudKitableProtocol {
    init?(record: CKRecord)
    var record: CKRecord { get }
    static var recordType: String { get }
}

class CloudKitCrudUtility {
    private static let logger = Logger(subsystem: "com.example.CloudKitApp", category: "CloudKitUtility")
    
    /// Fetch records
    static func fetch<T: CloudKitableProtocol>(
        predicate: NSPredicate = NSPredicate(value: true),
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            var fetchedItems: [T] = []
            var queryCursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let operation: CKQueryOperation
                if let cursor = queryCursor {
                    operation = CKQueryOperation(cursor: cursor)
                } else {
                    let query = CKQuery(recordType: recordType, predicate: predicate)
                    query.sortDescriptors = sortDescriptions
                    operation = CKQueryOperation(query: query)
                    if let limit = resultsLimit {
                        operation.resultsLimit = limit
                    }
                }
                
                // Ensure proper continuation usage
                let batchItems: [T] = try await withCheckedThrowingContinuation { continuation in
                    var items: [T] = []
                    
                    operation.recordMatchedBlock = { recordID, result in
                        switch result {
                        case .success(let record):
                            if let item = T(record: record) {
                                items.append(item)
                            } else {
                                logger.error("Failed to initialize \(T.self) from record: \(record)")
                            }
                        case .failure(let error):
                            logger.error("Error fetching record: \(error.localizedDescription)")
                        }
                    }
                    
                    operation.queryResultBlock = { result in
                        switch result {
                        case .success(let cursor):
                            queryCursor = cursor
                            continuation.resume(returning: items)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                    
                    CKContainer.default().publicCloudDatabase.add(operation)
                }
                
                fetchedItems += batchItems
            } while queryCursor != nil
            
            return fetchedItems
        }
    }
    
    /// Save or update a record
    static func saveOrUpdate<T: CloudKitableProtocol>(item: T) async throws {
        let record = item.record
        try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().publicCloudDatabase.save(record) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    /// Delete a record
    static func delete<T: CloudKitableProtocol>(item: T) async throws {
        let recordID = item.record.recordID
        try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().publicCloudDatabase.delete(withRecordID: recordID) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
