###########################################################################
# $Id: Makefile.PL,v 1.2 2003/03/09 06:29:37 wendigo Exp $
###########################################################################
#
# Makefile.PM
#
# RCS Revision: $Revision: 1.2 $
# Date: $Date: 2003/03/09 06:29:37 $
#
# Copyright 2002 Mark Rogaski, mrogaski@cpan.org
#
# See the README file included with the
# distribution for license information.
#
# $Log: Makefile.PL,v $
# Revision 1.2  2003/03/09 06:29:37  wendigo
# Modified to break if threads not available.
#
# Revision 1.1  2002/11/17 00:32:10  wendigo
# Initial revision
#
#
###########################################################################
use 5.008;
use threads ();
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Thread::Barrier',
    'VERSION_FROM'	=> 'Barrier.pm',
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'Barrier.pm',
       AUTHOR        => 'Mark Rogaski <mrogaski@cpan.org>') : ()),
);

