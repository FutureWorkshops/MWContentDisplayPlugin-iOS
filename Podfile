source 'https://cdn.cocoapods.org/'
source 'https://github.com/FutureWorkshops/MWPodspecs.git'

workspace 'MWContentDisplay'
platform :ios, '13.0'

inhibit_all_warnings!
use_frameworks!

project 'MWContentDisplay/MWContentDisplay.xcodeproj'
project 'MWContentDisplayPlugin/MWContentDisplayPlugin.xcodeproj'

abstract_target 'MobileWorkflowContentDisplay' do
  pod 'MobileWorkflow'
  pod 'Kingfisher', '~> 6.0'

  target 'MWContentDisplay' do
    project 'MWContentDisplay/MWContentDisplay.xcodeproj'

    target 'MWContentDisplayTests' do
      inherit! :search_paths
    end
  end

  target 'MWContentDisplayPlugin' do
    project 'MWContentDisplayPlugin/MWContentDisplayPlugin.xcodeproj'

    target 'MWContentDisplayPluginTests' do
      inherit! :search_paths
    end
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
  end
end

