package DxGame::Server;
use Dancer2;
use DxGame::Card;
use DxGame::User;
use DxGame::Board;

our $VERSION = '0.1';

use Modern::Perl;
use Dancer2;
set serializer => 'JSON';

my $BOARD = DxGame::Board->new;
my %HANDS;
my $DECK = DxGAme::Deck->new;

get '/' => sub {
    300 => 'Not valid. Try getting board.';
};

get '/hand' => sub {
    my $user = authenticate();
    return [ $user->hand ];
};

put '/board' => sub {
    my $user  = authenticate();
    # Try to change the state.
    if ( $BOARD->state ) {
        #code
    }
    
};

get '/board' => sub {
    return $BOARD->as_summary_hashref;
}

put '/board/card/:id' => sub {
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
                    $BOARD->cards_have_been_received_from_all_users
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
    my $BOARD = $GAME{board};
    if ( my $card_id = $BOARD->has_bet_from_user_id( $user->id ) ) {
        error("You have already bet on card $card_id");
    }
    else {
        $BOARD->lay_bet( $user, $card );    # later, add amount
    }
};

put '/user/:id' => sub {
    my $user_id = param('id');
    my $BOARD = $GAME{board} //= die "No board";
    if ( $BOARD->state == 1 ) {
        $BOARD->state = 2;                   #game created;
        push @{ $GAME{players} }, DxGame::User->new($user_id);
        $GAME{scores}->{$user_id} = 0;
    }
    elsif ( $BOARD->state == 2 ) {
        push @{ $GAME{players} }, DxGame::User->new($user_id);
        $GAME{scores}->{$user_id} = 0;
    }
    else {
        error("Game has already started");
    }
    return {};
};

put '/board/story' => sub {
    my $story = param("story");
    my $user  = authenticate();
    my $BOARD = $GAME{board};
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
    return $GAME{users}->{$user_id};
}

#sub error {
#    my ($message) = @_;
#    return { 500 => $message };
#}

true;
