#!/usr/bin/env bash
# Creates module labels and sample bugs for the demo.
# Usage: REPO=owner/name ./seed/seed_issues.sh   (needs the gh CLI, logged in)
set -euo pipefail
REPO="${REPO:-aswinbalasubramanian/switch_ai_qa_bot}"

for m in login cart checkout profile; do
  gh label create "module:$m" --repo "$REPO" --color 1d76db --force >/dev/null
done
gh label create "bug" --repo "$REPO" --color d73a4a --force >/dev/null

new() { gh issue create --repo "$REPO" --label "bug,module:$1" --title "$2" --body "$3" >/dev/null; echo "created: [$1] $2"; }

new login    "Login button stays disabled after entering valid email and password" "Steps: open /login, type valid email + password. Expected: button enabled. Actual: stays grey until page refresh."
new login    "Forgot password email never arrives for Gmail addresses" "Steps: click Forgot password, enter a gmail.com address. Actual: no email after 10 min. Other domains work."
new login    "Session expires after 2 minutes instead of 30" "User gets logged out while filling the profile form."
new cart     "Cart total does not update when quantity is changed to 0" "Set quantity to 0. Item stays and total keeps the old price."
new cart     "Applying coupon SAVE10 twice doubles the discount" "Coupon can be applied twice by double clicking Apply."
new cart     "Cart badge count shows 0 after page reload" "Items are still in the cart but the header badge resets to 0."
new checkout "Payment page crashes when card number has spaces" "Typing '4242 4242 4242 4242' gives a white screen. Without spaces it works."
new checkout "Shipping cost not added to order total for express delivery" "Choose Express. Summary shows shipping 0.00."
new profile  "Profile photo upload fails for PNG files over 1 MB" "Error 'Upload failed' with no detail. JPG of same size works."
new profile  "Phone number field accepts letters" "Can save 'abc123' as phone number."
echo "Done. Seeded $REPO"
