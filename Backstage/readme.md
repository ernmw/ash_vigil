# Ash Vigil

This `Backstage` folder won't be released to Nexus. It's just for internal notes and tools.

## Development Setup

Run this command:

```sh
git config core.hooksPath .githooks
```

This will keep `AshVigil_readonly.json` up-to-date. Don't edit this file directly; it will be overwritten all the time. This is important so we can see what's actually changing in the omwaddon during git diffs. It will let us catch accidental edits, and should help with merge conflicts.

## Development Guides

- Dialogue Editor: https://www.nexusmods.com/morrowind/mods/58547
- Dialogue Guide: https://wiki.project-tamriel.com/wiki/Writing_and_Dialogue_Guidelines#How_Dialogue_Works
