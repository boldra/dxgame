package DxGame::User;
use Moose;

#<<<
has id => (
    is          => 'ro',
    isa         => 'Str',
);

has hand => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    traits      => [qw<Array>],
    handles     => {
        hand_size => 'count',
        add_card => 'push',
        all_cards_in_hand => 'elements',
    },
    default => sub {[]},
);

has played_card_id => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
);

has bet_on_card_id => ( 
    is          => 'rw',
    isa         => 'Maybe[Str]',
);

#>>>
sub play_card_id {
    my ( $self, $card_id ) = @_;
    $self->has_card($card_id);
    $self->hand( [ grep { $_ ne $card_id } $self->all_cards_in_hand ] );
    $self->played_card_id($card_id);
    return $card_id;
}

sub has_card {
    my ( $self, $card_id ) = @_;
    for my $id ( $self->all_cards_in_hand ) {
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
