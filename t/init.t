use threads;
use threads::shared;
use Thread::Barrier;

use Test::More tests => 4;

my $flag : shared;

sub foo {
    my($b, $v) = @_;
    my $err = 0;

    $b->wait;

    {
        lock $flag;
        $err++ if $flag != $v;
    }

    return $err;
}

my($t, $b);

$flag = 0;
$b = Thread::Barrier->new(0);
$t = threads->create(\&foo, $b, 0);
ok($t->join == 0);

$flag = 0;
$b = Thread::Barrier->new;
eval {
    $b->init(-1);
};
ok($@);

$flag = 0;
$b = Thread::Barrier->new;
$b->init(0);
$t = threads->create(\&foo, $b, 0);
ok($t->join == 0);

$flag = 0;
eval {
    $b = Thread::Barrier->new(-1);
};
ok($@);




