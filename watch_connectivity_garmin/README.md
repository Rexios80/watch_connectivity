# watch_connectivity_garmin

A new Flutter plugin project.

## Getting Started

<!-- TODO -->
iOS podfile changes:
```ruby
pod 'ConnectIQ', :podspec => 'ConnectIQ.podspec'
```
```ruby
installer.pods_project.build_configurations.each do |config|
  config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
end
```
