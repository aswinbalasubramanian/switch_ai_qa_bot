# QA Bug Desk: stop filing duplicate bugs

A QA team splits an app by module. Modules overlap, so two testers often find the same bug and both file it.
Asking "has anyone filed this?" in the group chat means waiting for people to reply.

QA Bug Desk puts two AI agents in the team chat (via [Switch](https://docs.switchagents.ai/)) next to the testers:

- **@dup-checker** searches GitHub Issues for that module the moment a tester describes a bug.
- If nothing matches, it says **"go ahead"** and hands over to **@bug-filer**, which drafts the issue.
- If something looks similar, it **pings the module owner** in chat, and the owner decides.
- **Nothing is filed until a human says "file it".**

## Why this needs Switch
The work is a handoff between two agents and several people in one chat room: the checker hands to the filer,
the checker routes to the right human owner, and the filer waits for a human approval that Switch logs with the
approver's name. Without Switch these are two separate terminals and a group chat that nobody connects.

## Flow
```
Tester ──"@dup-checker login button stays grey"──▶ @dup-checker ──gh issue list──▶ GitHub Issues
                                                       │
            ┌──────────────── NO DUPLICATE ────────────┼──────── POSSIBLE DUPLICATE ───────┐
            ▼                                          ▼                                   ▼
   "@bug-filer please draft"                 DUPLICATE: link it,                 @login-owner: "same or different?"
            │                                tester comments instead                        │
            ▼                                                                    "different" │ "same"
   draft posted ── tester: "file it" ──▶ gh issue create ◀──────────────────────────────────┘  └─▶ gh issue comment
```

## Run it yourself
1. Install Switch Console and start the local server ([quickstart](https://docs.switchagents.ai/switch-rooms/getting-started)).
   Connect a chat app (we used Telegram; the bundled Mattermost also works).
2. Fork or clone this repo. Log in to GitHub with `gh auth login`.
3. Seed the demo tracker: `REPO=<you>/<repo> ./seed/seed_issues.sh` and set the same repo in `modules.json`.
4. Create the agents with [`switch/agents.md`](switch/agents.md).
5. Create a room, paste [`switch/room-instructions.md`](switch/room-instructions.md) as its Instructions,
   and attach `modules.json` as a reference.
6. Try the three demo scenarios below.

## Demo scenarios
| Tester says | Expected result |
|---|---|
| "@dup-checker On the profile page, changing my email and pressing Save does nothing" | NO DUPLICATE, draft, "file it", new issue |
| "@dup-checker Login button is greyed out even with correct email and password" | DUPLICATE of the "Login button stays disabled" issue |
| "@dup-checker Discount applied twice when I tap Apply quickly on the cart" | POSSIBLE DUPLICATE, cart owner pinged, owner decides |

## Files
- `modules.json`: modules, labels and owner Telegram handles
- `seed/seed_issues.sh`: creates labels and 10 sample bugs
- `switch/room-instructions.md`: the room's Instructions
- `switch/agents.md`: click-by-click agent setup and instructions
