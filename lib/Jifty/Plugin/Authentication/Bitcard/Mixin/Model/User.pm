use strict;
use warnings;

package Jifty::Plugin::Authentication::Bitcard::Mixin::Model::User;
use Jifty::DBI::Schema;
use base 'Jifty::DBI::Record::Plugin';

use Authen::Bitcard ();

our $VERSION = '0.053';

our @EXPORT = qw/ /;

=head1 NAME

Jifty::Plugin::Authentication::Bitcard::Mixin::Model::User - Bitcard plugin user mixin model

=head1 SYNOPSIS

  package MyApp::Model::User;
  use Jifty::DBI::Schema;
  use MyApp::Record schema {
      # custom column definitions
  };

  # name, email, bitcard_username, bitcard_id
  use Jifty::Plugin::Authentication::Bitcard::Mixin::Model::User;

=head1 DESCRIPTION

This mixin model is added to the application's account model for use with the Bitcard authentication plugin.

=head1 SCHEMA

This mixin adds the following columns to the model schema:

=head2 bitcard_id

The unique user id of the Bitcard user on your site.  It's a 128bit number as a 40 byte hex value.

=head2 bitcard_username

The unique username of the Bitcard user.

=head2 name

This is the username/nickname for the user of the account.

=head2 email

This is the email address of the account as returned by Bitcard.

=cut

use Jifty::Plugin::Authentication::Bitcard::Record schema {
    column bitcard_id =>
        render_as 'text',
        type is 'char(40)',
        label is _('Bitcard ID'),
        is immutable,
        is distinct,
        is indexed,
        is mandatory;

    column bitcard_username =>
        render_as 'text',
        type is 'text',
        label is _('Bitcard Username');

    column name =>
        type is 'text',
        label is _('Name'),
        hints is _('How should I display your name to other users?');

    column email =>
        type is 'text',
        label is _('Email address');
};

=head1 SEE ALSO

L<Jifty::Plugin::Authentication::Bitcard>

=head1 LICENSE

Copyright 2008 Jacob Helwig.
Distributed under the same terms as Perl itself.

=cut

1;

