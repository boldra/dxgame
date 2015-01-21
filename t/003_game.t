use Test::Most;
use Modern::Perl;
use Plack::Test;
use HTTP::Request::Common;
use DxGame::Server;

my $APP = DxGame::Server->to_app;

#my $test = Plack::Test->create($app);
my $JSON = JSON->new;

################################################################################
# Get initial board:
is_board_deeply(
    {
        state             => 1,           # no game
        state_description => 'No game',
        board_cards       => [],          # no cards on the board
        story             => undef,       # no story yet
        scores            => {},          # no players, so no scores
        storyteller       => undef,
    }
);

################################################################################
# Create game
dx_put('/user/paul');
is_board_deeply({
    state => 2, # game started
    state_description => 'waiting for start game or other players to join',
    board_cards => [],
    story => undef,
    scores => {
        paul => 0
    },
    storyteller       => undef,
} );
dx_put('/user/M');
is_board_deeply({
    state => 2, # game started
    state_description => 'waiting for start game or other players to join',
    board_cards => [],
    story => undef,
    users => {
        paul => 0,
        M => 0,
    },
    storyteller       => undef,
} );
dx_put( '/board', { state => '3' } ); # start the game

done_testing();

sub dx_put {
    my ($uri,$content) = @_;
    my $request = HTTP::Request->new( PUT => "http://localhost$uri");
    $content and $request->content($JSON->encode($content));
    test_psgi
      app    => $APP,
      client => sub {
        my $cb = shift;
        my $res = $cb->( $request ) ;
        is( $res->code, '200', "http '$uri' ok" );
      };
}

sub is_board_deeply {
    my ($expected) = @_;
    test_psgi
      app    => $APP,
      client => sub {
        my $cb = shift;
        my $res =
          $cb->( HTTP::Request->new( GET => "http://localhost/board" ) );
        is( $res->code, '200', 'http ok' );
        is_deeply( $JSON->decode( $res->content ), $expected );
      };

}
