Pod::Spec.new do |s|
    s.name                  = 'MWContentDisplayPlugin'
    s.version               = '1.8.3'
    s.summary               = 'A content display plugin for MobileWorkflow on iOS.'
    s.description           = <<-DESC
    Grid step for MobileWorkflow on iOS, using UICollectionView compositional layout.
    Stack step for MobileWorkflow on iOS, using SwiftUI for the content layout.
    DESC
    s.homepage              = 'https://www.mobileworkflow.io'
    s.license               = { :type => 'Copyright', :file => 'LICENSE' }
    s.author                = { 'Future Workshops' => 'info@futureworkshops.com' }
    s.source                = { :git => 'https://github.com/FutureWorkshops/MWContentDisplayPlugin-iOS.git', :tag => "#{s.version}" }
    s.platform              = :ios
    s.swift_version         = '5'
    s.ios.deployment_target = '17.1'
    s.default_subspecs      = 'Core'
	
    s.subspec 'Core' do |cs|
        cs.dependency            'MobileWorkflow', '~> 2.1.29'
        cs.dependency            'Kingfisher', '~> 6.3.1'
        cs.source_files          = 'MWContentDisplayPlugin/MWContentDisplayPlugin/**/*.swift'
    end
end
