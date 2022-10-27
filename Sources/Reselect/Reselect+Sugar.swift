//
//  File.swift
//  
//
//  Created by AJ Bartocci on 10/26/22.
//

import Foundation

// MARK: 2 Arguments
public func createSelector<
    A1,
    A2,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    cachePolicy: MemoCachePolicy = .default,
    equalityCheck: @escaping ((A1, A2), (A1, A2)) -> Bool,
    map: @escaping ((A1, A2)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        cachePolicy: cachePolicy,
        slice: {
            return (arg1($0), arg2($0))
        },
        equalityCheck: equalityCheck,
        map: map
    )
}

public func createSelector<
    A1: Equatable,
    A2: Equatable,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    cachePolicy: MemoCachePolicy = .default,
    map: @escaping ((A1, A2)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        arg1, arg2,
        cachePolicy: cachePolicy,
        equalityCheck: { return $0 == $1 },
        map: map
    )
}

// MARK: 3 Arguments
public func createSelector<
    A1,
    A2,
    A3,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    cachePolicy: MemoCachePolicy = .default,
    equalityCheck: @escaping ((A1, A2, A3), (A1, A2, A3)) -> Bool,
    map: @escaping ((A1, A2, A3)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        cachePolicy: cachePolicy,
        slice: {
            return (arg1($0), arg2($0), arg3($0))
        },
        equalityCheck: equalityCheck,
        map: map
    )
}

public func createSelector<
    A1: Equatable,
    A2: Equatable,
    A3: Equatable,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    cachePolicy: MemoCachePolicy = .default,
    map: @escaping ((A1, A2, A3)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        arg1, arg2, arg3,
        cachePolicy: cachePolicy,
        equalityCheck: { return $0 == $1 },
        map: map
    )
}

// MARK: 4 Arguments
public func createSelector<
    A1,
    A2,
    A3,
    A4,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    _ arg4: @escaping (Input) -> A4,
    cachePolicy: MemoCachePolicy = .default,
    equalityCheck: @escaping ((A1, A2, A3, A4), (A1, A2, A3, A4)) -> Bool,
    map: @escaping ((A1, A2, A3, A4)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        cachePolicy: cachePolicy,
        slice: {
            return (arg1($0), arg2($0), arg3($0), arg4($0))
        },
        equalityCheck: equalityCheck,
        map: map
    )
}

public func createSelector<
    A1: Equatable,
    A2: Equatable,
    A3: Equatable,
    A4: Equatable,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    _ arg4: @escaping (Input) -> A4,
    cachePolicy: MemoCachePolicy = .default,
    map: @escaping ((A1, A2, A3, A4)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        arg1, arg2, arg3, arg4,
        cachePolicy: cachePolicy,
        equalityCheck: { return $0 == $1 },
        map: map
    )
}

// MARK: 5 Arguments
public func createSelector<
    A1,
    A2,
    A3,
    A4,
    A5,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    _ arg4: @escaping (Input) -> A4,
    _ arg5: @escaping (Input) -> A5,
    cachePolicy: MemoCachePolicy = .default,
    equalityCheck: @escaping ((A1, A2, A3, A4, A5), (A1, A2, A3, A4, A5)) -> Bool,
    map: @escaping ((A1, A2, A3, A4, A5)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        cachePolicy: cachePolicy,
        slice: {
            return (arg1($0), arg2($0), arg3($0), arg4($0), arg5($0))
        },
        equalityCheck: equalityCheck,
        map: map
    )
}

public func createSelector<
    A1: Equatable,
    A2: Equatable,
    A3: Equatable,
    A4: Equatable,
    A5: Equatable,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    _ arg4: @escaping (Input) -> A4,
    _ arg5: @escaping (Input) -> A5,
    cachePolicy: MemoCachePolicy = .default,
    map: @escaping ((A1, A2, A3, A4, A5)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        arg1, arg2, arg3, arg4, arg5,
        cachePolicy: cachePolicy,
        equalityCheck: { return $0 == $1 },
        map: map
    )
}

// MARK: 6 Arguments
public func createSelector<
    A1,
    A2,
    A3,
    A4,
    A5,
    A6,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    _ arg4: @escaping (Input) -> A4,
    _ arg5: @escaping (Input) -> A5,
    _ arg6: @escaping (Input) -> A6,
    cachePolicy: MemoCachePolicy = .default,
    equalityCheck: @escaping ((A1, A2, A3, A4, A5, A6), (A1, A2, A3, A4, A5, A6)) -> Bool,
    map: @escaping ((A1, A2, A3, A4, A5, A6)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        cachePolicy: cachePolicy,
        slice: {
            return (arg1($0), arg2($0), arg3($0), arg4($0), arg5($0), arg6($0))
        },
        equalityCheck: equalityCheck,
        map: map
    )
}

public func createSelector<
    A1: Equatable,
    A2: Equatable,
    A3: Equatable,
    A4: Equatable,
    A5: Equatable,
    A6: Equatable,
    Input,
    Output
>(
    _ arg1: @escaping (Input) -> A1,
    _ arg2: @escaping (Input) -> A2,
    _ arg3: @escaping (Input) -> A3,
    _ arg4: @escaping (Input) -> A4,
    _ arg5: @escaping (Input) -> A5,
    _ arg6: @escaping (Input) -> A6,
    cachePolicy: MemoCachePolicy = .default,
    map: @escaping ((A1, A2, A3, A4, A5, A6)) -> Output
) -> Memo<Input, Output> {
    return createSelector(
        arg1, arg2, arg3, arg4, arg5, arg6,
        cachePolicy: cachePolicy,
        equalityCheck: { return $0 == $1 },
        map: map
    )
}

/*
 Why stop at 6?
 Because the compiler complains when equatable with 7 or more in tuple.
 
 func test() {
     let foo = (1,2,3,4,5,6)
     let bar = (6,5,4,3,2,1)
     let isEqual = foo == bar

     let foo7 = (1,2,3,4,5,6,7)
     let bar7 = (7,6,5,4,3,2,1)
     // compiler error
     let isEqual7 = foo7 == bar7
 }
 */

