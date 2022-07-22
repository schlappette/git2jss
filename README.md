# git2jss

A fast asynchronous python library for syncing your git-tracked scripts with your JSS easily. This allows admins to keep their scripts in a version control system for easy updating rather than googling and copy-pasting from resources that they find online.

## Getting Started

### If you are starting from scratch

1. Clone this repo to your local workstation where you will be editing the scripts and EAs:
    `git clone ssh://git@git.pcc.edu/sa/jamf-git2jss.git`
2. Install [Python version 3.6](https://www.python.org/downloads/) or higher. (this is because of the async requirements)
3. Run `python3.6 -m pip install -r requirements.txt` to install required modules
4. The scripts and extension_attributes directories are already populated in this repo.  However, if you want a fresh copy, you can run the `download.py` script (see below for syntax).

### Download from the JSS

**You should not need to do this step if you are cloning from this repo.**  The scripts and EAs are already downloaded from PCC's Jamf server and included here in this repo.

Run `./tools/download.py --url https://jamf-or-jamfdev.pcc.edu:8443 --username api_user` to download all scripts and extension attributes to the repository

Optional flags for `download.py`:

- `--password` for CI/CD (Will prompt for password if not set)
- `--do_not_verify_ssl` to skip ssl verification
- `--overwrite` to overwrite all scripts and extension attributes

### Upload/Sync to the JSS

Run `./sync.py --url https://jamf-or-jamfdev.pcc.edu:8443 --username api_user` to sync all scripts back to your JSS

Optional flags for `sync.py`:

- `--password` for CI/CD (Will prompt for password if not set)
- `--do_not_verify_ssl` to skip ssl verification
- `--overwrite` to overwrite all scripts and extension attributes
- `--limit` to limit max connections (default=25)
- `--timeout` to limit max connections (default=60)
- `--verbose` to add additional logging
- `--update_all` to upload all resources in `./extension_attributes` and `./scripts`
- `--jenkins` to write a Jenkins file:`jenkins.properties` with `$scripts` and `$eas` and compare `$GIT_PREVIOUS_COMMIT` with `$GIT_COMMIT`

### Prerequisites

git2jss requires [Python 3.6](https://www.python.org/downloads/) or newer, and the python modules listed in `requirements.txt`

## Deployment

The project can be run ad-hoc with the example listed above, but ideally you setup webhooks and integrate into a CI/CD pipeline so each time a push is made to the repo your scripts are re-uploaded to the JSS.

## Contributing

PRs are always welcome!
