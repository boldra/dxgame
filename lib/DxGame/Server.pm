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
my $STORY_CARD_ID;
my @PLAYED_CARD_IDS;
our %RULES = ( hand_size => 5 );

get '/' => sub {
    { 300 => 'Not valid. Try getting /board.' };
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
            $BOARD->set_next_storyteller_id;
            _deal_cards();
            return $BOARD->as_summary_hashref;
        }
        else {

            return { error =>
                  error( "Can't start the game. Wrong state " . $BOARD->state )
            };
        }
    }
    else {
        return {
            error => error(
                "missing state argument. Args:\n" . join ' ', keys %$args
            )
        };
    }

};

get '/board' => sub {
    return $BOARD->as_summary_hashref;
};

get '/hand' => needs login => sub {
    my $user = session('user');
    return $user->hand;
};

sub _deal_cards {
    for my $user ( values %USERS ) {
        while ( $user->hand_size < $RULES{hand_size} ) {
            my $card = $DECK->draw_card;
            $user->add_card($card);
        }
    }
}

put '/board/card/:card_id' => needs login => sub {
    my $user    = session('user');
    my $card_id = param('card_id');
    if ( $BOARD->state == 3 ) {

        # Storyteller
        $user->play_card($card_id);
        $BOARD->increment_hidden_cards;
        $STORY_CARD_ID = $card_id;
        if ( $BOARD->story ) {

            # We have a story and a card from the storyteller. Next state.
            $BOARD->state(4);
        }
        return $BOARD->as_summary_hashref;
    }
    elsif ( $BOARD->state == 4 ) {

        # Other players
        if ( $user->has_card($card_id) ) {
            if ( $user->played_card ) {
                return {
                    error => error(
                        "You have already played card $card_id this round.",
                    )
                };
            }
            else {
                $user->play_card($card_id);
                $BOARD->increment_hidden_cards;
                if ( $BOARD->hidden_card_count == scalar( values %USERS ) ) {

                    # All users have played cards
                    $BOARD->state(5);
                }

                return $BOARD->as_summary_hashref;
            }
        }
        else {
            my @cards = join q{ }, $user->all_cards_in_hand;
            return {
                error => error(
                    $user->id
                      . " doesn't have card $card_id. Choose from @cards."
                )
            };
        }
    }
    else {
        return {
            error => error(
                    "Game is in wrong state '"
                  . $BOARD->state
                  . "'. Not expecting a card yet!"
            )
        };
    }

};

put '/board/bet/:card_id' => needs login => sub {
    my $user = session('user');
    my $card = get_card( param('card_id') );
    if ( my $card_id = $BOARD->has_bet_from_user_id( $user->id ) ) {
        return { error => error("You have already bet on card $card_id") };
    }
    else {
        $BOARD->lay_bet( $user, $card );    # later, add amount
    }
    return $BOARD->as_summary_hashref;
};

put '/board/story' => needs login => sub {
    my $user  = session('user');
    my $story = param("story");
    if ( $user->id eq $BOARD->storyteller_id ) {
        $BOARD->story($story);
        if ( $BOARD->story and $STORY_CARD_ID ) {

            # We have a story and a card from the storyteller. Next state.
            $BOARD->state(4);
        }
    }
    else {
        return { error => error("You are not the storyteller this turn.") };
    }
    return $BOARD->as_summary_hashref;
};

put '/player' => sub {
    my $username = param('username');
    my $password = param('password');
    if ( _is_valid( $username, $password ) ) {
        my $user = DxGame::User->new($username);
        session user => $user;
        if ( $BOARD->state == 1 ) {

            # First player.
            $BOARD->state(2);    #game created;
            $BOARD->add_player( $user->id );
            $USERS{ $user->id } = $user;
        }
        elsif ( $BOARD->state == 2 ) {

            # additional player
            $BOARD->add_player( $user->id );
            $USERS{ $user->id } = $user;
        }
        return { login_ok => $username };
    }
    else {
        return { error => "invalid username or password" };
    }
    return $BOARD->as_summary_hashref;
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
