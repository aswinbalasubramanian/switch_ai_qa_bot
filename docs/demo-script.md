# Demo video script (about 2.5 minutes)

Record the screen with Telegram on the left and Switch Console (room Chat tab) on the right, plus a browser tab of GitHub Issues.

**0:00 to 0:20, the problem (voice over the GitHub Issues list)**
"Our QA team splits the app by module: login, cart, checkout, profile. Modules overlap, so two testers often find the same bug and both file it. Asking 'has anyone filed this?' in the group means waiting for someone to answer."

**0:20 to 0:35, the setup (Switch Console, room Configuration)**
"We connected our Telegram group to Switch. Two Claude Code agents sit in the room: dup-checker searches GitHub Issues, bug-filer writes and files bugs. Nothing gets filed without a human saying 'file it'."

**0:35 to 1:00, scene 1: a clear duplicate**
Type: `@dup-checker Login button is greyed out even with correct email and password`
Show the reply: DUPLICATE of #2, with the link. Say: "It caught the duplicate in seconds. No new ticket."

**1:00 to 1:45, scene 2: the module owner decides**
Type: `@dup-checker Discount applied twice when I tap Apply quickly on the cart`
The agent links #6. The owner (Natesan or you) replies "different". Show dup-checker handing off to @bug-filer in the chat.
Say: "When it's not sure, the agent asks the person who owns that module, right in the group."

**1:45 to 2:20, scene 3: a new bug, filed with approval**
Type: `@dup-checker On the profile page, changing my email and pressing Save does nothing`
NO DUPLICATE, then bug-filer posts a draft. Reply `file it`. Switch to GitHub and refresh: the new issue appears with the `module:profile` label.

**2:20 to 2:40, why Switch**
Show the Switch Console room with both agents and both people.
"Two agents and two people hand work to each other in one chat. Without Switch these are separate terminals that nobody connects. Switch routes the mentions, runs the agents on my laptop, and keeps the human in charge."

**End card:** repo link and "Built with Switch + Claude Code".
