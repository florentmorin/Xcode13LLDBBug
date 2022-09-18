# Static framework + LLDB bug with Xcode 13.3 & 13.4 : Bug fixed! 😊

Since Xcode 13.3 and before Xcode 14 beta, a strange bug appears when trying to use a static framework / library with LLDB or when using CocoaPods with frameworks and static linkage.

When using a simple LLDB command like `po <something>` on framework code, this message appears in debugging console:

```
error: expression failed to parse:
error: Couldn't realize type of self.
```

## Reproduce the bug

The project can be tested by opening `AppWithInternalFramework/AppWithInternalFramework.xcworkspace`, `AppWithInternalStaticLibrary/AppWithInternalStaticLibrary.xcworkspace` and `AppWithInternalPod/AppWithInternalPod.xcworkspace` before fixes, at 3755cd4a325a904c555d6470641a5dac9d0da093.

It works fine with `AppWithInternalPackage` which uses a Swift Package.

If you run the app on a simulator, a shared breakpoint will be triggered.

### In command line (fixed)

In a Terminal:

```sh
cd ./CommandLineApp
./compile.sh

```

In another Terminal:

```sh
lldb
```

In LLDB:

```lldb
(lldb) process attach -n 'app' --waitfor
```


Then, in first Terminal:

```sh
./build/app
```

Back to LLDB, once detected:

```lldb
(lldb) breakpoint set -f Hello.swift -l 18
(lldb) continue
```

Wait for breakpoint to be called...

```lldb
(lldb) po name
```

#### The fix on command line

I had to append `-add_ast_path "${LIB_BUILD_PATH}/Hello.swiftmodule"` with Xcode 13.4.1. (not required with Xcode 13.2.1 or Xcode 14+)

## The solution (thank you Xcode team ❤️)

I simply need to append `-add_ast_path` on `OTHER_LDFLAGS` by using `.xcconfig` file.

### Internal framework

Append `Debug.xcconfig` for Debug configuration

```xcconfig

// Xcode 13.3+
OTHER_LDFLAGS = -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalFramework.framework/Modules/InternalFramework.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-$(SHALLOW_BUNDLE_TRIPLE).swiftmodule

// Xcode 13.2
OTHER_LDFLAGS[sdk=iphoneos15.2] = -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalFramework.framework/Modules/InternalFramework.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-ios.swiftmodule
OTHER_LDFLAGS[sdk=iphonesimulator15.2] = -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalFramework.framework/Modules/InternalFramework.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-simulator.swiftmodule

```

### Internal static library

Append `Debug.xcconfig` for Debug configuration

```xcconfig

// Xcode 13.3+
OTHER_LDFLAGS = -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalStaticLibrary.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-$(SHALLOW_BUNDLE_TRIPLE).swiftmodule

// Xcode 13.2
OTHER_LDFLAGS[sdk=iphoneos15.2] = -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalStaticLibrary.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-ios.swiftmodule
OTHER_LDFLAGS[sdk=iphonesimulator15.2] = -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalStaticLibrary.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-simulator.swiftmodule

```

### Internal Pod

Edit `Podfile`

```ruby

post_integrate do |installer|
    xcconfig_path = installer.sandbox.target_support_files_root.to_s + '/Pods-App/Pods-App.debug.xcconfig'

    xcconfig_content = File.read xcconfig_path
    xcconfig_original_ld_flags = xcconfig_content.match(/OTHER_LDFLAGS = ([^\n]+)\n/)[1]

    xcconfig_new_ld_flags = <<~CONTENT

    // Xcode 13.3+
    OTHER_LDFLAGS = #{xcconfig_original_ld_flags} -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalPod/InternalPod.framework/Modules/InternalPod.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-$(SHALLOW_BUNDLE_TRIPLE).swiftmodule

    // Xcode 13.2
    OTHER_LDFLAGS[sdk=iphoneos15.2] = #{xcconfig_original_ld_flags} -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalPod/InternalPod.framework/Modules/InternalPod.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-ios.swiftmodule
    OTHER_LDFLAGS[sdk=iphonesimulator15.2] = #{xcconfig_original_ld_flags} -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/InternalPod/InternalPod.framework/Modules/InternalPod.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-simulator.swiftmodule

    CONTENT

    xcconfig_content.gsub! /OTHER_LDFLAGS = ([^\n]+)\n/, xcconfig_new_ld_flags

    File.open(xcconfig_path, 'w') do |f|
      f.puts xcconfig_content
    end

end

```

## Tests results

| Xcode version | Result |
| ------------- | ------ |
| 13.2.1        | ✅     |
| 13.3.1        | ✅     |
| 13.4.1        | ✅     |
| 14.0.0        | ✅     |
| 14.0.1        | ✅     |
| 14.1.0 beta   | ✅     |
