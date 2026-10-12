# lhui — Linkhive UI modules

Remote-fetched UI modules for the Linkhive "Steal An Egg" script hub. They are
loaded at runtime by `LH_SourcesHub.lua` exactly the way Airflow-UI's
`Source.luau` is:

```
game:HttpGet(url) -> disk cache -> loadstring -> call
```

The hub holds **no** UI body of its own; these files are what the runtime loads.
The **working source** is kept in the Linkhive-scripts repo at
`StealAnEgg/ui/*.luau` (edited and reviewed there); this repository is the
**published mirror** the hub fetches from — keep the two byte-identical.

## Modules (`ui/`)

| Module name (`LH_UI_FILES`) | File | What it owns |
| --- | --- | --- |
| `UI` | `ui/Linkhive_UI.luau` | palette `C` + drawing primitives |
| `Overlays` | `ui/Linkhive_Overlays.luau` | `Notify` / `Banner` / `RiskBadge` / `Splash` |
| `Dock` | `ui/Linkhive_Dock.luau` | floating Speed / Lock dock |
| `StealPanel` | `ui/Linkhive_StealPanel.luau` | Steal Panel tool window + compat chrome |
| `AntiGuard` | `ui/Linkhive_AntiGuard.luau` | Anti-Guard floating pill |
| `ESP` | `ui/Linkhive_ESP.luau` | `espModule` primitives + world tags |

## Contract

Every module is `return function(ctx) -> table`. All outer-scope dependencies are
injected through `ctx`; a module must never reference a hub local by name (it runs
in a different chunk). Each file's header comment lists the `ctx.*` keys it reads.

## Raw base URL

```
https://raw.githubusercontent.com/afkar-gg/lhui/refs/heads/main/ui/
```

`LH_SourcesHub.lua` sets `LH_UI_BASE` to this prefix and appends the file names in
`LH_UI_FILES`.

## Keep in sync

The working source is `StealAnEgg/ui/*.luau` in the Linkhive-scripts repo; this
repository mirrors it. When a UI behaviour changes:

1. Edit the module in the working source — never re-inline UI into `LH_SourcesHub.lua`.
2. Copy the updated file here (`ui/`) and push, so the runtime picks it up.
3. Keep the module's `ctx` contract, the hub call site that builds that `ctx`,
   `LH_SourcesHub.comments.md` and `AGENTS.md` consistent.
4. Adding / renaming a module is a three-point edit: the file here, the
   `LH_UI_FILES` entry, and the matching `loadUI(...)` call site.
5. Preserve the `--!mv:omit` directives on extracted functions.
6. Re-verify with `luau-compile --binary` (exit 0) plus the adapter smoke test.
