source 'https://cdn.cocoapods.org/'
source 'https://github.com/FutureWorkshops/MWPodspecs.git'

workspace 'MWVideoGrid'
platform :ios, '13.0'

inhibit_all_warnings!
use_frameworks!

project 'MWVideoGrid/MWVideoGrid.xcodeproj'
project 'MWVideoGridPlugin/MWVideoGridPlugin.xcodeproj'

abstract_target 'MobileWorkflowVideoGrid' do
  pod 'MobileWorkflow'
  pod 'Kingfisher', '~> 6.0'
  pod 'FancyScrollView', path: '/Users/xmollv/Developer/FutureWorkshops/FancyScrollView/FancyScrollView.podspec'

  target 'MWVideoGrid' do
    project 'MWVideoGrid/MWVideoGrid.xcodeproj'

    target 'MWVideoGridTests' do
      inherit! :search_paths
    end
  end

  target 'MWVideoGridPlugin' do
    project 'MWVideoGridPlugin/MWVideoGridPlugin.xcodeproj'

    target 'MWVideoGridPluginTests' do
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

