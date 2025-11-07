# SplashScreen Visual Guide

## Screen Layout

```
┌──────────────────────────────────────┐
│                                      │
│           (Empty Space)              │
│                                      │
│                                      │
│         ┌───────────────┐            │
│         │               │            │
│         │   ◯ Watch     │  ← Animated Logo
│         │     Icon      │    (Fade + Scale)
│         │               │            │
│         └───────────────┘            │
│                                      │
│        Smart Watch         ← Title   │
│                                      │
│     Health Data Monitor  ← Subtitle │
│                                      │
│                                      │
│           (Empty Space)              │
│                                      │
│              ⟳                       │
│                                      │
│    Checking authentication...        │
│                                      │
│                                      │
│         Version 1.0.0                │
│                                      │
└──────────────────────────────────────┘
```

## State Variations

### 1. Initial/Loading State
```
    ⟳
Checking authentication...
```

### 2. Authenticated + Biometric Check
```
    ⟳
Verifying biometric...
```

### 3. Error State (with SnackBar)
```
┌──────────────────────────────────────┐
│  ❌ Authentication error occurred    │
└──────────────────────────────────────┘
```

## Dialog Variations

### Biometric Failed Dialog
```
┌─────────────────────────────────────┐
│ Authentication Failed               │
│                                     │
│ Biometric authentication failed.   │
│ Please try again or logout.         │
│                                     │
│        [Logout]    [Try Again]      │
└─────────────────────────────────────┘
```

### Biometric Error Dialog
```
┌─────────────────────────────────────┐
│ Error                               │
│                                     │
│ An error occurred during            │
│ authentication: [error message]     │
│                                     │
│     [Logout]    [Continue Anyway]   │
└─────────────────────────────────────┘
```

## Color Scheme

### Light Theme
- Background: `#F8FAFC` (Very light gray)
- Logo Border: `#3B82F6` (Blue)
- Logo Background: `#3B82F6` with 10% opacity
- Text Primary: `#1E293B` (Dark gray)
- Text Secondary: `#64748B` (Medium gray)

### Dark Theme
- Background: `#0F172A` (Very dark blue)
- Logo Border: `#60A5FA` (Light blue)
- Logo Background: `#60A5FA` with 10% opacity
- Text Primary: `#F1F5F9` (Very light gray)
- Text Secondary: `#94A3B8` (Light gray)

## Animation Timeline

```
0ms ─────────── 750ms ──────────── 1500ms
 │                │                   │
 │    Fade In     │                   │
 ├───────────────►│                   │
 │                                    │
 │    Scale Up                        │
 ├───────────────────────────────────►│
                                      
Start              Mid               End
Opacity: 0.0       Opacity: 1.0
Scale: 0.5         Scale: 1.0
```

## Navigation Flow Chart

```
                  ┌─────────────┐
                  │ SplashScreen│
                  └──────┬──────┘
                         │
                         ▼
              ┌──────────────────┐
              │ Check Auth Status│
              └─────────┬────────┘
                        │
          ┌─────────────┼─────────────┐
          │             │             │
          ▼             ▼             ▼
    ┌─────────┐   ┌──────────┐  ┌────────┐
    │Unauthen-│   │Authenti- │  │ Error  │
    │ticated  │   │cated     │  │        │
    └────┬────┘   └────┬─────┘  └───┬────┘
         │             │             │
         │             ▼             │
         │    ┌────────────────┐    │
         │    │ Check Biometric│    │
         │    └────────┬───────┘    │
         │             │             │
         │    ┌────────┼────────┐   │
         │    │        │        │   │
         │    ▼        ▼        ▼   │
         │  ┌────┐ ┌─────┐ ┌─────┐ │
         │  │Not │ │Dis- │ │Ena- │ │
         │  │Avail│ │abled│ │bled │ │
         │  └──┬─┘ └──┬──┘ └──┬──┘ │
         │     │      │       │     │
         │     ▼      ▼       ▼     │
         │     │      │   ┌────────┐│
         │     │      │   │Show    ││
         │     │      │   │Biometric│
         │     │      │   └────┬───┘│
         │     │      │        │    │
         │     │      │   ┌────┼───┐│
         │     │      │   │    │   ││
         │     │      │   ▼    ▼   ▼│
         │     │      │ ┌───┐┌────┐│
         │     │      │ │Fail││Err ││
         │     │      │ └─┬─┘└─┬──┘│
         │     │      │   │    │   │
         │     │      │   ▼    ▼   │
         │     │      │ ┌────────┐ │
         │     │      │ │ Dialog │ │
         │     │      │ └────┬───┘ │
         │     │      │      │     │
         │     ▼      ▼      ▼     ▼
         │  ┌────────────────────┐ │
         └─►│   MainScreen       │◄┘
            └────────────────────┘
                       ▲
                       │
         ┌─────────────┘
         │
    ┌────────────┐
    │LoginScreen │
    └────────────┘
```

## Component Hierarchy

```
SplashScreen
├── Scaffold
│   ├── backgroundColor (theme-aware)
│   └── SafeArea
│       └── Center
│           └── Column
│               ├── Spacer (flex: 2)
│               ├── AnimatedBuilder
│               │   └── FadeTransition
│               │       └── ScaleTransition
│               │           └── Container (Logo)
│               │               └── Icon
│               ├── SizedBox (height: 32)
│               ├── FadeTransition (App Name)
│               │   └── Text
│               ├── SizedBox (height: 8)
│               ├── FadeTransition (Subtitle)
│               │   └── Text
│               ├── Spacer (flex: 2)
│               ├── BlocBuilder
│               │   └── CircularProgressIndicator
│               │       └── Text (status)
│               ├── SizedBox (height: 48)
│               ├── FadeTransition (Version)
│               │   └── Text
│               └── SizedBox (height: 32)
└── BlocListener (for navigation)
```

## Size Specifications

- Logo Container: 120x120 px
- Logo Icon: 64 px
- Logo Border: 3 px
- Title Font Size: 24 px (headlineLarge)
- Subtitle Font Size: ~16 px (titleMedium)
- Version Font Size: ~12 px (bodySmall)
- Progress Indicator: Default size
- Status Text: ~14 px (bodyMedium)

## Spacing

- Top Spacer: Flex 2 (flexible)
- Logo to Title: 32 px
- Title to Subtitle: 8 px
- Content to Loading: Flex 2 (flexible)
- Loading to Version: 48 px
- Version to Bottom: 32 px

## Accessibility

- ✅ Semantic labels on important widgets
- ✅ High contrast colors (WCAG AA compliant)
- ✅ Readable font sizes
- ✅ Clear error messages
- ✅ Screen reader support (inherited from Material widgets)
- ⚠️ TODO: Add custom semantic labels for better screen reader experience

## Responsiveness

The layout uses:
- `Spacer` widgets for flexible spacing
- `Center` widget for horizontal centering
- Relative sizing with theme typography
- SafeArea for device-specific insets
- Works on all screen sizes (phone, tablet)

## Performance Notes

- Animations use `AnimationController` (efficient)
- Single `setState` minimal overhead
- Lazy loading of dependencies via get_it
- Async operations don't block UI
- Proper disposal of animation controller
