linecook(1) -- render ERB templates
=============================================

## SYNOPSIS

`linecook` [options] TEMPLATES...

## DESCRIPTION

**linecook** renders ERB templates.  Templates have access to an 'obj'
(typically a hash) read from an attributes file as YAML.  When multiple
(documents are present in the attributes file the templates will render
(multiple times.

All files in a directory are rendered when specified as a template.  Options
are provided to render results to an output directory.

## OPTIONS

These options control how `linecook` operates.

* `-A FILE`:
  Read attrs as lines from FILE. STDIN can be specified as '-'.Each line is
  parsed as YAML into an object.

* `-a FILE`:
  Read attrs as YAML documents from FILE. STDIN can be specified as '-'.

* `-e`:
  Treat TEMPLATE as the template string.

* `-f`, `--[no-]force`:
  Remove the target directory if it exists on '-o'. 

* `-h`, `--help`:
  Prints help.

* `-o TARGET_DIR`:
  Output results to the target dir, which will be created if it does not
  exist. Templates are rendered using their basename; in the case of a
  directory the output files will preserve the relative path to the
  template.Multiple rendering are appended to each file.

* `-r RUBY_FILE`:
  Require the specified ruby file. Use this to expand the Linecook::Context
  class to make templates more intelligent.

## ENVIRONMENT

**linecook** reserves all variables starting with 'LINECOOK\_' for internal use.

## INSTALLATION

Add `linecook` to your PATH (or execute it directly). A nice way of doing so
is to clone the repo and add the bin dir to PATH. This allows easy updates via
`git pull` and should make the manpages available via `man linecook`.

    git clone git://github.com/goodlittlescript/linecook.git
    export PATH="$PWD/linecook/bin:$PATH"

If you're using [homebrew](http://brew.sh/) on OSX you can tap
[goodlittlescript](https://github.com/goodlittlescript/homebrew-gls).

    brew tap goodlittlescript/homebrew-gls
    brew install linecook

## DEVELOPMENT

Clone the repo as above.  To run the tests (written in `ts` - see
https://github.com/thinkerbot/ts for installation instruction):

    ./test/suite

To generate the manpages:

    rake manpages

Report bugs here: http://github.com/goodlittlescript/linecook/issues.

## COPYRIGHT

Linecook is Copyright (C) 2015 Simon Chiang <http://github.com/thinkerbot>
