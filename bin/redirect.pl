#!/usr/bin/perl
# ============================================================================== 
#
#      File: redirect.pl
#      Date: Thu Oct 17 10:23:22 CEST 2013
#      What: redirect STDIN and format to deploy format
#      Who: Gert J. Willems | gjwillems@itassist.nl
#
#                         Copyright (c) 2013 ITASSIST
#
# ============================================================================== 
use strict;
use lib "$FindBin::Bin/home/postgres/global/lib";
use Timex;

sub getTimestamp() {

   my $tso = Timex->new;
   my $ts = $tso->get_timestring;

   return $ts;

}

my $lts;
my $line;

open STDERR, '>&STDOUT' or die $!;

foreach $line (<STDIN>) {
   chomp $line;
   $line =~ s/\t/        /g;
   $lts = getTimestamp();
   if ( length( $line ) gt 0 ) {
      printf ( STDOUT "%s  INFO - %s\n", $lts, $line);
   }
}

# ====== redirect ===============================================================

