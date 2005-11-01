###########################################################################
# $Id: Barrier.pm,v 1.5 2005/11/01 18:30:54 wendigo Exp $
###########################################################################
#
# Barrier.pm
#
# RCS Revision: $Revision: 1.5 $
# Date: $Date: 2005/11/01 18:30:54 $
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
use Carp;

our $VERSION = '0.200';

#
# new - creates a new Thread::Barrier object
#
# Arguments:
#
# threshold (opt)
#   Specifies the required number of threads that 
#   must block on the barrier before it is released.
#   Default value is 0.
# 
# Returns a Thread::Barrier object on success, dies on failure.
#
sub new {
    my $class       = shift;
    my $threshold   = shift || 0;

    # quick check for a nonnegative integer
    confess "invalid argument supplied" if $threshold =~ /[^0-9]/;

    my %self : shared;
    %self = (
        threshold   => $threshold,
        count       => 0
    );

    bless \%self, $class;
}


#
# init - set the threshold value for the barrier
#
# Arguments:
#
# threshold
#   Specifies the required number of threads that 
#   must block on the barrier before it is released.
# 
# Returns the passed argument.
#
sub init {
    my($self, $threshold) = @_;

    # make sure an argument was passed
    confess "no argument supplied" unless defined $threshold;

    # verify that the argument is a nonnegative integer
    confess "invalid argument supplied" if $threshold =~ /[^0-9]/;

    {
        #
        # This could be called with threads already blocking,
        # so we'll make sure we do appropriate locking.
        #
        lock $self;     
        $self->{threshold} = $threshold;

        if ($self->{threshold} <= $self->{count}) {
            # release the barrier if enough threads are blocking
            $self->{count} = 0;
            cond_broadcast($self);
        }
    }

    return $threshold;
}


#
# wait - block until a sufficient number of threads have reached the barrier
#
# Arguments:
#
# none
#
sub wait {
    my $self = shift;
    lock $self;
    $self->{count}++;
    my $id = threads->self->tid;
    if ($self->{threshold} > $self->{count}) {
        cond_wait($self) while ($self->{count} && 
                $self->{threshold} > $self->{count});
    } else {
        $self->{count} = 0;
        cond_broadcast($self);
    }
}


#
# threshold - accessor for debugging purposes
#
sub threshold {
    my $self = shift;
    lock $self;
    return $self->{threshold};
}


#
# count - accessor for debugging purposes
#
sub count {
    my $self = shift;
    lock $self;
    return $self->{count};
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
positive integer.  If the value of C<COUNT> is less than or equal to the
number of threads blocking on the barrier when C<init> is called, the barrier
is released and reset.

=item wait

C<wait> causes the thread to block until the number of threads blocking on 
the barrier meets the threshold.  When the blocked threads are released, the
barrier is reset to its initial state.

=item threshold

Returns the currently configured threshold.

=item count

Returns the instantaneous count of threads blocking on the barrier.

B<WARNING:  This is an accessor method that is intended for debugging 
purposes only, the lock on the barrier object is released when the 
method returns.>  

=back


=head1 SEE ALSO

L<perlthrtut>.


=head1 AUTHOR

Mark Rogaski, E<lt>mrogaski@cpan.orgE<gt>

If you find this module useful or have any questions, comments, or 
suggestions please send me an email message.


=head1 COPYRIGHT AND LICENSE

Copyright 2002, 2005 by Mark Rogaski.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the README file distributed with
Perl for further details.


=cut

