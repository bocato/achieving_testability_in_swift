import Foundation
import XCTest

struct User {
    let id: Int
    let name: String
    let lastName: String
    let nickname: String?
}
 
final class ProfileViewModelProtocol {
    func getUserName() -> String
}
 
final class ProfileViewModel {
    private let user: User
    init(user: User) {
        self.user = user
    }
     
    func getUserName() -> String {
        guard let nickname = user.nickname else { return user.name }
        return nickname
    }
}

final class ProfileViewModelTests: XCTestCase {
    // Without fixtures
    func test_getUserName_whenNickNameIsNotNil_itShouldReturnNickname() {
        // Given
        let userMock: User = .init(
            id: 1,
            name: "my_name",
            lastName: "last_name",
            nickname: "Nickname"
        )
        let sut = ProfileViewModel(user: userMock)
        // When
        let returnedValue = sut.getUserName()
        // Then
        XCTAssertEqual(returnedValue, userMock.nickname)
    }
}

// Then come the fixtures...

extension User {
    static func fixture(
        id: Int = 1,
        name: String = "my_name",
        lastName: String = "last_name",
        nickname: String? = nil
    ) -> User {
        return .init(
            id: id,
            name: name,
            lastName: lastName,
            nickname: nickname
        )
    }
}

final class ProfileViewModelTests_2: XCTestCase {
    func test_getUserName_whenNickNameIsNotNil_itShouldReturnNickname() {
        // Given
        let userMock: User = .fixture(nickname: "Nickname")
        let sut = ProfileViewModel(user: userMock)
        // When
        let returnedValue = sut.getUserName()
        // Then
        XCTAssertEqual(returnedValue, userMock.nickname)
    }
}

