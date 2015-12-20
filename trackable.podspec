Pod::Spec.new do |s|
  s.name = 'Trackable'
  s.version = '0.2'
  s.license = 'MIT'
  s.homepage = 'https://github.com/VojtaStavik/Trackable'
  s.social_media_url = 'http://twitter.com/VojtaStavik'
  s.authors = { "Vojta Stavik" => "stavik@outlook.com" }
  s.source = { :git => 'https://github.com/VojtaStavik/Trackable', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files   = 'Trackable/*.swift'
  s.frameworks = 'Foundation'
  s.requires_arc = true
end
