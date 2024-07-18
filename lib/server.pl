#!/usr/bin/perl
use strictures 2;
use 5.30.0;
use Net::Async::HTTP::Server;
use IO::Async::Loop;
 
use HTTP::Response;

our $keycode_translations = {
    Tab => 0x09,
    Escape => 0x1b,

    F1  => 0x80,
    F2  => 0x81,
    F3  => 0x82,
    F4  => 0x83,
    F5  => 0x84,
    F6  => 0x85,
    F7  => 0x86,
    F8  => 0x87,
    F9  => 0x88,
    F10 => 0x89,
    F11 => 0x8a,
    F12 => 0x8c,

    'Arrow Up'    => 0x91,
    'Arrow Down'  => 0x92,
    'Arrow Left'  => 0x93,
    'Arrow Right' => 0x94,
    'Arrow Enter' => 0x9c,
    Home => 0x95,
    End => 0x96,
    'Page Up' => 0x97,
    'Page Down' => 0x98,
    Insert => 0x99,
    Delete => 0x9a,
    'Numpad Divide' => 0xa4, # / (Block Skip)
    Pause => 0xb7,

    # 'Scroll Lock'
    # 'Num Lock'
    # 'Numpad Multiply'
    # 'Numpad Subtract'
    # 

};

my $loop = IO::Async::Loop->new();
 
my $httpserver = Net::Async::HTTP::Server->new(
   on_request => sub {
      my $self = shift;
      my ( $req ) = @_;

      my $path = $req->path;
      if ($path =~ m/\.\./) {
        die "Potental path traversal attack: '$path'";
      }

      if ($path eq '/') {
        $path = '/index.html';
      }

      my $response = HTTP::Response->new( 200 );

      my $filename = "build/web/$path";
      if (-e $filename) {
        print "Static file $path\n";

        open my $in_file, "<:raw", $filename or die "Can't open $filename: $!";
        local $/=undef;
        
        my $content = <$in_file>;
        $response->add_content($content);

        my $content_type = "application/octet-stream";
        if ($path =~ m/\.html$/) {
            $content_type = 'text/html';
        }
        $response->content_type($content_type);

      } elsif ($path eq '/key') {
        my $content = $req->as_http_request->content;

        my $key;
        if ($content =~ m/key=(.*?)$/) {
            $key = $1;
            $key =~ s/\+/ /g;
            $key =~ s/%(..)/chr hex $1/ge;
        }

        my $out;

        if (length($key) == 1) {
            $out = $key;
        } elsif (exists $keycode_translations->{$key}) {
            $out = $keycode_translations->{$key};
        }

        if (defined $out) {
          $response->add_content(sprintf("output code: 0x%x", ord $out));
        } else {
          $response->add_content("Unknown key code '$key'");
        }

        $response->content_type('text/plain');
      } else {
        die "Unhandled request, path=$path, query=".($req->query_string || 'no query');
      }

      # say "Response: ", $response->as_string;
 
      $response->content_length( length $response->content );
      $req->respond( $response );
   },
);
 
$loop->add( $httpserver );
 
$httpserver->listen(
   addr => { family => "inet", socktype => "stream", port => 8123 },
)->get;
print "Listening on :8123\n";
 
$loop->run;