#!/usr/bin/perl -w
use v5.10;
use version;
our $VERSION = qv('0.1.0');

my $uenv = "uEnv.txt";
my $arg_count = @ARGV;

$uenv = "/boot/$uenv" if !(-f $uenv);
die "uEnv.txt not find!" if !(-f $uenv);

my $USAGE = <<"END_USAGE";
Usage: $0 [rm <param>|set <param>]
Mode:
                : print boot params from uEnv.txt
    rm  <param> : remove param
    set <param> : set or update param value
END_USAGE

sub usage {
    warn $USAGE;
    exit 1;
}

# return param name with '=', if exist
sub param_name {
    my $param = shift @_;
    my $i = index $param, '=';
    if ($i < 0) {
        return $param;
    } else {
        return substr $param, 0, $i+1;
    }
}

# read uEnv.txt
sub read_uenv {
    my $path = shift @_;
    open( my $src, '<', $path) or die "Cannot open : $!";
    my @input = <$src>;
    close($src) or die "Error closing: $!";
    return @input;
}

# write uEnv.txt
sub write_uenv {
    my $path = shift @_;
    open( my $dest, '>', $path) or die "Cannot open : $!";
    foreach my $line (@_) {
        print($dest $line);
    }
    close($dest) or die "Error closing: $!";
}

my @input = read_uenv $uenv;
my @params = split(' ', shift @input);
my @res = ();
my $param;
my $value;

# return param index
sub check_params {
    my $name = param_name(shift @_);
    for my $i (0..(@params-1)) {
        if ($params[$i] =~ /^$name/) {
            return $i
        }
    }
    return -1;
}

if ($arg_count == 0) {
    # list params
    # remove bootargs=
    shift @params;
    my $param_count = @params;
    print "param count: $param_count\n";
    foreach my $p (@params) {
        print "$p\n";
    }
    exit 0;
} elsif ($arg_count == 1) {
    usage();
} elsif ($ARGV[0] eq "rm") {
    # remove param
    $param = param_name($ARGV[1]);
    print "remove param: $param\n";
    foreach my $p (@params) {
        if ( !($p =~ /^$param/) ) {
            push(@res, $p);
        }
    }
} elsif ($ARGV[0] eq "set") {
    # set param
    push (@res, @params);
    $param = $ARGV[1];

    my $param_index = check_params($param);
    if ($param_index < 0) {
        print "add param: $param\n";
        push (@res, $param);
    } else {
        print "update param: $param\n";
        $res[$param_index] = $param;
    }
} else {
    usage();
}

my $new_params = join " ", @res;
unshift @input, "$new_params\n";
write_uenv $uenv, @input;

__END__

=head1 NAME

uboot_params.pl - working with uboot configuration file uEnv.txt

=head1 SYNOPSIS

C<uboot_params.pl>
C<uboot_params.pl rm quiet>
C<uboot_params.pl set quiet>
C<uboot_params.pl set camera=>
C<uboot_params.pl set camera=ov2643>

=head1 DESCRIPTION

...some description...

=head1 AUTHOR

sv99@inbox.ru

