use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Time::Moment;

plugin 'Mojolicious::Plugin::TimeMoment';

my $t = Test::Mojo->new;
my $c = $t->app->build_controller;

my $tm1 = $c->tmc->from_string( '2025-01-01T23:59:59Z');
my $tm2 = $c->tmc->from_string( '2025-01-01T00:00:00Z');

# Comparison tests, run through a day.
for (0 .. 1439) {
  ok( $tm1->epoch == $tm2->plus_minutes($_)->at_end_of_day->epoch );
}

done_testing();
