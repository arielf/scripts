#!/usr/bin/perl -w
# vim: ts=4 sw=4 expandtab
#
# Density plot of a vector
#   x:      http://docs.ggplot2.org/current/geom_density.html
#
# Scatter-plot of a pair of parallel vectors
#   xy:     http://docs.ggplot2.org/current/geom_point.html
#
# - Works on any file:column by calling 'cuts'
#
# -- ariel faigon - 2014-07
#
use strict;
use Getopt::Std;
use File::Basename;
use File::Temp;
use Scalar::Util qw(looks_like_number);

use vars qw($opt_v $opt_c $opt_o $opt_s $opt_n);

my $Progname = basename($0);

#
# R script supported parameters.
#
# All the below are defaults
# Override from the command-line using:
#       varname=newvalue
#
#
my %Params = (
    # Add supported args as needed:

    # -- Chart size and aspect ratio
    'width'     => 4,   # in inches?
    'ratio'     => 1,   # height vs width

    # -- Text title and axis-labels
    'title'     => '',
    'xlab'      => 'X',
    'ylab'      => 'Y',

    # -- Aesthetics
    'alpha'     => ($Progname eq 'x' ? 0.5 : 0.3),
    'color'     => ($Progname eq 'x' ? '#0000ff' : '#0055ff'),
    'fill'      => '#3377ff',
    'shape'     => ($Progname eq 'x' ? 20 : 21),
    'size'      => ($Progname eq 'x' ? 0.3 : 0.7),
    'linetype'  => 1,

    # -- Data clip boundaries
    'xlim'      => '',
    'ylim'      => '',

    #
    # Options for kernel (used in 'x' density) are:
    #   "gaussian", "rectangular", "triangular", "epanechnikov",
    #   "biweight", "cosine" or "optcosine" 
    # http://www.inside-r.org/r-doc/stats/density
    #
    'kernel'    => 'gaussian',
    'adjust'    => 1,   # bandwidth adjust, numeric multiplier on 'bw'
    'cut'       => 3,   # by default, the values of from and to are
                        # 'cut' bandwidths beyond the extremes of the data.
                        # This allows the estimated density to drop to
                        # approximately zero at the extremes.
                        # pass 'cut=0' to completely disable
    'n'         => 512, # number of equally spaced points at which
                        # the density is to be estimated.
                        # Use a power-of-2 (due to FFT algo used)

    # -- External program to display images
    'display'   => 'gwenview',

    # -- Debug/verbose
    'v'         => 0,
);

my $ConfigFile = "$ENV{HOME}/.x.pl";

# ----- CONFIGURATION SECTION START -----
# ----- You may copy and change these values in your personal $ConfigFile

# Add config vars as needed
1;

# ----- CONFIGURATION SECTION END -----

my $RScript = <<'EOF';
#!/usr/bin/Rscript
# --vanilla
#
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(ggplot2))

eprintf <- function(...) {
    if ({v}) cat(sprintf(...), sep='', file=stderr())
}

progname <- '{progname}'
col.names <- c('X','Y')

get_columns <- function() {
    cmd <- "{CUTSCMD}"
    # conn <- pipe(cmd)

    # eprintf("get_columns: CUTSCMD: conn <- pipe('%s')\n", cmd)
    eprintf("get_columns: CUTSCMD: '%s'\n", cmd)
    # Read the data as character (no conversion) so we can deal
    # with both numeric and non-numeric elements later
    if (progname == "x") {
        col.types <- c('character')
        col.names <<- c('X')
    } else {
        col.types <- c('character', 'character')
        col.names <<- c('X', 'Y')
    }

    eprintf("get_columns: before fread: col.names=(%s) col.types=(%s)\n",
            col.names, col.types)
    # dat <- read.csv(conn, sep="\t", header=F,
    dat <- fread(cmd=cmd, sep="\t", header=F,
                    colClasses=col.types,
                    col.names=col.names)

    # The 1st element might be a header name, so check it
    first.elem <- dat[1,1]

    # Try to see if it can be converted to numeric
    first.elem = suppressWarnings(as.numeric(first.elem))

    if (is.na(first.elem)) {

        # 1st element was probably a header line - remove it from
        # the vector, but preserve its value for later use
        col.names <<- as.character(dat[1,])
        # remove first header (non-numeric) row
        dat <- dat[-1,]
        eprintf("header present: col.names=%s\n", col.names)

    } else {
        eprintf("No header: col.names=%s\n", col.names)
    }

    # convert to numeric
    dat <- as.data.frame(sapply(dat, as.numeric))
    colnames(dat) <- col.names

    if ({v}) {
        head(dat)
        str(dat)
    }
    dat
}

# -- style variables
ratio = {ratio}
W = {width}
H = W / ratio
DPI = 200
FONTSIZE = 9
MyGray = 'grey50'

title.theme   <- element_text(family="FreeSans", face="bold.italic",
                            size=FONTSIZE, hjust=0.5)
x.title.theme <- element_text(family="FreeSans", face="bold.italic",
                            size=FONTSIZE, vjust=-0.1)
y.title.theme <- element_text(family="FreeSans", face="bold.italic",
                           size=FONTSIZE, angle=90, vjust=0.2)
x.axis.theme  <- element_text(family="FreeSans", face="bold",
                            size=FONTSIZE-2, colour=MyGray)
y.axis.theme  <- element_text(family="FreeSans", face="bold",
                            size=FONTSIZE-2, colour=MyGray)
legend.theme  <- element_text(family="FreeSans", face="bold.italic",
                            size=FONTSIZE-1, colour="black")


d <- get_columns()
# only caling this outside get_columns() actually sets the column names
names(d) <- col.names

if ({v}) head(d)

pngfile <- "{pngfile}"

if (ncol(d) == 1) {
    #####  x
    if ("{xlab}" == 'X') {
        x.lab <- col.names[1]
    } else {
        x.lab <- "{xlab}"
    }

    if (nchar("{title}") == 0) {
        title = sprintf("density of %s", x.lab)
    } else {
        title = "{title}"
    }

    g <- ggplot(data=d, aes(x=d[[1]])) +
        geom_density(fill='{fill}', alpha={alpha}, lwd={size},
                     kernel='{kernel}',
                     linetype={linetype},
                     adjust={adjust}) +
        scale_x_continuous({xlim}) +
        ggtitle(title) +
        xlab(x.lab) +
        ylab("{ylab}") +
        theme(
            plot.title=title.theme,
            axis.title.y=y.title.theme,
            axis.title.x=x.title.theme,
            axis.text.x=x.axis.theme,
            axis.text.y=y.axis.theme
        )

} else if (ncol(d) == 2) {
    #####  xy
    col.names <- colnames(d)
    if ("{xlab}" == 'X') {
        x.lab <- col.names[1]
    } else {
        x.lab <- "{xlab}"
    }
    if ("{ylab}" == 'Y') {
        y.lab <- col.names[2]
    } else {
        y.lab <- "{ylab}"
    }

    pearson <- as.numeric(cor(d[[1]], d[[2]]))
    eprintf("Pearson Correlation: %.8f\n", pearson)
    pearson.str <- sprintf("Pearson correlation: %.8f", pearson)

    if (nchar("{title}") == 0) {
        title <- sprintf('%s vs %s\n%s', x.lab, y.lab, pearson.str)
    } else {
        title <- sprintf('%s\n%s', "{title}", pearson.str)
    }

    g <- ggplot(data=d, aes(x=d[,1], y=d[,2])) +
        geom_point(
                    shape=as.factor({shape})
                    ,colour='{color}'
                    ,alpha=as.numeric({alpha})
                    ,size=as.numeric({size})
        ) +
        scale_color_identity() +
        scale_alpha(guide='none') +
        scale_size(guide='none') +
        scale_shape(guide='none') +
        ggtitle(title) +
        xlab(x.lab) +
        ylab(y.lab) +
        scale_x_continuous({xlim}) +
        scale_y_continuous({ylim}) +
        theme(
            plot.title=title.theme,
            axis.title.y=y.title.theme,
            axis.title.x=x.title.theme,
            axis.text.x=x.axis.theme,
            axis.text.y=y.axis.theme
        )

} else {
    eprintf("ncol(d)=%d: too many columns: not yet supported\n", ncol(d));
    exit(1);
}

ggsave(g, file="{pngfile}", width=W, height=H, dpi=DPI)
eprintf("Wrote chart: %s\n", "{pngfile}")

EOF


sub v {
    return unless $opt_v;
    if (@_ == 1) {
        print STDERR @_;
    } else {
        printf STDERR @_;
    }
}

sub usage(@) {
    print STDERR @_, "\n" if @_;
    my $params_help = '';
    foreach my $k (keys %Params) {
        my $v = $Params{$k};
        $params_help .= "\n\t\t$k\t$v";
    }
    die "Usage: $0 [Options] [var=value...] [Column_Specs]...
    Options:
        -v              verbose (mostly for debugging)
        -c              Don't use personal config-file (even if exists)
        -s scriptfile   Save script to scriptfile and exit (for debug)
        -o pngfile      Save chart to pngfile
        -n              Don't display chart

    var=value...
        Optional list of settings to modify the visuals (size, color, etc.)
        These are passed to the R/ggplot APIs in an implementation dependent
        manner. Defaults are: $params_help

    Column_Specs:
        All (other) file/column specs are passed down to cuts
        These are essentially file-names to get the data from and
        columns numbers to select for display.  Simple examples are:
            x  File 1       plot distribution of column 1 from File
            xy File 1 2     scatter-plot of File columns (1,2) as (x,y)
        See cuts (perdoc POD) for exact details on file/column extractions
";
}


my @CutsArgs = ('cuts');

sub get_args {
    $0 =~ s{.*/}{};

    usage() if (-t STDIN && @ARGV == 0);

    my @OurArgs = ();
    my @ParamArgs = ();
    my $column_count = 0;
    my $nargs = scalar @ARGV;

    for (my $i = 0; $i < $nargs; $i++) {
        my $arg = $ARGV[$i];
        if ($arg =~ /^-[vcn]$/) {
            push(@OurArgs, $arg);
            next;
        }
        if ($arg =~ /^-[os]/) {
            push(@OurArgs, $arg);
            if ($arg =~ /^-[os]$/) {
                # one more arg follows
                $i++;
                $arg = $ARGV[$i];
                push(@OurArgs, $arg);
            }
            next;
        }
        if ($arg =~ /^([\w.]+)=(.+)$/) {
            push(@ParamArgs, $arg);
            next;
        }
        # if we get here, arg is not ours and should be passed to cuts
        push(@CutsArgs, $arg);
        if ($arg =~ /(?:^|:)-?\d+$/) {
            # looks like a column number spec
            $column_count++;
        }
    }
    if ($column_count == 0) {
        # Default for x/xy without explicit columns:
        if ($Progname eq 'xy') {
            push(@CutsArgs, -2, -1);
            $column_count = 2;
        } elsif ($Progname eq 'x') {
            push(@CutsArgs, -1);
            $column_count = 1;
        }
    }
    if (length($Progname) != $column_count) {
        # x 1
        # xy 1 2
        usage("$Progname: expecting exactly $column_count numeric column arg");
    }

    @ARGV = @OurArgs;
    getopts('vns:co:');

    v("\@CutsArgs = (@CutsArgs)\n");
    if (-e $ConfigFile && ! $opt_c) {
        v("Found config file: %s\n", $ConfigFile);
        do $ConfigFile || die "$0: $ConfigFile: $@\n";
    }

    $Params{'CUTSCMD'} = "@CutsArgs";
    $Params{'progname'} = $Progname;
    $Params{'pngfile'} = $opt_o ? $opt_o : sprintf("/tmp/%s.png", $Progname);
    $Params{'v'} = $opt_v ? 1 : 0;

    if ($Progname eq 'x') {
        $Params{'ylab'} = '';
    }

    # -- Overwrite defaults from command line if any name=value
    foreach my $arg (@ParamArgs) {
        if ($arg =~ /^(\w+)=(.+)$/) {
            my ($name, $value) = ($1, $2);
            if ($name =~ /^[xy]lim$/) {
                if ($value !~ /^c\([-+0-9.]+[, ]+[-+0-9.]+\)$/) {
                    my ($low, $high) = split(/[\s,;:]+/, $value);
                    if ((defined $high) && looks_like_number($high)) {
                        $value = "c($low,$high)";
                    } else {
                        usage("$name must be 'c(low,high)' or 'low,high'");
                    }
                }
                # Ugly hack: ggplot doesn't like empty 'limits=...'
                # So we need {xlim} to either have it all name=value
                # or none
                $value = "limits=$value";
            }
            if ($name =~ /^b(?:and)?w(?:idth)?$/) {
                # bandwidth and adjust are two ways to change the
                # same thing so just be friendly to the user here
                # and allow either one
                $name = 'adjust';
            } elsif ($name eq 'lt') {
                # User friendliness
                $name = 'linetype';
            } elsif ($name eq 'lw') {
                # User friendliness: line-width in 'x' density
                $name = 'size';
            }
            $Params{$name} = $value;
        }
    }

    v("get_args done. Params are:\n");
    if ($opt_v) {
        for my $k (sort keys %Params) {
            v("\t%s\t%s\n", $k, $Params{$k});
        }
    }
}

sub template_2_script($) {
    my $script = shift;

    foreach my $k (keys %Params) {
        my $v = $Params{$k};
        $script =~ s/{$k}/$v/g;
    }
    if ($opt_s) {
        open(my $fh, ">$opt_s") || die "$0: can open $opt_s: $!\n";
        print $fh $script;
        close $fh;
        v("Wrote Rscript into %s\n", $opt_s);
        chmod 0755, $opt_s;
        exit 0;
    }

    $script;
}

sub generate_chart($) {
    my $script = shift;
    my $tmp_script = mktemp("x-rscript-XXXXXX");
    open(my $r_script, ">$tmp_script");
    print $r_script $script;
    close $r_script;
    system("Rscript $tmp_script");
    wait;
    unlink($tmp_script);
    $Params{'pngfile'};
}

sub display($) {
    my $chartfile = shift;
    my $display_prog = $Params{'display'};
    system(qq{$display_prog "$chartfile" 2>/dev/null});
    wait;
}

# -- main
get_args();
my $FinalScript = template_2_script($RScript);
my $ChartFile = generate_chart($FinalScript);
display($ChartFile) unless ($opt_n);
unlink($ChartFile) unless ($opt_o);

__END__

=head1 NAME

x - plot density of a single data vector from file:column
xy - scatter plot of two parallel vectors from file column1 column2

=head1 SYNOPSIS

x  [Options] [Column_Specs]...
xy [Options] [Column_Specs]...

Column_Specs:

  filename:colno  Extract colno from filename
  filename        Use filename to extract columns from
  colno           Use column colno to extract columns
  -               An alias for stdin

  If there's an excess of colno args, will duplicate the last
  file arg.  If there's an excess of file args, will duplicate
  the last colno.

  If omitted:
      Default file is /dev/stdin
      Default colno is 0

=head1 DESCRIPTION

x plots density distribution of x (single numeric vector)

x uses cuts for column extraction.  You may extract the data
from any file:colum_no (argument) or stdin.

=head1 OPTIONS

    -v              verbose (mostly for debugging)
    -o <chartfile>  write generated chart to <chartfile>

    Other options & args (not including VAR=VALUE form vars)
    are passed down to 'cuts' (see cuts) to select data-columns.

=head1 VAR=VALUE settings

    You may pass more arguments of the form:

        var=value

     to modify the visuals (size, color, etc.)
     These are passed to the R/ggplot APIs in an implementation dependent
     manner. Defaults are:

                v       0
                size    0.5
                xlim
                ratio   1
                width   4
                ylim
                display gwenview
                ylab    Y
                fill    #3377ff
                alpha   0.5
                shape   20
                color   #0000ff
                xlab    X
                title

=head1 EXAMPLES

 x file 3           Plot column 3 from file
 x file:3           Same as above

 xy file 3 1        Plot columns 3 (on X axis) and 1 (on Y axis)
                    from file as a scatter-plot

=head1 AUTHOR

Ariel Faigon

=head1 FILES

Optional personal configuration ~/.x.pl

If this file exists, x will read it during startup allowing
you override default parameters and variables.

The config file is eval'ed in perl just after reading the options.
The option -c disables reading of the config file.
 
=head1 SEE ALSO

cuts, R, ggplot2

=head1 BUGS

Probably

=cut

