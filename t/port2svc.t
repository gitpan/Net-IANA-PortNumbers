#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 7 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok($iana->port2svc(25, 'tcp'), 'smtp');
ok($iana->port2svc(80, 'tcp'), 'http');
ok($iana->port2svc(543, 'tcp'), 'klogin');
ok($iana->port2svc(126, 'tcp'), 'nxedit');
ok($iana->port2svc(6666, 'tcp'), 'ircu');
ok(not defined $iana->port2svc(555555, 'tcp'));
