package DxGame::Board;
use Moose;

my %STATES = (
    1 => 'No game',
    2 => 'waiting for start game or other players to join',
    3 => 'waiting for storyteller to play',
    4 => 'waiting for at least one player to lay a card',
    5 => 'waiting for at least one player to make a bet',
    6 => 'waiting for players to confirm the round is finished',
);

# This is all the public information, and only the public information.

# <<<

has player_ids => (
    is     => 'rw',
    isa    => 'ArrayRef',
    traits => [qw<Array>],
    handles => {
        add_player => 'push'
    },
);

has state => (
    is => 'rw',
    isa => 'Num',
);

has scores => (
    is          => 'rw',
    isa         => 'HashRef',
    traits      => [qw<Hash>],
);

has story => (
    is  => 'rw',
    isa => 'Str'
);

has storyteller_id => (
    is          => 'rw',
    isa         => 'Str'
);

has showing_cards => (
    is          => 'rw',
    isa         => 'ArrayRef',
    traits      => [qw<Array>],
);

has hidden_card_count => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);

#>>>

sub summary_as_hashref {
    my ($self) = @_;
    my %summary = %$self;
    return \%summary
}

sub state_description {
    $STATES{$_[0]->state};    
}

sub card_ids {
    map { $_->id } $_[0]->cards;
}

sub has_card_from_user_id {
    my ( $self, $user_id ) = @_;
    for my $card ( $self->cards ) {
        if ( $card->{owner_id} == $user_id ) {
            return 1;
        }
    }
    return 0;
}

sub has_cards_from_all_players {
    my ($self,@players) = @_;
    for my $player ( @players ) {
        $player->player_card or return 0
    }
    return 1;
}

sub has_bet_from_user_id {
    my ( $self, $user_id ) = @_;
    for my $bet ( $self->bets ) {
        if ( $bet->{owner_id} == $user_id ) {
            return 1;
        }
    }
    return 0;
}

sub update_story {
    
}

sub cards_have_been_received_from_all_users {
    
}

1;
