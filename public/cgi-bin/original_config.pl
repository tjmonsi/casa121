#!/usr/bin/perl5
$program = "Inloggning till http://www.begrafic.com";
$version = "/Entergate";





$numofdays = 30;


$logfile = "/usr/local/etc/httpd/htdocs/aispuro/cgi-bin/log/access.log";


$backup = "/usr/local/etc/httpd/htdocs/aispuro/cgi-bin/log/access.bak";

$lockfile = "/usr/local/etc/httpd/htdocs/aispuro/cgi-bin/log/access.lok";


$oldlogfile = "/usr/local/etc/httpd/htdocs/aispuro/cgi-bin/log/access.old";
 

$hadablogurl = "http://www.begrafic.com/cgi-bin/blog.pl";


$pagelogurl = "http://www.begrafic.com/cgi-bin/pagelog.pl";


$gifdirurl = "http://www.begrafic.com/images";

@referers = ('www.begrafic.com');


@ignoresites = ('.shadow.net');


$connections = 100;


$fullhost = 0;


#------------------------------------------#
# Page background image:
# $background = "BACKGROUND=";
# Page background color:
$bgcolor = "BGCOLOR=#000000";
# Text color:
$textcolor = "TEXT=#ffefc6";
# Link color:
$linkcolor = "LINK=#ffff58";
# Visited link color:
$vlinkcolor = "VLINK=#FF3232";
# Active link color:
$alinkcolor = "ALINK=#000000";
# Table header background color:
$tableheadercolor = "BGCOLOR=#000000";
# Table border around hour/date charts:
$border = "BORDER=3";

#------------------------------------------#
$limitpages{'all'} = 0;
$limitpages{'page'} = 0;
$limithosts{'all'} = 15;
$limithosts{'page'} = 25;
$limitbrowsers{'all'} = 10;
$limitbrowsers{'page'} = 10;
$limitdays{'all'} = 10;
$limitdays{'page'} = 0;


#-----------------------------#

1;
