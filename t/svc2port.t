#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 16 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok(scalar @{$iana->svc2port('smtp', 'tcp')}, 1);
ok(scalar @{$iana->svc2port('http', 'tcp')}, 1);
ok(scalar @{$iana->svc2port('klogin', 'tcp')}, 1);
ok(scalar @{$iana->svc2port('nxedit', 'tcp')}, 1);
ok(scalar @{$iana->svc2port('ircu', 'tcp')}, 5);
ok((@{$iana->svc2port('smtp', 'tcp')})[0], 25);
ok((@{$iana->svc2port('http', 'tcp')})[0], 80);
ok((@{$iana->svc2port('klogin', 'tcp')})[0], 543);
ok((@{$iana->svc2port('nxedit', 'tcp')})[0], 126);
ok((@{$iana->svc2port('ircu', 'tcp')})[0], 6665);
ok((@{$iana->svc2port('ircu', 'tcp')})[1], 6666);
ok((@{$iana->svc2port('ircu', 'tcp')})[2], 6667);
ok((@{$iana->svc2port('ircu', 'tcp')})[3], 6668);
ok((@{$iana->svc2port('ircu', 'tcp')})[4], 6669);
ok(scalar @{$iana->svc2port('foobar', 'tcp')}, 0);
