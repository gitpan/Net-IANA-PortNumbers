#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->port(0))[0])->desc, 'Reserved');
ok((($iana->port(0))[1])->desc, 'Reserved');
ok((($iana->port(1))[0])->desc, 'TCP Port Service Multiplexer');
ok((($iana->port(1))[1])->desc, 'TCP Port Service Multiplexer');
ok((($iana->port(2))[0])->desc, 'Management Utility');
ok((($iana->port(2))[1])->desc, 'Management Utility');
ok((($iana->port(3))[0])->desc, 'Compression Process');
ok((($iana->port(3))[1])->desc, 'Compression Process');
ok((($iana->port(5))[0])->desc, 'Remote Job Entry');
ok((($iana->port(5))[1])->desc, 'Remote Job Entry');
ok((($iana->port(7))[0])->desc, 'Echo');
ok((($iana->port(7))[1])->desc, 'Echo');
ok((($iana->port(9))[0])->desc, 'Discard');
ok((($iana->port(9))[1])->desc, 'Discard');
ok((($iana->port(11))[0])->desc, 'Active Users');
ok((($iana->port(11))[1])->desc, 'Active Users');
ok((($iana->port(13))[0])->desc, 'Daytime (RFC 867)');
ok((($iana->port(13))[1])->desc, 'Daytime (RFC 867)');
ok((($iana->port(17))[0])->desc, 'Quote of the Day');
ok((($iana->port(17))[1])->desc, 'Quote of the Day');
ok((($iana->port(18))[0])->desc, 'Message Send Protocol');
ok((($iana->port(18))[1])->desc, 'Message Send Protocol');
ok((($iana->port(19))[0])->desc, 'Character Generator');
ok((($iana->port(19))[1])->desc, 'Character Generator');
ok((($iana->port(20))[0])->desc, 'File Transfer [Default Data]');
