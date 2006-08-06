#!/usr/bin/perl

use SDL;
use SDL::App;
use SDL::Surface;
use SDL::Event;
use SDL::Tool::Font;

use CM::Maze;
use CM::MazeRenderer;
use CM::MazeGenerator::GrowingTree;
use CM::MazeGenerator::RecursiveBacktracker;

#my $maze = new CM::Maze(25, 25);
my $maze = new CM::Maze(49, 37);

#$maze->create_empty_box(11, 11, 5, 5);

# The "goal"
$maze->create_empty_box($maze->width - 6, 1, 5, 5);
$maze->open_position($maze->width - 7, 3);

#$maze->enable_all;
#$maze->block_position(1,2);
#$maze->block_position(2,1);
#$maze->block_position(2,3);
#$maze->block_position(3,2);
#$maze->block_position(3,3);
#$maze->block_position(4,3);
#$maze->block_position(3,4);
#$maze->debug_print_adjacency;

my $gen = new CM::MazeGenerator::RecursiveBacktracker();
$gen->generate($maze, 1, $maze->height-2, $maze->width - 8, 3);

my $window = new SDL::App(
    -width => 800,
    -height => 600,
    -depth => 32,
    -title => "Crazy Mazes",
);

my $all = new SDL::Rect( -height => $window->height, -width => $window->width );

my $renderer = new CM::MazeRenderer($window, 8, 4, $maze);
$renderer->draw();
$window->flip();

my $event = new SDL::Event();

eatevents($event);

# Just eat up all the queued events ... except QUIT
sub eatevents {
    my ($event) = @_;
    $event->pump();
    $event->set_unicode(1);
    
    while ($event->wait()) {
        my $etype = $event->type();
    
        exit(0) if ($etype == main::SDL_QUIT());
    }
}
