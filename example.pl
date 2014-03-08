#!/usr/bin/perl

use strict;
use warnings;
use BoardGameGeek;
use Data::Dumper;

#Intiate Boardgames support. 
my $game = Boardgame->new();

#init empty holder
my @data; 

# Get data based on ID
@data = $game->gameData(1);
print Dumper(@data);

# Search for a game. 
@data = $game->search('Twilight Struggle');
print Dumper(@data);

my @data2;
#Create user connection
my $bgg_user = BggUser->new();

# Show users full collection. This might take a while.
@data2 = BggUser->getCollection('virre');
print Dumper(@data2);

my @data3;

# Create GeekList. 
my $geeklist = BggList->new();

# Get Geeklist
@data3 = $geeklist->getList(49088);
print Dumper (@data3);
