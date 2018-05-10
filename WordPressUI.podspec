Pod::Spec.new do |s|
  s.name          = "WordPressUI"
  s.version       = "1.0"
  s.summary       = "Home of reusable WordPress UI components."

  s.description   = <<-DESC
                    This framework contains standalone and reusable components, brought to you by the WordPress iOS Team.
                    DESC

  s.homepage      = "http://apps.wordpress.com"
  s.license       = "GPLv2"
  s.author        = { "Jorge Leandro Perez" => "jorge.perez@automattic.com" }
  s.platform      = :ios, "10.0"
  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressUI-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressUI/**/*.{h,m,swift}'
  s.private_header_files = "WordPressUI/Private/*.h"
  s.resources     = [ 'WordPressUI/Resources/*.{ttf,otf,json}' ]
  s.exclude_files = 'WordPressUI/Exclude'
  s.requires_arc  = true
  s.header_dir    = 'WordPressUI'
end

