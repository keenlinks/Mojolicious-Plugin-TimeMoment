package Mojolicious::Plugin::TimeMoment;

use Mojo::Base 'Mojolicious::Plugin';
use Scalar::Util qw(looks_like_number);
use Time::Moment;
use Time::y2038 ();
use Mojo::Util ('monkey_patch');

monkey_patch 'Time::Moment', then => sub {
	$_[0]->from_epoch( $_[1] )->with_offset_same_instant( int( ( Time::y2038::timegm( Time::y2038::localtime( $_[1] ) ) - $_[1] ) / 60 ) );
};

our $VERSION = '0.06';

sub register {
	my ( $self, $app, $conf ) = @_;

	$app->helper( tm => sub {
		shift;
		return Time::Moment->now unless $_[0];
		return Time::Moment->then($_[0]) if looks_like_number($_[0]);
		my $constructor = shift;
		return Time::Moment->$constructor( @_ );
	});

	# If formats provided, format names become Time::Moment instance functions and template helpers using Time::Moment's strftime function.
	if ( keys %$conf ) {
		for my $helper ( keys %$conf ) {
			monkey_patch 'Time::Moment', $helper => sub { shift->strftime( $conf->{$helper} ) };
			$app->helper( $helper => sub { shift->tm( @_ )->$helper });
		}
	}
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::TimeMoment - Adds a Time::Moment object as a helper.

=head1 VERSION

0.05

=head1 SYNOPSIS

  # Mojolicious:

  $ENV{TZ} = 'America/Chicago';
  POSIX::tzset();

  $app->plugin( 'time_moment' => {
    dt_mdy => '%D, %-l:%M %p',
    basic_date_time => '%B %-e, %Y %-l:%M %p',
  });

  # Controllers: Objects created below have access to Time::Moment's instance methods
  # and any custom date format methods ($tm->dt_mdy & $tm->basic_date_time).

  my $tm = $c->tm; # System's current time
  my $tm2 = $c->tm( 1465483062 ); # From an existing epoch and localized to the system
  my $tm3 = $c->tm( '2016-06-09T09:37:42-05' );
  my $tm4 = $c->tm( Time::Moment->new(...) );


  # Templates:

  <%= $tm->basic_date_time %>

  # Or use the helper

  <%= basic_date_time 1465483062 %>


=head1 DESCRIPTION

Time::Moment is a great module and fast. Mojolicious::Plugin::TimeMoment uses this module as a plugin.

=head1 METHODS

=head2 register

  $app->plugin( 'time_moment' );

  $app->plugin( 'time_moment' => {
    $format_name => $custom_strftime_format,
  });

Registers the plugin into the Mojolicious app.

=head1 HELPERS

=head2 tm

  $c->tm;
  $c->tm( $date_string );
  $c->tm( $epoch );
  $c->tm( $tm );

Used to create a Time::Moment object. Time::Moment has several constructors, but only a few are used in this plugin: "now", "from_string" and "from_object". In addition, an additional constructor "then" is added so an epoch can be used to create an object which is localized to the system time (Time::Moment uses a similar method to localize the "now" constructor). I like to store my dates as epoch values in the database making the "then" constructor necessary. The "to_object" constructor was included to allow a Time::Moment object created by a non-included constructor to be passed into the plugin.

=head2 "custom_date_formats"

The following configuration creates custom instance methods and helpers called "dt_mdy", "basic_date_time" and "unconventional_date." The helpers use the instance methods internally.

  $app->plugin( 'time_moment' => {
    dt_mdy => '%D, %-l:%M %p',
    basic_date_time => '%B %-e, %Y %-l:%M %p',
    unconventional_date => 'This is a %A in %B, to be more precise %d/%m of %Y.',
  });

  <%= dt_mdy 1465483062 %> is "06/09/16, 9:37 AM"
  <%= basic_date_time 1465483062 %> is "June 9, 2016 9:37 AM"
  <%= unconventional_date 1465483062 %> is "This is a Thursday in June, to be more precise 09/06 of 2016."

=head1 SOURCE REPOSITORY

L<http://github.com/keenlinks/Mojolicious-Plugin-TimeMoment>

=head1 AUTHOR

Scott Kiehn E<lt>sk.keenlinks@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2016 - Scott Kiehn

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Time::Moment>

=cut
