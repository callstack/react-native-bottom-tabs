# React Native Bottom Tabs

This is a React Native library for Bottom Tabs using native platform primitives (SwiftUI's TabView on iOS and BottomNavigationView on Android).

It can be used as a standalone library or as a drop-in replacement for the bottom tabs in React Navigation / Expo Router.

It is designed to be a drop-in replacement for JavaScript-based bottom tabs.

## GitHub account

Use the GitHub account `thiagobrez` for this repository. Scope every `gh` command with `GH_TOKEN="$(gh auth token --hostname github.com --user thiagobrez)"` so another repository's active account cannot affect it. Before GitHub mutations, verify that the same prefix with `gh api user --jq .login` returns `thiagobrez`. If that account's token is unavailable, stop and report it; keep tokens out of output and files.

## agent-device usage

Use agent-device only for app/device automation tasks. Before planning commands, run `agent-device --version` and read `agent-device help workflow`. For exploratory QA, read `agent-device help dogfood`. For logs, network, traces, or runtime failures, read `agent-device help debugging`. For React Native component trees, props/state/hooks, slow renders, or rerenders, read `agent-device help react-devtools`. For React Native apps, overlays, Metro/Fast Refresh blockers, and routing to React DevTools or debugging evidence, read `agent-device help react-native`.

Use the CLI in the integrated terminal. If `agent-device` is not on PATH but the user installed it globally in another shell, resolve the command the same way the user would from a normal terminal session and run that absolute path instead. This may require inspecting shell startup behavior or package-manager/global bin locations; do not assume the agent process `PATH` is the user's `PATH`. Do not silently fall back to `npx -y agent-device@latest`; ask or use an exact version. MCP is only a discovery/help router and does not expose device automation tools. Prefer `open -> snapshot -i -> act -> re-snapshot -> verify -> close`. Use current refs such as `@e3` for exploration and selectors for durable replay. Keep mutating commands against one session serial. Capture screenshots, logs, network, perf, traces, recordings, and `.ad` replay scripts only when they add evidence.
