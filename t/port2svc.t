#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->port(0))[0])->svc, 'unnamed-port-0-service');
ok((($iana->port(0))[1])->svc, 'unnamed-port-0-service');
ok((($iana->port(1))[0])->svc, 'tcpmux');
ok((($iana->port(1))[1])->svc, 'tcpmux');
ok((($iana->port(2))[0])->svc, 'compressnet');
ok((($iana->port(2))[1])->svc, 'compressnet');
ok((($iana->port(3))[0])->svc, 'compressnet');
ok((($iana->port(3))[1])->svc, 'compressnet');
ok((($iana->port(5))[0])->svc, 'rje');
ok((($iana->port(5))[1])->svc, 'rje');
ok((($iana->port(7))[0])->svc, 'echo');
ok((($iana->port(7))[1])->svc, 'echo');
ok((($iana->port(9))[0])->svc, 'discard');
ok((($iana->port(9))[1])->svc, 'discard');
ok((($iana->port(11))[0])->svc, 'systat');
ok((($iana->port(11))[1])->svc, 'systat');
ok((($iana->port(13))[0])->svc, 'daytime');
ok((($iana->port(13))[1])->svc, 'daytime');
ok((($iana->port(17))[0])->svc, 'qotd');
ok((($iana->port(17))[1])->svc, 'qotd');
ok((($iana->port(18))[0])->svc, 'msp');
ok((($iana->port(18))[1])->svc, 'msp');
ok((($iana->port(19))[0])->svc, 'chargen');
ok((($iana->port(19))[1])->svc, 'chargen');
ok((($iana->port(20))[0])->svc, 'ftp-data');
