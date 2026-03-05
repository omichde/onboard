# djay Onboarding Prototype

03.2026, Oliver Michalak

## What This Project Is
This repository contains an iOS onboarding flow prototype for djay.
It is implemented with UIKit, storyboard/XIB composition, and embedded child view controllers.
A shared onboarding model drives state, navigation, and transition progress across all pages.
The flow is intentionally implementation-focused and optimized for interactive UI behavior prototyping.
The project has been tested on iOS 15 and newer, on both iPhone and iPad.
It follows the [design spec](https://www.figma.com/design/89ixax554qGiZBeSI0vvq1/UI-Challenge?node-id=1-2473&t=vZoaiCuQA7Lp3zDg-11), with adjustments for landscape and iPad.

## Project Scope
- Four-page onboarding flow: `welcome`, `mix`, `skill`, `final`
- Step-button and swipe-based navigation
- Skill-gate barrier behavior before advancing beyond the skill page
- Progress-driven transitions across global and per-page UI elements

## Architecture At a Glance
- `Onboard` model: source of truth for progress and selected skill, exposed as Combine publishers
- `OnboardRootViewController`: host/orchestrator for global UI (logo, step button, pager) and page embedding
- `OnboardPagesViewController`: paged `UIScrollView` container that embeds all onboarding pages and syncs progress
- Page controllers under `Onboard/Content`: page-specific visuals and animation state logic
- `Animator` + `Animator.State`: keyframe-segment interpolation based on continuous progress

## Special Features
- Interactive swipe-driven transitions controlled by continuous progress (via `Animator`)
- Programmatic segment interpolation using `UIViewPropertyAnimator`
- Skill barrier snap-back behavior and target-offset clamping in pages scrolling
- Adaptive portrait/landscape behavior via size classes and layout variants
- SpriteKit-based particle effects on final onboarding screen
- Final step attempts to launch djay via URL scheme (`djay://`)

## Internals
- The content pages are visually self-contained, with layouts defined in XIB files.
- Initially a `UIPageViewController` was used, but it lacked the scroll interactivity needed for the transitions.
- All pages are loaded into the view hierarchy up front; not optimal, but acceptable for four pages.
- Barrier logic is intentional: swiping can overshoot briefly but snaps back to the allowed boundary.
- The `LaunchScreen` is intentionally in sync with the layout of the `welcome` screen.
- A custom gradient background view using `CAGradientLayer` was used initially, but LaunchScreen synchronization prevented it.

For onboarding flows I have used different frameworks in the past, like [Motion](https://github.com/b3ll/Motion) or [JazzHands](https://github.com/IFTTT/JazzHands), but I wanted to keep the scope focused and leverage `UIViewPropertyAnimator`.
The decision to use XIBs was mainly driven by faster UI iteration and their declarative layout model. Combined with size classes, they make responsive layouts easier to maintain while keeping controller code focused on behavior and animation. With the right abstractions or libraries, this could also be implemented fully in code.
