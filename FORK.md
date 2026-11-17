# betrOS fork of Fleather

This is a fork of [Fleather](https://github.com/fleather-editor/fleather)
(MIT) with a few small patches. Upstream's history and license are kept
unchanged; our changes are separate commits on the `betros` branch, based on
the upstream release `v1.28.0`. Only `packages/fleather` is patched.

## Patches

Each patch is a contained, opt-in change: existing behavior stays the same
unless the new option is used. When upstream releases an equivalent, the
patch is dropped.

| Patch | What it does |
| --- | --- |
| `FleatherEditor.cursorColor`, `FleatherEditor.cursorWidth` | Set the caret's color and width (the width was fixed at 2 px). |
| `bringIntoView` without a scroll position | Selecting text in a non-scrolling editor (`scrollable: false`) no longer throws. |
| `FleatherEditor.checklistTogglesWhenReadOnly` | Lets checklist items be ticked while the editor is read-only. |
| `FleatherEditor.checkboxBuilder` | Lets apps draw checklist boxes with their own widget. |

Tests: `packages/fleather/test/widgets/betros_patches_test.dart`.

Pull requests to upstream have not been opened yet; that is decided
separately.

## Using it

```yaml
dependencies:
  fleather:
    git:
      url: https://github.com/betr-os/fleather.git
      ref: <commit on betros>
      path: packages/fleather
```

## Updating to a new upstream release

```sh
git remote add upstream https://github.com/fleather-editor/fleather.git  # once
git fetch upstream --tags
git switch betros
git rebase --onto vX.Y.Z v1.28.0 betros   # replace v1.28.0 by the current base
cd packages/fleather
flutter pub get && dart analyze && flutter test
git push --force-with-lease origin betros
```

Then update the base version in this file and drop any patch upstream now
covers.
