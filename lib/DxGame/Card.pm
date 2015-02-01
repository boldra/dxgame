package DxGame::Card;
use Moose;

has id => (
    is          => 'ro',
    isa         => 'Str',
);

=over

This class could later contain a link to a deck, and possibly a url.

=cut

1;