import XCTest
@testable import Reselect

struct ExampleItem: Identifiable, Equatable {
    let id: String
    let title: String
    let count: Int
}
struct NormalizedState {
    var itemIndex = [ExampleItem.ID: ExampleItem]()
    var itemIds = [ExampleItem.ID]()
    var favoriteItems = Set<ExampleItem.ID>()
}

struct UIItem: Equatable {
    let id: String
    let title: String
    let count: Int
    let isFavorite: Bool
}

class MockCache: MemoCacheable {
    var hasBeenCalled = false
    var addedRefKey: String?
    var removedRefKey: String?
    var addedItem: MemoCacheItem?
    
    func item(forKey key: String) -> MemoCacheItem? {
        hasBeenCalled = true
        return nil
    }
    
    func setItem(_ item: MemoCacheItem, forKey key: String) {
        hasBeenCalled = true
        addedItem = item
    }
    
    func removeReference(forKey key: String) {
        hasBeenCalled = true
        removedRefKey = key
    }
    
    func addReference(forKey key: String) {
        hasBeenCalled = true
        addedRefKey = key
    }
}

final class MemoizedStateTestsTests: XCTestCase {
    
    var cache: MockCache!
    var state: NormalizedState!
    typealias SUT = MemoizedState<
        NormalizedState,
        ([ExampleItem.ID: ExampleItem], [ExampleItem.ID], Set<ExampleItem.ID>),
        [UIItem],
        MockCache
    >
    typealias IntegrationSUT = MemoizedState<
        NormalizedState,
        ([ExampleItem.ID: ExampleItem], [ExampleItem.ID], Set<ExampleItem.ID>),
        [UIItem],
        MemoCache
    >
    var sut: SUT!
    
    override func setUpWithError() throws {
        cache = MockCache()
        state = NormalizedState()
        sut = MemoizedState(
            sharedCache: cache,
            cachePolicy: .isolated,
            input: { state in
                return (state.itemIndex, state.itemIds, state.favoriteItems)
            },
            equalityCheck: { return $0 == $1 },
            map: { (itemIndex, itemIds, favoriteItems) -> [UIItem] in
                return itemIds.compactMap { id in
                    guard let item = itemIndex[id] else {
                        return nil
                    }
                    let isFavorite = favoriteItems.contains(id)
                    return UIItem(
                        id: item.id,
                        title: item.title,
                        count: item.count,
                        isFavorite: isFavorite
                    )
                }
            }
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        cache = nil
        state = nil
    }
    
    func testIsolated_DoesNot_TouchCache() throws {
        XCTAssertFalse(cache.hasBeenCalled)
        sut = MemoizedState(
            sharedCache: cache,
            cachePolicy: .isolated,
            input: { state in
                return (state.itemIndex, state.itemIds, state.favoriteItems)
            },
            equalityCheck: { return $0 == $1 },
            map: { (itemIndex, itemIds, favoriteItems) -> [UIItem] in
                return itemIds.compactMap { id in
                    guard let item = itemIndex[id] else {
                        return nil
                    }
                    let isFavorite = favoriteItems.contains(id)
                    return UIItem(
                        id: item.id,
                        title: item.title,
                        count: item.count,
                        isFavorite: isFavorite
                    )
                }
            }
        )
        state.itemIds = ["foo"]
        _ = sut.sync(state)
        XCTAssertFalse(cache.hasBeenCalled)
    }
    
    func testShared_Uses_Cache() throws {
        XCTAssertFalse(cache.hasBeenCalled)
        XCTAssertNil(cache.addedRefKey)
        
        let key = "some-key"
        sut = MemoizedState(
            sharedCache: cache,
            cachePolicy: .shared(key: key),
            input: { state in
                return (state.itemIndex, state.itemIds, state.favoriteItems)
            },
            equalityCheck: { return $0 == $1 },
            map: { (itemIndex, itemIds, favoriteItems) -> [UIItem] in
                return itemIds.compactMap { id in
                    guard let item = itemIndex[id] else {
                        return nil
                    }
                    let isFavorite = favoriteItems.contains(id)
                    return UIItem(
                        id: item.id,
                        title: item.title,
                        count: item.count,
                        isFavorite: isFavorite
                    )
                }
            }
        )
        
        XCTAssertTrue(cache.hasBeenCalled)
        XCTAssertEqual(cache.addedRefKey, key)
        XCTAssertNil(cache.addedItem)
        XCTAssertNil(cache.removedRefKey)
        
        state.itemIds = ["foo"]
        _ = sut.sync(state)
        
        XCTAssertNotNil(cache.addedItem)
        
        sut = nil
        
        XCTAssertNotNil(cache.removedRefKey)
    }
    
    // MARK: Integration Tests
    
    func testShared_SharesCache_BetweenMemos() throws {
        
        var didMapMemo = false
        var didMapOtherMemo = false
        
        let cache = MemoCache.shared
        let key = "some-key"
        var memo: IntegrationSUT! = MemoizedState(
            sharedCache: cache,
            cachePolicy: .shared(key: key),
            input: { state in
                return (state.itemIndex, state.itemIds, state.favoriteItems)
            },
            equalityCheck: { return $0 == $1 },
            map: { (itemIndex, itemIds, favoriteItems) -> [UIItem] in
                didMapMemo = true
                return itemIds.compactMap { id in
                    guard let item = itemIndex[id] else {
                        return nil
                    }
                    let isFavorite = favoriteItems.contains(id)
                    return UIItem(
                        id: item.id,
                        title: item.title,
                        count: item.count,
                        isFavorite: isFavorite
                    )
                }
            }
        )
        
        var otherMemo: IntegrationSUT! = MemoizedState(
            sharedCache: cache,
            cachePolicy: .shared(key: key),
            input: { state in
                return (state.itemIndex, state.itemIds, state.favoriteItems)
            },
            equalityCheck: { return $0 == $1 },
            map: { (itemIndex, itemIds, favoriteItems) -> [UIItem] in
                didMapOtherMemo = true
                return itemIds.compactMap { id in
                    guard let item = itemIndex[id] else {
                        return nil
                    }
                    let isFavorite = favoriteItems.contains(id)
                    return UIItem(
                        id: item.id,
                        title: item.title,
                        count: item.count,
                        isFavorite: isFavorite
                    )
                }
            }
        )
        
        XCTAssertFalse(didMapMemo)
        XCTAssertFalse(didMapOtherMemo)
        
        let initialOtherState = otherMemo.sync(state)
        let initalMemoState = memo.sync(state)
        
        XCTAssertEqual(initialOtherState, initalMemoState)
        XCTAssertFalse(didMapMemo)
        XCTAssertTrue(didMapOtherMemo)
        
        let item = ExampleItem(
            id: "foo",
            title: "title",
            count: 1337
        )
        state.itemIds = [item.id]
        state.favoriteItems.insert(item.id)
        state.itemIndex[item.id] = item
        
        let finalOtherState = otherMemo.sync(state)
        let finalMemoState = memo.sync(state)
        
        XCTAssertEqual(finalOtherState, finalMemoState)
        XCTAssertEqual(finalMemoState.count, 1)
        XCTAssertFalse(didMapMemo)
        XCTAssertTrue(didMapOtherMemo)
        
        otherMemo = nil
        XCTAssertNotNil(cache.item(forKey: key))
        memo = nil
        XCTAssertNil(cache.item(forKey: key))
    }
}
