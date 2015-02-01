package DxGame::User;
use Moose;
use DxGame::Card;

#<<<
has id => (
    is          => 'ro',
    isa         => 'Str',
);

has hand => (
    is          => 'rw',
    isa         => 'ArrayRef',
    traits      => [qw<Array>],
    handles     => {
        hand_size => 'count',
        add_card => 'push',
    },
    default => sub {[]},
);

has played_card => (
    is          => 'rw',
    isa         => 'Maybe[DxGame::Card]',
);

#>>>

# This is public, so it's a property of the board.
#
#has is_storyteller => (
#    is  => 'rw',
#    isa => 'Bool',
#);


sub BUILDARGS {
    my ( $class, $args ) = @_;
    if ( ref $args eq 'HASH' ) {
        return $args;
    }
    else {
        return { id => $args };
    }

}

1;
