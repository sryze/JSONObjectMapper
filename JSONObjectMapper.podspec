Pod::Spec.new do |s|
  s.name = 'JSONObjectMapper'
  s.version = '0.1.1'
  s.summary = 'JSON -> Core Data mapper for iOS (Objective-C)'
  s.description = <<-DESC
    JSONObjectMapper allows you to automatically map JSON data to Core Data
    entities in your Objective-C code by simply defining a single method that
    returns a mapping configuration in your entity class. See the README for
    more details and some examples.
  DESC
  s.homepage = 'https://github.com/sryze/JSONObjectMapper'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Sergey Zolotarev' => 'sryze@protonmail.com' }
  s.source = { :git => 'https://github.com/sryze/JSONObjectMapper.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'JSONObjectMapper/Classes/**/*'
end
