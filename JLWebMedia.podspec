Pod::Spec.new do |s|

  s.name         = "JLWebMedia"
  s.version      = "1.0.0"
  s.summary      = "A short description of JLWebMedia."

  s.description  = <<-DESC
                   A longer description of JLWebMedia in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/JLWebMedia"

  s.license      = "MIT"

  s.author             = { "JeremyLyu" => "734875137@qq.com" }

  s.source       = { :git => "https://github.com/JeremyLyu/JLWebMedia.git" }

  s.source_files  = "Classes", "JLWebMedia/Classes/**/*.{h,m}"

  s.requires_arc = true

  s.platform = :ios

  s.ios.deployment_target = "6.0"

end
