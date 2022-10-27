import Foundation

public class Memo<Input, Output> {
    let memo: MemoBox<Input, Output>
    
    init<Slice, Cache, T: MemoizedState<Input, Slice, Output, Cache>>(_ memo: T) {
        self.memo = MemoBox(memo)
    }
    
    public func sync(_ input: Input) -> Output {
        return memo.sync(input)
    }
}

public enum MemoCachePolicy {
    case isolated
    case shared(key: String)
    
    public static let `default` = MemoCachePolicy.isolated
}

protocol MemoRepresentable {
    associatedtype Input
    associatedtype Output
    
    func sync(_ input: Input) -> Output
}

class MemoBox<Input, Output>: MemoRepresentable {
    let _sync: (Input) -> Output
    
    init<T: MemoRepresentable>(_ concrete: T) where T.Input == Input, T.Output == Output {
        self._sync = concrete.sync
    }
    
    func sync(_ input: Input) -> Output {
        return _sync(input)
    }
}

protocol MemoCacheable {
    func item(forKey key: String) -> MemoCacheItem?
    func setItem(_ item: MemoCacheItem, forKey key: String)
    func removeReference(forKey key: String)
    func addReference(forKey key: String)
}

class MemoCache: MemoCacheable {
    static let shared = MemoCache()
    
    private var cache = [String: MemoCacheItem]()
    private var refIndex = [String: Int]()
    
    func item(forKey key: String) -> MemoCacheItem? {
        return cache[key]
    }
    
    func setItem(_ item: MemoCacheItem, forKey key: String) {
        cache[key] = item
    }
        
    func removeReference(forKey key: String) {
        if let count = refIndex[key] {
            let newCount = count - 1
            if newCount == 0 {
                refIndex[key] = nil
                cache[key] = nil
            } else {
                refIndex[key] = newCount
            }
        } else {
            print("Trying to remove reference for item that has no reference")
        }
    }
    
    func addReference(forKey key: String) {
        let count = refIndex[key] ?? 0
        refIndex[key] = count + 1
    }
}

class MemoCacheItem {
    var input: Any
    var output: Any
    
    init(
        input: Any,
        output: Any
    ) {
        self.input = input
        self.output = output
    }
}

class MemoizedState<State, Input, Output, Cache: MemoCacheable>: MemoRepresentable {
    
    var isolatedInput: Input?
    var isolatedOutput: Output?
    
    var cachedInput: Input? {
        switch cachePolicy {
        case .isolated:
            return isolatedInput
        case .shared(key: let key):
            guard let item = sharedCache.item(forKey: key) else {
                return nil
            }
            guard let input = item.input as? Input else {
                print(sharedKeyMismatchError(for: key))
                return nil
            }
            return input
        }
    }
    var cachedOutput: Output? {
        switch cachePolicy {
        case .isolated:
            return isolatedOutput
        case .shared(key: let key):
            guard let item = sharedCache.item(forKey: key) else {
                return nil
            }
            guard let output = item.output as? Output else {
                print(sharedKeyMismatchError(for: key))
                return nil
            }
            return output
        }
    }
    
    let input: (State) -> Input
    let equalityCheck: (Input, Input) -> Bool
    let map: (Input) -> Output
    let sharedCache: Cache
    let cachePolicy: MemoCachePolicy
    
    init(
        sharedCache: Cache = MemoCache.shared,
        cachePolicy: MemoCachePolicy,
        input: @escaping (State) -> Input,
        equalityCheck: @escaping (Input, Input) -> Bool,
        map: @escaping (Input) -> Output
    ) {
        self.sharedCache = sharedCache
        self.cachePolicy = cachePolicy
        self.input = input
        self.equalityCheck = equalityCheck
        self.map = map
        switch cachePolicy {
        case .isolated:
            break
        case .shared(key: let key):
            sharedCache.addReference(forKey: key)
        }
    }
    
    func sync(_ state: State) -> Output {
        switch cachePolicy {
        case .isolated:
            return syncIsolated(state)
        case .shared(key: let key):
            return syncShared(state, forKey: key)
        }
    }
    
    private func syncIsolated(_ state: State) -> Output {
        let newInput = input(state)
        guard let cachedInput = self.cachedInput, let cachedOutput = self.cachedOutput else {
            // nothing in cache so compute everyting
            return recomputeIsolated(state)
        }
        guard equalityCheck(cachedInput, newInput) == true else {
            // inputs are different so recompute
            return recomputeIsolated(state)
        }
        // inputs have not changed so return cache
        return cachedOutput
    }
    
    private func syncShared(_ state: State, forKey key: String) -> Output {
        let newInput = input(state)
        guard let cacheItem = sharedCache.item(forKey: key) else {
            return recomputeShared(state, forKey: key)
        }
        guard let cachedInput = cacheItem.input as? Input, let cachedOutput = cacheItem.output as? Output else {
            print(sharedKeyMismatchError(for: key))
            return recomputeShared(state, forKey: key)
        }
        guard equalityCheck(cachedInput, newInput) == true else {
            return recomputeShared(state, forKey: key)
        }
        // inputs have not changed so return cache
        return cachedOutput
    }
    
    private func recomputeIsolated(_ state: State) -> Output {
        let newInput = input(state)
        let newOutput = map(newInput)
        self.isolatedInput = newInput
        self.isolatedOutput = newOutput
        return newOutput
    }
    
    private func sharedKeyMismatchError(for key: String) -> String {
        return "Output item found in cache for key: \(key) has a mismatched type. Make sure the same key is not being used for multiple selectors!"
    }
    
    private func recomputeShared(_ state: State, forKey key: String) -> Output {
        let newInput = input(state)
        let newOutput = map(newInput)
        if let existing = sharedCache.item(forKey: key) {
            existing.input = newInput
            existing.output = newOutput
        } else {
            let item = MemoCacheItem(input: newInput, output: newOutput)
            sharedCache.setItem(item, forKey: key)
        }
        return newOutput
    }
    
    deinit {
        // TODO: send notification here with the key if shared
        switch cachePolicy {
        case .isolated:
            break
        case .shared(key: let key):
            sharedCache.removeReference(forKey: key)
        }
    }
}
