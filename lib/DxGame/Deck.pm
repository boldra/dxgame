package DxGame::Deck;
use Moose;
use List::Util qw<>;

#<<<
has unused_cards => (
    is          => 'rw',
    isa         => 'ArrayRef',
    traits          => [qw<Array>],
);

has used_cards => (
    is          => 'rw',
    isa         => 'ArrayRef',
    traits          => [qw<Array>],
);
#>>>


sub BUILD {
    # shuffle
    my @cards = qw<1..100>;
    @cards = List::Util::shuffle(@cards);
    $_[0]->unused_cards(\@cards);
}

1;
