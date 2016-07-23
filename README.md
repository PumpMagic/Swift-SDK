# Knurld Swift SDK
The Knurld Swift SDK wraps the Knurld web API to simplify integration of Knurld's voice verification services into your iOS applications.

For information on the Knurld API, especially to learn the significance and expected values of each API call's data types, please see the [developer guide](https://developer.knurld.io/developer-guide). This SDK's documentation omits detailed information on the API specifics and assumes user familiarity with all API endpoints used.

For information on Knurld, please visit us at [https://www.knurld.io](https://www.knurld.io/).

## Requirements
* iOS 8.0+
* Freddy

## Communication
For help using this SDK, please reach out to us on GitHub or via email at help@knurld.com.

## Installation
### Carthage
Add the Knurld Swift SDK to your `Cartfile`:

`github "knurld/SwiftSDK" ~> 1.0`

### CocoaPods
Add the Knurld Swift SDK to your `Podfile`:

`pod 'KnurldSwiftSDK', '~> 1.0'`

## Usage
Create an instance of `KnurldAPI` and execute all of your requests against its members. For example, to check the status of the Knurld services:

1. Create an instance of `KnurldAPI`:

    ```swift
    let api = KnurldAPI()
    ```

1. Get an access token using your Knurld credentials:

    ```swift
    let oAuthCredentials = OAuthCredentials(clientID: "your client ID",
                                            clientSecret: "your client secret")
    var knurldCredentials: KnurldCredentials? = nil
    api.authorization.authorize(credentials: oAuthCredentials,
                                developerID: "your developer ID",
                                successHandler: { creds in knurldCredentials = creds },
                                failureHandler: { error in print("ERROR: \(error)") })
    ```

1. Once `knurldCredentials` is non-nil, ask the API for its status:

    ```swift
    var status: ServiceStatus? = nil
    api.status.get(credentials: knurldCredentials,
                   successHandler: { stat in status = stat },
                   failureHandler: { error in print("ERROR: \(error)") })
    ```

1. Once `status` is non-nil, it will contain the Knurld service status, and can be checked like

    ```swift
    if let status = status {
        print("Knurld API version is \(status.version)")
    }
    ```

## Development
1. Clone this repository
1. Install Carthage on your system, if it isn't already installed
1. From the repository root, run `./bin/setup` to pull Carthage dependencies
1. Open SwiftSDK.xcworkspace in Xcode and develop
1. If running tests, populate your Knurld API credentials in SwiftSDKTests/TestCredentials.swift
