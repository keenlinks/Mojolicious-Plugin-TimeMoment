package Mojolicious::Plugin::LocalMoment;

use Mojo::Base 'Mojolicious::Plugin';
use Time::Moment;
use Time::timegm ('timegm');

our $VERSION = '0.03';

sub register {
	my ( $self, $app, $conf ) = @_;

	$app->helper( tm => sub {
		return Time::Moment->now unless $_[1];
		if ( $_[1] =~ m/T/ ) {
			return Time::Moment->from_string( $_[1] );
		} else {
			Time::Moment->from_epoch( $_[1] )->with_offset_same_instant( int( ( timegm( localtime( $_[1] ) ) - $_[1] ) / 60 ) );
		}
	});

	# Date format helpers (not instance methods)
	if ( keys %$conf ) {
		for my $helper ( keys %$conf ) {
			$app->helper( $helper => sub {
				$_[0]->tm( $_[1] )->strftime( $conf->{$helper} );
			});
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
