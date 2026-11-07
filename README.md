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
Tester: "@TwinTurbines_Aibot login button stays grey"     (the bot is aliased to @qa-desk)
   │
   ▼
@qa-desk ── routes ──▶ @dup-checker ── gh issue list ──▶ GitHub Issues
                           │
     ┌──── NO DUPLICATE ───┼──── DUPLICATE ────┬──── POSSIBLE DUPLICATE ────┐
     ▼                     ▼                   │                            ▼
 @bug-filer drafts    link to existing issue   │           pings the module owner: "same or different?"
     │                                         │                 "different" │ "same"
 human: "file it" ──▶ gh issue create ◀────────┴─────────────────────────────┘  └─▶ gh issue comment
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
   (`!set-alias @qa-desk <@your_bot>`), paste
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

## Handling the hard cases
- **Approval gate:** bug-filer only files after a person types `file it <draft id>`. "ok", "raise an issue" or another agent relaying approval don't count, and bug-filer checks the room for the person's own message.
- **Bugs that come back:** dup-checker searches closed issues too and answers `REGRESSION?`, asking the module owner whether to reopen or file new.
- **History and backup:** every draft, filing and cancel is logged as a comment on the `QA Desk log` issue (#16). Only bug-filer writes to GitHub; the other agents just read. Drafts survive an agent restart because bug-filer reads them back from there.
- **Two people, same bug, same minute:** drafts are logged as `IN-PROGRESS` before anyone files, and dup-checker checks that list, so the second tester gets `ALREADY BEING REPORTED`. Ask `@TwinTurbines_Aibot what's in progress?` to see who is reporting what.

## Security and guardrails
Anyone in the group can type to the desk, and it can write to GitHub, so it's guarded in layers
(details in [docs/security.md](docs/security.md)):
- **Input guard:** off-topic chat, bad words, prompt-injection tricks, "which AI are you?", risky asks and pasted secrets get one fixed polite line, and no agent work starts.
- **Least privilege:** qa-desk and dup-checker are read-only. Only bug-filer can write, only `gh issue` commands, and only after a person types `file it <draft id>`.
- **Output guard:** blocks any reply that names the model, vendor, tools, file paths or internal errors, links outside this repo, or runs long.
- **Evals:** 109 labelled cases in `evals/`, run by a GitHub Action on every change (`python evals/run_evals.py`).
- **Audit:** issue #16 logs every draft, filing and approver.

## Known limitations
- The approval gate is enforced by the agents' instructions, not by a hard permission. Switch logs who sent each message, so every filing can be traced to a person in issue #16.
- Switch runs on one laptop, so the agents are only available while it's on.
- Switch always posts a short "Worked for Ns" status under each agent turn. It can't be turned off, so the agents keep their own replies to 1 to 3 lines.

## Files
- `modules.json`: modules, labels and owner Telegram handles
- `seed/seed_issues.sh`: creates labels and 10 sample bugs
- `switch/room-instructions.md`: the room's Instructions
- `switch/agents.md`: click-by-click agent setup and instructions
- `docs/demo-script.md`: the script for our demo video
- `guardrails/guard.py`: input and output guard (also runs as Claude Code hooks via `guardrails/claude-settings.json`)
- `evals/`: guardrail test cases, runner and latest report
- `docs/security.md`: threat model, layers and known limits
