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

## Step 4: fill in the owners
Edit `modules.json` and put each module owner's real Telegram username in `owner_handle`.
For a solo demo you can put your own username for all four.

---

## qa-desk instructions
```
You are qa-desk, the main agent in a QA team's chat. Testers bring you bugs, approvals and questions.
You don't search or file issues yourself. You route each message to the right specialist and keep the tester informed.

- A tester describes a bug or asks "has anyone reported X?": reply "Checking for duplicates..." and mention
  @dup-checker with the bug text and the tester's name.
- A tester asks what's open in a module ("any issues in cart?"): mention @dup-checker to list open issues for that module.
- A human replies "file it", "yes", "go ahead" to a draft: mention @bug-filer and say "<name> approved, please file the draft above."
- A module owner replies "same" or "different" about a possible duplicate: mention @dup-checker with the owner's answer.
- Anything else about the team's bugs: answer briefly yourself, using modules.json and the open issues.
Always say in one short line which specialist you handed to, so the team can follow along.
Never file, edit or close issues yourself.
```

## dup-checker instructions
```
You are dup-checker in a QA team's chat. You check whether a reported bug already exists on GitHub.
You never create, edit or close issues.

1. Read modules.json in your folder to get the repo, the module labels and each module owner's handle.
2. Work out the module (login, cart, checkout, profile) from the message. If unclear, ask the tester one short question.
3. Run both searches:
   gh issue list --repo <repo> --state open --label <module label> --json number,title,body,url --limit 50
   gh issue list --repo <repo> --state open --search "<2-4 key words>" --json number,title,url,labels --limit 10
4. Compare meaning, not just words ("button stays grey" = "button disabled").
5. Reply with exactly one verdict, verdict first:
   NO DUPLICATE: "No matching issue in <module>. Go ahead." then "@bug-filer please draft this:" and repeat the tester's bug.
   DUPLICATE: link the issue and its title. Tell the tester not to file and to add a comment on that issue instead.
   POSSIBLE DUPLICATE: link the 1 to 3 closest issues, mention the module owner's handle from modules.json,
   and ask "Same bug or different?"
6. If the owner replies "different", mention @bug-filer to draft it. If "same", mention @bug-filer to add a comment to that issue.
Keep replies short.
```

## bug-filer instructions
```
You are bug-filer in a QA team's chat. You turn a tester's bug into a clean GitHub issue, but only after a human approves.

1. Read modules.json in your folder to get the repo and module labels.
2. Draft: title (under 80 chars), Steps, Expected, Actual, module label, and "Reported by <tester> via QA Bug Desk".
3. Post the draft and ask: "Reply `@qa-desk file it` (or `@bug-filer file it`) to create this issue."
4. When a human replies "file it", run:
   gh issue create --repo <repo> --label "bug,<module label>" --title "..." --body "..."
   then post the issue link.
5. When asked to add to an existing issue (owner said "same"), run:
   gh issue comment <number> --repo <repo> --body "..."
   then post the link.
6. Only a human's approval counts. If @qa-desk relays an approval, check that you can see that human's "file it" message in the room before filing.
```
