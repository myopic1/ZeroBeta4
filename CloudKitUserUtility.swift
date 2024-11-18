//
//  CloudKitUserUtility.swift
//  ZeroBeta4
//
//

import CloudKit

class CloudKitUserUtility {
    enum CloudKitUserError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case temporarilyUnavailable
        case unknown
    }

    /// Check iCloud account status
    static func getiCloudStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().accountStatus { status, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    switch status {
                    case .available:
                        continuation.resume(returning: true)
                    case .noAccount:
                        continuation.resume(throwing: CloudKitUserError.iCloudAccountNotFound)
                    case .couldNotDetermine:
                        continuation.resume(throwing: CloudKitUserError.iCloudAccountNotDetermined)
                    case .restricted:
                        continuation.resume(throwing: CloudKitUserError.iCloudAccountRestricted)
                    case .temporarilyUnavailable:
                        continuation.resume(throwing: CloudKitUserError.temporarilyUnavailable)
                    @unknown default:
                        continuation.resume(throwing: CloudKitUserError.unknown)
                    }
                }
            }
        }
    }

    /// Fetch user record ID
    static func fetchUserRecordID() async throws -> CKRecord.ID {
        try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().fetchUserRecordID { recordID, error in
                if let id = recordID {
                    continuation.resume(returning: id)
                } else {
                    continuation.resume(throwing: CloudKitUserError.iCloudAccountNotFound)
                }
            }
        }
    }
}
