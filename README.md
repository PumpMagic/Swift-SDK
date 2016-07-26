# Knurld Swift SDK
The Knurld Swift SDK wraps the Knurld web API to simplify integration of Knurld's voice verification services with your iOS applications.

To learn more about Knurld, please visit us at [https://www.knurld.io](https://www.knurld.io/).

## Communication
If you encounter any issues using this SDK, please reach out to our development team at developer@knurld.com.

## Requirements
* iOS 8.0+

## Installation
### Carthage
Add the Knurld Swift SDK to your `Cartfile`:

`github "knurld/Swift-SDK" ~> 1.0`

### CocoaPods
Add the Knurld Swift SDK to your `Podfile`:

`pod 'KnurldSDK', '~> 1.0'`

## Usage
Create an instance of `KnurldAPI` and execute all of your requests against its members. For example, to check the status of the Knurld services:

1. Create an instance of `KnurldAPI`:

    ```swift
    let api = KnurldAPI()
    ```

1. Get an access token using your API credentials:

    ```swift
    let oAuthCredentials = OAuthCredentials(clientID: "your client ID",
                                            clientSecret: "your client secret")
    var knurldCredentials: KnurldCredentials?
    api.authorization.authorize(credentials: oAuthCredentials,
                                developerID: "your developer ID",
                                successHandler: { knurldCredentials = $0 },
                                failureHandler: { print("ERROR: \($0)") })
    ```

1. Once `knurldCredentials` is non-nil, ask the API for its status:

    ```swift
    var status: ServiceStatus?
    api.status.get(credentials: knurldCredentials,
                   successHandler: { status = $0 },
                   failureHandler: { print("ERROR: \($0)") })
    ```

1. Once `status` is non-nil, it will contain the Knurld service status.

    ```swift
    if let status = status {
        print("Knurld API version is \(status.version)")
    }
    ```

## Documentation
Full documentation of the SDK is at [https://knurld.github.io/Swift-SDK/](https://knurld.github.io/Swift-SDK/). The SDK documentation assumes familiarity with the Knurld web API.

For details on the Knurld web API, especially to learn its call flow and the significance of each call's data types, please see the [Knurld developer guide](https://developer.knurld.io/developer-guide).

## Development
To develop this SDK:

1. Install Carthage on your system, if it isn't already installed
1. Clone the SDK repository and run `./bin/setup` from the repository root
1. Open KnurldSDK.xcworkspace in Xcode and develop
1. To test, populate your Knurld API credentials in `KnurldSDKTests/TestCredentials.swift` and run Product -> Test in Xcode
