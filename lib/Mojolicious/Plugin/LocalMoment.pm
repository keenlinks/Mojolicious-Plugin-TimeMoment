package Mojolicious::Plugin::LocalMoment;

use Mojo::Base 'Mojolicious::Plugin';
use Time::Moment;
use Time::y2038 ();
use Mojo::Util ('monkey_patch');

monkey_patch 'Time::Moment', from_epoch_local => sub {
	$_[0]->from_epoch( $_[1] )->with_offset_same_instant( int( ( Time::y2038::timegm( Time::y2038::localtime( $_[1] ) ) - $_[1] ) / 60 ) );
};

our $VERSION = '0.04';

sub register {
	my ( $self, $app, $conf ) = @_;

	$app->helper( tm => sub {
		return Time::Moment->now unless $_[1];
		return Time::Moment->from_object( $_[1] ) if ref( $_[1] ) eq 'Time::Moment';
		return Time::Moment->from_string( $_[1] ) if $_[1] =~ m/T/;
		Time::Moment->from_epoch_local( $_[1] );
	});

	# If formats provided, format names become instance functions and template helpers using Time::Moment's strftime function.
	if ( keys %$conf ) {
		for my $helper ( keys %$conf ) {
			monkey_patch 'Time::Moment', $helper => sub { $_[0]->strftime( $conf->{$helper} ) };
			$app->helper( $helper => sub { $_[0]->tm( $_[1] )->$helper });
		}
	}
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::LocalMoment - Blah blah blah

=head1 SYNOPSIS

  use Mojolicious::Plugin::LocalMoment;

=head1 DESCRIPTION

Mojolicious::Plugin::LocalMoment is

=head1 AUTHOR

Scott Kiehn E<lt>sk.keenlinks@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Scott Kiehn

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
