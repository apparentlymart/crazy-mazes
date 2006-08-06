#!/usr/bin/perl

package CM::MazeGenerator::GrowingTree;

use strict;
use CM::MazeGenerator;
use List::Util qw(shuffle);

use base ("CM::MazeGenerator");

sub new {
    my ($class) = @_;
    
    my $self = new CM::MazeGenerator;
    return bless {}, $class;
}

sub generate {
    my ($self, $maze, $startx, $starty, $goalx, $goaly) = @_;
    
    my %cells = ();

    my $add_cell = sub {
        my ($x, $y) = @_;
        $cells{"$x\0$y"} = [ $x, $y ];
        $maze->open_position($x, $y);
    };
    my $random_cell = sub {
        my @list = keys %cells;
        return undef unless (scalar(@list));
        my $key = $list[int(rand(scalar(@list)-1))];
        return $cells{$key};
    };
    my $zzap_cell = sub {
        my ($x, $y) = @_;
        delete $cells{"$x\0$y"};
    };
    
    $add_cell->($goalx, $goaly);
    
    while (my $cell = $random_cell->()) {
        my ($x, $y) = @$cell;
        
        my @walls = $self->random_directions($x, $y);
        
        foreach my $dir (@walls) {
            my ($wx, $wy, $px, $py) = @$dir;
            
            # We can't go this way if the wall is already part of the maze
            # (otherwise we'd run outside the maze boundary walls)
            next if $maze->position_in_maze($wx, $wy);

            # We also can't go this way if the wall on the other side is already part of the maze.
            if ($maze->position_in_maze($px, $py)) {
                $maze->block_position($wx, $wy);
            }
            else {
                $maze->open_position($wx, $wy);
                $add_cell->($px, $py);
            }            
        }
        
        $zzap_cell->($x, $y);
    }
}

sub do_cell {
    my ($self, $maze, $x, $y) = @_;

    my @walls = shuffle ([0,-1],[0,1],[-1,0],[1,0]);
    
    # This cell is now "in" the maze
    $maze->open_position($x, $y);
    
    foreach my $dir (@walls) {
        my ($wx, $wy) = ($x + $dir->[0], $y + $dir->[1]);
        my ($px, $py) = ($x + ($dir->[0]*2), $y + ($dir->[1]*2));
    
        # We can't go this way if the wall is already part of the maze
        # (otherwise we'd run outside the maze boundary walls)
        next if $maze->position_in_maze($wx, $wy);
        
        # We also can't go this way if the wall on the other side is already part of the maze.
        if ($maze->position_in_maze($px, $py)) {
            $maze->block_position($wx, $wy);
        }
        else {
            $maze->open_position($wx, $wy);
            $self->do_cell($maze, $px, $py);
        }
    }
    
    
}


1;
