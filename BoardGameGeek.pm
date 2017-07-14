# Moose based Perl module for BGG API connections
# Version 0.3 
# Copyright 2014-2017 Virre Linwendil Annergård
# Contact: virre.annergard@gmail.com
#
# This libary is released under the GNU GPL Ver 3
#
#  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

{
    package Boardgame;
    use Moose;
    use XML::LibXML qw(:libxml);
    use LWP::Simple;

    sub callBggApi {
	my $call = $_[0];
	my $value = $_[1];
	my $options = $_[2];
	my $base_url = 'https://www.boardgamegeek.com/xmlapi/';
	my $data = get("$base_url$call/$value");
	return $data;
    }

    sub search  {
	my $self = shift;
	my $xml_raw = callBggApi('search/?search=', $_[0], $_[1]);
	my $parser = new XML::LibXML;
	my $dom = $parser->load_xml(string => $xml_raw);
	my @boardgames= $dom->getElementsByTagName('boardgame');
	my $id = 0;
	my %output = ();
	for my $boardgame (@boardgames) {
		my $name = $boardgame->getElementsByTagName('name')->string_value;
		$id = $boardgame->{objectid};
		$output{$id} = $boardgame->to_literal;
	}
	return \%output;
    }

    sub gameData {
	my $self = shift;
	my $xml_raw = callBggApi('boardgame/', $_[0], $_[1]);
    	my $parser = new XML::LibXML;
	my $dom = $parser->load_xml(string => $xml_raw);
	my @boardgames = $dom->getElementsByTagName('boardgame');
	my $id = 0;
	my %output = ();
	for my $boardgame (@boardgames) {
		my @children = grep { $_->nodeType == XML_ELEMENT_NODE } $boardgame->childNodes;
		$id = $boardgame->{objectid};
		for my $child (@children) {
			my $name = $child->nodeName;
			next if $name eq 'poll';
			$output{$id}{$name} = $boardgame->getElementsByTagName($name)->string_value; 
		}
	}
	return \%output;
    }
    no Moose;
}

{
    package BggUser; 
    use Moose; 
    use LWP::UserAgent;
    use XML::LibXML;

    sub callBggApi {
	my $ua = LWP::UserAgent->new;
	my $call = $_[0];
	my $value = $_[1];
	my $options = $_[2];
	my $uri = "https://www.boardgamegeek.com/xmlapi/$call/$value";
	my $response = $ua->get($uri);
	if ($response->code eq '200') { 
		my $data = $response->decoded_content;
		return -2 if $data =~ m/\<error\>/;
		return $data;
	} elsif ($response->code eq '202') { 
		return -1;
	} else { 
		return -2;
	}
    }

    sub getCollection {
	my $self = shift;
	my $xml_raw = callBggApi('collection/', $_[0],$_[1]);
	if ($xml_raw eq -1) { 
		die("Request to create data have been sent to BGG but not processed, please try again later");	
	} elsif ($xml_raw eq -2 ) {
		die("Unknown issue created request for collection to fail");
	}
    	my $parser = new XML::LibXML;
	my $dom = $parser->load_xml(string => $xml_raw);
	my @boardgames = $dom->getElementsByTagName('item');
	my $id = 0;
	my %output = ();
    	for my $boardgame (@boardgames) {
		$id = $boardgame->{objectid};
		# TODO: Skip none boardgame/boardgame expansions.
		$output{$id}{'subtype'} = $boardgame->{'subtype'};
		my @children = grep { $_->nodeType == XML_ELEMENT_NODE } $boardgame->childNodes;
		for my $child (@children) {
			my $name = $child->nodeName;
			if ($name eq 'status') {
				# We only support Owned and wishlist status...
				my $status;
				if ($child->getAttribute('own') eq 1) {
					$status = 'Owned';
				} elsif ($child->getAttribute('wishlist') eq 1) { 
					$status = 'Wishlist';	
				} else {
					delete $output{$id};
					last;
				}
				$output{$id}{'status'} = $status;
			} elsif ($name eq 'stats') {
				# TODO: Add the stats to return hash.
				next;
			}  else { 
				$output{$id}{$name} = $boardgame->getElementsByTagName($name)->string_value;
			}
		}	
	}
	return \%output;
    }

    no Moose;
}


{
    package BggList; 
    use Moose; 
    use LWP::Simple;
    use XML::LibXML;

    sub callBggApi {
	my $call = $_[0];
	my $value = $_[1];
	my $options = $_[2];
	my $base_url = 'https://www.boardgamegeek.com/xmlapi/';
	my $data = get("$base_url$call/$value");
	return $data;
    }

    sub getBggList {
	my $self = shift;
	my $id = $_[0];	
	my $xml_raw = callBggApi('geeklist/', $id);
    	my $parser = new XML::LibXML;
	my $dom = $parser->load_xml(string => $xml_raw);
	my %output = ();
	my $title = $dom->getElementsByTagName('title')->string_value;
	$output{$id}{'title'} = $title;
	my @geeklistitems = $dom->getElementsByTagName('item');
	for my $item (@geeklistitems) {
		my $body = $item->getElementsByTagName('body')->string_value;
		# There seems to be some random false entries in the api with this as the body so...
		next if $body =~ m/This page is torn up with some script that will not get it to load. I need to create dummy entries in order to force it to page/;
		my $entry_id = $item->{id};	
		my %entry = (
			'poster' => $item->{username},
			'imageid' => $item->{imageid},
			'object_type' => $item->{objecttype},
			'object_id' => $item->{objectid},
			'object_name' => $item->{objectname},
			'thumbs' => $item->{'thumbs'},
			'entry_text' => $body,
		);
		$output{$entry_id}{$entry_id} = \%entry;		
	}	
    	return \%output;
    }
    no Moose;
}

1;
