
# About

I've done this small project over a weekend out of interest on learning about the latest swift framework SwiftUI and its usefulness in a UIKit project.

# How to run

In order to run this project, you will need to configure the `.netrc` file for MapBox and run `carthage update --platform iOS --use-netrc --use-xcframeworks`, and finally update the public token in the `info.plist` file

> To run project in iOS simulator, please run in rosetta (`product > destination > Show All Run Destinations`) or set arm64 as excluded arch in iOS simulator.


# MapBox

Following app uses MapBox 6.4.1 https://docs.mapbox.com/ios/legacy/maps/guides/install/

To add the Mapbox Maps SDK dependency with Carthage, you will need to configure your build to download the Maps SDK from Mapbox directly. This requires a valid username and an access token with the Downloads: Read scope. In a previous step, you added these items to your .netrc file.

    Open your project in Xcode.
    Confirm that you are using Carthage version 0.35.0 or higher.
    Add the following to your Cartfile:
    
```
binary "https://api.mapbox.com/downloads/v2/carthage/mobile-maps/mapbox-ios-sdk-dynamic.json" ~> 6.4.1
github "mapbox/mapbox-events-ios" ~> 0.10.4
```

    Install the SDK with `carthage update --platform iOS --use-netrc --use-xcframeworks`

    Continue setting up the Maps SDK for iOS by following the Carthage quick start instructions, starting with step 6 with both the generated Mapbox.framework and MapboxMobileEvents.framework.
