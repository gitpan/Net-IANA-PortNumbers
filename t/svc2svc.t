#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->service('chargen'))[0])->svc, 'chargen');
ok((($iana->service('chargen'))[1])->svc, 'chargen');
ok((($iana->service('compressnet'))[0])->svc, 'compressnet');
ok((($iana->service('compressnet'))[1])->svc, 'compressnet');
ok((($iana->service('compressnet'))[2])->svc, 'compressnet');
ok((($iana->service('compressnet'))[3])->svc, 'compressnet');
ok((($iana->service('daytime'))[0])->svc, 'daytime');
ok((($iana->service('daytime'))[1])->svc, 'daytime');
ok((($iana->service('discard'))[0])->svc, 'discard');
ok((($iana->service('discard'))[1])->svc, 'discard');
ok((($iana->service('echo'))[0])->svc, 'echo');
ok((($iana->service('echo'))[1])->svc, 'echo');
ok((($iana->service('ftp-data'))[0])->svc, 'ftp-data');
ok((($iana->service('ftp-data'))[1])->svc, 'ftp-data');
ok((($iana->service('msp'))[0])->svc, 'msp');
ok((($iana->service('msp'))[1])->svc, 'msp');
ok((($iana->service('msp'))[2])->svc, 'msp');
ok((($iana->service('msp'))[3])->svc, 'msp');
ok((($iana->service('qotd'))[0])->svc, 'qotd');
ok((($iana->service('qotd'))[1])->svc, 'qotd');
ok((($iana->service('rje'))[0])->svc, 'rje');
ok((($iana->service('rje'))[1])->svc, 'rje');
ok((($iana->service('systat'))[0])->svc, 'systat');
ok((($iana->service('systat'))[1])->svc, 'systat');
ok((($iana->service('tcpmux'))[0])->svc, 'tcpmux');
