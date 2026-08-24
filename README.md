# node-rules

A Node.js toolchain for the [Please](https://please.build) build system.

This plugin does one thing: fetch a Node.js distribution for the host platform
and expose `node`, `npm`, `npx` and `corepack` as entry points. It has no
opinions about JavaScript, so a ruleset that needs a hermetic node can depend on
it without inheriting a build system for JS.

## Install

Add the plugin in `plugins/BUILD`:

```python
plugin_repo(
    name = "node",
    owner = "becomeliminal",
    plugin = "node-rules",
    revision = "v0.1.0",
)
```

Register it in `.plzconfig`:

```ini
[Plugin "node"]
Target = //plugins:node
```

Declare a toolchain in `third_party/node/BUILD`:

```python
subinclude("///node//build_defs:node")

node_toolchain(
    name = "node",
)
```

Then point the plugin config at it, so rules can find it:

```ini
[Plugin "node"]
Target = //plugins:node
NodeTool = //third_party/node:node|node
NpmTool = //third_party/node:node|npm
```

## Using it in a rule

`node` is a real binary and runs standalone. **`npm`, `npx` and `corepack` are
JavaScript**, so they are run *through* node:

```python
subinclude("///node//build_defs:node")

build_rule(
    name = "example",
    outs = ["out.txt"],
    cmd = "$TOOLS_NODE $TOOLS_NPM --version > $OUT",
    tools = {
        "node": [CONFIG.NODE.NODE_TOOL],
        "npm": [CONFIG.NODE.NPM_TOOL],
    },
)
```

The `subinclude` is required in every `BUILD` file that reads `CONFIG.NODE`, not
only in ones calling `node_toolchain` — the config namespace is scoped to files
that have loaded the plugin. A downstream ruleset gets this for free by
subincluding `///node//build_defs:node` from its own `build_defs`.

The Node.js tarball ships `bin/npm` as a symlink to a `.js` file carrying a
`#!/usr/bin/env node` shebang, so invoking `bin/npm` directly resolves node from
`$PATH` — silently using the host's node where there is one, and failing where
there is not. The entry points therefore name the scripts themselves, and the
downloaded tree is left byte-identical to what nodejs.org shipped.

## Configuration

| Config key | Default | Meaning |
|---|---|---|
| `NodeTool` | `///node//third_party/node:node\|node` | Build label for the node binary |
| `NpmTool` | `///node//third_party/node:node\|npm` | Build label for the npm CLI |
| `DefaultVersion` | `22.23.2` | Version used when `node_toolchain` is called without one |

## Versions

`node_toolchain` carries pinned SHA256 hashes for each supported release, so
callers pass a version and never a hash:

```python
node_toolchain(
    name = "node",
    version = "22.23.2",
)
```

Hashes come from `https://nodejs.org/dist/v<version>/SHASUMS256.txt` and live in
the generated block at the top of `build_defs/node.build_defs`. To use a release
that is not pinned, pass `hashes` explicitly.

Supported platforms: `linux-x64`, `linux-arm64`, `darwin-x64`, `darwin-arm64`.
