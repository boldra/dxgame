package DxGame::Server;
use Dancer2;
use DxGame::User;
use DxGame::Board;
use DxGame::Deck;
use Dancer2::Plugin::Auth::Tiny;
use DxGame::Card;

our $VERSION = '0.1';

use Modern::Perl;
use Dancer2;
set serializer => 'JSON';
set session    => 'simple';
set plugins    => { 'Auth::Extensible' => { provider => 'Example' } };

my $BOARD = DxGame::Board->new;
my $DECK  = DxGame::Deck->new;
my %USERS;

get '/' => sub {
    { 300 => 'Not valid. Try getting /board.' };
};

get '/hand' => needs login => sub {
    my $user = session('user');
    return [ $user->hand ];
};

put '/board' => needs login => sub {
    my $user = session('user');
    my $args = params();

    # Try to change the state.
    if ( $args->{state} == 3 ) {

        # Request to begin game
        if ( $BOARD->state == 2 ) {

            # perfect time to begin the game!
            $BOARD->state(3);
            return $BOARD->as_summary_hashref;
        }
        else {
            error( "Can't start the game. Wrong state " . $BOARD->state );
        }
    }
    else {
        error( "missing state argument. Args:\n" . join ' ', keys %$args );
    }

};

get '/board' => sub {
    return $BOARD->as_summary_hashref;
};

put '/board/card/:card_id' => needs login => sub {
    my $user = session('user');
    my $card = get_card( param('card_id') );
    if ( $BOARD->state == 3 ) {

        # Storyteller
        $user->remove_from_hand($card);
        $BOARD->place_card( $user, $card );
    }
    elsif ( $BOARD->state == 4 ) {

        # Other players
        if ( $user->has_card( $card->id ) ) {
            if ( $BOARD->has_card_from_user($user) ) {
                warn "already have card from user";
                error(  "You have already played card "
                      . $card->id
                      . " this round " );
            }
            else {
                $BOARD->play_card( $user, $card );
                if ( $BOARD->has_cards_from_all_players( values %USERS ) ) {
                    $BOARD->state = 5;    #waiting for players to make a bet.
                }
            }
        }
        else {
                warn "already have card from user";
            error( "You don't have card " . $card->id );
        }
    }
    else {
                warn "already have card from user";
        error(  "Game is in wrong state '"
              . $BOARD->state
              . "'. Not expecting a card yet!" );
    }

};

put '/board/bet/:card_id' => needs login => sub {
    my $user = session('user');
    my $card = get_card( param('card_id') );
    if ( my $card_id = $BOARD->has_bet_from_user_id( $user->id ) ) {
        error("You have already bet on card $card_id");
    }
    else {
        $BOARD->lay_bet( $user, $card );    # later, add amount
    }
};

put '/board/story' => needs login => sub {
    my $user = session('user');
    my $story = param("story");
    if ( $user->is_storyteller ) {
        $BOARD->update_story($story);
    }
    else {
        warn "not storyteller";
        error("You are not the storyteller");
    }
};

put '/player' => sub {
    my $username = param('username');
    my $password = param('password');
    if ( _is_valid( $username, $password ) ) {
        my $user = DxGame::User->new($username);
        session user => $user;
        if ( $BOARD->state == 1 ) {
    
            # First player.
            $BOARD->state(2);                   #game created;
            $BOARD->add_player($user->id);
            $USERS{$user->id} = $user;
        }
        elsif ( $BOARD->state == 2 ) {
    
            # additional player
            $BOARD->add_player($user->id);
            $USERS{$user->id} = $user;
        }
        return { login_ok => $username };
    }
    else {
        return { error => "invalid username or password" };
    }
};

sub _initial_game_state {
    return (
        board => DxGame::Board->new,
        hands => {},
    );
}

sub _is_valid {
    my ( $username, $password ) = @_;
    if ($username) {
        $username =~ /P\d/ and return 1;
        warn "invalid credentials for user '$username'";
        return 0;
    }
    else {
        warn "Username missing";
        return 0;
    }
}

true;
