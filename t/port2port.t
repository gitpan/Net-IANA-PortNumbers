#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->port(0))[0])->port, 0);
ok((($iana->port(0))[1])->port, 0);
ok((($iana->port(1))[0])->port, 1);
ok((($iana->port(1))[1])->port, 1);
ok((($iana->port(2))[0])->port, 2);
ok((($iana->port(2))[1])->port, 2);
ok((($iana->port(3))[0])->port, 3);
ok((($iana->port(3))[1])->port, 3);
ok((($iana->port(5))[0])->port, 5);
ok((($iana->port(5))[1])->port, 5);
ok((($iana->port(7))[0])->port, 7);
ok((($iana->port(7))[1])->port, 7);
ok((($iana->port(9))[0])->port, 9);
ok((($iana->port(9))[1])->port, 9);
ok((($iana->port(11))[0])->port, 11);
ok((($iana->port(11))[1])->port, 11);
ok((($iana->port(13))[0])->port, 13);
ok((($iana->port(13))[1])->port, 13);
ok((($iana->port(17))[0])->port, 17);
ok((($iana->port(17))[1])->port, 17);
ok((($iana->port(18))[0])->port, 18);
ok((($iana->port(18))[1])->port, 18);
ok((($iana->port(19))[0])->port, 19);
ok((($iana->port(19))[1])->port, 19);
ok((($iana->port(20))[0])->port, 20);
