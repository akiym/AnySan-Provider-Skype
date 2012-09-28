package AnySan::Provider::Skype;
use strict;
use warnings;
our $VERSION = '0.01';

use parent qw/AnySan::Provider/;
use AnySan;
use AnySan::Receive;
use Skype::Any;

our @EXPORT = qw(skype);

sub skype {
    my(%config) = @_;
    my $self = __PACKAGE__->new(
        client => undef,
        config => \%config,
    );

    my $client = Skype::Any->new(%config);
    $self->{client} = $client;
    {
        no warnings 'redefine';
        *AnySan::run = sub {
            $client->run;
        };
    }

    $client->message_received(sub {
        my $msg = shift;
        my $receive; $receive = AnySan::Receive->new(
            provider      => 'skype',
            event         => 'chatmessage',
            message       => $msg->body,
            from_nickname => $msg->from_handle,
            attribute     => {
                chatname  => $msg->chatname,
                dispname  => $msg->from_dispname,
                timestamp => $msg->timestamp,
                obj       => $msg,
            },
            cb            => sub { $self->event_callback($receive, @_) },
        );
        AnySan->broadcast_message($receive);
    });

    return $self;
}

sub event_callback {
    my($self, $receive, $type, @args) = @_;

    if ($type eq 'reply') {
        my $chat = $receive->attribute('obj')->chat;
        $chat->send_message($args[0]);
    }
}

sub send_message {
    my($self, $message, %args) = @_;

    my $user = $self->{client}->user($args{nickname});
    $user->send_message($message);
}


1;
__END__

=head1 NAME

AnySan::Provider::Skype - AnySan provide Skype API protocol

=head1 SYNOPSIS

  use AnySan;
  use AnySan::Provider::Skype;

  my $skype = skype
      name     => 'myapp',
      protocol => 8;

  AnySan->register_listener(
      url => {
          event => 'chatmessage',
          cb => sub {
              my $receive = shift;
              my $message = $receive->message;
              if ($message eq 'ping') {
                  $receive->send_reply('pong');
              }
          },
      },
  );

  AnySan->run;

=head1 AUTHOR

Takumi Akiyama E<lt>t.akiym at gmail.comE<gt>

=head1 SEE ALSO

L<AnySan>, L<Skype::Any>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
