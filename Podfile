# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'switchPriceKana' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for switchPriceKana
  pod 'Kanna'
  pod 'SCLAlertView'
  pod 'Firebase/Analytics'
  pod 'Firebase/Database'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Core'
  pod 'Firebase/AdMob'
  pod 'Firebase/Messaging'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end
end
