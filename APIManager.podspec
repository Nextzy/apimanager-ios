
Pod::Spec.new do |s|
  s.name             = 'APIManager'
  s.version          = '0.0.1'
  s.summary          = 'APIManager for Nextzy'

  s.homepage         = 'http://nextzy.me/'
  s.license      = 'MIT'
  s.author           = { 'Thongpak Pongsilathong' => 'thongpak21@gmail.com' }
  s.source       = { :git => 'https://github.com/Nextzy/apimanager-ios.git',:tag => s.version.to_s}

  s.ios.deployment_target = '8.0'
  s.exclude_files = '**/AppDelegate.swift'
  s.resources = 'CommonClassMyAIS-Resources/**/*.{xcassets,storyboard,xib,xcdatamodeld,lproj,crt,cer}'
  s.preserve_paths = 'CommonClassMyAIS-Resources/**/*.{lproj}',

  s.framework  = 'UIKit'
  s.preserve_paths = 'Crashlytics.framework'
  s.requires_arc = true
  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
    ss.ios.dependency 'CommonClassMyAIS/CommonMyAIS'
    ss.ios.dependency 'CommonClassMyAIS/CommonMyAIS-Lib'
    ss.ios.dependency 'CommonClassMyAIS/GlobalFile'

    ss.dependency 'Alamofire'

  end

  s.subspec 'CommonMyAIS' do |ss|
    ss.source_files  = 'CommonMyAIS/**/*'
  end

  s.subspec 'CommonMyAIS-Lib' do |ss|
  	ss.source_files  = 'CommonClassMyAIS-Lib/**/*'
  end

  s.subspec 'GlobalFile' do |ss|
    ss.source_files  = 'GlobalPrefix-Files/**/*'
  end

end
