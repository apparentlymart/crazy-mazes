#!/usr/bin/perl

package CM::Maze;

use strict;

use constant BLOCKED => 1;
use constant IN_MAZE => 2;
use constant HAS_TOKEN => 4;

sub new {
    my ($class, $wid, $hei) = @_;
    
    my $size = $wid * $hei;

    die "Width must be an odd number" unless ($wid % 2) == 1;
    die "Height must be an odd number" unless ($hei % 2) == 1;
    
    my $self = {
        'wid' => $wid,
        'hei' => $hei,
        'size' => $size,
        'data' => [ map { 0 } 1 .. $size ],
    };
    
    bless $self, $class;
    $self->create_initial_maze;
    
    return $self;
}

sub create_initial_maze {
    my ($self) = @_;

    for (my $x = 0; $x < $self->width; $x += 2) {
        for (my $y = 0; $y < $self->width; $y += 2) {
            $self->block_position($x, $y);
        }
    }

    # Fill in the border and enable it
    for (my $x = 0; $x < $self->width; $x += 1) {
        $self->block_position($x, 0);
        $self->block_position($x, $self->height - 1);
    }    
    for (my $y = 0; $y < $self->height; $y += 1) {
        $self->block_position(0, $y);
        $self->block_position($self->width - 1, $y);
    }
    
}

sub create_empty_box {
    my ($self, $x1, $y1, $w, $h, $in_maze) = @_;
    
    $in_maze = 1 unless defined($in_maze);
    
    die "x1 must be an odd number" unless ($x1 % 2) == 1;
    die "y1 must be an odd number" unless ($y1 % 2) == 1;
    die "w must be an odd number" unless ($w % 2) == 1;
    die "h must be an odd number" unless ($h % 2) == 1;
    
    my $x2 = $x1+$w;
    my $y2 = $y1+$h;
    
    for (my $y = $y1; $y < $y2; $y++) {
        for (my $x = $x1; $x < $x2; $x++) {
            $self->open_position($x, $y);
            $self->disable_position($x, $y) unless $in_maze;
        }
    }
}

sub block_position {
    my ($self, $x, $y, $no_enable) = @_;
    
    #die "Can't block out positions where both X and Y are odd" if (($x % 2) == 1 && ($y % 2) == 1);
    
    $self->{data}->[$self->stride($x,$y)] |= BLOCKED;
    $self->enable_position($x, $y) unless $no_enable;
}
sub open_position {
    my ($self, $x, $y, $no_enable) = @_;
    
    $self->{data}->[$self->stride($x,$y)] &= ~BLOCKED;
    $self->enable_position($x, $y) unless $no_enable;
}

sub enable_position {
    my ($self, $x, $y) = @_;
    
    $self->{data}->[$self->stride($x,$y)] |= IN_MAZE;
}
sub disable_position {
    my ($self, $x, $y) = @_;
    
    $self->{data}->[$self->stride($x,$y)] &= ~IN_MAZE;
}

sub enable_all {
    my ($self) = @_;
    
    local $_;
    foreach (@{$self->{data}}) {
        $_ |= IN_MAZE;
    }
}

sub disable_all {
    my ($self) = @_;
    
    local $_;
    foreach (@{$self->{data}}) {
        $_ &= ~IN_MAZE;
    }
}

sub stride {
    my ($self, $x, $y) = @_;
    my $result = ($self->width * $y) + $x;
    return 65536 if $result < 0; # Ensure that we never return a negative number
    return $result;
}

sub position_is_blocked {
    my ($self, $x, $y) = @_;
    return ($self->{data}[$self->stride($x,$y)] & BLOCKED) ? 1 : 0;
}

sub position_in_maze {
    my ($self, $x, $y) = @_;
    return ($self->{data}[$self->stride($x,$y)] & IN_MAZE) ? 1 : 0;
}

sub adjacency_mask {
    my ($self, $x, $y) = @_;
    
    my $above = $self->position_is_blocked($x, $y - 1);
    my $below = $self->position_is_blocked($x, $y + 1);
    my $left = $self->position_is_blocked($x - 1, $y);
    my $right = $self->position_is_blocked($x + 1, $y);
    
    $left = 0 if ($x == 0);
    $above = 0 if ($y == 0);
    $right = 0 if ($x == $self->width - 1);
    $below = 0 if ($y == $self->height - 1);
    
    return $above | ($left * 2) | ($below * 4) | ($right * 8);
}

sub data_size {
    return $_[0]->{size};
}

sub width {
    return $_[0]->{wid};
}

sub height {
    return $_[0]->{hei};
}

sub debug_print {
    my ($self) = @_;

    for (my $i = 0; $i < $self->data_size; $i++) {
        my $point = $self->{data}[$i];
        if (($point & BLOCKED) && ($point & IN_MAZE)) { print "O"; }
        else { print " "; }
        print "\n" if ($i % $self->width) == ($self->width - 1);
    }
}

sub debug_print_adjacency {
    my ($self) = @_;

    for (my $y = 0; $y < $self->height; $y++) {
        for (my $x = 0; $x < $self->width; $x++) {
            printf("%1x", $self->adjacency_mask($x,$y));
        }
        print "\n";
    }
}

1;
