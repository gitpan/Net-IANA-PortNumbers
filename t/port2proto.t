#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->port(0))[0])->proto, 'tcp');
ok((($iana->port(0))[1])->proto, 'udp');
ok((($iana->port(1))[0])->proto, 'tcp');
ok((($iana->port(1))[1])->proto, 'udp');
ok((($iana->port(2))[0])->proto, 'tcp');
ok((($iana->port(2))[1])->proto, 'udp');
ok((($iana->port(3))[0])->proto, 'tcp');
ok((($iana->port(3))[1])->proto, 'udp');
ok((($iana->port(5))[0])->proto, 'tcp');
ok((($iana->port(5))[1])->proto, 'udp');
ok((($iana->port(7))[0])->proto, 'tcp');
ok((($iana->port(7))[1])->proto, 'udp');
ok((($iana->port(9))[0])->proto, 'tcp');
ok((($iana->port(9))[1])->proto, 'udp');
ok((($iana->port(11))[0])->proto, 'tcp');
ok((($iana->port(11))[1])->proto, 'udp');
ok((($iana->port(13))[0])->proto, 'tcp');
ok((($iana->port(13))[1])->proto, 'udp');
ok((($iana->port(17))[0])->proto, 'tcp');
ok((($iana->port(17))[1])->proto, 'udp');
ok((($iana->port(18))[0])->proto, 'tcp');
ok((($iana->port(18))[1])->proto, 'udp');
ok((($iana->port(19))[0])->proto, 'tcp');
ok((($iana->port(19))[1])->proto, 'udp');
ok((($iana->port(20))[0])->proto, 'tcp');
