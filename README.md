# scripts

A collection of random useful scripts - ariel faigon

### x
### xy (just a link to x, they are both the same program)
    Handy plotting command line utilities.
    Note: requires 'cuts'

    x  plots a density chart of a uni-dimensional numeric vector
    xy plots a scatter-plot of two numeric columns (x, y)

    Documentation (man page style) is included, to get it, run:

       $ perldoc x

    Note that 'xy' doesn't exist in this repository. You can
    create it by simply running this command in a shell:

        $ ln x xy

    in the directory where 'x' resides.

### cuts
    Handy cut and paste of columns (more powerful than 'cut')
    See: https://arielf.github.io/cuts/

### xyz
    Python (using matplotlib) script to quickly plot 3D numeric data
    from the command-line.  Expects a *.tsv or *.csv input file, and
    3 names (or 0-based integer indices) of columns to select from
    the file and map them to the 3D (X, Y, Z) dimensions.

    Supports many options to control how the plot looks like.

    Emphasis on friendliness. Order of arguments doesn't matter.
    Run without arguments for usage.

    The default is to plot a contour map (topographical view)
    of the Z dimension vs the X & Y dimensions.

    For all options/parameters, prefix matches and regexp/abbreviations
    are supported.  For example a color-map parameter, can be
    specified as any of:
        colormap
        cmap
        cm
    etc.

    Examples:

        # Get a usage summary:
        xyz

        # Visualize the R 3D volcano data-set:
        xyz volcano.csv X Y Z

        # Same + also modify the color-map & Z-axis color-resolution
        xyz volcano.csv X Y Z cmap=jet zres=20

        # Similar, but use integer indices (0,1,2) for column-selection,
        # disable grid-lines (gl=0) and countour-lines (cl=0)
        # increase Z-dimension resolution & add dots where data appears.
        xyz 0 1 2 volcano.csv dotsize=0.01 zres=100 gr=0 cl=0

    The data file volcano.csv (credit: Ross Ihaka)
    is included here for convenience.

![volcano contour rendering](volcano-contour.png  "volcano contour rendering by the xyz utility")

    The following names can be symlinked to the same (xyz) script.
    * If called as 'xyzb' will produce a bubble chart
    * If called as 'xyzs' will produce a scatter plot
    * If called as 'xyzp' will produce a polar plot (X-dim mapped to angle)

### colidx

    Print indices of column-names from a csv/tsv file with a header

    Example:

        colidx volcano.csv

### mff

    My Find File.

    Basically a wrapper around multiple stages of `locate` and `grep`.
    Helps find files by name. Especially useful if you only vaguely
    remember parts of the file name (say "jpe?g" to search for photos,
    or a name of a person).

    Smart about doing case-insensitive searches, supporting PCRE regexes, and more.

    Examples:

        mff katelin 'jpe?g'
        mff beatles rubber.soul mp3

### T
    Handy bi-directional/smart universal time converter
    - If it sees a Unix time_t (integer) - will convert to date
      Example:
        $ T 1443526029
        Tue Sep 29 04:27:09 2015
    - If it sees anything else - will convert to time_t
      Example:
        $ T week ago
        1443381375
    Input flexible: Works on either command-line-args OR stdin


### sorted-count-with-pct
    percentage and cumulative-percentage summary of a list of items (one per line)

    Usage example: summarize word frequency in /etc/passwd:
    $ tr -cs 'A-Za-z' '\012' < /etc/passwd | sorted-count-with-pct

### sort-by-abs
    Sort data-file(s) descending by absolute value of some field.
    Can define separator and field-number to sort by.

    Use:
        sort-by-abs -h
    for a usage message

### byte-entropy
    Calculates entropy of a file (or string) object by byte values.

    One pass over the file/string to summarize frequencies of each
    byte value and count total bytes.

    Another loop over the (non-zero) frequencies to calculate the entropy.

    Very simple: doesn't try to do N-gram/context/language-detection,
    Only considers char-frequencies within the object as independent
    probabilities.

    Result is always normalized to [0 .. 1] range.
    1.0 means highest-randomness.

### time-by-line
Time a sequence of commands (each output line is timed separately).

e.g. you have a test-suite, normally invoked as 'make test' with many sub-tests and we want to get the sub-tests sorted by the time they took to run.

Example:
```
    time-by-line make test
```

The output (trimmed for brevity):
```
    [normal output comes first. And after everything completes:]

    0.000006      test 42: OK
    ...
    0.149873      test 127: OK
    0.241587      test 134: OK
    0.602354      test 126: OK
```
where the 1st column is number of seconds a line took to complete, and the lines are sorted by the time the individual sub-tests took to run.

Invocation is flexible. You can also use 'time-by-line' in a pipe:

```
    make test |& time-by-line
```

There are 2 different ways to attribute times to lines:

* Attribute time to 1st line in a sequence (starting line)
* Attribute time to 2nd line in a sequence (ending line)

The default used by `time-by-line` is to attribute times to the ending-line

To change the default, simply pass `-` or `--` as the 1st argument to `time-by-line`:
```
    # Will attribute each time-slot duration to its 1st line:
    time-by-line -- make test

    # ditto:
    make test |& time-by-line --
```

### cpu-hog-killer

Kill high-CPU hogging processes by command/args patterns.

Buggy (or malicious) 3rd-party javascript code is often taking
our browsers and computing resources hostage.

I used to find some processes on my desktop running at 100% CPU
all night when I was not even noticing, because of bad javascript.

Involuntary CPU hogging might be caused by an infected ad,
badly written code, "drive-by-scripting" leading to someone
co-opting your computer to run crypto-mining, or much worse.

It makes you pay for electricity you don't want to, and multiplied
by many desktops and browsers left running at night, is also very bad
for our planet.

`cpu-hog-killer` is a simple script which I run from periodically
during the night.  I make it from cron every 13 minutes like this:
```
    # Add this line (or similar) using 'crontab -e'
    */13 0-7 * * *  ~/bin/cpu-hog-killer
```

It identifies CPU hogging processes, mainly inside Chrome or Firefox,
and kills them instantly upon detection.

In the morning when I'm back, the worst case scenario is that
I go to a browser tab and it says: "Aw this tab has crashed"
I take notice (of which site was misbehaving based on its title)
and the browser allows me to restart it if I want to,
so nothing is actually lost.

You can add more rules to the script to cover more apps that
may be hogging your CPU when you don't want them to. Just look
at the 'main' section (last few lines of the script) and add more rules
as needed. Each rule looks like this:
```
process_list '<some pattern>' | terminate-hogs
```

For example, the Firefox rule which only kills one tab is:
```
process_list '[/]firefox -contentproc -childID.*tab$' | terminate-hogs
```

And for Chrome/chromium it is:
```
process_list '[/]chrom(e|ium) --type=(renderer|utility)' | terminate-hogs
```

I've seen (very rare) cases where even KDE `plasma` had was spinning
at 100% in some add-on, so there's a rule for that as well. YMMV.
