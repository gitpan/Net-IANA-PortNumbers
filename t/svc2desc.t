#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 7 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok($iana->svc2desc('smtp', 'tcp'), 'Simple Mail Transfer');
ok($iana->svc2desc('http', 'tcp'), 'World Wide Web HTTP');
ok($iana->svc2desc('klogin', 'tcp'), 'klogin');
ok($iana->svc2desc('nxedit', 'tcp'), 'NXEdit');
ok($iana->svc2desc('ircu', 'tcp'), 'IRCU');
ok(not defined $iana->svc2desc('foobar', 'tcp'));
