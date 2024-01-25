# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name          = 'WordPressUI'
  s.version       = '1.16.0'

  s.summary       = 'Home of reusable WordPress UI components.'
  s.description   = <<-DESC
                    This framework contains standalone and reusable components, brought to you by the WordPress iOS Team.
  DESC

  s.homepage      = 'https://github.com/wordpress-mobile/WordPressUI-iOS'
  s.license       = { type: 'GPLv2', file: 'LICENSE' }
  s.author        = { 'The WordPress Mobile Team' => 'mobile@wordpress.org' }

  s.platform      = :ios, '11.0'
  s.swift_version = '5.0'

  s.source = { git: 'https://github.com/wordpress-mobile/WordPressUI-iOS.git', tag: s.version.to_s }

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/WordPressUI/**/*.{h,m,swift}', 'Sources/WordPressUIObjC/**/*.{h,m,swift}'
    core.resource_bundles = {
      WordPressUIResources: [
        'Sources/WordPressUI/Resources/*.{xcassets,storyboard}'
      ]
    }

    core.test_spec do |test|
      test.source_files = ['Tests/WordPressUITests/**/*.{swift,h,m}']
    end
  end

  s.subspec 'Gravatar' do |gravatar|
    gravatar.source_files = 'Sources/Gravatar/*.swift'
    gravatar.resource_bundles = {
      GravatarResources: [
        'Sources/Gravatar/Resources/*.xcassets'
      ]
    }

    gravatar.test_spec do |test|
      test.source_files = ['Tests/GravatarTests/**/*.swift']
    end
  end
end
