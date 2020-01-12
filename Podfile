platform :ios, '9.0'

target 'swift-corkboard' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for swift-corkboard

    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'SVProgressHUD'
    pod 'ChameleonFramework'
    pod 'Firebase'
    pod 'Firebase/Storage'
    pod 'Firebase/Firestore'
    pod 'FirebaseUI/Storage'
    pod 'PusherSwift'
    pod 'SwiftKeychainWrapper', '~> 3.0'
    pod 'SwiftLinkPreview'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    pod 'GoogleMaps'
    pod 'YPImagePicker'
    pod 'Persei'
    pod 'SCLAlertView'
    pod 'Eureka'
    pod 'iOSDropDown'
    
  target 'swift-corkboardTests' do
    inherit! :search_paths
    # Pods for testing

    pod 'Quick'
    pod 'Nimble'

  end

  target 'swift-corkboardUITests' do
    inherit! :search_paths
    # Pods for testing

    pod 'Quick'
    pod 'Nimble'

  end

end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
end
end
end
