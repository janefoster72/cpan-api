use strict;
use warnings;

use MetaCPAN::Server::Test;
use Test::More;
use IO::String;
use Module::Metadata;
use List::MoreUtils qw(uniq);

use lib 't/lib';
use MetaCPAN::TestHelpers;

test_release(
    {
        name   => 'Packages-Unclaimable-2',
        author => 'RWSTAUNER',
        abstract =>
            'Dist that appears to declare packages that are not allowed',
        authorized => \1,
        first      => \1,
        provides   => [ 'Packages::Unclaimable', ],
        status     => 'latest',

        modules => {
            'lib/Packages/Unclaimable.pm' => [
                {
                    name             => 'Packages::Unclaimable',
                    indexed          => \1,
                    authorized       => \1,
                    version          => 2,
                    version_numified => 2,
                    associated_pod =>
                        'RWSTAUNER/Packages-Unclaimable-2/lib/Packages/Unclaimable.pm',
                },
            ],
        },

        extra_tests => sub {
            my ($self) = @_;

            ok $self->data->authorized, 'dist is authorized';

            my $content;
            test_psgi app, sub {
                my $cb = shift;
                $content
                    = $cb->( GET
                        '/source/RWSTAUNER/Packages-Unclaimable-2/lib/Packages/Unclaimable.pm'
                    )->content;
            };

            my $mm
                = Module::Metadata->new_from_handle(
                IO::String->new($content),
                'lib/Packages/Unclaimable.pm' );
            is_deeply [ uniq sort $mm->packages_inside ],
                [ sort qw(Packages::Unclaimable main DB) ],
                'Module::Metadata finds the packages we ignore';
        },
    },
    'Packages::Unclaimable is authorized but ignores unclaimable packages',
);

done_testing;
