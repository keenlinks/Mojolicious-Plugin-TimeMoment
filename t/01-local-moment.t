use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'Mojolicious::Plugin::LocalMoment' => {
	dt_mdy => '%D, %l:%M %p',
	basic_date => '%B %e, %Y',
};

my $t = Test::Mojo->new;
my $c = $t->app->build_controller;
my $time = time();

isa_ok( $c->tm, 'Time::Moment' );
isa_ok( $c->tm( $time ), 'Time::Moment' );
isa_ok( $c->tm( '2015-01-01T01:01:01Z' ), 'Time::Moment' );

ok( $time == $c->tm( $time )->epoch );

my $dt_mdy_rex = qr/^\d{2}\/\d{2}\/\d{2},{1} {1,2}\d{1,2}:\d{2} {1}(A|P)M$/;
like( $c->dt_mdy, $dt_mdy_rex );
like( $c->dt_mdy( $time ), $dt_mdy_rex );
like( $c->dt_mdy( '2015-01-01T01:01:01Z' ), $dt_mdy_rex );
like( $c->dt_mdy( '2015-01-01T10:01:01Z' ), $dt_mdy_rex );

my $basic_date_rex = qr/^[JFMASOND]{1}[a-z]{2,8} {1,2}\d{1,2},{1} {1}\d{4}$/;
like( $c->basic_date, $basic_date_rex );
like( $c->basic_date( $time ), $basic_date_rex );

for ( 1 .. 12 ) {
	like( $c->basic_date( '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-01T01:01:01Z' ), $basic_date_rex );
	like( $c->basic_date( '2015-' . ($_ < 10 ? '0' . $_ : $_) . '-10T10:10:10Z' ), $basic_date_rex );
}

done_testing();
