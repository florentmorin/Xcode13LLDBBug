# Static framework + LLDB bug with Xcode 13.3 & 13.4

Since Xcode 13.3 and before Xcode 14 beta, a strange bug appears when trying to use a static framework / library with LLDB or when using CocoaPods with frameworks and static linkage.

When using a simple LLDB command like `po <something>` on framework code, this message appears in debugging console:

```
error: expression failed to parse:
error: Couldn't realize type of self.
```

## Reproduce the bug

The project can be tested by opening `AppWithInternalFramework/AppWithInternalFramework.xcworkspace`, `AppWithInternalStaticLibrary/AppWithInternalStaticLibrary.xcworkspace` and `AppWithInternalPod/AppWithInternalPod.xcworkspace`.

If you run the app on a simulator, a shared breakpoint will be triggered.

### In command line

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


## Tests results

| Xcode version | Result |
| ------------- | ------ |
| 13.2.1        | ✅     |
| 13.3.1        | ❌     |
| 13.4.1        | ❌     |
| 14.0 beta 1   | ✅     |
| 14.0 beta 2   | ✅     |

## Any solution?

If you found the bug from my code, don't hesitate to create a pull request. ^^
