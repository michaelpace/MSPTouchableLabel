Pod::Spec.new do |s|
  s.name         = "MSPTouchableLabel"
  s.version      = "0.0.1"
  s.summary      = "UILabel subclass with UITableView -like data source and delegate for easy dynamic labels."
 s.description  = <<-DESC
    The MSPTouchableLabel class is a UILabel subclass which provides an interface
    for easy interaction and updates. It offers a data source and delegate for
    you to dynamically update its contents.
    DESC
  s.homepage     = "https://github.com/michaelpace/MSPTouchableLabel"
  s.screenshots  = "http://i.imgur.com/5sxXxBR.gif", "http://i.imgur.com/zwvMlp2.gif", "http://i.imgur.com/IzkJmff.gif", "http://i.imgur.com/vGlygCp.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Michael Pace" => "mpace1027@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/michaelpace/MSPTouchableLabel.git", :tag => "0.0.1" }
  s.source_files  = "MSPTouchableLabel/MSPTouchableLabel.{h,m}"
  s.requires_arc = true
end
