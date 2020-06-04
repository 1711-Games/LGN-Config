import XCTest
@testable import LGNConfig

final class LGNConfigTests: XCTestCase {
    func testConfig() {
        enum ConfigKeys: String, AnyConfigKey {
            case FOO
            case BAR
        }

        // Local with missing key and empty local values
        XCTAssertThrowsError(try Config<ConfigKeys>(
            rawConfig: [
                "FOO": "foo_val_raw"
            ],
            isLocal: true
        )) { error in
            guard case Config<ConfigKeys>.E.MissingEntries(let missingKeys) = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            XCTAssertEqual(missingKeys, [.BAR])
        }

        // Local with empty raw values
        let instance1 = try! Config<ConfigKeys>(
            rawConfig: [:],
            isLocal: true,
            localConfig: [
                .FOO: "foo_val_local",
                .BAR: "bar_val_local",
            ]
        )
        XCTAssertEqual(instance1.get("FOO"), String?("foo_val_local"))
        XCTAssertEqual(instance1["FOO"], String?("foo_val_local"))
        XCTAssertEqual(instance1[.FOO], "foo_val_local")
        XCTAssertEqual(instance1[.BAR], "bar_val_local")

        // Local with empty local values
        let instance2 = try! Config<ConfigKeys>(
            rawConfig: [
                "FOO": "foo_val_raw",
                "BAR": "bar_val_raw",
            ],
            isLocal: true
        )
        XCTAssertEqual(instance2.get("FOO"), String?("foo_val_raw"))
        XCTAssertEqual(instance2[.FOO], "foo_val_raw")
        XCTAssertEqual(instance2[.BAR], "bar_val_raw")

        // Non-local with missing keys and filled local values
        XCTAssertThrowsError(try Config<ConfigKeys>(
            rawConfig: [:],
            localConfig: [
                .FOO: "foo_val_local",
                .BAR: "bar_val_local",
            ]
        )) { error in
            guard case Config<ConfigKeys>.E.MissingEntries(let missingKeys) = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            XCTAssertEqual(missingKeys, [.FOO, .BAR])
        }

        // Prod with filled local values
        let instance3 = try! Config<ConfigKeys>(
            rawConfig: [
                "FOO": "foo_val_raw_prod",
                "BAR": "bar_val_raw_prod",
            ],
            localConfig: [
                .FOO: "foo_val_local",
                .BAR: "bar_val_local",
            ]
        )
        XCTAssertEqual(instance3.get("FOO"), String?("foo_val_raw_prod"))
        XCTAssertEqual(instance3.get("LUL"), nil)
        XCTAssertEqual(instance3["LUL"], nil)
        XCTAssertEqual(instance3[.FOO], "foo_val_raw_prod")
        XCTAssertEqual(instance3[.BAR], "bar_val_raw_prod")
    }

    static var allTests = [
        ("testConfig", testConfig),
    ]
}
