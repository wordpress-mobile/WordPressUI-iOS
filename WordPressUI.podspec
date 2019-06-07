Pod::Spec.new do |s|
  s.name          = "WordPressUI"
  s.version       = "1.3.2"
  s.summary       = "Home of reusable WordPress UI components."

  s.description   = <<-DESC
                    This framework contains standalone and reusable components, brought to you by the WordPress iOS Team.
                    DESC

  s.homepage      = "http://apps.wordpress.com"
  s.license       = "GPLv2"
  s.author        = { "Jorge Leandro Perez" => "jorge.perez@automattic.com" }
  s.platform      = :ios, "10.0"
  s.swift_version = '4.2'
  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressUI-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressUI/**/*.{h,m,swift}'
  s.resource_bundles = {
    'WordPressUIResources': [
      'WordPressUI/Resources/*.{xcassets}',
      'WordPressUI/**/*.{storyboard}'
    ]
  }
  s.requires_arc  = true
  s.header_dir    = 'WordPressUI'
end

