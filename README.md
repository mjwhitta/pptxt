# pptxt

## What is this?

This gem can extract the xml info from a pptx file and convert it to
human-readable text. It was intended to be used with git for seeing
changes between revisions.

## How to install

```
$ gem install pptxt
```

## How to use

```
$ pptxt --help
Usage: pptxt [OPTIONS] <pptx>
    -c, --configure               Configure git repo to use pptxt
    -d, --detailed                Display full xml
        --git                     Hide the slide dividers for git-diff
    -g, --global-config           Configure git to use pptxt globally
    -h, --help                    Display this help message
    -s, --slideshow               Display as slideshow
    -v, --verbose                 Show backtrace when error occurs
```

Once pptxt has been installed, `cd` to the top-level of your repo and
run the following command:

```
$ pptxt --configure
```

This command creates (or appends to) the `.gitattributes` file and
configures git to use pptxt for git-diff.

If you would rather configure pptxt to be used globally, run the
following command:

```
$ pptxt --global-config
```

## Links

- [Source](https://gitlab.com/mjwhitta/pptxt)
- [Mirror](https://github.com/mjwhitta/pptxt)
- [RubyGems](https://rubygems.org/gems/pptxt)

## TODO

- Better README
- RDoc
