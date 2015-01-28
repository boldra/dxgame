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
is_board_deeply( \%expected_board );

my @players =
  ( {}, { P1 => 'secret1' }, { P2 => 'secret2' }, { P3 => 'secret3' }, );

################################################################################
# Create game
dx_put( '/user/P1', $players[1] );
$expected_board{scores}     = { P1 => 0 };
$expected_board{player_ids} = [qw<P1>];
$expected_board{state}      = 2;
$expected_board{state_description} =
  'waiting for start game or other players to join';
is_board_deeply( \%expected_board, 'Game created' );

################################################################################
# Add second user:
dx_put( '/user/P2', $players[2], );
$expected_board{player_ids} = [qw<P1 P2>];
$expected_board{scores} = { P1 => 0, P2 => 0 };
is_board_deeply( \%expected_board, 'P2 added' );

################################################################################
# Add third user:
dx_put( '/user/P3', $players[3], );
$expected_board{player_ids} = [qw<P1 P2 P3>];
$expected_board{scores} = { P1 => 0, P2 => 0, P3 => 0 };
is_board_deeply( \%expected_board, 'P3 added' );

################################################################################
# Start the game
dx_put( '/board', $players[1], { state => '3' } );
$expected_board{state}             = 3;
$expected_board{state_description} = 'waiting for storyteller to play';
is_board_deeply( \%expected_board, 'game started' );

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
        if ( $res->code eq '302' and $res->header('location') =~ /login/ ) {
            login( $cb, $res->header('location'), $user );
            $res = $cb->($req);    #redo original request
        }
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
        is( $res->code, '200', 'http ok' );
        my $struct = eval { $JSON->decode( $res->content ) };
        $@ and die $res->content;
        is_deeply( $struct, $expected, $description );
      };

}

sub login {
    my ( $cb, $uri, $user, ) = @_;
    my $auth_req = HTTP::Request->new( POST => $uri );
    $auth_req->authorization_basic( $user->{username}, $user->{password} );
    my $res = $cb->($auth_req);    # login
    say "Login result:\n" . Dump( { req => $auth_req, res => $res } );

    # we expect another redirect, and we send our cookies:
    $res = $cb->($auth_req);
    $user->{cookie} = $res->header('set-cookie');
    $auth_req->method('GET');
    $auth_req->header( Cookie => $user->{cookie} );
    say "########## location:" . $res->header('location');
    say "post-login confirm:\n" . Dump( { req => $auth_req, res => $res } );
    die;
    #
    #$res->code == 200
    #  or Carp::confess(
    #    "Login failed\n" . Dump { req => $req, res => $res } );

}
