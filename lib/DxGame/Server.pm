package DxGame::Server;
use Dancer2;
use DxGame::Card;
use DxGame::User;
use DxGame::Board;
use DxGame::Deck;

our $VERSION = '0.1';

use Modern::Perl;
use Dancer2;
set serializer => 'JSON';

my $BOARD = DxGame::Board->new;
my $DECK = DxGame::Deck->new;
my %USERS;

get '/' => sub {
    { 300 => 'Not valid. Try getting board.' };
};

get '/hand' => sub {
    my $user = authenticate();
    return [ $user->hand ];
};

put '/board' => sub {
    my $user  = authenticate();
    my $args = params();
    # Try to change the state.
    if( $args->{state} == 3 ) {
        # Request to begin game
        if ( $BOARD->state == 2) {
            # perfect time to begin the game!
            $BOARD->state(3);
        }
        else {
            error("Can't start the game. Wrong state " . $BOARD->state);
        }
    } else {
        error("missing state argument. Args:\n" .  join ' ', keys %$args)
    }
    
};

get '/board' => sub {
    return $BOARD->as_summary_hashref;
};

put '/board/card/:card_id' => sub {
    my $user  = authenticate();
    my $card  = get_card( param('card_id') );
    if ( $BOARD->state == 3 ) {

        # Storyteller
        $user->remove_from_hand($card);
        $BOARD->place_card( $user, $card );
    }
    elsif ( $BOARD->state == 4 ) {

        # Other players
        if ( $user->has_card( $card->id ) ) {
            if ( $BOARD->has_card_from_user($user) ) {
                error(  "You have already played card "
                      . $card->id
                      . " this round " );
            }
            else {
                $BOARD->play_card( $user, $card );
                if (
                    $BOARD->has_cards_from_all_players(values %USERS)
                  )
                {
                    $BOARD->state = 5;    #waiting for players to make a bet.
                }
            }
        }
        else {
            error( "You don't have card " . $card->id );
        }
    }
    else {
        error(
"Game is in wrong state '" . $BOARD->state . "'. Not expecting a card yet!"
        );
    }

};

put '/board/bet/:card_id' => sub {
    my $card  = get_card( param('card_id') );
    my $user  = authenticate();
    if ( my $card_id = $BOARD->has_bet_from_user_id( $user->id ) ) {
        error("You have already bet on card $card_id");
    }
    else {
        $BOARD->lay_bet( $user, $card );    # later, add amount
    }
};

put '/user/:id' => sub {
    my $user_id = param('id');
    if ( $BOARD->state == 1 ) {
        # First player.
        $BOARD->state(2);                   #game created;
        $BOARD->add_player($user_id);
        $USERS{$user_id} = DxGame::User->new($user_id);
    }
    elsif ( $BOARD->state == 2 ) {
        # additional player
        $BOARD->add_player($user_id);
        $USERS{$user_id} = DxGame::User->new($user_id);
    }
    else {
        error("Too late to join game, game has already started");
    }
    return {};
};

put '/board/story' => sub {
    my $story = param("story");
    my $user  = authenticate();
    if ( $user->is_storyteller ) {
        $BOARD->update_story($story);
    }
    else {
        error("You are not the storyteller");
    }

};

sub _initial_game_state {
    return (
        board => DxGame::Board->new,
        hands => {},
    );
}

sub authenticate {
    my ($user_id) = @_;
    return $USERS{$user_id} // die "Not authenticated user_id='$user_id'";
}

#sub error {
#    my ($message) = @_;
#    return { 500 => $message };
#}

true;
