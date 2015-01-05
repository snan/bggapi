# Moose based Perl module for BGG API connections
# Version 0.2 
# Copyright 2014-2015 Virre Linwendil Annergård
# Contact: virre.annergard@gmail.com
#
# This libary is released under the GNU GPL Ver 3
#
#  This program is free software: you can redistribut#e it and/or modify it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 o#f the License, or
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
    use XML::Simple;
    use LWP::Simple;

    sub callBggApi {
	my $call = $_[0];
	my $value = $_[1];
	my $options = $_[2];
	my $base_url = 'http://www.boardgamegeek.com/xmlapi/';
	my $data = get("$base_url$call/$value");
	return $data;
    }

    sub search  {
	my $self = shift;
	my $xml_raw = callBggApi('search/?search=', $_[0], $_[1]);
	my $parser = new XML::Simple;
	my $dom = $parser->XMLin($xml_raw, ForceArray => 1);
	my $result = scalar($dom->{boardgame});
	my $key = 0;
	my $id = 0;
	my $name = '';
	my %output = ();
	while (($key, my $value) = each $result) {
	    my $name_data = $result->[$key]->{name}; 
	    if (ref($name_data->[0]) eq 'HASH') {
		$name = $name_data->[0]->{content};
		$id = $result->[$key]->{objectid}; 
		$output{$id} = $name;
	    }
	}
	return %output;
    }

    sub gameData {
	my $self = shift;
	my $xml_raw = callBggApi('boardgame/', $_[0], $_[1]);
	my $parser = new XML::Simple;
	my $dom = $parser->XMLin($xml_raw, ForceArray => 1);
	my $result = scalar($dom->{boardgame});
	return $result;
    }

    no Moose;
}

{
    package BggUser; 
    use Moose; 
    use LWP::Simple;
    use XML::Simple;

    sub callBggApi {
	my $call = $_[0];
	my $value = $_[1];
	my $options = $_[2];
	my $base_url = 'http://www.boardgamegeek.com/xmlapi/';
	my $data = get("$base_url$call/$value");
	
	return $data;
    }

    sub getCollection {
	my $self = shift;
	my $xml_raw = callBggApi('collection/', $_[0],$_[1]);
	my $parser = new XML::Simple;
	my $dom = $parser->XMLin($xml_raw, ForceArray => 1);
	my $result = scalar($dom->{item});
	return $result;
    }

    no Moose;
}

{
    package BggForums; 
    use Moose; 
    use LWP::Simple;
    use XML::Simple;
    
    sub callBggApi {
	my $call = $_[0];
	my $value = $_[1];
	my $options = $_[2];
	my $base_url = 'http://www.boardgamegeek.com/xmlapi/';
	my $data = get("$base_url$call/$value");
	return $data;
    }

    # This function seems to try to redirect to the RSS flow. 
    sub getThread {
	my $self = shift();
	my $xml_raw = callBggApi('thread/', $_[0]);
	my $parser = new XML::Simple;
	my $dom = $parser->XMLin($xml_raw, ForceArray => 1);
	my $result = scalar($dom->{boardgame});
	return $result;
    }
    no Moose;
}

{
    package BggList; 
    use Moose; 
    use LWP::Simple;
    use XML::Simple;
    use Data::Dumper;

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
	my $xml_raw = callBggApi('geeklist/', $_[0]);
	my $parser = new XML::Simple;
	my $dom = $parser->XMLin($xml_raw, ForceArray => 1);
	my $result = scalar($dom->{item});
	return $result;
    }
    no Moose;
}

1;
