# watch_connectivity_garmin

A new Flutter plugin project.

## Getting Started

<!-- TODO -->
iOS podfile changes:
```ruby
platform :ios, '13.0'

...

target 'Runner' do
  ...

  pod 'ConnectIQ', :podspec => 'ConnectIQ.podspec'
end

...

post_install do |installer|
  ...

  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
```
Info.plist changes:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>None</string>
        <key>CFBundleURLName</key>
        <string>{your.bundle.identifier}</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>{your_unique_string}</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>gcm-ciq</string>
</array>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Used to connect to wearable devices</string>
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```