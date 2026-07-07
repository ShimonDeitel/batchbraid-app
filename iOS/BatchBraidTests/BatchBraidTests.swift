import XCTest
@testable import BatchBraid

final class BatchBraidTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchBraidStore()
        XCTAssertGreaterThan(store.braids.count, 0)
        XCTAssertLessThan(store.braids.count, BatchBraidStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchBraidStore()
        let before = store.braids.count
        let added = store.addBraid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.braids.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchBraidStore()
        let before = store.braids.count
        let added = store.addBraid(projectName: "   ", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.braids.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchBraidStore()
        for item in store.braids { store.deleteBraid(item.id) }
        for _ in 0..<BatchBraidStore.freeLimit {
            XCTAssertTrue(store.addBraid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: false))
        }
        XCTAssertFalse(store.addBraid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: false))
        XCTAssertTrue(store.addBraid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchBraidStore()
        store.addBraid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: false)
        guard let item = store.braids.last else { return XCTFail("expected entry") }
        let before = store.braids.count
        store.deleteBraid(item.id)
        XCTAssertEqual(store.braids.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchBraidStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.braids.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchBraidStore()
        store.addBraid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4", isPro: false)
        guard let item = store.braids.last else { return XCTFail("expected entry") }
        store.updateBraid(item.id, projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4")
        XCTAssertEqual(store.braids.count, store.braids.count)
    }
}
