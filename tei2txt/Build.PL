use Module::Build;
my $build = Module::Build->new(
    module_name => 'DTA::TEI::Text',
    dist_author => 'Konstantin Baierer <konstantin.baierer@gmail.com>',
    dist_abstract => 'Tools for transforming TEI to Plain Text',
    license => 'perl',
    requires => {
        # 'File::Slurp' => '9999.13',
        'Moose' => 0,
        'MooseX::Getopt' => 0,
        'Test::More' => 0,
        'XML::LibXML' => '1.80',
        'XML::LibXSLT' => '1.74',
        'File::Share' => 0,
        'Data::Dumper' => 0,
        'String::Diff' => 0,
        'IPC::Open2' => 0,

    },
    share_dir =>  'share',
);

$build->create_build_script;
