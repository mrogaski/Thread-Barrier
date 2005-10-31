use threads;
use threads::shared;
use Thread::Barrier;

use Test::More tests => 3;

our $k = 8;
my  $flag   : shared = 0;
my  $ctr    : shared = 0;

sub foo {
    my($b0, $b1, $v0, $v1) = @_;
    my $err = 0;

    $b0->wait;

    {
        lock $flag;
        $err++ if $flag != $v0;
    }

    $b1->wait;

    {
        lock $flag;
        $err++ if $flag != $v1;
    }

    return $err;
}

sub bar {
    my($b0, $b1) = @_;

    my $id = threads->self->tid;

    for ($k) {

        $b0->wait;
        {
            lock $ctr;
            $ctr++;
        }

        $b1->wait;

        $b0->wait;
        {
            lock $ctr;
            $ctr--;
        }

        $b1->wait;

    }


    return;
}

my $a = Thread::Barrier->new($k);
my $b = Thread::Barrier->new;
$b->init($k * 2);

for (1..$k) {
    threads->create(\&foo, $a, $b, 0, 1);
}

{
    lock $flag;
    $flag = 1;
}

for (1..$k) {
    threads->create(\&foo, $a, $b, 1, 1);
}

my $sum = 0;
foreach my $t (threads->list) { 
    if ($t->tid && ! threads::equal($t, threads->self)) { 
        my $rv = $t->join;
        #
        # It looks like the return value of thread::join() 
        # is lost in threads version 1.05.
        #
        $sum += defined $rv ? $rv : 0; 
    } 
}  
is($sum, 0, "cascade test");

my $c = Thread::Barrier->new($k);
my $d = Thread::Barrier->new;
$d->init($k);

for (1..$k) {
    threads->create(\&bar, $c, $d);
}

foreach my $t (threads->list) { 
    if ($t->tid && ! threads::equal($t, threads->self)) { 
        $t->join;
    }
}

is($ctr, 0, "iterative test");
is($c->waiting, 0, "counter reset");


