###########################################################################
# $Id: Barrier.pm,v 1.4 2005/10/31 05:37:30 wendigo Exp $
###########################################################################
#
# Barrier.pm
#
# RCS Revision: $Revision: 1.4 $
# Date: $Date: 2005/10/31 05:37:30 $
#
# Copyright 2002, 2005 Mark Rogaski, mrogaski@cpan.org
#
# See the README file included with the
# distribution for license information.
#
###########################################################################

package Thread::Barrier;

use 5.008;
use strict;
use warnings;
use threads;
use threads::shared;

our $VERSION = '0.200';

sub new {
    my $class = shift;
    my $val   = shift || 0;
    my @self : shared;
    die "invalid argument supplied" if $val =~ /[^0-9]/;
    @self = ( $val, 0 );
    bless \@self, $class;
}

sub init {
    my($self, $val) = @_;
    die "no argument supplied" unless defined $val;
    die "invalid argument supplied" if $val =~ /[^0-9]/;
    lock $self;
    $self->[0] = $val;
}

sub wait {
    my $self = shift;
    lock $self;
    $self->[1]++;
    my $id = threads->self->tid;
    if ($self->[0] > $self->[1]) {
        cond_wait($self) while ($self->[1] && $self->[0] > $self->[1]);
    } else {
        $self->[1] = 0;
        cond_broadcast($self);
    }
}

sub expected {
    my $self = shift;
    lock $self;
    return $self->[0];
}

sub waiting {
    my $self = shift;
    lock $self;
    return $self->[1];
}

1;
__END__

=head1 NAME

Thread::Barrier - thread execution barrier

=head1 SYNOPSIS

  use Thread::Barrier;

  my $b = new Thread::Barrier;

  $b->init($thr_cnt);
  
  $b->wait;

=head1 ABSTRACT

Execution barrier for multiple threads.

=head1 DESCRIPTION

Thread barriers provide a mechanism for synchronization of multiple threads.
All threads issuing a C<wait> on the barrier will block until the count
of waiting threads meets some threshold value.  This mechanism proves quite
useful in situations where processing progresses in stages and completion
of the current stage by all threads is the entry criteria for the next stage.

=head1 METHODS

=over 8

=item new

=item new COUNT

C<new> creates a new barrier and initializes the threshold count to C<NUMBER>.
If C<NUMBER> is not specified, the threshold is set to 0.

=item init COUNT

C<init> specifies the threshold count for the barrier, must be zero or a
positive integer.

=item wait

C<wait> causes the thread to block until the number of threads blocking on 
the barrier meets the threshold.

=back

=head1 SEE ALSO

L<perlthrtut>.

=head1 AUTHOR

Mark Rogaski, E<lt>mrogaski@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002 by Mark Rogaski

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the README file distributed with
Perl for further details.

=cut

