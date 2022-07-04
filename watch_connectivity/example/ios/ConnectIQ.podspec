Pod::Spec.new do |s|
    s.name             = "ConnectIQ"
    s.version          = "1.5"
    s.summary          = "Cocoapods wrapper for the ConnectIQ framework"
    s.homepage         = "https://developer.garmin.com/connect-iq"
    s.author           = { "" => "" }
    s.license          = ""

    s.source           = { :http => "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-mobile-sdk-ios-#{s.version}.zip", :type => "zip" }
    s.vendored_frameworks = "#{s.name}.xcframework"
    s.compiler_flags = "–ObjC"
end
