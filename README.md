# LGNConfig
This package contains a simple config engine.

## `LGNConfig` usage
In order to use this class you have to define an `enum` with all config keys. Example:

```swift
public enum ConfigKey: String, AnyConfigKey {
    case KEY
    case SALT
    case LOG_LEVEL
    case HTTP_PORT
    case PRIVATE_IP
    case REGISTER_TO_CONSUL
}
```

Then you try to init the config. `main.swift` is not the worst place for it, as it doesn't require `try` calls to be wrapped with `do catch`:

```swift
let config = try Config<ConfigKey>(
    // this is optional, you may provide any `[AnyHashable: String]` input here
    rawConfig: ProcessInfo.processInfo.environment,
    // optional, default value is `false`
    isLocal: true,
    // optional, see below
    localConfig: [
        .KEY: "sdfdfg",
        .SALT: "mysecretsalt",
        .LOG_LEVEL: "trace",
        .HTTP_PORT: "8081",
        .PRIVATE_IP: "127.0.0.1",
        .REGISTER_TO_CONSUL: "false",
    ]
)
```

`localConfig` argument contains default config entries for local app environment which are used only when `isLocal` is set to `true`, otherwise it exits the application with respective message if one or more config entries are missing from config. Then you use config like this:

```swift
let cryptor = try LGNP.Cryptor(salt: config[.SALT], key: config[.KEY])
```

Please notice that subscript with enum keys returns non-optional string value. It's because all keys are expected to be present in initialized config, and if not, there is something very wrong with `LGNConfig`, and should be reported.

Additionally you can try to get a config value by string key name:

```swift
let HTTPPort: String? = config["HTTP_PORT"]
```

This call returns optional string because of obvious reasons.

## Vapor compatibility
If you'd like to use it in a Vapor 4 project, you may create this handy layer of compatibility. In my projects it's called `Vapor+LGNConfig.swift`. The initializer now accepts Vapor's `Environment` struct instead of `isLocal`, and so local config would be used only in `.development` environment. Additionally, you will be able to use config from `Application`, that is, as `app.config` at bootstrap stage or as `request.application.config` in routes. You just need to init the config in `configure.swift` and assign it to `app.config`. 

```swift
import LGNConfig
import Vapor

public extension Config {
    init(env: Environment, localConfig: [Key: String] = [:]) throws {
        try self.init(isLocal: env == Environment.development, localConfig: localConfig)
    }
}

public extension Application {
    fileprivate struct StorageConfigKey: StorageKey {
        typealias Value = Config<ConfigKey>
    }

    var config: Config<ConfigKey> {
        get {
            guard let config = self.storage[StorageConfigKey.self] else {
                fatalError("LGN Config not initiated")
            }
            return config
        }
        set {
            self.storage[StorageConfigKey.self] = newValue
        }
    }
}
```
