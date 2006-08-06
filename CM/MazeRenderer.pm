#!/usr/bin/perl

package CM::MazeRenderer;

use strict;
use CM::TileSet;

my $tileset = new CM::TileSet('images/mazewalls.png', new SDL::Color(-r => 192, -g => 0, -b => 0));

# Mappings of adjacency masks onto wall tile indices
my %blocktilemap = (
    0xf => 0,
    0xc => 1,
    0x6 => 2,
    0x3 => 3,
    0x9 => 4,
    0x4 => 5,
    0x2 => 6,
    0x1 => 7,
    0x8 => 8,
    0x0 => 9,
);
my %spacetilemap = (
    0x0 => 16,
    0x3 => 17,
    0x9 => 18,
    0xc => 19,
    0x6 => 20,
    0xb => 21,
    0xd => 22,
    0xe => 23,
    0x7 => 24,
    0xf => 25,
);

sub new {
    my ($class, $surface, $x, $y, $maze) = @_;
    
    my $self = {
        surface => $surface,
        x => $x,
        y => $y,
        maze => $maze,
    };
    
    return bless $self, $class;
}

sub maze {
    return $_[0]->{maze};
}

sub draw {
    my ($self) = @_;
    
    $self->draw_walls();
    $self->draw_tokens();
    $self->draw_characters();
}

sub draw_walls {
    my ($self) = @_;

    # FIXME: Don't redraw the entire grid every frame
    # Need to keep track of what needs re-drawing.

    my $maze = $self->maze;
    my $mwidth = $maze->width;
    my $mheight = $maze->height;
    
    my $osx = $self->{x};
    my $osy = $self->{y};
    my $srf = $self->{surface};

    # To avoid the overhead of instantiating this over and over,
    # just use one rect object for the entire maze and keep
    # tweaking the X and Y.
    my $destrect = new SDL::Rect(
        -width => 16,
        -height => 16,
    );

    for (my $y = 0; $y < $mheight; $y++) {
        for (my $x = 0; $x < $mwidth; $x++) {
            next unless $maze->position_in_maze($x, $y);
            my $gx = $osx + ($x * 16);
            my $gy = $osy + ($y * 16);
            $destrect->x($gx);
            $destrect->y($gy);
            my $tile = $self->get_wall_tile($x, $y);
            $tile->image->blit(0, $srf, $destrect);
        }
    }
}

sub get_wall_tile {
    my ($self, $x, $y) = @_;
    
    # TODO: Make this use the nice rounded corners
    # based on the adjacency mask.
    if ($self->maze->position_is_blocked($x, $y)) {
        my $adjacency = $self->maze->adjacency_mask($x, $y);
        return $tileset->tile($blocktilemap{$adjacency} ? $blocktilemap{$adjacency} : 0);
    }
    else {
        my $adjacency = $self->maze->adjacency_mask($x, $y);
        return $tileset->tile($spacetilemap{$adjacency} ? $spacetilemap{$adjacency} : 16);
    }
    
}

sub draw_tokens {
    my ($self) = @_;

}

sub draw_characters {
    my ($self) = @_;

}

1;
