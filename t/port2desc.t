#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 7 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok($iana->port2desc(25, 'tcp'), 'Simple Mail Transfer');
ok($iana->port2desc(80, 'tcp'), 'World Wide Web HTTP');
ok($iana->port2desc(543, 'tcp'), 'klogin');
ok($iana->port2desc(126, 'tcp'), 'NXEdit');
ok($iana->port2desc(6666, 'tcp'), 'IRCU');
ok(not defined $iana->port2desc(555555, 'tcp'));
