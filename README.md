# scripts

A collection of random useful scripts - ariel faigon

### jh
    Connect to a bastion host with 2FA, starts openvpn if not running
    calls autovpn to establish the openvpn tunnel, prompts user only
    when/if needed.
    Note: requires 'autovpn'


### autovpn
    Expect script to establish tunnel to bastion host
    Note: requires 'expect'


### x
### xy (just a link to x, they are both the same program)
    Handy plotting command line utilities.
    Note: requires 'cuts'
    
    x  plots a density chart of a uni-dimensional numeric vector
    xy plots a scatter-plot of two numeric columns (x, y) coordinates
    
    Documentation (man page style) is included, to get it, run:
       $ perldoc xy


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
