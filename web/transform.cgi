#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use strict;
use CGI qw(param);

use XML::LibXSLT;
use XML::LibXML;

if (param()) 
{
	my $wp = param('wp');
	my $dir = "/home/engarde/live/web";

	my $parser = XML::LibXML->new();
	my $xslt = XML::LibXSLT->new();

	my $source = $parser->parse_file("$dir/competitions/$wp.xml");
	my $style_doc = $parser->parse_file("$dir/transform.xsl");

	my $stylesheet = $xslt->parse_stylesheet($style_doc);

	my $results = $stylesheet->transform($source);

	print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">";
	print "<head><title></title>";

	print "<style type=\"text/css\"> #top, #bottom, #left, #right { background: blue;} </style>";
	print "<link href=\"css/live.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />";
	print "<script src=\"script/screens.js\" type=\"text/javascript\"></script>";
	
	print "</head><div id=\"left\" name=\"border\"</div><div id=\"right\" name=\"border\"</div>";
	print "<div id=\"top\" name=\"border\"></</div> <div id=\"bottom\" name=\"border\"></div>";
	print "<span name=\"timestamp\" class=\"timestamp\">00:00</span>";
	print $stylesheet->output_string($results);

	print "</body></html>";
}
