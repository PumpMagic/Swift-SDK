# Knurld Swift SDK
The Knurld Swift SDK wraps the Knurld web API to simplify integration of Knurld's voice verification services into your iOS applications..

For more information on Knurld, please visit us at [knurld.io](https://www.knurld.io/).

## Requirements
## Communication
## Installation
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

