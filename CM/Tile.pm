#!/usr/bin/perl

package CM::Tile;

use strict;
use Scalar::Util;

use constant TILESET => 0;
use constant INDEX => 1;
use constant IMAGE => 2;

# We cache tiles the first time they are instantiated so that there's
# only ever one instance of each tile in memory.
# The cache has weakened scalars so that they'll fall out of the cache
# as soon as they aren't used anywhere else.
my %cache = ();

sub new {
    my ($class, $tileset, $idx) = @_;
    
    return $cache{$tileset}{$idx} if ($cache{$tileset} && $cache{$tileset}{$idx});
    
    my $self = [ $tileset, $idx, undef ];
    bless $self, $class;
    
    $cache{$tileset}{$idx} = $self;
    Scalar::Util::weaken($cache{$tileset}{$idx});
    
    return $self;
}

sub image {
    my ($self) = @_;
    return $self->[IMAGE] if $self->[IMAGE];
    my $img = $self->[TILESET]->image($self->[INDEX]);
    $self->[IMAGE] = $img;
    Scalar::Util::weaken($self->[IMAGE]);
    return $img;
}

1;
