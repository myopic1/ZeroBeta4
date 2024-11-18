//
//  CloudKitUtilityTest.swift
//  ZeroBeta4
//
//

import CloudKit
import Foundation

struct CloudKitUtilityTest {
    static func testSaveAndDelete() async {
        let testDummy = DummyModel(
            id: CKRecord.ID(recordName: "TestDummy"),
            dummyName: "Test Dummy"
        )

        do {
            print("Testing save...")
            try await CloudKitCrudUtility.saveOrUpdate(item: testDummy)
            print("Saved successfully.")

            print("Testing delete...")
            try await CloudKitCrudUtility.delete(item: testDummy)
            print("Deleted successfully.")
        } catch {
            print("Error during save or delete: \(error)")
        }
    }
}
