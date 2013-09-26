#!perl -w
use 5.10.0;
use strict;
use Benchmark qw(:all);

use Data::Validator;
use Params::Validate qw(:all);
use Smart::Args;
use Type::Params qw(compile);
use Types::Standard qw(ClassName Any Dict Int);

foreach my $mod (qw(Params::Validate Smart::Args Type::Params Data::Validator)) {
    print $mod, "/", $mod->VERSION, "\n";
}

sub pv_add {
    my $self = shift;
    my %args = validate( @_ => { x => 1, y => 1 } );
    return $args{x} + $args{y};
}

sub sa_add {
    args my $self, my $x, my $y;
    return $x + $y;
}

sub tp_add {
    state $check = compile( Any, Dict[ x => Any, y => Any ] );
    my($self, $args) = $check->(@_);
    return $args->{x} + $args->{y};
}

sub dv_add {
    state $v = Data::Validator->new(
        x => { },
        y => { },
    )->with('Method');
    my($self, $args) = $v->validate(@_);
    return $args->{x} + $args->{y};
}

print "methods without type constraints\n";
cmpthese -1, {
    'P::Validate' => sub {
        my $x = main::->pv_add({ x => 10, y => 10 });
        $x == 20 or die $x;
    },
    'S::Args' => sub {
        my $x = main::->sa_add({ x => 10, y => 10 });
        $x == 20 or die $x;
    },
    'T::Params' => sub {
        my $x = main::->dv_add({ x => 10, y => 10 });
        $x == 20 or die $x;
    },
    'D::Validator' => sub {
        my $x = main::->dv_add({ x => 10, y => 10 });
        $x == 20 or die $x;
    },
};
