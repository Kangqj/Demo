#! /bin/bash
echo "archive..."
xcodebuild -scheme iADdemo -archivePath build/iADdemo.xcarchive archive
echo "export ipa..."
xcodebuild -exportArchive -exportFormat IPA -archivePath build/iADdemo.xcarchive -exportPath build/iADdemo.ipa
