source 'https://github.com/CocoaPods/Specs.git'


platform :ios, '9.0'

workspace 'GriitChat'

def common_target_pods
    pod 'CocoaLumberjack', :configurations => ['Debug']
    pod 'SBJson', '~> 4.0.2'
    #    pod 'libjingle_peerconnection', '~> 11177.2.0'
    #pod 'nighthawk-webrtc', :podspec => './nighthawk-webrtc-chrome-m45-capture-xcode.podspec'
    pod 'SocketRocket', '~> 0.4.2'
end

target 'GriitChat' do
    pod 'KurentoToolbox', :path => "."
    pod 'MBProgressHUD', '~> 0.9.2'
    pod 'Reachability', '~> 3.2'
    pod 'DGActivityIndicatorView'
    pod 'Masonry', '~> 0.6.4'

    pod 'TrueTime', :git => 'https://github.com/instacart/TrueTime.swift', :commit => '8aadebabe2590d6ab295c390df5bbc109b346348'
    pod 'SwiftInstagram', '~> 1.1.1'

    pod 'AccountKit'
end
