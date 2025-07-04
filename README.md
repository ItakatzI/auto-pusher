# Auto Pusher 🧠🔥

Automatically commit motivational quotes to your Git repository at random times during the day. Ideal for creative journaling, habit tracking, or just keeping your GitHub streak alive with a little inspiration.

---

## ✨ Features

- Pulls motivational quotes from [ZenQuotes.io](https://zenquotes.io/)
- Appends them to a specified file in your repo
- Makes random commits 0–6 times daily
- Schedules itself to re-randomize every morning
- Optional: sends Windows toast notifications with each quote

---

## 🛠 Setup

### 1. Clone the Repo and Create a Target Repository

This project consists of a scheduler and automation system. You'll also need a **separate two Git repository** where your motivational commits will be pushed.


## Clone this project (scheduler + scripts)
```
git clone https://github.com/ItakatzI/auto-pusher.git
cd auto-pusher
```

### Separately, create or identify the Git two repositories where quotes should be committed
#### Example (You will have to do this twice or tweak the code to only have one):
```
mkdir ../quotesForGit
cd ../quotesForGit
git init
git remote add origin https://github.com/YOUR_USERNAME/quotesForGit.git
```


### 2. Configure Your `.env`

Create a file called `.env` in the root directory with the following variables:

```
REPO_DIR=/c/path/to/your/repo-to-commit
REPO_ALT=/c/path/to/your/another-repo-to-commit
REPO_DIR2=C:\Users\path\to\auto-push\folder\quotesForGit
TARGET_FILE=quotes.txt
```

> 💡 `REPO_DIR` should be the Git repository you use to automate.  
> 💡 `REPO_ALT` should be the another Git repository you use to automate for multiple repository contribution. (You can fill the same as `REPO_DIR` and then you will push to only one repo) 
> 💡 `REPO_DIR2` should be the Git repository you want to push to.  

> `TARGET_FILE` will be created if it doesn't exist.

### 3. Run the Setup Script

From PowerShell:

```
.\setup.ps1
```

This will:
- Run the quote scheduler for today
- Create a daily task at 11:00 AM to randomize future push schedules

---

## 📅 How Scheduling Works

- A PowerShell task creates 0–5 random scheduled tasks every morning
- These tasks run `auto_commit.sh` between 11:00 AM and 5:00 PM
- Each run fetches 1–5 quotes, adds them to your file, and commits them to Git

---

## 🔔 Optional: Show Toast Notifications

To enable Windows toast popups with each quote:

1. Open PowerShell as Admin
2. Run:

```
Install-Module -Name BurntToast -Force
```

Or use Windows message boxes with no extra install (already supported).

---

## 📓 Example Commit Message

```
Motivation: "For changes to be of any true value, they've got to be lasting and consistent. - Tony Robbins" (2025-06-04 15:24:49)
```

---

## 🧼 Notes

- `.env` and `push_log.txt` are ignored via `.gitignore` to keep your environment private
- If `zenquotes.io` rate limits, the script will fallback or skip quotes gracefully

---


## 📜 License

MIT — Use freely, modify creatively, push responsibly.


Created By Katzir and 🤖
