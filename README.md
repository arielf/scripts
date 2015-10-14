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
