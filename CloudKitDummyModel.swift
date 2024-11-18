//
//  CloudKitDummyModel.swift
//  ZeroBeta4
//
//

import CloudKit

struct DummyModel: CloudKitableProtocol, Hashable, Sendable {
    var id: CKRecord.ID
    var dummyName: String
 

    static var recordType: String { "DummyModel" }

    init(id: CKRecord.ID = CKRecord.ID(), dummyName: String) {
        self.id = id
        self.dummyName = dummyName
    }

    var record: CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: id)
        record["dummyName"] = dummyName as CKRecordValue
        return record
    }

    init?(record: CKRecord) {
        guard let dummyName = record["dummyName"] as? String else { return nil }
        self.init(id: record.recordID, dummyName: dummyName)
    }
}
