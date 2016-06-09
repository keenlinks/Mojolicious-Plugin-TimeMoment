use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Time::Moment;
use POSIX ();

my $tz = 'America/Chicago';
$ENV{TZ} = $tz;
POSIX::tzset();

plugin 'Mojolicious::Plugin::TimeMoment';

my $t = Test::Mojo->new;
my $c = $t->app->build_controller;

# Use DateTime to test the monkey_patched constructor.
 
SKIP: {
	# Check for DateTime
	eval { require DateTime };
	skip( 'DateTime is not installed (skipping epoch comparison tests).', 1 ) if $@;

	my $time = time();
	for ( 1 .. 24 ) {
		ok( DateTime->from_epoch( epoch => $time, time_zone => $tz )->epoch == $c->tm( $time )->epoch );
		$time -= ( 60 * 60 );
	}

	$time = time();
	for ( 1 .. 365 ) {
		ok( DateTime->from_epoch( epoch => $time, time_zone => $tz )->epoch == $c->tm( $time )->epoch );
		$time -= ( 60 * 60 * 24 );
	}

	my $leap_year_epoch = DateTime->new(
		year      => 2016,
		month     => 2,
		day       => 29,
		hour      => 0,
		minute    => 0,
		second    => 0,
		time_zone => $tz,
	)->epoch;

	for ( 1 .. 24 ) {
		ok( DateTime->from_epoch( epoch => $leap_year_epoch, time_zone => $tz )->epoch == $c->tm( $leap_year_epoch )->epoch );
		$leap_year_epoch -= ( 60 * 60 );
	}

	my $daylight_savings_start_epoch = DateTime->new(
		year      => 2016,
		month     => 3,
		day       => 13,
		hour      => 0,
		minute    => 0,
		second    => 0,
		time_zone => $tz,
	)->epoch;

	for ( 1 .. 24 ) {
		ok( DateTime->from_epoch( epoch => $daylight_savings_start_epoch, time_zone => $tz )->epoch == $c->tm( $daylight_savings_start_epoch )->epoch );
		$daylight_savings_start_epoch -= ( 60 * 60 );
	}

	my $daylight_savings_end_epoch = DateTime->new(
		year      => 2016,
		month     => 11,
		day       => 6,
		hour      => 0,
		minute    => 0,
		second    => 0,
		time_zone => $tz,
	)->epoch;

	for ( 1 .. 24 ) {
		ok( DateTime->from_epoch( epoch => $daylight_savings_end_epoch, time_zone => $tz )->epoch == $c->tm( $daylight_savings_end_epoch )->epoch );
		$daylight_savings_end_epoch -= ( 60 * 60 );
	}

	# Go back in time.
	$time = time();
	for ( 1 .. 1000 ) {
		ok( DateTime->from_epoch( epoch => $time, time_zone => $tz )->epoch == $c->tm( $time )->epoch );

		my $days_in_a_year = 365;
		$days_in_a_year = 366 if  DateTime->from_epoch( epoch => $time, time_zone => $tz )->is_leap_year;

		$time -= ( 60 * 60 * 24 * $days_in_a_year );
	}

	# Go forward in time.
	$time = time();
	for ( 1 .. 1000 ) {
		ok( DateTime->from_epoch( epoch => $time, time_zone => $tz )->epoch == $c->tm( $time )->epoch );

		my $days_in_a_year = 365;
		$days_in_a_year = 366 if  DateTime->from_epoch( epoch => $time, time_zone => $tz )->is_leap_year;

		$time += ( 60 * 60 * 24 * $days_in_a_year );
	}

}

done_testing();
