#!perl -w
use 5.10.0;
use strict;
use Benchmark qw(:all);

use Data::Validator;
use Params::Validate qw(:all);
use Type::Params qw(compile);
use Types::Standard qw(ClassName Any Dict Int);

foreach my $mod (qw(Params::Validate Type::Params Data::Validator)) {
    print $mod, "/", $mod->VERSION, "\n";
}

sub pv_add {
    my($x, $y) = validate_pos( @_, 1, 1);
    return $x + $y;
}

sub tp_add {
    state $check = compile( Any, Any );
    my($x, $y) = $check->(@_);
    return $x + $y;
}

sub dv_add {
    state $v = Data::Validator->new(
        x => { },
        y => { },
    )->with('Sequenced');
    my $args = $v->validate(@_);
    return $args->{x} + $args->{y};
}

print "sequence without type constraints\n";
cmpthese -1, {
    'P::Validate' => sub {
        my $x = pv_add(10, 20);
        $x == 30 or die $x;
    },
    'T::Params' => sub {
        my $x = tp_add(10, 20);
        $x == 30 or die $x;
    },
    'D::Validator' => sub {
        my $x = dv_add(10, 20);
        $x == 30 or die $x;
    },
};
