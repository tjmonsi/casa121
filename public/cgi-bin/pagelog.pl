#!/usr/bin/perl
$curpath = substr($0, 0, rindex($0, "/")+1);
require "${curpath}config.pl";





$ENV{'QUERY_STRING'} =~ s/%2C/,/g;
@from_info = split(/,/, $ENV{'QUERY_STRING'});
($envdate,$envhostname,$envpagename,$envpageurl,$envbrowser) = @from_info;



#============================================#
if ($envdate ne '=') {$match_pattern=$envdate;$match_title="On Date:";}
if ($envhostname ne '=') {$match_pattern=$envhostname;$match_title="From Host:";}
if ($envpagename ne '=') {$match_pattern=$envpagename;$match_title="To Page:";}
if ($envbrowser ne '=') {$match_pattern=$envbrowser;$match_title="Using Browser:";}
# If we need connections to the whole site there
# is no pattern to match, but we need a title:
if (!$match_pattern) {$match_title="To Site:";}



$pagetitle = $envpagename;
$pagetitle =~ s/=/ /g;


#==========================#
#==========================#
# Speed up output:
$! = 1;
$| = 1;
print "Content-type: text/html\n\n";
print "<HTML>\n";
if ($match_title eq "To Page:")
 {print " <HEAD>  <TITLE>$program:Last $connections Connections $match_title $pagetitle</TITLE>  </HEAD>\n";}
 else
  {print " <HEAD>  <TITLE>$program:Last $connections Connections $match_title $match_pattern</TITLE>  </HEAD>\n";}

print <<EOF;
 <BODY $background $bgcolor $textcolor $linkcolor $vlinkcolor $alinkcolor >
  <CENTER>
   <H1>Last $connections Connections $match_title</H1>
EOF

if ($match_title eq "To Page:")
 {print "   <H1>$pagetitle</H1>\n";}
 else {print "   <H1>$match_pattern</H1>\n";}

print <<EOF;
   <TABLE BORDER=2 WIDTH=100%>
    <TR>
     <TH $tableheadercolor><FONT SIZE=+1>Date/Time</FONT></TH>
     <TH $tableheadercolor><FONT SIZE=+1>Hostname</FONT></TH>
     <TH $tableheadercolor><FONT SIZE=+1>Page</FONT></TH>
     <TH $tableheadercolor><FONT SIZE=+1>Browser</FONT></TH>
    </TR>
EOF
  


#===================================================#
$concount=0;
$todaycount=0;
$nooflines=0;

open (LOG,"$logfile");
while (<LOG>) {
 if ($_ ne "LOG-BEGIN\n") {
  $nooflines++;
  ($thedate,$hostname,$pagename,$pageurl,$browser) = split;
  ($second,$minute,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($thedate);
  ($tsecond,$tminute,$thour,$tmday,$tmon,$tyear,$junk,$junk,$junk)=localtime(time);
  $sanepagename = $pagename;
  $sanepagename =~ s/=/ /g;
  $mon = $mon + 1;
  $tmon = $tmon + 1;
  $date = sprintf ("%2d/%2d/%2d",$mon,$mday,$year);
  $date =~ s/ /0/g;
  $today = sprintf ("%2d/%2d/%2d",$tmon,$tmday,$tyear);
  $today =~ s/ /0/g;
  $time = sprintf ("%2d:%2d:%2d",$hour,$minute,$second);
  $time =~ s/ /0/g;
  $todaytime = sprintf ("%2d:%2d:%2d",$thour,$tminute,$tsecond);
  $todaytime =~ s/ /0/g;
  # In case we need to recurse into pagelog for additional matches
  $url_datematch = "$pagelogurl?$date,=,=,=,=";
  $url_hostmatch = "$pagelogurl?=,$hostname,=,=,=";
  $url_pagematch = "$pagelogurl?=,=,$pagename,$pageurl,=";
  $url_browsermatch = "$pagelogurl?=,=,=,=,$browser";

  if ($ENV{'QUERY_STRING'}) {
   if ($match_title eq "On Date:") {if ($match_pattern eq $date) {&show_match;}}
   if ($match_title eq "From Host:") {if ($hostname =~ $match_pattern) {&show_match;}}
   if ($match_title eq "To Page:") {if ($match_pattern eq $pagename) {&show_match;}}
   if ($match_title eq "Using Browser:") {if ($match_pattern eq $browser) {&show_match;}}
   }
   else {&show_match;}
  }
 }

sub show_match {
 if ($concount < $connections)
  {print "    <TR><TD ALIGN=CENTER><A TARGET=\"_top\" HREF=\"$url_datematch\">$date</A> - $time</TD><TD><A TARGET=\"_top\" HREF=\"$url_hostmatch\">$hostname</A></TD><TD><A TARGET=\"_top\" HREF=\"$pageurl\"><FONT SIZE=2>.</FONT></A> <A TARGET=\"_top\" HREF=\"$url_pagematch\">$sanepagename</A></TD><TD><A TARGET=\"_top\" HREF=\"$url_browsermatch\">$browser</A></TD></TR>\n";}
 $concount++;
 if ($date eq $today) {$todaycount++;}
 }

close (LOG);

print "   </TABLE><BR><BR>\n";


#==========================================#
#==========================================#
# Calculating percentage of connections 
# out of total site connections
$percent = ($concount / $nooflines) * 100;
if (rindex($percent,".") != -1) 
 {$decimal = substr($percent,rindex($percent,"."),3);}
if ($decimal == 0) {$decimal="";}
$percentage = int($percent).$decimal;

# Fixing up some variables
$match_title =~ tr/A-Z/a-z/;
$match_title =~ s/://g;

if ($match_pattern) {$match_pattern =~ s/=/ /g;}

# Send out summary to the browser
print "   <H2>Summary</H2>\n";
print "   <TABLE BORDER=1 CELLPADDING=3>\n";
print "    <TR><TD ALIGN=CENTER COLSPAN=2><B>Today's date:</B> $today <B>Actual time:</B> $todaytime</TD></TR>\n";
if ($concount == 0) {
 if ($match_pattern) {print "    <TR><TH COLSPAN=3>There has been no connection $match_title [$match_pattern]</TH></TR>\n";}
  else {print "    <TR><TH COLSPAN=3>There has been no connection $match_title</TH></TR>\n";}
 }
 else {
  print "    <TR><TD ALIGN=RIGHT><B>Total site connections:</B></TD>\n";
  print "     <TH><B>$nooflines</B></TH></TR>\n";
  if ($match_pattern) {
   print "    <TR><TD ALIGN=RIGHT><B>Connections $match_title [$match_pattern]:</B></TD>\n";
   print "     <TH><B>$concount</B></TH></TR>\n";
   print "    <TR><TD ALIGN=RIGHT><B>Which is about:</B></TD>\n";
   print "     <TH><B>$percentage %</B></TH></TR>\n";
   }
  if ($todaycount > 0) {
   if ($match_pattern) {
    print "    <TR><TD ALIGN=RIGHT><B>Connections $match_title [$match_pattern] today only:</B></TD>\n";
    }
    else {print "    <TR><TD ALIGN=RIGHT><B>Connections $match_title today only:</B></TD>\n";}   
   print "     <TH><B>$todaycount</B></TH></TR>\n"; 
   }
  }

print "   </TABLE>\n";
print "  </CENTER>\n";


#=============#

#=============#
print <<EOF;
  <P><HR>
  <CENTER>
   <FONT SIZE=2>
    By
    <A TARGET="_top" HREF="http://www.entergate.com">Syroos Daneshmir</A>
   </FONT>
  </CENTER>
 </BODY>
</HTML>

EOF

exit;
