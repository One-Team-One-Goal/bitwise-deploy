# 🔐 Secrets Management Guide

You have sensitive files like `.pem` keys (for SSH access) and `.env` files (database passwords, API keys). **These must NEVER be committed to Git.**

Here is how to share them with your team securely.

## 1. What NOT to do ❌
-   **NEVER** push `.env` or `.pem` files to GitHub/GitLab.
-   **NEVER** send them via Slack/Discord/Messenger (these are not end-to-end encrypted for files and stay in history).
-   **NEVER** put them in a Google Doc.

## 2. How to Share Secrets (The "Right" Ways) ✅

### Option A: Password Managers (Best for Small Teams)
If your team uses **1Password**, **Bitwarden**, or **LastPass**:
1.  Create a "Secure Note".
2.  Paste the contents of your `.env` file there.
3.  Attach the `.pem` file as a file attachment to the note.
4.  Share the item with your team members via the password manager's sharing feature.

### Option B: Encrypted Zip (Quick & Free)
If you don't have a shared password manager:
1.  Put your `.env` and `.pem` in a folder.
2.  Zip it with a password:
    ```bash
    zip -e secrets.zip .env key.pem
    ```
3.  Send the `secrets.zip` file via email or chat.
4.  **Send the PASSWORD via a DIFFERENT channel** (e.g., send file on Email, send password on Telegram/Signal).

### Option C: Developer-to-Developer (Manual)
For a small team, just have one person set up the server. If another developer needs access:
1.  **SSH Keys**: Instead of sharing the `.pem` file, ask the developer for their **Public SSH Key** (`id_rsa.pub`).
2.  Add their public key to the server's `~/.ssh/authorized_keys` file.
3.  Now they can SSH in using *their own* key, and you don't need to share the `.pem` file at all.

## 3. Where to Store Them?
-   **Local Machine**: Keep them in a secure folder (e.g., `~/.ssh/` for keys).
-   **Backup**: Store a copy in your personal secure cloud storage (Google Drive/Dropbox) **inside an encrypted zip** or use a Password Manager.

## 4. Summary for Your Repo
Since you are using this repo for deployment:
1.  Ensure `.env` is in your `.gitignore`.
2.  Create a `.env.example` file in the repo.
    -   Include all the *keys* (e.g., `DATABASE_URL=`) but leave the *values* empty or put placeholders.
    -   This tells your team what variables they need to ask you for.
