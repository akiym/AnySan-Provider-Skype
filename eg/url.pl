use strict;
use warnings;
use AnySan;
use AnySan::Provider::Skype;
use LWP::UserAgent;
use URI::Find;

my $ua = LWP::UserAgent->new;

my $skype = skype;

AnySan->register_listener(
    url => {
        event => 'chatmessage',
        cb => sub {
            my $receive = shift;
            my $message = $receive->message;
            while ($message =~ m!(?=(https?://\S+))!g) {
                my $url = $1;
                my $res = $ua->get($url);
                $res->is_success or return;

                my ($title) = $res->decoded_content =~ m!<title>(.*?)</title>!i;
                $title // return;

                $receive->send_reply($title);
            }
        },
    },
);

AnySan->run;
