Pod::Spec.new do |s|
  s.name = 'Trackable'
  s.version = '0.4'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Swift app analytics using protocol extensions'
  s.homepage = 'https://github.com/VojtaStavik/Trackable'
  s.social_media_url = 'http://twitter.com/VojtaStavik'
  s.authors = { "Vojta Stavik" => "stavik@outlook.com" }
  s.source = { :git => 'https://github.com/VojtaStavik/Trackable.git', :tag => 'v0.4' }
  s.ios.deployment_target = '8.0'
  s.source_files   = 'Trackable/*.swift'
  s.frameworks = 'Foundation'
  s.requires_arc = true
end
