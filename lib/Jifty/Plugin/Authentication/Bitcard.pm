use strict;
use warnings;

package Jifty::Plugin::Authentication::Bitcard;
use base qw/Jifty::Plugin/;

use Authen::Bitcard ();

our $VERSION = '0.052';

=head1 NAME

Jifty::Plugin::Authentication::Bitcard - Bitcard authentication plugin

=head1 DESCRIPTION

B<CAUTION:> This plugin has not thuroughly been tested in the wild.

This plugin replaces L<Jifty::Plugin::User>, and L<Jifty::Plugin::Authentication::Password>, since Bitcard handles all the heavy lifting for us.

User logins are handled through Bitcard.

=head2 CONFIGURATION

You will need the following in your site_config.yml:

    Plugins:
      -
        Authentication::Bitcard:
          site_token: [Your site token here]

=head2 METHODS

=cut

our %CONFIG = ();

=head3 init

Initialize the plugin.

=cut

sub init
{
    my $self = shift;
    %CONFIG = @_;
}

=head3 api

Return an Authen::Bitcard object setup with the token, and Bitcard url.

=cut

sub api
{
    my $self = shift;

    my $api = Authen::Bitcard->new();
    $api->token($CONFIG{'site_token'});
    $api->bitcard_url($CONFIG{'bitcard_url'}) if $CONFIG{'bitcard_url'};
    $api->info_required([qw/ username email /]);
    $api->info_optional([qw/ name /]);

    return $api;
}

=head1 SUPPORT

Mailing list:

=over 8

=item L<jifty-plugin-authen-bitcard@lists.technosorcery.net>

=item http://lists.technosorcery.net/listinfo.cgi/jifty-plugin-authen-bitcard-technosorcery.net/

=back

=head1 BUGS

No known bugs (yet).

Please report all bugs to bug-Jifty-Plugin-Authentication-Bitcard@rt.cpan.org

=head1 SEE ALSO

L<Jifty::Manual::AccessControl>, L<Jifty::Plugin::Authentication::Bitcard::Mixin::Model::User>

=head1 AUTHOR

    Jacob Helwig
    CPAN ID: JHELWIG
    jacob@technosorcery.net
    http://technosorcery.net/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;

