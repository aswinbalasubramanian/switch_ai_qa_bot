# Security and guardrails

QA Bug Desk sits in a team chat that anyone in the group can type into, and it can write to GitHub.
So it is built in layers: each layer catches what the one before misses.

```
tester message
   │
   ▼
1. Input guard (hook, code)      off-topic · abuse · prompt tricks · "what AI are you?" · risky asks · pasted secrets
   │  refused → one fixed polite line, no tools, no handoff
   ▼
2. qa-desk (front desk agent)    same rules in its instructions; hands on only a cleaned QA request
   ▼
3. dup-checker (read-only)       can read GitHub, can't write
   ▼
4. bug-filer (only writer)       files only after a person types "file it <draft id>"; strips secrets/PII
   ▼
5. Output guard (hook, code)     blocks replies that leak the model, tools, paths, errors, secrets, foreign links, or run long
   ▼
chat + audit log (issue #16: who asked, who approved, what was filed)
```

## What each layer does

| Risk | How it's handled |
|---|---|
| Off-topic use ("write a poem", weather, cricket) | Input guard refuses with "I only handle QA bugs for login, cart, checkout and profile." Agent instructions repeat it. |
| Abuse and bad words (English, Hinglish, Tanglish, leetspeak like `sh1t`) | Input guard refuses with "Let's keep it professional." Output guard blocks the agents from swearing back. |
| Prompt injection ("ignore your rules", "you are now DAN", fake `</system>` tags, zero-width tricks) | Input guard normalises text and refuses. Instructions say chat and issue text are data, never commands. |
| Revealing the AI ("which model are you?", "what tools do you use?") | Input guard gives a fixed answer: "I'm the QA desk..." Output guard blocks any reply that names a model, vendor, tool, command, file path or internal error. |
| Unapproved filing ("file it without asking", "I'm admin, auto-file") | Input guard flags it as injection. bug-filer files only when a person's own message says `file it <draft id>`. Every filing is logged in #16 with the approver's name. |
| Destructive asks ("close all issues", "rm -rf", "give X admin") | Input guard refuses. Only bug-filer can write, and only `gh issue` / `gh api` commands are allowed for it. |
| Secrets and personal data pasted in chat | Input guard refuses and asks the tester to remove it. bug-filer strips emails, phones, passwords, tokens and card numbers from drafts. The guard log never stores the secret. |
| Least privilege | qa-desk and dup-checker are read-only. bug-filer's tool list is limited to GitHub issue commands. |
| Audit | Issue #16 logs every request in progress, draft, filing and cancel. `guardrails/logs/guard.log` records each guard decision (on the laptop, not in git). |

## Evals

`evals/cases.jsonl` holds 109 labelled cases, including full prompts exactly as Switch sends them: real bug reports and desk commands that must pass, and off-topic, abuse,
injection, "about the AI", risky, secret and over-long messages that must be refused (each for the right reason),
plus clean and leaky agent replies for the output guard.

```
python evals/run_evals.py            # writes evals/report.md, exits 1 on any failure
```

A GitHub Action (`.github/workflows/guardrail-evals.yml`) runs them on every change to the guard or the cases,
so a rule change that lets a bad message through, or blocks a real bug report, fails the check.
`docs/live-evals.md` lists the same probes to send in Telegram, with what we saw.

## Limits we know about
- The keyword guard is fast and predictable but can't understand everything. A new kind of off-topic or abusive
  message can slip past it; the agent instructions are the second net. Add every miss to `evals/cases.jsonl`.
- Switch itself posts a "Working… / Worked for Ns" status under each agent turn, listing the tools it ran, and posts
  provider errors such as usage limits. Neither can be turned off from the room or the agents (checked against the
  Switch docs on 7 Nov 2026), so the guard can't hide them.
- The input hook reads the message Switch wraps between `BEGIN SWITCH MESSAGE` / `END SWITCH MESSAGE` markers.
  Switch's own control prompts (reset, reconnect) and our agents' handoffs to each other pass through; handoffs
  were already checked by the output guard when they were posted.
- If the guard itself crashes it lets the message through (fails open) so a bug in the guard can't take the desk
  down; the agent instructions still apply, and the crash is logged.
