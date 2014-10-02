xcodebuild clean -project "Epub.xcodeproj"
xcodebuild -project "Epub.xcodeproj" -sdk "iphoneos7.1" -configuration "Release" -target "Epub" install DSTROOT="app_file"
xcrun -sdk "iphoneos7.1" PackageApplication "${PWD}/app_file/Applications/Epub.app" -o "${PWD}/ipa_file/Epub.ipa" -embed "~/Library/MobileDevice/Provisioning\  Profiles/36f2a6a7-f8ba-44a9-a4e3-e997dc72980a.mobileprovision"
