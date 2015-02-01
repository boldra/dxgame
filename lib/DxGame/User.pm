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
        all_cards_in_hand => 'elements',
    },
    default => sub {[]},
);

has played_card => (
    is          => 'rw',
    isa         => 'Maybe[DxGame::Card]',
);

#>>>
sub play_card {
    my ( $self, $card_id ) = @_;
    $self->has_card($card_id);
    $self->hand( [ grep { $_ ne $card_id } $self->all_cards_in_hand ] );

}

sub has_card {
    my ( $self, $card_id ) = @_;
    for my $id ( $self->hand ) {
        $id == $card_id and return 1;
    }
    return 0;
}

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
