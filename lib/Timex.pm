# ------------------------------------------------------------------------------
#   $Header: m:\cvsroot/ppg/lib/Timex.pm,v 1.5 2007/04/17 14:19:25 willemsg Exp $
#
#      file: Timex.pm
#   $Source: m:\cvsroot/ppg/lib/Timex.pm,v $
#      what: Timer Class Interface
#      date: 2005-01-04
#       who: Gert Jan Willems $Author: willemsg $
#
# $Revision: 1.5 $
#    $State: Exp $
#
# -- interface specification --
# Timex   => Base class
# Object methods:
#   get_timestring
#   get_timestring_diff
#
# Abstract:
#
# the instantiation of the timex class has always this format
#   new Timex( );
# e.g. $to1 = new Timex( );
#      $tstr = $to1->get_timestring( );
#      print $tstr
#           2005-01-05 07:21:47.734
#      $to2 = new Timex( );
#      $tstr = $to2->get_timestring( );
#      print $tstr
#           2005-01-05 07:22:48.758
#      $diff = $to1->get_timestring_diff( $to2 );
#      print $diff
#           00 00:01:01.024
# NOTE: the granularity of time differences = 1/1.000.000
#       the maximum recordable time difference = 23:59:59.999
#
# wishes: no bugs!
# ------------------------------------------------------------------------------
# $Log: Timex.pm,v $
# Revision 1.5  2007/04/17 14:19:25  willemsg
# 3rd method added: get_ftimestamp; see comments
#
# Revision 1.4  2007/03/21 15:04:01  willemsg
# several BUGS fixed; fundamental problem in time difference algorithm fixed.
#
# Revision 1.3  2006/05/03 14:50:01  willemsg
# cosmetic error fixed
#
# Revision 1.2.1.1  2006/05/03 14:28:54  willemsg
# import to CVS on 20060503 [GJW]
#
# ------------------------------------------------------------------------------
# manual history (obsolete as of 20060503, replaced by CVS)
# 2005-01-04 gjwillems created
# 2005-01-17 gjwillems get time difference algoritm improved & debugged
# 2007-03-19 gjwillems BUG7031901 Bug found in get_timstring_diff routine, when
#                      msec equals it should be set to zero
# 2007-03-21 gjwillems FUNDAMENTAL error in timing difference algorithm fixed:
#
# ------------------------------------------------------------------------------
#                  (c) 2004/2005 ITASSIST | DLG/Facilitair/BS
# ------------------------------------------------------------------------------
# $CommitId: b5c4624d76d7d38 $
# ------------------------------------------------------------------------------

our $VERSION = '$Revision: 1.5 $';

# Timer base class  - - - - i n t e r f a c e - - - -
{

    package Timex;

    use strict;
    use Time::localtime;
    use Time::HiRes qw(gettimeofday);


    sub new {
        my ( $class ) = shift @_;

        my $ts;
        my $tm = localtime;
        my ( $s, $msec ) = gettimeofday;
        my $msc = $msec ; # / 1000;

        my $self = bless {
            _time => $tm,
            _msec => $msc
        }, $class;

        return $self;
    }

    # object method 1
    # returns a date and timestring
    sub get_timestring {
        my ( $self ) = shift @_;

        my $ts = sprintf(
            "%02d-%02d-%04d %02d:%02d:%02d.%06.06d",
            $self->{_time}->mday,
            $self->{_time}->mon + 1,
            $self->{_time}->year + 1900,
            $self->{_time}->hour,
            $self->{_time}->min,
            $self->{_time}->sec,
            $self->{_msec}
        );

        return $ts;
    }

    # object method 2
    # return the difference between $self (the first timestamp) and
    # $tobj, the nth timestamp object AFTER $self.
    #
    sub get_timestring_diff {
        my ( $self, $tobj ) = @_;
        # my $err = "calling object has a timestamp after the parsed object";
        my $msec  = 0;
        my $hours = 0;
        my $mins = 0;
        my $secs = 0;
        my $ssec;  # self total sec
        my $tsec;  # tobj total sec
        my $tdiff; # difference of those 2
        my $ts;

        $ssec = $self->{_time}->sec + ($self->{_time}->min * 60) +
            ($self->{_time}->hour * 3600);

        $tsec = $tobj->{_time}->sec + ($tobj->{_time}->min * 60) +
            ($tobj->{_time}->hour * 3600);

        if ($ssec >= $tsec) {
            $ts = -1;
        } else {
            $ssec = $ssec + ($self->{_msec} / 1000000);
            $tsec = $tsec + ($tobj->{_msec} / 1000000);
            $tdiff = $tsec - $ssec;
            $hours = int( $tdiff / 3600 );
            $mins =  int (60 * (($tdiff / 3600) - $hours));
            $secs =  int (60 * (($tdiff /60) - int ($tdiff / 60)));
        }

        # t1 - test and calc msec
        if ( $self->{_msec} == $tobj->{_msec} ) {
            $msec = 0; # BUG7031901
        }
		elsif ( $self->{_msec} < $tobj->{_msec} ) {
            $msec = $tobj->{_msec} - $self->{_msec};
        }
        elsif ( $self->{_msec} > $tobj->{_msec} ) {
            $msec = (1000000 - $self->{_msec}) + $tobj->{_msec};
        }

        $ts = sprintf(
            "%02d:%02d:%02d.%06.06d",
            $hours,
            $mins,
            $secs,
            $msec
        );

        return $ts;
    }

    # object method 3, timestamp e.g. 2busd in filespec
    # get a timestamp string with the following format:
    # YYYYMMDDHH24MI
    sub get_ftimestamp {
        my ( $self ) = shift @_;

        my $fts = sprintf(
            "%04d%02d%02d%02d%02d",
            $self->{_time}->year + 1900,
            $self->{_time}->mon + 1,
            $self->{_time}->mday,
            $self->{_time}->hour,
            $self->{_time}->min
        );

        return $fts;
    }


}

1;
