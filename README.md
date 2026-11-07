# QA Bug Desk: stop filing duplicate bugs

A QA team splits an app by module. Modules overlap, so two testers often find the same bug and both file it.
Asking "has anyone filed this?" in the group chat means waiting for people to reply.

QA Bug Desk puts three AI agents in the team chat (via [Switch](https://docs.switchagents.ai/)) next to the testers:

- **@qa-desk** is the one agent testers talk to. It hands each request to the right specialist.

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
   Connect a chat app. We used a Telegram group through our own bot (Admin > Messaging apps > Telegram);
   the bundled Mattermost also works if you don't want Telegram.
2. Clone this repo and run `gh auth login` on the same machine. The agents use `gh` to search and file issues.
3. Seed the demo tracker: `REPO=<you>/<repo> ./seed/seed_issues.sh`, and set the same repo and your
   chat usernames in `modules.json`.
4. Create `qa-desk`, `dup-checker` and `bug-filer` with [`switch/agents.md`](switch/agents.md). Set each agent's
   **Who can talk to your agent** to **Anyone** so teammates who aren't Switch users can use them.
5. Invite the agents to the room (`!invite-agent @qa-desk`, `@dup-checker`, `@bug-filer`), alias the bot to the main agent
   (`!set-alias @qa-desk @<your_bot>`), paste
   [`switch/room-instructions.md`](switch/room-instructions.md) into the room's **Instructions**, and send
   `!follow-ups off` so agents only answer when mentioned by name.
6. Try the three demo scenarios below.

### Things we learned setting it up
- Agents aren't Telegram members, so Telegram's @ autocomplete won't list them. Type the name in full.
- With follow-ups on, an agent treats your next message as meant for it, even a chat with a friend. Turn it off in group chats.
- Switch roles can only be held by agents, so human module owners are pinged by their chat username from `modules.json`.
- Edited Telegram messages may not reach the agents. Send a new message instead.

## Demo scenarios
| Tester says | Expected result |
|---|---|
| "@dup-checker On the profile page, changing my email and pressing Save does nothing" | NO DUPLICATE, draft, "file it", new issue |
| "@dup-checker Login button is greyed out even with correct email and password" | DUPLICATE of the "Login button stays disabled" issue |
| "@dup-checker Discount applied twice when I tap Apply quickly on the cart" | Links #6 (coupon applied twice). If the tester or owner says "different", it goes to bug-filer |

## Files
- `modules.json`: modules, labels and owner Telegram handles
- `seed/seed_issues.sh`: creates labels and 10 sample bugs
- `switch/room-instructions.md`: the room's Instructions
- `switch/agents.md`: click-by-click agent setup and instructions
- `docs/demo-script.md`: the script for our demo video
