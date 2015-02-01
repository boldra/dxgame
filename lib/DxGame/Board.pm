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
    is          => 'rw',
    isa         => 'ArrayRef',
    traits      => [qw<Array>],
    handles => {
#        first_player_id => 'first',
        push_player => 'push',
    },
);

has state => (
    is          => 'rw',
    isa         => 'Num',
    default     => 1,
);

has scores => (
    is          => 'rw',
    isa         => 'HashRef',
    traits      => [qw<Hash>],
    default     => sub { { } },
);

has story => (
    is  => 'rw',
    isa => 'Maybe[Str]',
    default     => undef,
);

has storyteller_id => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    default     => undef,
);

has visible_cards => (
    is          => 'rw',
    isa         => 'ArrayRef',
    traits      => [qw<Array>],
    default     => sub { [] },
);

has hidden_card_count => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw<Counter>],
    handles => {
        increment_hidden_cards => 'inc',
        remove_hidden_cards => 'reset',
    }
);

#>>>

sub as_summary_hashref {
    my ($self) = @_;
    my %summary = %$self;
    $summary{state_description} = $STATES{$summary{state}};
    return \%summary
}

sub set_next_storyteller_id {
    my ($self) = @_;
    if (my $old = $self->storyteller_id) {
        return $self->storyteller_id($self->player_after($old));
    }
    else {
        return $self->storyteller_id($self->player_ids->[0]);
    }
}

sub player_after {
    my ($self,$prev) = @_;
    my $next;
    for my $id ($self->all_player_ids) {
        if( $next == 1 ) {
            return $id;
        }
        if ($id eq $prev) {
            my $next = 1;
        }
    }
    return $self->player_ids->[0];

}

sub add_player {
    my ($self,$player_id) = @_;
    $self->push_player($player_id);
    $self->scores->{$player_id} = 0
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

sub cards_have_been_received_from_all_users {
    
}

1;
