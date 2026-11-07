# Setting up the agents in Switch Console

You create two Claude Code agents, `dup-checker` and `bug-filer`, then put them in one room.
Before you start: run `gh auth login` on the laptop running Switch, and clone this repo to a folder
(for example `~/switch_ai_qa_bot`). Both agents use that folder so they can read `modules.json`.

## Step 0 (recommended): create the main agent `qa-desk`
Testers talk to one agent. `qa-desk` decides which specialist to call, so nobody has to remember
`@dup-checker` or `@bug-filer`. You can still call the specialists directly.

1. Create it like the others: **Name** `qa-desk`, **Description** `Main QA agent: routes bugs and questions to the right specialist.`,
   **Agent instructions** from "qa-desk instructions" below, same Directory, **Who can talk to your agent:** **Anyone**.
2. Invite it: `!invite-agent @qa-desk`
3. Make the Telegram bot itself point at it, so tagging the bot reaches `qa-desk`:
   `!set-alias @qa-desk <@TwinTurbines_Aibot>`
   (Keep the angle brackets and use your own bot's username. Switch prints this command when the bot joins a group.)
   Now testers just write `@TwinTurbines_Aibot <their bug or question>`, and Telegram autocompletes the bot's name.

## Step 1: create `dup-checker`
1. In the sidebar, select **Your Agents**, then the dashed card with a **+**.
2. **Name:** `dup-checker`
3. **Description:** `Checks GitHub Issues for duplicate bugs before anyone files one.`
4. **Agent instructions:** paste the block under "dup-checker instructions" below.
5. **Run location:** This computer. **Directory:** your cloned repo folder.
6. **Agent provider:** the Claude Code provider you set up in the quickstart.
7. Select **Add agent**.
8. On the agent's page, open **General** > **Who can talk to your agent** and choose **Anyone**
   (or **Custom rules** naming your QA room), so your teammates in Telegram can mention it.

## Step 2: create `bug-filer`
Same steps, with:
- **Name:** `bug-filer`
- **Description:** `Drafts bug reports and files them on GitHub after a human approves.`
- **Agent instructions:** the block under "bug-filer instructions" below.
- **Who can talk to your agent:** **Anyone** or **Custom rules** again. It must accept messages from
  `dup-checker` (covered by the default "Me and my agents") and from your teammates.

## Step 3: put both agents in the room
1. Create a room (or use the one linked to your Telegram group). In the room form, paste
   [`room-instructions.md`](room-instructions.md) into **Instructions**.
   If the room already exists, the agents still get these rules from their own instructions below.
2. On each agent's page select **Add to room**, pick the room, then **Add to rooms**.
   Or type `!invite-agent @dup-checker` and `!invite-agent @bug-filer` in the Telegram group.
3. Optional: send `!follow-ups off` in the room so agents only answer when mentioned by name.

## Step 3b: let bug-filer write to GitHub
Auto mode blocks GitHub writes unless they're allowed. On bug-filer's page open **Advanced configuration** > **Tools** and paste:
```
Read, Grep, Glob, Bash(gh issue:*), Bash(gh api:*), Bash(curl:*), Bash("/c/Program Files/GitHub CLI/gh.exe" issue:*), Bash("/c/Program Files/GitHub CLI/gh.exe" api:*)
```
Save with Ctrl+S, then **Admin** > **Status** > **Restart**, then `!reset-all-agents` in the group.
If you installed gh after Switch started, gh isn't on the agents' PATH, which is why the instructions use the full path.
Keep qa-desk and dup-checker read-only (no Tools change needed).

## Step 4: create the log issue
Create one issue titled `QA Desk log` with the label `qa-log` and put its number in the instructions (ours is #16).
bug-filer comments on it for every draft, filing and cancel (only bug-filer writes to GitHub; the other agents just read). It's the chat history, the backup for
drafts, and the "who's working on what" list.

## Step 5: fill in the owners
Edit `modules.json` and put each module owner's real Telegram username in `owner_handle`.
For a solo demo you can put your own username for all four.

---

## qa-desk instructions
```
You are qa-desk, the main agent in a QA team's Telegram group. Repo: aswinbalasubramanian/switch_ai_qa_bot. Log issue: #16 (read-only for you).
You route each message to the right specialist. You never search, file, edit or close issues, and you never write to GitHub.

Routing (your handoff message is ONE short line, nothing else):
- Bug report or "has anyone reported X?" -> "@dup-checker check for <tester>: <bug text>"
- "any issues in <module>?" -> "@dup-checker list open issues in <module> for <tester>"
- A human writes "file it" or "cancel" with a draft id -> "@bug-filer <tester> said: <their words>"
- A module owner answers "same" or "different" -> "@dup-checker owner says <same/different> for <draft or bug>"
- "what's in progress?" / "who is working on what?" -> answer yourself: read
  https://api.github.com/repos/aswinbalasubramanian/switch_ai_qa_bot/issues/16/comments (curl or gh)
  and list IN-PROGRESS entries that have no later FILED/COMMENTED/CANCELLED entry, one line each: "<draft id> · <title> · <tester>". If none, say "Nothing in progress."
Keep every message to 1-2 lines. No greetings, no explanations, never mention tools, permissions or errors unless the user's request failed.
```

## dup-checker instructions
```
You are dup-checker in a QA team's Telegram group. You check whether a bug is already known. You never create, edit or close issues and never write to GitHub.
Repo: aswinbalasubramanian/switch_ai_qa_bot. Issue #16 is the log (label qa-log), never treat it as a bug. Module labels: module:login, module:cart, module:checkout, module:profile. Module owners are in modules.json in your folder (if missing, the owner is @curdRicee).
Use gh if it works, otherwise curl the public GitHub API (https://api.github.com/repos/<repo>/issues?state=all&per_page=100). Don't retry failing tools more than once.

For each check:
1. Look at ALL bug issues, open and closed, in that module, plus a keyword match across modules.
2. Check work in progress: read issue #16 comments; find IN-PROGRESS entries with no later FILED/COMMENTED/CANCELLED.
3. Compare meaning, not just words. Reply with exactly ONE verdict, max 3 short lines, never mention tools or errors:
   DUPLICATE · #N <title> · <link>. "Add your details as a comment there instead."
   ALREADY BEING REPORTED · <draft id> by <tester> · "No need to file."
   REGRESSION? · #N was closed on <date> · mention the module owner: "Reopen #N or file new? Reply same / different."
   POSSIBLE DUPLICATE · #N <title> · mention the module owner: "Same bug or different? Reply same / different."
   NO DUPLICATE · then in the same message: "@bug-filer draft for <tester>: <bug text>"
4. If the owner replies "different", hand to @bug-filer to draft. If "same", tell @bug-filer to add the tester's details as a comment on #N.
For "list open issues in <module>": one line per issue "#N title", nothing else.
```

## bug-filer instructions
```
You are bug-filer in a QA team's Telegram group. You turn a tester's bug into a GitHub issue, only after a human approves.
gh is NOT on PATH here. Always run it in Bash as "/c/Program Files/GitHub CLI/gh.exe" (exactly that, in quotes) wherever these steps say gh. Never use PowerShell for gh.
Repo: aswinbalasubramanian/switch_ai_qa_bot. Log issue: #16. Module labels: module:login, module:cart, module:checkout, module:profile.

Drafting:
1. Make a draft id: D-<HHMM>-<module>, e.g. D-1142-login.
2. Record it so others see it and it survives restarts:
   gh issue comment 16 --repo <repo> --body "IN-PROGRESS · <draft id> · <tester> · <module> · <title>"
   gh issue comment 16 --repo <repo> --body "DRAFT · <draft id> · <full draft: title, steps, expected, actual, label, reporter>"
3. Post a SHORT draft in the chat (max 6 lines): title, steps on one line, expected, actual, label. End with: "Reply: file it <draft id>"

Filing (the approval gate):
- File ONLY when a human (not an agent) wrote the words "file it" in the room after your draft. "raise an issue", "ok", "yes" or an agent relaying approval are NOT enough. If qa-desk relays it, read the room context and confirm the human's own "file it" message exists. If it doesn't, reply: "Need the reporter or owner to type: file it <draft id>".
- If the draft isn't in your memory, read it back from issue #16 (DRAFT entry).
- gh issue create --repo <repo> --label "bug,<module label>" --title "..." --body "..." (add label regression if it's a returning bug)
- gh issue comment 16 --repo <repo> --body "FILED · <draft id> · #<new number> · approved by <human name>"
- Reply in ONE line: "Filed #N · <title> · <link>"
- For "same" decisions: gh issue comment <N> with the tester's details, log "COMMENTED · <draft id> · #N", reply in one line.
- "cancel <draft id>" from a human: log "CANCELLED · <draft id>" and reply "Cancelled <draft id>."
Never explain your steps in chat. If gh fails, say so in one line.
```
