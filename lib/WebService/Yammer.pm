package WebService::Yammer;

use 5.010000;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use XML::Simple;

use JSON;

our $REQUEST_TOKEN_URL = "https://www.yammer.com/oauth/request_token";
our $ACCESS_TOKEN_URL = "https://www.yammer.com/oauth/access_token";
our $AUTHORIZE_URL = "https://www.yammer.com/oauth/authorize?oauth_token=";

require Exporter;
require LWP::UserAgent;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use WebService::Yammer ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
#
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( );
our $VERSION = '0.01';
our $ua;

# Preloaded methods go here.

sub new {
        my $self = {};
	my $class = shift;

	my %args = @_;
	#print Dumper(\%args);

	if(defined($args{'consumer_key'})){
		$self->{CONSUMER_KEY}   = $args{'consumer_key'};
	} else {
		croak "consumer_key not defined. See documentation\n\n"
	}

	if(defined($args{'consumer_secret'})){
		$self->{CONSUMER_SECRET}   = $args{'consumer_secret'};
	} else {
		croak "consumer_secret not defined. See documentation\n\n"
	}

        bless($self);           # but see below
	$ua = LWP::UserAgent->new;
        return $self;
}

sub consumer_key {
        my $self = shift;
	if (@_) { $self->{CONSUMER_KEY} = shift }
	return $self->{CONSUMER_KEY};
}

sub consumer_secret {
        my $self = shift;
	if (@_) { $self->{CONSUMER_SECRET} = shift }
	return $self->{CONSUMER_SECRET};
}

sub request_token{
        my $self = shift;
	if (@_) { $self->{REQUEST_TOKEN} = shift }
	return $self->{REQUEST_TOKEN};
}

sub request_token_secret {
        my $self = shift;
	if (@_) { $self->{REQUEST_TOKEN_SECRET} = shift }
	return $self->{REQUEST_TOKEN_SECRET};
}

sub verifier{
        my $self = shift;
	if (@_) { $self->{VERIFIER} = shift }
	return $self->{VERIFIER};
}

sub access_token {
	my $self = shift;
	if (@_) { $self->{ACCESS_TOKEN} = shift }
	return $self->{ACCESS_TOKEN};
}

sub access_token_secret{
	my $self = shift;
	if (@_) { $self->{ACCESS_TOKEN_SECRET} = shift }
	return $self->{ACCESS_TOKEN_SECRET};
}

sub request_access_token(){
	my $self = shift;
	my $pin = shift;
	my $response = $ua->post($ACCESS_TOKEN_URL,
	      'Authorization' => $self->_oauth_headers($self->request_token, $self->request_token_secret, $pin)
        );

	if ($response->is_success) {
              print "Auth with Pin successful\n";
	      $self->request_token("");
	      $self->request_token_secret("");
              my %bits = split(/[&=]/,$response->content);
	      #print Dumper(\%bits);

              $self->access_token($bits{'oauth_token'});
              $self->access_token_secret($bits{'oauth_token_secret'});
	      print "Access tokens ".$bits{'oauth_token'}.", secret: ".$bits{'oauth_token_secret'}."\n";
              return ($self->access_token,$self->access_token_secret);
        } else {
              print "Failed\n";
        }
}

sub get_authorization_url {
	my $self = shift;
	if(!defined($self->consumer_secret) || !defined($self->consumer_key)){
                croak( "CONSUMER stuff not defined");
        }

	my $response = $ua->post($REQUEST_TOKEN_URL,
        	'Authorization' => $self->_oauth_headers()
        );

	if ($response->is_success) {
	      print "Whheee!\n";
	      my %bits = split(/[&=]/,$response->content);
	      #print Dumper(\%bits);
	      $self->request_token($bits{'oauth_token'});
	      $self->request_token_secret($bits{'oauth_token_secret'});
	      print "OAuthed request tokens: ".$bits{'oauth_token'}.", secret: ".$bits{'oauth_token_secret'}."\n";
	      return $AUTHORIZE_URL.$bits{'oauth_token'};
      	} else {
	      print "Failed\n";
	}
}

sub authorized {
    my $self = shift;
    return (defined($self->access_token) && defined($self->access_token_secret))
}

sub _oauth_headers{
	my $self = shift;
	my $token = shift;
	my $token_secret = shift;
	my $verifier = shift;

	my $buff = "";

	$buff.="OAuth realm=\"";
	$buff.="\", oauth_consumer_key=\"";
	$buff.=$self->consumer_key;
	$buff.="\", ";

	if (defined($token)) {
		$buff.="oauth_token=\"";
		$buff.=$token;
		$buff.="\", ";
	}
	
	$buff.="oauth_signature_method=\"";
	$buff.="PLAINTEXT";
	$buff.="\", oauth_signature=\"";
	$buff.=$self->consumer_secret;
	$buff.="%26";
	if(defined($token_secret)) {
		$buff.=$token_secret;
	}

	$buff.="\", oauth_timestamp=\"";
	$buff.=time();
	$buff.="\", oauth_nonce=\"";
	$buff.=time();

	if(defined( $verifier )){
		$buff.="\", ";
		$buff.="oauth_verifier=\"";
		$buff.=$verifier;
	}

	$buff.="\", oauth_version=\"1.0\"";

	return $buff;
}

1;

sub getMessages(){
	my $self = shift;
	my $response = $ua->get("https://www.yammer.com/api/v1/messages",
		'Authorization' => $self->_oauth_headers($self->access_token, $self->access_token_secret)
        );
	print "Auth: ".$self->_oauth_headers($self->access_token, $self->access_token_secret)."\n";
	if ($response->is_success) {
	      print Dumper($response->content);
	      return _parseMessages($response->content);
	} else {
		return;
		#print Dumper($response->content);
	}
	return 
}

sub _parseMessages(){
	my $self = shift;
	my $xmlMessages = shift;
	#my $XML = XMLin($xmlMessages,ForceArray => ['message']);
	my $XML = XMLin($xmlMessages,KeyAttr => []);
	#print Dumper($XML->{messages}{message});
	return @{$XML->{messages}{message}};
}

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WebService::Yammer - Perl extension for blah blah blah

=head1 SYNOPSIS

  use WebService::Yammer;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for WebService::Yammer, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

bhenry, E<lt>bhenry@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by bhenry

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
