# Ash Vigil

This `Backstage` folder won't be released to Nexus. It's just for internal notes and tools.

## Development Setup

Run these commands from the project root directory:

```sh
git config core.hooksPath .githooks
git config --local include.path .gitconfig.local
git config --local push.autoSetupRemote true
```

This will keep `AshVigil_readonly.json` up-to-date. Don't edit this file directly; it will be overwritten all the time. This is important so we can see what's actually changing in the omwaddon during git diffs. It will let us catch accidental edits, and should help with merge conflicts.

## Development Guides

- Dialogue Editor: https://www.nexusmods.com/morrowind/mods/58547
- Dialogue Guide: https://wiki.project-tamriel.com/wiki/Writing_and_Dialogue_Guidelines#How_Dialogue_Works

### Git tips for Windows Users

After you install git (and git bash), you should have a file in `C:\Users\NAME\.bashrc`. If you don't have that file, go ahead and make it now.

In that file, add these lines:

```sh
# Change UPSTREAM to "master" if the repo is old.
export UPSTREAM="main"
# Start a new branch off the latest main
alias gidup='test -z "$(git status --porcelain)" && git checkout ${UPSTREAM} && git fetch origin ${UPSTREAM} && git reset --hard origin/${UPSTREAM} && git checkout -b'
# Clean directory (remove git-ignored files and un-committed files)
alias gclean='git clean -fdx'
# Combine all commits on branch into one.
alias gmush='test -z "$(git status --porcelain)" && git reset --soft $(git merge-base HEAD ${UPSTREAM})'
# Update main
alias gupdate='test -z "$(git status --porcelain)" && git checkout ${UPSTREAM} && git fetch origin ${UPSTREAM} && git reset --hard origin/${UPSTREAM}'
```

Before you start editing files, open up your git bash terminal and run this: `gidup nameofthingimworkingon`. This will make a new local branch based on the latest changes from the repo. Then make your edits. Then run `git add -A` to stage all your edits. Then run `git commit -m "description of what i did"`. This will bundle up all your changes into a local commit. Then run `git push`. This will send your branch to the remote repository. Then you can go to https://github.com/ernmw/ash_vigil and make a pull request based on your branch. That will let you review all the stuff you changed. If you're happy with the edits, then you'll merge your branch to `main`. This will incorporate it into the branch, so any future edits will include your changes.
