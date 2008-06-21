use strict;
use warnings;

package Jifty::Plugin::Authentication::Bitcard::Dispatcher;
use Jifty::Dispatcher -base;

=head1 NAME

Jifty::Plugin::Authentication::Bitcard::Dispatcher - Bitcard plugin dispatcher

=head1 DESCRIPTION

All the dispatcher rules jifty needs to support L<Jifty::Authentication::Bitcard/>

=head1 RULES

=head2 before /logout

Logout and return home.

=cut

before qr{^/logout} => run {
    unless (Jifty->web()->current_user()->id()) {
        redirect(Jifty->web()->request()->argument('return') ? Jifty->web()->request()->argument('return') : '/');
    }

    my $return_url = Jifty->web()->url();
    $return_url =~ s{/$}{};
    $return_url .= Jifty->web()->request()->argument('return');

    Jifty->web()->current_user(undef);
    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Bitcard');
    Jifty->web()->_redirect($plugin->api()->logout_url(
        r => $return_url,
    ));
};

=head2 before *

Setup the navigation menu for login or logout.

=cut

before '*' =>  run {
    if (Jifty->web()->current_user()->id()) {
        logged_in_nav();
    }
    else {
        not_logged_in_nav();
    }
};

=head2 on /signup

Redirect to home if logged in already.

Signup for an account otherwise.

=cut

before qr{^/signup$} => run {
    if (Jifty->web()->current_user()->id()) {
        redirect(Jifty->web()->request()->argument('return') ? Jifty->web()->request()->argument('return') : '/');
    }

    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Bitcard');

    Jifty->web()->_redirect($plugin->api()->register_url(
        r => Jifty->web()->url(path => '/bitcard_signup?return=' . Jifty->web()->request()->argument('return')),
    ));
};

=head2 on /login

Redirect to home if logged in already.

Redirecto to Bitcard, otherwise.

=cut

before '/login' => run {
    if (Jifty->web()->current_user()->id()) {
        redirect(Jifty->web()->request()->argument('return') ? Jifty->web()->request()->argument('return') : '/');
    }

    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Bitcard');

    Jifty->web()->_redirect($plugin->api()->login_url(
        r        => Jifty->web()->url(path => '/bitcard_login?return=' . Jifty->web()->request()->argument('return')),
    ));
};

=head 2 before /bitcard_(login|signup)

Verify the bitcard login.

=cut

before qr{^/bitcard_(?:login|signup)} => run {
    if (Jifty->web()->current_user()->id()) {
        redirect(Jifty->web()->request()->argument('return') ? Jifty->web()->request()->argument('return') : '/');
    }

    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Bitcard');
    my $verified = $plugin->api()->verify(Jifty->handler()->cgi());

    unless (defined $verified) {
        redirect(Jifty->web()->request()->argument('return') ? Jifty->web()->request()->argument('return') : '/');
    }


    my $bitcard_id = $verified->{'id'};
    my $username   = $verified->{'username'};
    my $name       = $verified->{'name'};
    my $email      = $verified->{'email'};

    my $user = Jifty->app_class("Model", "User")->new(current_user => Jifty->app_class("CurrentUser")->superuser );

    $user->load_by_cols( bitcard_id => $bitcard_id );

    if ( $user->id ) {
        $user->__set(column => 'email', value => $email);
        $user->__set(column => 'name', value => $name);
    }
    else {
        $user->create(
            bitcard_id       => $bitcard_id,
            bitcard_username => $username,
            name             => $name,
            email            => $email,
        );
    }

    my $current_user = Jifty->app_class("CurrentUser")->new( bitcard_id => $bitcard_id );

    # Actually do the signin thing.
    Jifty->web()->current_user($current_user);
    Jifty->web()->session()->expires(undef);
    Jifty->web()->session()->set_cookie();

    redirect(Jifty->web()->request()->argument('return') ? Jifty->web()->request()->argument('return') : '/');
};

=head2 not_logged_in_nav

Adds the login and signup links to the navigation menu.

=cut

sub not_logged_in_nav {
    my $current_path = Jifty->web()->request()->path();

    Jifty->web->navigation->child(
        'Signup',
        label        => _('Signup'),
        url          => "/signup?return=$current_path",
        sort_order   => '950',
    );
    Jifty->web->navigation->child(
        'Login',
        label        => _('Login'),
        url          => "/login?return=$current_path",
        sort_order   => '999',
    );
}

=head2 logged_in_nav

Adds the logout link to the navigation menu.

=cut

sub logged_in_nav {
    my $current_path = Jifty->web()->request()->path();

    Jifty->web->navigation->child(
        'Logout',
        label      => _('Logout'),
        url        => "/logout?return=$current_path",
        sort_order => '999'
    );
}

=head1 SEE ALSO

L<Jifty::Plugin::Authentication::Bitcard>,

=head1 COPYRIGHT

Copyright 2008 Jacob Helwig.
Distributed under the same terms as Perl itself.

=cut

1;
