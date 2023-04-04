# Building the Site

## Dependencies

Make sure you have Python 3.11 installed.

```bash
# macOS with Homebrew installed
brew install python@3.11
```

Use Python to install `virtualenv`, then setup the `virtualenv` environment.

```bash
python3.11 -m pip install -U virtualenv
python3.11 -m virtualenv -p python3.11 .venv
```

Then _activate_ the `virtualenv` environment.

```bash
# For Bash or Zsh
source .venv/bin/activate
```

Now, you have your very own localized environment for running Python commands without affecting anything else on your system.

Lastly, install the Python packages required by this code, using `pip`.

```bash
pip install --upgrade pip
pip install -U -r requirements.txt
poetry install -v
```
