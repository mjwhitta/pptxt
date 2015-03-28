# pptxt

## What is it?

This tool can extract the xml info from a pptx and convert to human-readable text. It was intended to be used with git for seeing changes between revisions.

## How to install

Open a terminal and run the following:

```bash
$ git clone https://gitlab.com/mjwhitta/pptxt
$ cd pptxt
$ ./install_pptxt.sh
```

The default install directory is `~/bin`. You can change this by providing the install directory of your choice like below:

```bash
$ ./install_pptxt.sh ~/scripts
```

## How to use

```bash
$ pptxt --help
Usage: pptxt [OPTIONS] [pptx]
    -d, --detailed                   Display full xml
        --git                        Hide the slide dividers for git-diff
    -g, --global-init                Configure git to use pptxt globally
    -h, --help                       Display this help message
    -i, --init                       Initialize git repo to use pptxt
```

Once pptxt has been installed, `cd` to the top-level of your repo and run the following command:

```bash
$ pptxt --init
```

This command creates (or appends to) the `.gitattributes` file and configures git to use pptxt for git-diff.

If you would rather configure pptxt to be used globally, run the following command:

```bash
$ pptxt --global-init
```

## TODO

 - Increment numbers in number lists
 - Make comments/documentation more thorough.
