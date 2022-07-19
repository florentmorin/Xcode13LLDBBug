# Static framework + LLDB bug with Xcode 13.3 & 13.4

Since Xcode 13.3 and before Xcode 14 beta, a strange bug appears when trying to use a static framework with LLDB or when using CocoaPods with frameworks and static linkage.

When using a simple LLDB command like `po <something>` on framework code, this message appears in debugging console:

```
error: expression failed to parse:
error: Couldn't realize type of self.
```

## Reproduce the bug

The project can be tested by opening `AppWithInternalFramework/AppWithInternalFramework.xcworkspace` and `AppWithInternalPod/AppWithInternalPod.xcworkspace`.

If you run the app on a simulator, a shared breakpoint will be triggered.

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
