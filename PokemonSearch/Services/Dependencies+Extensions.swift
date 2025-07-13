import Foundation
import ComposableArchitecture

// 明示的な成功型の定義
struct SaveFavoriteSuccess: Equatable {}
struct DeleteFavoriteSuccess: Equatable {}

extension TaskResult: Equatable where Success: Equatable {
    public static func == (lhs: TaskResult<Success>, rhs: TaskResult<Success>) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lhsValue), .success(let rhsValue)):
            return lhsValue == rhsValue
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
