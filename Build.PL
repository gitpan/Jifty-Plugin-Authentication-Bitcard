use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Jifty::Plugin::Authentication::Bitcard',
    license     => 'perl',
    dist_author => 'Jacob Helwig <jacob@technosorcery.net>',
    requires    => {
        'Jifty'           => '0.80408',
        'Authen::Bitcard' => '0.86',
    },
    sign        => 1,
)->create_build_script;
