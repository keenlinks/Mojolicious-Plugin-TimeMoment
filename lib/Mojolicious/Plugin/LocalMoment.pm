package Mojolicious::Plugin::LocalMoment;

use Mojo::Base 'Mojolicious::Plugin';
use Time::Moment;
use Time::Local ('timegm_nocheck');

our $VERSION = '0.01';

sub register {
	my ( $self, $app, $conf ) = @_;

	$app->helper( tm => sub {
		return Time::Moment->now unless $_[1];
		if ( $_[1] =~ m/T/ ) {
			return Time::Moment->from_string( $_[1] );
		} else {
			my @t = localtime( $_[1] );
			my $offset = int( ( timegm_nocheck( @t[0..4], ( $t[5] > -901 ? $t[5] + 1900 : $t[5] ) ) - $_[1] ) / 60 );
			return Time::Moment->from_epoch( $_[1] )->with_offset_same_instant( $offset );
		}
	});

	# Template helpers: Not instance methods, but class methods that use the above constructor helper.
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
