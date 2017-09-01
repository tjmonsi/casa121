#!/usr/bin/perl5
$curpath = substr($0, 0, rindex($0, "/")+1);
require "${curpath}config.pl";





#======================================#
$usebackup = 0;
$date = time();
$numofsecs = 60 * 60 * 24 * $numofdays;
$ENV{'QUERY_STRING'} =~ s/%2C/,/g;
@from_info = split(/,/, $ENV{'QUERY_STRING'});
($pagename,$pageurl) = @from_info;
$hostname = $ENV{'REMOTE_HOST'};



#=========================================================#
# Speed up output:
$! = 1;
$| = 1;
if ($ARGV[0] =~ /Location/i) 
 {print "$ARGV[0]";}
 else {print "Content-type: image/gif\n\nGIF89a\1\0\1\0\200\0\0\0\0\0\0\0\0!\371\4\1\0\0\0\0,\0\0\0\0\1\0\1\0\0\2\2D\1\0\n";}



#=========================================================#
if ($ENV{'REMOTE_HOST'} && ($ENV{'REMOTE_HOST'} !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/)) 
 {$hostname = $ENV{'REMOTE_HOST'};} 
 else {&address_to_name ($ENV{'REMOTE_ADDR'});}

sub address_to_name {
 local ($address) = shift(@_);
 local (@octets);
 local ($name, $aliases, $type, $len, $addr);
 local ($ip_number);
 @octets = split ('\.', $address);
 $ip_number = pack ("CCCC", @octets[0..3]);
 ($name, $aliases, $type, $len, $addr) = gethostbyaddr ($ip_number, 2);
 if ($name) {$hostname = $name;}
  else {$hostname = $ENV{'REMOTE_ADDR'};}
 }



#==================================================#
@brow = split ('\(', $ENV{'HTTP_USER_AGENT'});
$browser = $brow[0];



#==================================================#
&check_url;
sub check_url {
 if ($ENV{'HTTP_REFERER'}) {
  foreach $referer (@referers) {
   if ($ENV{'HTTP_REFERER'} =~ /$referer/i) {
    $check_referer = 1;
    last;
    }
   }
  }
  else {$check_referer = 1;}
  if ($check_referer != 1) {exit;}
 }


#========================================#
# Should the connecting user be logged ? #
#========================================#
&check_ignoresites;
sub check_ignoresites {
 if ($hostname) {
  foreach $ignoresite (@ignoresites) {if ($hostname =~ /$ignoresite/i) {exit;}}
  }
 }



#==========================================================#
if (-f $lockfile) {
 if (-M $lockfile > (1/24)) {
  unlink($lockfile);
  $usebackup = 1;
  }
  else {
   for ($i = 60; $i > 0; --$i) {
    sleep(1);
    last unless -f $lockfile;
    }
   if (-f $lockfile) {exit;}
   }
 }



#=========================================================#
open(LOCKFILE,">$lockfile");
close(LOCKFILE);


#==================================#
# Logfile exist ? If not create it #
#==================================#
if (! -e $logfile) {
 open (LOG,">$logfile") || die "Can't create $logfile: $!\n";
 print LOG "LOG-BEGIN\n";
 close(LOG);
 }



#===================================================#
if (!$usebackup) {open (FILE,"$logfile") || die "Can't open $logfile: $!\n";}
 else {open (FILE,"$backup") || die "Can't open $backup: $!\n";}
@LINE=<FILE>;
close(FILE); 
$SIZE=@LINE;


#===============#
# Create Backup #
#===============#
rename($logfile,$backup) || die "Can't create $backup: $!\n";



#===========================#
if ($oldlogfile) {open (OLDLOG, ">>$oldlogfile") || die "Can't create $oldlogfile: $!\n";}
open (LOG,">$logfile") || die "Can't create $logfile: $!\n";

# Write entry at very top and move subsequent lines down
# and delete all lines starting from and below time limit
$delete = 0;
for ($i=0;$i<=$SIZE;$i++) {
 $_=$LINE[$i];
 if ($delete==0) {
  if (/LOG-BEGIN/)
   {
    print LOG "LOG-BEGIN\n";
    print LOG "$date $hostname ";
    if ($pagename) {print LOG "$pagename ";} else {print LOG "HTML_ERROR:Missing_Pagename ";}
    if ($pageurl) {print LOG "$pageurl ";} else {print LOG "HTML_ERROR:Missing_URL ";}
    if ($browser) {print LOG "$browser\n";} else {print LOG "Unknown\n";}
   }
   else {
    ($timeinlog,$junk,$junk,$junk)=$_;
    $timediff = $date - $timeinlog;
    if ($timediff > $numofsecs) {
     $delete = 1; 
     if ($oldlogfile) {print OLDLOG $_;}
     }
     else {print LOG $_;}
    }
  } elsif ($oldlogfile) {print OLDLOG $_;}
 }

close (LOG);
if ($oldlogfile) {close (OLDLOG);}



#==========================================#
unlink($lockfile);

exit;
