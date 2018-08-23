Pod::Spec.new do |s|
  s.name = 'JSONObjectMapper'
  s.version = '0.1.3'
  s.summary = 'JSON to Core Data mapper for iOS'
  s.description = <<-DESC
    JSONObjectMapper lets you to easily map JSON data to Core Data objects by
    defining simple mappings in your classes without rewriting the same 
    manual bolierplate conversion code over and over again. It's written in 
    Objective-C but can be used in Swift projects as well. See the README for 
    more information and examples.
  DESC
  s.homepage = 'https://github.com/sryze/JSONObjectMapper'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Sergey Zolotarev' => 'sryze@protonmail.com' }
  s.source = { :git => 'https://github.com/sryze/JSONObjectMapper.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'JSONObjectMapper/Classes/**/*'
  s.public_header_files = [
    'JSONObjectMapper/Classes/JSONAttributeMapping.h',
    'JSONObjectMapper/Classes/JSONMappingProtocol.h',
    'JSONObjectMapper/Classes/JSONObjectMapper.h',
    'JSONObjectMapper/Classes/JSONObjectMapping.h',
    'JSONObjectMapper/Classes/JSONRelationshipMapping.h'
  ]
end
