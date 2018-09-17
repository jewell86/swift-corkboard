platform :ios, '9.0'

target 'swift-corkboard' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for swift-corkboard

    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'SVProgressHUD'
    pod 'ChameleonFramework'
    pod 'DZNEmptyDataSet'
    pod 'PKRevealController'
    pod 'Firebase/Core'
    pod 'Firebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'Firebase/Functions'

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
