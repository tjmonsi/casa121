#!/usr/bin/perl5

#=====================================================#
#=====================================================#


#---------------Configure----------------#
# Minimum number of fields (columns)
# expected in the logfile
# As of LogScribe 1.0 this should be '5'
$minimum = 5;
#----------------------------------------#


#==================================#

#==================================#
$prog = substr ($0, rindex ($0, '/') + 1);
if ($#ARGV < 0) {
 print "usage: $prog \'accesslog\'\n";
 print "        ^--Scan log for errors\n\n";   
 print "       $prog \'accesslog\' \'fixedlog\'\n";
 print "        ^--Scan log for errors and output fix to fixedlog\n";
 exit;
 }


#==================================#

#==================================#
if ($#ARGV >= 0) {$logfile = $ARGV[0];}
if ($#ARGV > 0) {$writeto = $ARGV[1];}


#=================================#

#=================================#
print "Processing file: $ARGV[0]\n";
if ($writeto) {
 print "Outputing fix to file: $writeto\n\n";
 if (-e $writeto) {die "Error: Cannot output to $writeto, file exists\n";}
 }

#==============================#
# Process, process, process :p #
#==============================#
if (!$writeto)
 {
  print "The following lines have less columns than the expected $minimum:\n";
  print "----------------------------------------------------------\n";
  print "Line #\n"; 
 }

$minimum -= 1;
$linecount = 1;

open (LOG,"$logfile") || die "Can't open $logfile: $!\n";
if ($writeto) {open (FIX,">$writeto") || die "Can't create $writeto: $!\n";}
while (<LOG>) {
 undef @words;
 @words=split(/\W*\s+\W*/,$_);
 if ($writeto && $_ =~ /LOG-BEGIN/) {print FIX "LOG-BEGIN\n";}
 if ($_ !~ /LOG-BEGIN/)
  {
   $count=$#words;
   if ($count < $minimum) {
    $found = 1;
    if (!$writeto) { 
     print "------\n";
     chop;
     if ($count == -1)
      {printf "%6lu: BLANK LINE !\n",$linecount;}
      else {printf "%6lu: %s\n",$linecount,$_;}
     }
    }
    else {if ($writeto) {print FIX $_;}}
  }
 $linecount++;
 }

if ($found != 1)
 {
  if ($writeto)
  {unlink($writeto);}
  else {print "******: I can't find any errors at this time\n";}
 }


#=============#
# Wrapping up #
#=============#
close (LOG);
if ($writeto) {close (FIX);}
