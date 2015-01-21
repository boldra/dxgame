package DxGame::Deck;
use Moose;
use List::Util qw<>;

has cards => (
    is          => 'rw',
    isa         => 'ArrayRef',
    traits          => [qw<Array>],
);


sub BUILD {
    # shuffle
    my @cards = qw<1..100>;
    @cards = List::Util::shuffle(@cards);
    $_[0]->cards(\@cards);
}

1;