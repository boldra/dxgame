use Test::Most;
use Modern::Perl;
use Plack::Test;
use HTTP::Request::Common;
BEGIN { $ENV{DANCER_ENVIRONMENT} = 'testing' }
use DxGame::Server;
my $APP = DxGame::Server->to_app;


#my $test = Plack::Test->create($app);
my $JSON = JSON->new;

################################################################################
# Get initial board:
my %expected_board = (
    state             => 1,           # no game
    state_description => 'No game',
    visible_cards     => [],          # no cards on the board
    story             => undef,       # no story yet
    scores            => {},          # no players, so no scores
    storyteller_id    => undef,
    hidden_card_count => 0,
);
is_board_deeply( \%expected_board );

################################################################################
# Create game
dx_put('/user/P1');
$expected_board{scores} = { P1 => 0 };
is_board_deeply( \%expected_board );

################################################################################
# Add second user:
dx_put('/user/P2');
$expected_board{scores} = { P1 => 0, P2 => 0 };
is_board_deeply( \%expected_board );

################################################################################
# Add third user:
dx_put('/user/P3');
$expected_board{scores} = { P1 => 0, P2 => 0, P3 => 0 };
is_board_deeply( \%expected_board );


################################################################################
# Start the game
dx_put( '/board', { state => '3' } ); 

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
