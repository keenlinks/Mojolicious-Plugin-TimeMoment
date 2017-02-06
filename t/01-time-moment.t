use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Time::Moment;

plugin 'Mojolicious::Plugin::TimeMoment' => {
	dt_mdy => '%D, %-l:%M %p',
	basic_date => '%B %-e, %Y',
};

my $t = Test::Mojo->new;
my $c = $t->app->build_controller;

my $time = time();

my @new_params = (
    year       => 2016,
    month      => 01,
    day        => 01,
    hour       => 12,
    minute     => 0,
    second     => 0,
    offset     => 0,
);

my $tm = Time::Moment->new( @new_params );

# Uses Time::Moment->now
isa_ok( $c->tm, 'Time::Moment' );

# Uses Time::Moment->then - monkey_patched constructor
isa_ok( $c->tm( $time ), 'Time::Moment' );

# Uses Time::Moment->from_string
isa_ok( $c->tm( 'from_string', '2015-01-01T01:01:01Z' ), 'Time::Moment' );

# Uses Time::Moment->from_epoch
isa_ok( $c->tm( 'from_epoch', $time ), 'Time::Moment' );

# Uses Time::Moment->now_utc
isa_ok( $c->tm( 'now_utc' ), 'Time::Moment' );

# Uses Time::Moment->from_object
isa_ok( $c->tm( 'from_object', $tm ), 'Time::Moment' );

# Comparison tests
ok( time() == $c->tm->epoch );
ok( time() == $c->tm( 'now' )->epoch );

sleep 1;

ok( $time == $c->tm( $time )->epoch );
ok( $time == $c->tm( 'then', $time )->epoch );
ok( $c->tm( $time )->epoch == $c->tm( 'from_epoch', $time )->epoch );
ok( $tm->epoch == $c->tm( $tm->epoch )->epoch );


# Test instance functions and helpers.

# Format 1
my $dt_mdy_rex = qr/^\d{2}\/\d{2}\/\d{2}, \d{1,2}:\d{2} {1}(A|P)M$/;

# Uses Time::Moment->now
like( $c->tm->dt_mdy, $dt_mdy_rex );
like( $c->dt_mdy, $dt_mdy_rex );

# Uses Time::Moment->then - monkey_patched constructor
like( $c->tm( $time )->dt_mdy, $dt_mdy_rex );
like( $c->dt_mdy( $time ), $dt_mdy_rex );

# Uses Time::Moment->from_string
for ( 1 .. 12 ) {
	like( $c->tm( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-01T01:01:01Z' )->dt_mdy, $dt_mdy_rex );
	like( $c->dt_mdy( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-01T01:01:01Z' ), $dt_mdy_rex );

	like( $c->tm( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-10T10:10:10Z' )->dt_mdy, $dt_mdy_rex );
	like( $c->dt_mdy( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-10T10:10:10Z' ), $dt_mdy_rex );
}

# Uses Time::Moment->from_object
like( $c->tm( 'from_object', $tm )->dt_mdy, $dt_mdy_rex );
like( $c->dt_mdy( 'from_object', $tm ), $dt_mdy_rex );


# Format 2
my $basic_date_rex = qr/^[JFMASOND]{1}[a-z]{2,8} \d{1,2}, \d{4}$/;

like( $c->tm->basic_date, $basic_date_rex );
like( $c->basic_date, $basic_date_rex );

like( $c->tm( $time )->basic_date, $basic_date_rex );
like( $c->basic_date( $time ), $basic_date_rex );

for ( 1 .. 12 ) {
	like( $c->tm( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-01T01:01:01Z' )->basic_date, $basic_date_rex );
	like( $c->basic_date( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-01T01:01:01Z' ), $basic_date_rex );

	like( $c->tm( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-10T10:10:10Z' )->basic_date, $basic_date_rex );
	like( $c->basic_date( 'from_string', '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-10T10:10:10Z' ), $basic_date_rex );
}

like( $c->tm( 'from_object', $tm )->basic_date, $basic_date_rex );
like( $c->basic_date( 'from_object', $tm ), $basic_date_rex );

done_testing();
