Pod::Spec.new do |s|
  s.name          = "WordPressUI"
  s.version       = "1.9.0"

  s.summary       = "Home of reusable WordPress UI components."
  s.description   = <<-DESC
                    This framework contains standalone and reusable components, brought to you by the WordPress iOS Team.
                  DESC

  s.homepage      = "https://github.com/wordpress-mobile/WordPressUI-iOS"
  s.license       = { :type => "GPLv2", :file => "LICENSE" }
  s.author        = { "The WordPress Mobile Team" => "mobile@automattic.com" }

  s.platform      = :ios, "11.0"
  s.swift_version = '5.0'

  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressUI-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressUI/**/*.{h,m,swift}'
  s.resource_bundles = {
    'WordPressUIResources': [
      'WordPressUI/Resources/*.{xcassets}',
      'WordPressUI/**/*.{storyboard}'
    ]
  }
  s.header_dir    = 'WordPressUI'
end
