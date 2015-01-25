linecook(1) -- render ERB templates
=============================================

## SYNOPSIS

`linecook` [options] TEMPLATE CSV_FILES...

## DESCRIPTION

**linecook** renders ERB templates from csv files, once per row.  Templates
can specify named arguments, defaults, and are simple enough to serve as
recipes for all the little things.

## OPTIONS

These options control how `linecook` operates.

    -F, --field-sep FS               field sep for csv inputs (assumes -f)
    -f, --csv-file                   read args from csv inputs
    -H, --headers                    map csv headers to args
    -I, --path LC_PATH               set template search path
    -L, --list-filter                list filtering for matches
    -l, --list                       list templates
    -h, --help                       print this help
    
* `-h`:
  Prints help.

## USAGE

Templates are ruby ERB.  When rendered the template can access the fields of
each record in the csv file as the Array `fields` and global attributes as the
Hash `attrs`.

    printf '%s\n' 'got <%= fields.inspect %> <%= attrs.inspect %>' > example.erb
    printf '%s,%s,%s\n' a b c x y z > example.csv
    linecook example.erb example.csv
    # got ["a", "b", "c"] {}
    # got ["x", "y", "z"] {}

No specific extname is needed for a template file, but if the extname is
`.erb` then `linecook` will look for a YAML properties file with the same name
but with a `.yml` extname.  The properties file can specify default attrs,
field names/defaults, template documentation, etc.  With properties `linecook`
can map fields by header, and provide the template with variables to access
named attrs and fields.

    cat > example.erb <<DOC
    got A=<%= a %> B=<%= b %> (<%= key %>)
    DOC

    cat > example.yml <<DOC
    attrs:
      key: value
    fields:
      a: A
      b: 1
    DOC

    printf '%s,%s\n' 1 2 3 4 > example.csv

    linecook example.erb example.csv
    # got A=1 B=2 (value)
    # got A=4 B=4 (value)

Both files can be combined in the `.lc` format wherein the properties are
expressed in a section separated from the template by '---'.

    cat > example.lc <<DOC
    attrs:
      key: value
    fields:
      a: A
      b: 1
    ---
    got A=<%= a %> B=<%= b %> (<%= key %>)
    DOC

    linecook example.lc example.csv
    # got A=1 B=2 (value)
    # got A=4 B=4 (value)

Note the `.lc` format is shebang-friendly.

## ENVIRONMENT

The behavior of **linecook** can be modified via environment variables. Many
of these may be set using options.

* `LINECOOK_PATH` (~/.linecook:/etc/linecook):
  The path for looking up templates.

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

    make manpages

Report bugs here: http://github.com/goodlittlescript/linecook/issues.

## COPYRIGHT

Linecook is Copyright (C) 2015 Simon Chiang <http://github.com/thinkerbot>
