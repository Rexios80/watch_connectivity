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

  pod 'ConnectIQ', :git => 'https://github.com/Rexios80/ConnectIQ-pod', :tag => '0.1.0' # This might update with new plugin versions
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
<key>CFBundleDisplayName</key>
<string>${PRODUCT_NAME}</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>None</string>
        <key>CFBundleURLName</key>
        <string>{your.bundle.identifier}</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>{your-unique-string}</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>gcm-ciq</string>
</array>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Used to connect to wearable devices</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Used to connect to wearable devices</string>
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```