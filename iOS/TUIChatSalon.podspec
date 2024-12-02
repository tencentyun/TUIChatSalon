Pod::Spec.new do |spec|
  spec.name         = 'TUIChatSalon'
  spec.version      = '1.0.0'
  spec.platform     = :ios
  spec.ios.deployment_target = '11.0'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIChatSalon'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  spec.swift_version = '5.0'

  spec.dependency 'Alamofire'
  spec.dependency 'SnapKit'
  spec.dependency 'MJExtension'
  spec.dependency 'MJRefresh'
  spec.dependency 'Toast-Swift'
  spec.dependency 'Kingfisher', '<= 6.3.1'
  spec.dependency 'TXAppBasic'
  spec.dependency 'TUICore/ImSDK_Scenario'
  
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :git => '', :tag => "#{spec.version}" }
  spec.source_files = 'Source/**/*.{h,m,mm,swift}', 'Source/*.{h,m,mm,swift}'
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  spec.default_subspec = 'TRTC'
  spec.subspec 'TRTC' do |trtc|
    trtc.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/../../SDK/TXLiteAVSDK_TRTC.framework/Headers/'}
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.source_files = 'Source/Localized/**/*.{h,m,mm,swift}', 'Source/model/**/*.{h,m,mm,swift}', 'Source/ui/**/*.{h,m,mm,swift}', 'Source/TUIChatSalonKit_TRTC/*.{h,m,mm,swift}'
    trtc.ios.framework = ['AVFoundation', 'Accelerate']
    trtc.library = 'c++', 'resolv'
    trtc.resource_bundles = {
      'TUIChatSalonKitBundle' => ['Resources/localized/**/*.strings','Resources/*.xcassets']
    }
  end
 
  spec.subspec 'Enterprise' do |enterprise|
    enterprise.dependency 'TXLiteAVSDK_Enterprise'
    enterprise.source_files = 'Source/Localized/**/*.{h,m,mm,swift}', 'Source/model/**/*.{h,m,mm,swift}', 'Source/ui/**/*.{h,m,mm,swift}', 'Source/TUIChatSalonKit_Enterprise/*.{h,m,mm,swift}'
    enterprise.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    enterprise.library = 'c++', 'resolv', 'sqlite3'
    enterprise.resource_bundles = {
      'TUIChatSalonKitBundle' => ['Resources/localized/**/*.strings','Resources/*.xcassets']
    }
  end

  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.source_files = 'Source/Localized/**/*.{h,m,mm,swift}', 'Source/model/**/*.{h,m,mm,swift}', 'Source/ui/**/*.{h,m,mm,swift}', 'Source/TUIChatSalonKit_Professional/*.{h,m,mm,swift}'
    professional.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    professional.library = 'c++', 'resolv', 'sqlite3'
    professional.resource_bundles = {
      'TUIChatSalonKitBundle' => ['Resources/localized/**/*.strings','Resources/*.xcassets']
    }
  end
  
end

