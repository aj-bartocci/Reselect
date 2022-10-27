import Foundation

public func createSelector<
    Slice,
    Input,
    Output
>(
    cachePolicy: MemoCachePolicy = .default,
    slice: @escaping (Input) -> Slice,
    equalityCheck: @escaping (Slice, Slice) -> Bool,
    map: @escaping (Slice) -> Output
) -> Memo<Input, Output> {
    return Memo(MemoizedState(
        sharedCache: MemoCache.shared,
        cachePolicy: cachePolicy,
        input: slice,
        equalityCheck: equalityCheck,
        map: map
    ))
}

public func createSelector<
    Slice: Equatable,
    Input,
    Output
>(
    cachePolicy: MemoCachePolicy = .default,
    slice: @escaping (Input) -> Slice,
    map: @escaping (Slice) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        cachePolicy: cachePolicy,
        slice: slice,
        equalityCheck: { return $0 == $1 },
        map: map
    )
}
