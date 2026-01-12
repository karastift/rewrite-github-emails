# Rewrite GitHub Emails

Bash script to automate the rewriting of commit author/email history across multiple GitHub repositories using `git filter-repo` and a mailmap file. It clones each repository, applies the rewrite, force-pushes the cleaned history to the default branch (`main` or `master`), and cleans up locally.

## Purpose

Use this script when you need to:
- Standardize or correct commit author names and emails across many repositories
- Remove sensitive or old email addresses from commit history

**Warning**: This script performs a **history rewrite** and **force-pushes** to the remote. This can disrupt collaborators and break existing pull requests. Use with caution and preferably on repositories where you are the sole contributor or have coordinated with your team.

## Requirements

- `git`
- `git-filter-repo` ([repo](https://github.com/newren/git-filter-repo))
- SSH access configured for GitHub (so pushes work without password prompts)
- A mailmap file at `~/Desktop/mailmap.txt` (see format below)

### Mailmap Format Example (`mailmap.txt`)

```text
Correct Name <correct@email.com> Old Name <old@email.com>
Correct Name <correct@email.com> Old Name <another-old@email.com>
Correct Name <correct@email.com> Maybe Another Name <another-old@email.com>
```

## Usage

1. Save the script as `rewrite_repos.sh`
2. Make it executable:

```bash
curl https://raw.githubusercontent.com/karastift/rewrite-github-emails/refs/heads/main/rewrite_repos.sh > rewrite_repos.sh
chmod +x rewrite_repos.sh
```

3. Create a file (e.g., repos.txt) with one GitHub SSH URL per line:

```text
git@github.com:username/repo1.git
git@github.com:username/repo2.git
git@github.com:username/repo3.git
```

4. Run the script:

```bash
./rewrite_repos.sh repos.txt
```

Or pass URLs directly:

```bash
./rewrite_repos.sh git@github.com:username/repo1.git git@github.com:username/repo2.git
```

