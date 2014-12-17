# pptxt

## What is it?

This is a tool that can extract the xml info from a pptx. It was intended to be used with git for seeing changes between revisions.

## How to install

Open a terminal and run the following:

```bash
$ git clone https://bitbucket.org/mjwhitta/pptxt
$ cd pptxt
$ ./install_pptxt.sh
```

The default install directory is `~/bin`. You can change this by passing in the install directory of you choice like below:

```bash
$ ./install_pptxt.sh ~/scripts
```

## How to use

```bash
$ pptxt --help
Usage: pptxt [OPTIONS] [pptx]
    -h, --help                       Display this help message
    -i, --init                       Initialize git repo to use pptxt
```

Once pptxt has been installed, `cd` to the top-level of your repo and run the following command:

```bash
$ pptxt --init
```

This command creates (or appends to) the `.gitattributes` file and configures git to use pptxt for git-diff.

## TODO

 - Add the ability to only show slide contents, not full xml
 - Make comments/documentation more thorough.
