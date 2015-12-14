1.将NYShareEngine 拖入工程
2.在Targets->Build Phases->Link Binary With Libraries中添加QuartzCore.framework、ImageIO.framework、SystemConfiguration.framework、
Security.framework、CoreTelephony.framework、CoreText.framework、 UIKit.framework、Foundation.framework、CoreGraphics.framework 、libz.dylib、 libsqlite3.dylib、SystemConfiguration.framework,libz.dylib,libsqlite3.0.dylib,libc++.dylib，
”Security.framework”, “libiconv.dylib”，“SystemConfiguration.framework”，“CoreGraphics.Framework”、“libsqlite3.dylib”、“CoreTelephony.framework”、“libstdc++.dylib”、“libz.dylib”。
3.程序 Target->Buid Settings->Linking 下 Other Linker Flags 项添加-ObjC。
4.实现app delegate的方法
5.设置app key等
6.注册应用