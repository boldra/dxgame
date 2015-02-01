use Test::Most;
use Modern::Perl;
use Plack::Test;
use HTTP::Request::Common;
use YAML::XS qw<Dump>;
BEGIN { $ENV{DANCER_ENVIRONMENT} = 'testing' }
use DxGame::Server;
my $APP = DxGame::Server->to_app();

#my $test = Plack::Test->create($app);
my $JSON = JSON->new;

################################################################################
# Get initial board:
my %expected_board = (
    state             => 1,           # state 1 = no game
    state_description => 'No game',
    visible_cards     => [],          # no cards on the board
    story             => undef,       # no story yet
    scores            => {},          # no players, so no scores
    storyteller_id    => undef,       # storyteller defined after game begins
    hidden_card_count => 0,           # no hidden cards
);
is_board_deeply( \%expected_board, 'initial board' );

my @players = (
    {},
    { username => 'P1', password => 'secret1' },
    { username => 'P2', password => 'secret2' },
    { username => 'P3', password => 'secret3' },
);

################################################################################
# Create game
is( ( defined $players[1]->{cookie} ),
    '', "No session cookie $players[1]->{username}" );
login( $players[1] );
like( $players[1]->{cookie},
    qr{session},
    "session cookie $players[1]->{username}=$players[1]->{cookie}" );
$expected_board{scores}     = { P1 => 0 };
$expected_board{player_ids} = [qw<P1>];
$expected_board{state}      = 2;
$expected_board{state_description} =
  'waiting for start game or other players to join';
is_board_deeply( \%expected_board, 'Game created' );

################################################################################
# Add second user:
login( $players[2] );
$expected_board{player_ids} = [qw<P1 P2>];
$expected_board{scores} = { P1 => 0, P2 => 0 };
is_board_deeply( \%expected_board, 'P2 added' );

################################################################################
# Add third user:
login( $players[3] );
$expected_board{player_ids} = [qw<P1 P2 P3>];
$expected_board{scores} = { P1 => 0, P2 => 0, P3 => 0 };
is_board_deeply( \%expected_board, 'P3 added' );

################################################################################
# Start the game
dx_put( '/board', $players[1], { state => '3' } );
$expected_board{state}             = 3;
$expected_board{storyteller_id}    = $players[1]->{username}; #1 becomes the storyteller
$expected_board{state_description} = 'waiting for storyteller to play';
is_board_deeply( \%expected_board, 'game started' );

################################################################################
# Get hand of P1
my @hands;
my $req = HTTP::Request->new( GET => "http://localhost/hand" );
test_psgi
    app    => $APP,
      client => sub {
        my $cb = shift;
        $req->header( Cookie => $players[1]->{cookie} );
        my $res = $cb->( $req );
        my $struct = eval { $JSON->decode( $res->content ) };
        $hands[1] = $struct;
        is( $res->code, '200', "Got hand @{$struct}" );
        is( (scalar @{ $hands[1]} ), $DxGame::Server::RULES{hand_size}, "got five cards");
    };

################################################################################
# Storyteller: play one card
dx_put( '/board/card/'.$hands[1]->[0], $players[1] ); # play the first card

################################################################################
# Storyteller: tell a the story

################################################################################
# Put other cards

################################################################################
# lay bets

################################################################################
# update scores

################################################################################
# check storyteller has changed

done_testing();

sub dx_put {
    my ( $uri, $user, $content ) = @_;
    my $req = HTTP::Request->new( PUT => "http://localhost$uri" );
    $req->header( Cookie => $user->{cookie} );
    $content and $req->content( $JSON->encode($content) );
    test_psgi
      app    => $APP,
      client => sub {
        my $cb  = shift;
        my $res = $cb->($req);
        is( $res->code, '200', "http '$uri' ok" );
      };
}

sub is_board_deeply {
    my ( $expected, $description ) = @_;
    test_psgi
      app    => $APP,
      client => sub {
        my $cb = shift;
        my $res =
          $cb->( HTTP::Request->new( GET => "http://localhost/board" ) );
        is( $res->code, '200', 'fetch board HTTP ok' );
        my $struct = eval { $JSON->decode( $res->content ) };
        $@ and die $res->content;
        is_deeply( $struct, $expected, $description );
    };
}

sub login {
    my ($user) = @_;
    my $uri = 'http://localhost/player';
    my $auth_req = HTTP::Request->new( PUT => $uri );
    my $json = $JSON->encode($user);
    $auth_req->content($json);
    $auth_req->content_type('application/json');
    $auth_req->content_length( length( $auth_req->content ) );
    test_psgi
      app    => $APP,
      client => sub {
        my $cb  = shift;
        my $res = $cb->($auth_req);
        is( $res->code, '200', "login as '$user->{username}' successful" );

     #        say "Login result:\n" . Dump( { req => $auth_req, res => $res } );
        my $cookie = $res->header('set-cookie');
        $cookie =~ s{HttpOnly}{};
        $user->{cookie} = $cookie;
      };

}
