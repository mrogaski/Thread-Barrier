use threads;
use threads::shared;
use Thread::Barrier;

use Test::More tests => 1;

my $flag : shared = 0;
my $k = 3;

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
        $sum += $t->join; 
    } 
}  
ok(! $sum);


