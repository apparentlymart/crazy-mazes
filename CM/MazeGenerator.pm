#!/usr/bin/perl

package CM::MazeGenerator;
use List::Util qw(shuffle);

use strict;

sub new {
    my ($class) = @_;
    
    return bless {}, $class;
}

sub generate {
    my ($self, $maze, $startx, $starty, $goalx, $goaly) = @_;
    
    die "generate not implemented for $self";
}

sub random_directions {
    my ($self, $x, $y) = @_;
    
    local $_;
    
    return map {
        [$x + $_->[0], $y + $_->[1], $x + ($_->[0]*2), $y + ($_->[1]*2)]
    } shuffle ([0,-1],[0,1],[-1,0],[1,0]);
}

1;
