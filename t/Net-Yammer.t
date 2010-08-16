# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-Yammer.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
use WebService::Yammer;
use lib '/home/bhenry/WebService--Yammer/WebService-Yammer/lib/';

BEGIN { use_ok('WebService::Yammer') };

#use Film;  # What you're testing.

my $consumer_key = "testingconsumer_key";
my $consumer_secret = "testingconsumer_secret";

my $y = WebService::Yammer->new(
        consumer_key => $consumer_key,
        consumer_secret => $consumer_secret
);

ok( defined($y) && ref $y eq 'WebService::Yammer', 'new() works' );
is($y->consumer_secret , $consumer_secret,'Consumer Secret get works');
is($y->consumer_key , $consumer_key,'Consumer key get works');
my $access_token = "ACCESSTOKEN";
my $access_token_secret = "REQUESTTOKEN";
my $request_token = "REQUESTTOKEN";
my $request_token_secret = "REQUESTTOKEN";
my $verifier = "VERIFIER";

ok(!$y->authorized(),"Authorized = false works");
ok($y->access_token($access_token) && $y->access_token eq $access_token,'Access Token get and set work');
ok($y->access_token_secret($access_token_secret) && $y->access_token_secret eq $access_token_secret,'Access Token Secret get and set work');
ok($y->authorized(),"Authorized = true works");
ok($y->request_token($request_token) && $y->request_token eq $request_token,'request Token get and set work');
ok($y->request_token_secret($request_token_secret) && $y->request_token_secret eq $request_token,'request Token Secret get and set work');
like($y->_oauth_headers("token", "token_secret", "verifier"),
	qr/OAuth realm="", oauth_consumer_key="$consumer_key", oauth_token="token", oauth_signature_method="PLAINTEXT", oauth_signature="$consumer_secret%26token_secret", oauth_timestamp="\d.*", oauth_nonce="\d.*", oauth_verifier="verifier", oauth_version="1.0"/,
	"_oauth_headers returned correct authstring"); 

my $xml = ' <?xml version="1.0" encoding="UTF-8"?>
<response>
  <messages>
    <message>
      <system-message>false</system-message>
      <created-at>2010-08-10T03:23:10Z</created-at>
      <client-type>ntam</client-type>
      <message-type>update</message-type>
      <network-id>115215</network-id>
      <sender-type>user</sender-type>
      <thread-id>57889130</thread-id>
      <liked-by>
        <names/>
        <count>0</count>
      </liked-by>
      <id>57889131</id>
      <url>https://www.yammer.com/api/v1/messages/57889130</url>
      <body>
        <parsed>Parsed Message</parsed>
        <plain>Plain Message</plain>
      </body>
      <attachments/>
      <sender-id>1807015</sender-id>
      <replied-to-id nil="true"></replied-to-id>
      <web-url>https://www.yammer.com/agbnielsen.com.au/messages/57889130</web-url>
      <client-url>http://company.com.au</client-url>
    </message>
    <message>
      <system-message>false</system-message>
      <created-at>2010-08-10T03:23:10Z</created-at>
      <client-type>ntam</client-type>
      <message-type>update</message-type>
      <network-id>115215</network-id>
      <sender-type>user</sender-type>
      <thread-id>57889130</thread-id>
      <liked-by>
        <names/>
        <count>0</count>
      </liked-by>
      <id>57889130</id>
      <url>https://www.yammer.com/api/v1/messages/57889130</url>
      <body>
        <parsed>Parsed Message</parsed>
        <plain>Plain Message</plain>
      </body>
      <attachments/>
      <sender-id>1807015</sender-id>
      <replied-to-id nil="true"></replied-to-id>
      <web-url>https://www.yammer.com/agbnielsen.com.au/messages/57889130</web-url>
      <client-url>http://company.com.au</client-url>
    </message>
  </messages>
  <threaded-extended>
  </threaded-extended>
  <meta>
    <followed-user-ids>
      <followed-user-id>1000001</followed-user-id>
      <followed-user-id>1000002</followed-user-id>
      <followed-user-id>1000003</followed-user-id>
    </followed-user-ids>
    <show-billing-banner nil="true"></show-billing-banner>
    <older-available>true</older-available>
    <ymodules/>
    <realtime>
      <authentication-token>longstringofauthenticationtokentypecharacters</authentication-token>
      <channel-id>kjshdf</channel-id>
      <uri>https://17.rt.yammer.com/cometd/</uri>
    </realtime>
    <requested-poll-interval>60</requested-poll-interval>
    <current-user-id>1764458</current-user-id>
  </meta>
  <references>
    <reference>
      <type>user</type>
      <stats>
        <following>13</following>
        <followers>9</followers>
        <updates>14</updates>
      </stats>
      <full-name>Firstname Lastname</full-name>
      <job-title>Technical Dogsbody</job-title>
      <state>active</state>
      <url>https://www.yammer.com/api/v1/users/1000000</url>
      <web-url>https://www.yammer.com/agbnielsen.com.au/users/firstnamelastmane</web-url>
      <name>firstnamelastname</name>
      <id>1000000</id>
      <mugshot-url>https://assets1.yammer.com/user_uploaded/photos/p1/9999/99991689/small.JPG</mugshot-url>
    </reference>
  </references>
</response>';

my @parsedMessages = $y->_parseMessages($xml);
is(scalar(@parsedMessages),2,"Messages Parsed OK");
is($parsedMessages[0]->{id},57889131,"Messages Parsed OK");
is($parsedMessages[1]->{id},57889130,"Messages Parsed OK");

