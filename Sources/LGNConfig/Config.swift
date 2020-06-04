import Foundation
import Logging

public protocol AnyConfigKey: Hashable, RawRepresentable, CaseIterable where RawValue == String {}

public struct Config<Key: AnyConfigKey> {
    public enum E: Error {
        /// An error reporting missing config entries, holds an array of missing keys
        case MissingEntries([Key])
    }

    public static var empty: Self {
        return Self(storage: [:])
    }

    private let storage: [Key: String]
    private let logger = Logging.Logger(label: "LGNConfig")

    fileprivate init(storage: [Key: String]) {
        self.storage = storage
    }

    public init(
        rawConfig: [AnyHashable: String] = ProcessInfo.processInfo.environment,
        isLocal: Bool = false,
        localConfig: [Key: String] = [:]
    ) throws {
        var missing: [Key] = []
        var storage: [Key: String] = [:]

        for key in Key.allCases {
            let value: String

            if let _value = rawConfig[key.rawValue] {
                value = _value
            } else if isLocal, let _value = localConfig[key] {
                value = _value
            } else {
                missing.append(key)
                continue
            }

            storage[key] = value
        }

        guard missing.count == 0, Key.allCases.count == storage.count else {
            throw E.MissingEntries(missing)
        }

        self.init(storage: storage)
    }

    /// Returns value for given key
    ///
    /// Since all keys are known at compile stage, and Config does a storage validation on init, this method returns
    /// non-optional result.
    public subscript(key: Key) -> String {
        guard let value = self.storage[key] else {
            self.logger.critical("Config value for key '\(key)' missing (how is this possible?)")
            return "__\(key)__MISSING__"
        }
        return value
    }

    /// Returns value for given raw string key
    ///
    /// This method return `Optional<String>` because of raw `String` key argument. If you know config key at
    /// compile time and want non-optional result value, please use `subscript` access method.
    public func get(_ rawKey: String) -> String? {
        guard let key = Key(rawValue: rawKey) else {
            return nil
        }
        return self[key]
    }
}
