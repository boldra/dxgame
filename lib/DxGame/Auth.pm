package DxGame::Auth;

=head1 NAME

DxGame::Auth - Basic HTTP authentication for Dancer web apps

=cut

use warnings;
use strict;

use Dancer2 ':syntax';
use Dancer2::Plugin;
use HTTP::Headers;
use MIME::Base64;

our $VERSION = '0.011';

my $settings = plugin_setting;

# Protected paths defined in the configuration
my $paths = {};
# "Global" users
my $users = {};

if (exists $settings->{paths}) {
    $paths = $settings->{paths};
}

if (exists $settings->{users}) {
    $users = $settings->{users};
}

sub _auth_basic {
    my (%options) = @_;
    
    # Get authentication data from request
    my $auth = request->env->{HTTP_AUTHORIZATION};
    
    if (defined $auth && $auth =~ /^Basic (.*)$/) {
        my ($user, $password) = split(/:/, (MIME::Base64::decode($1) || ":"));
        
        if (exists $options{user}) {
            # A single user is defined
            if ($user eq $options{user} && $password eq $options{password}) {
                # Authorization succeeded
                return 1;
            }
        }
        elsif (exists $options{users}) {
            # Multiple users are defined
            if ($password eq $options{users}->{$user}) {
                # Authorization succeeded
                return 1;
            }
        }
        elsif (defined $users) {
            # Use the "global" users list
            if ($password eq $users->{$user}) {
                # Authorization succeeded
                return 1;
            }
        }
        else {
            # No users defined? NONE SHALL PASS!
            warning __PACKAGE__ . ": No user/password defined";
        }
    }
    
    my $content = "Authorization required";
    
    return halt(response(
        status => 401,
        content => $content,
        headers => [
            'Content-Type' => 'text/plain',
            'Content-Length' => length($content),
            'WWW-Authenticate' => 'Basic realm="' . ($options{realm} ||
                "Restricted area") . '"'
        ]
    ));
}

before sub {
    # Check if the request matches one of the protected paths (reverse sort the
    # paths to find the longest matching path first)
    foreach my $path (reverse sort keys %$paths) {
        my $path_re = '^' . quotemeta($path);
        
        if (request->path_info =~ qr{$path_re}) {
            _auth_basic %{$paths->{$path}};
            last;
        }
    }
};

register auth_basic => \&_auth_basic;

register_plugin;

1; # End of Dancer::Plugin::Auth::Basic