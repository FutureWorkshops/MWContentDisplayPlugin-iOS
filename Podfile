project 'MWVideoGrid/MWVideoGrid.xcodeproj'
platform :ios, '13.0'

inhibit_all_warnings!
use_frameworks!

target 'MWVideoGrid' do
end

post_install do | installer |
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
end