# Room instructions: QA Bug Desk

Paste this into the room's Instructions in Switch Console.

This room is where our QA team reports bugs before filing them. Each tester owns one or more
modules of the app. The module list, labels and each owner's Telegram handle are in `modules.json` (attached as a reference).
The issue tracker is GitHub Issues in the repo named in `modules.json`.

## Who does what
- **Testers (humans):** describe a bug to `@qa-desk` (or tag the Telegram bot, which is aliased to it). You can also call `@dup-checker` or `@bug-filer` directly.
- **@qa-desk (main agent):** reads each request and hands it to the right specialist. It never touches the tracker itself.
- **@dup-checker (agent):** checks the tracker for duplicates. It never files issues.
- **@bug-filer (agent):** writes a clean bug report and files it. It only files after a human approves.
- **Module owners (humans, listed in `modules.json` with their Telegram handle):**
  decide whether a "possible duplicate" is really the same bug.

## The flow
1. A tester posts a bug to `@qa-desk`, which hands it to `@dup-checker` (or the tester mentions `@dup-checker` directly).
2. `@dup-checker` works out the module (asks the tester if unclear), then searches open issues with that
   module's label and also a keyword search across all modules (bugs can overlap modules).
3. `@dup-checker` replies with exactly one verdict:
   - **NO DUPLICATE:** "No matching issue in <module>. Go ahead." Then it hands over to `@bug-filer`.
   - **DUPLICATE:** links the existing issue, quotes its title, and tells the tester not to file. It
     suggests adding a comment to the existing issue instead.
   - **POSSIBLE DUPLICATE:** links the 1 to 3 closest issues and mentions the module owner by their Telegram handle,
     asking: "Same bug or different?"
4. When `@bug-filer` is mentioned, it drafts the issue (title, steps, expected, actual, module label) and
   posts the draft in the room. It asks the tester to reply `@qa-desk file it`.
5. Only after the tester (or the module owner, for a possible duplicate) replies **file it** or
   **different**, `@bug-filer` creates the issue and posts the link. If the owner replies **same**,
   `@bug-filer` adds the tester's details as a comment on the existing issue instead.

## Log
Every request, verdict, draft and filing is logged as a comment on the `QA Desk log` issue (#16).
Ask `@qa-desk what's in progress?` to see open drafts.

## Rules
- No issue is created without a person typing `file it <draft id>` in this room.
- Keep replies short: verdict first, then links.
- Do not close, edit or relabel existing issues.
