# LGNConfig
This package contains a simple config engine.

## `LGNConfig` usage
In order to use this class you have to define an `enum` with all config keys. Example:

```swift
public enum ConfigKeys: String, AnyConfigKey {
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
let config = try Config<ConfigKeys>(
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

Please notice that subscript with enum keys returns non-optional string value. It's because all keys are expected to be present in initialized config, and if not, there is something very wrong with `LGNConfig`, and should be reported. However, if it happens, the return value will be something like `__HTTP_PORT__MISSING`. But again, it should not happen at all.

Additionally you can try to get a config value by string key name:

```swift
let HTTPPort: String? = config["HTTP_PORT"]
```

This call returns optional string because of obvious reasons.
