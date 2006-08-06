#!/usr/bin/perl

package CM::MazeGenerator::RecursiveBacktracker;

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
    
    $self->do_cell($maze, $goalx, $goaly);
}

sub do_cell {
    my ($self, $maze, $x, $y) = @_;

    my @walls = $self->random_directions($x, $y);
    
    # This cell is now "in" the maze
    $maze->open_position($x, $y);
    
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
            $self->do_cell($maze, $px, $py);
        }
    }
    
    
}


1;
