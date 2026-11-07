# Demo video script (about 2.5 minutes)

Record Telegram (the "Ai Switch Group" chat) full screen, with a browser tab of GitHub Issues ready to switch to.
Before recording: run `!reset-all-agents`, make sure the laptop won't sleep, and pick bug texts that aren't already in the repo.

**0:00 to 0:20, the problem (voice over the GitHub Issues list)**
"Our QA team splits the app by module: login, cart, checkout, profile. Modules overlap, so two testers often find the same bug and both file it. Asking 'has anyone filed this?' in the group means waiting for someone to answer."

**0:20 to 0:35, the setup (Switch Console, Your Agents)**
"We connected our Telegram group to Switch. Three agents sit in the room: qa-desk is the front desk, dup-checker searches GitHub Issues, bug-filer writes and files bugs. Testers only talk to the bot. Nothing gets filed until a person types 'file it'."

**0:35 to 0:55, scene 1: a clear duplicate**
Type: `@TwinTurbines_Aibot Login button is greyed out even with correct email and password`
qa-desk hands it to dup-checker, which replies DUPLICATE of #2 with the link. Say: "One message, one answer. No new ticket."

**0:55 to 1:35, scene 2: a new bug, filed only after approval**
Type: `@TwinTurbines_Aibot <a new bug, e.g. Wishlist heart icon doesn't stay filled after refreshing the cart page>`
NO DUPLICATE, then bug-filer posts a short draft with an id like D-1405-cart.
Type `ok` first and show that it is NOT filed. Then type `@bug-filer file it D-1405-cart`.
Switch to GitHub and refresh: the new issue appears with the `bug` and `module:cart` labels.

**1:35 to 2:05, scene 3: two testers, one bug**
Before filing, a second person (Natesan) reports the same bug in different words.
dup-checker replies ALREADY BEING REPORTED with the draft id, so it isn't filed twice.
Then type `@TwinTurbines_Aibot what's in progress?` and show the one-line list.
Optional: report a bug that matches a closed issue and show REGRESSION? pinging the module owner.

**2:05 to 2:20, the log**
Open issue #16 on GitHub: every draft, filing and cancel is logged there with who approved it.
"This is the team's shared memory. It survives restarts and shows who is working on what."

**2:20 to 2:40, why Switch**
Show Switch Console with the three agents and the Telegram room.
"Three agents and a team of people hand work to each other in one group chat. Without Switch these are separate terminals nobody connects. Switch routes the mentions, runs the agents on my laptop, and keeps people in charge of what gets filed."

**End card:** repo link and "Built with Switch".
