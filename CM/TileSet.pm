#!/usr/bin/perl

package CM::TileSet;

use strict;
use Scalar::Util;
use SDL::Surface;
use CM::Tile;

use constant IMAGE => 0;
use constant TILES_PER_ROW => 1;

# We cache tilesets the first time they are instantiated so that there's
# only ever one instance of each tileset in memory.
# The cache has weakened scalars so that they'll fall out of the cache
# as soon as they aren't used anywhere else.
my %cache = ();

sub new {
    my ($class, $imgfile, $tint_color, $shade_color) = @_;
    
    # Can't use undef as a hash key for the cache
    $tint_color ||= 0;
    $shade_color ||= 0;
    
    return $cache{$imgfile}{$tint_color}{$shade_color} if ($cache{$imgfile}{$tint_color}{$shade_color});

    my $img = new SDL::Surface -name => $imgfile;
    my $wid = $img->width;
    my $hei = $img->height;
    my $tilesperrow = $wid / 16;
    die "$imgfile width is not a multiple of 16" unless int($tilesperrow) == $tilesperrow;
    
    my $self = [ $img, $tilesperrow ];
    
    bless $self, $class;

    $self->tint_self($tint_color, $shade_color) if $tint_color || $shade_color;
    
    $cache{$imgfile}{$tint_color}{$shade_color} = $self;
    Scalar::Util::weaken($cache{$imgfile}{$tint_color}{$shade_color});
    
    return $self;
}

sub tile {
    my ($self, $idx) = @_;
    return new CM::Tile($self, $idx);
}

sub image {
    my ($self, $idx) = @_;
    
    my $tilesperrow = $self->[TILES_PER_ROW];
    my $x = ($idx % $tilesperrow) * 16;
    my $y = int($idx / $tilesperrow) * 16;
    
    my $setimg = $self->[IMAGE];
    my $tileimg = new SDL::Surface(
        -flags => 0x00010000, # SRCALPHA
        -width => 16,
        -height => 16,
        -depth => 32,
    );
    my $rect = new SDL::Rect(
        -width => 16,
        -height => 16,
        -x => $x,
        -y => $y,
    );
    $setimg->blit($rect, $tileimg, 0);
    
    return $tileimg;
}

sub tint_self {
    my ($self, $tint_color, $shade_color) = @_;
    
    $tint_color ||= new SDL::Color(-r => 255, -g => 255, -b => 255);
    $shade_color ||= new SDL::Color(-r => 0, -g => 0, -b => 0);
    
    my $img = $self->[IMAGE];
    my $wid = $img->width;
    my $hei = $img->height;

    # Re-use the same Color object to avoid re-instantiating this
    # class for each iteration
    my $dstclr = new SDL::Color();
    
    # FIXME: Does this clobber the alpha channel?
    # FIXME: This is really slow.
    
    for (my $y = 0; $y < $hei; $y++) {
        for (my $x = 0; $x < $wid; $x++) {
            my $srcclr = $img->pixel($x,$y);

            my $tint = sub {
                my ($src, $tint, $shade) = @_;
                
                my $diff = $tint - $shade;
                return int($shade + $diff * $src / 255);
            };
           
            $dstclr->r($tint->($srcclr->r, $tint_color->r, $shade_color->r));
            $dstclr->g($tint->($srcclr->g, $tint_color->g, $shade_color->g));
            $dstclr->b($tint->($srcclr->b, $tint_color->b, $shade_color->b));
            
            $img->pixel($x, $y, $dstclr);
        }
    }
    
    #use Data::Dumper;
    #print Data::Dumper::Dumper($img->pixel(0,0));
}

1;
