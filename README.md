
 Moose based Perl module for BGG API connections version 0.3
 ----

 Requirements
 Moose
 ~~XML::Simple~~ (Removed in version 0.3)
 XML::LibXML
 LWP::Simple
 LWP::UserAgent

----
 Installation

 Just clone the represitory and copy BoardGameGeek.pm to your directorys path. 

----
 Usage 
 
 Use BoardGameGeek and call the functions as seen in example.pl. These will from version 0.3 return hashrefs. 
----
 Todo 

 Move all Requests to LWP:UserAgent instead of LWP::Simple.
 Move callBggApi to a main class to inherit from.
 Better search.
 Skip none boardgames/expansions from getCollection
 Add Status to return hash from getCollection
 Add forum support 
 Add Tests
----

 License 

 This software is released using the GNU General Public License Version 3. See gpl-3.0.txt for more information. 

 Please note that the content you recive from BoardGameGeek might have other restrictions. 

 
