#
#   Created by : Nghia Tran
#
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.12'
workspace 'UberGoWorkspace.xcworkspace'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

# Pods
def important_pods

    # Core
    pod 'Alamofire', '~> 4.4'
    pod 'ObjectMapper', '~> 2.2'
    pod 'RxSwift',    '~> 3.0'
    pod 'RxCocoa',    '~> 3.0'
    pod 'SwiftLint'
    pod 'OAuthSwift', '~> 1.1.0'
    pod 'SwiftyBeaver'
end

# UberGo
target "UberGo" do
  project 'UberGo/UberGo.xcodeproj'
  important_pods
end

# UberGoCore
target "UberGoCore" do
  project 'UberGoCore/UberGoCore.xcodeproj'
  important_pods
end

# UberGoCoreTests
target "UberGoCoreTests" do
  project 'UberGoCore/UberGoCore.xcodeproj'
  important_pods
end

# UberGoTests
target "UberGoTests" do
  project 'UberGo/UberGo.xcodeproj'
  important_pods
end

# Configuration
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.12'
    end
  end
end
