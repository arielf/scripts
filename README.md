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

    e.g. you have a test-suite, normally invoked as `make test`
    with many sub-tests and we want to get the sub-tests sorted by the
    time they took to run.

    We run:
        `time-by-line make test`

    and get output like (trimmed for previty):
```
    [normal output comes first. And after everything completes:]

    0.000006      test 42: OK
    ...
    0.149873      test 127: OK
    0.241587      test 134: OK
    0.602354      test 126: OK
```
    where the 1st column is number of seconds a line took to complete.
    and the lines are sorted by the time the individual sub-tests
    took to run.

    Invocation is flexible. You can also use `time-by-line` in a pipe:
```
        make test | time-by-line
```


