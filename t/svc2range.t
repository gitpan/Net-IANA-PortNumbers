#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->service('chargen'))[0])->range, 'Well known');
ok((($iana->service('chargen'))[1])->range, 'Well known');
ok((($iana->service('compressnet'))[0])->range, 'Well known');
ok((($iana->service('compressnet'))[1])->range, 'Well known');
ok((($iana->service('compressnet'))[2])->range, 'Well known');
ok((($iana->service('compressnet'))[3])->range, 'Well known');
ok((($iana->service('daytime'))[0])->range, 'Well known');
ok((($iana->service('daytime'))[1])->range, 'Well known');
ok((($iana->service('discard'))[0])->range, 'Well known');
ok((($iana->service('discard'))[1])->range, 'Well known');
ok((($iana->service('echo'))[0])->range, 'Well known');
ok((($iana->service('echo'))[1])->range, 'Well known');
ok((($iana->service('ftp-data'))[0])->range, 'Well known');
ok((($iana->service('ftp-data'))[1])->range, 'Well known');
ok((($iana->service('msp'))[0])->range, 'Well known');
ok((($iana->service('msp'))[1])->range, 'Well known');
ok((($iana->service('msp'))[2])->range, 'Registered');
ok((($iana->service('msp'))[3])->range, 'Registered');
ok((($iana->service('qotd'))[0])->range, 'Well known');
ok((($iana->service('qotd'))[1])->range, 'Well known');
ok((($iana->service('rje'))[0])->range, 'Well known');
ok((($iana->service('rje'))[1])->range, 'Well known');
ok((($iana->service('systat'))[0])->range, 'Well known');
ok((($iana->service('systat'))[1])->range, 'Well known');
ok((($iana->service('tcpmux'))[0])->range, 'Well known');
