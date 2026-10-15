# AudioTraverser

A lightweight Roblox Studio plugin for auditioning AudioPlayers and audio nodes.

This scaffold adds a toolbar button only. Preview mode, selection handling, audio
wiring, and cleanup are intentionally left as implementation exercises.

## Setup

With Rokit installed, run this from the project directory:

```sh
rokit install
```

## Build

Build a plugin model without installing it:

```sh
mkdir -p dist
rojo build default.project.json --output dist/AudioTraverser.rbxm
```

Install a development copy into Studio's local plugins folder:

```sh
rojo build default.project.json --plugin AudioTraverser.rbxm
```

Reopen Studio to load the local plugin. Rebuild and reload it after changes.
The toolbar button has no click behavior yet.

## Source layout

`src/init.server.luau` is the plugin entry point. Add ModuleScripts alongside it
as the implementation grows; Rojo bundles them as children of the entry script.

## Intended behavior

- A toolbar button enables or disables preview mode.
- Selecting an AudioPlayer while enabled prepares a temporary output connection
  for Studio's existing Preview control.
- Deselecting it, disabling preview mode, or unloading the plugin cleans up
  instances owned by the plugin.
- A separate plugin action can later support auditioning a specific audio node.
