
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

  s.framework  = 'UIKit'
  s.requires_arc = true
  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
    ss.ios.dependency 'APIManager/Responses'
    ss.ios.dependency 'APIManager/Managers'

    ss.dependency 'Alamofire'

  end

  s.subspec 'Responses' do |ss|
    ss.source_files  = 'Responses/**/*'
  end

  s.subspec 'Managers' do |ss|
    ss.source_files  = 'Managers/**/*'
  end

end
