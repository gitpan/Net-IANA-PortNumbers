#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->service('chargen'))[0])->port, 19);
ok((($iana->service('chargen'))[1])->port, 19);
ok((($iana->service('compressnet'))[0])->port, 2);
ok((($iana->service('compressnet'))[1])->port, 2);
ok((($iana->service('compressnet'))[2])->port, 3);
ok((($iana->service('compressnet'))[3])->port, 3);
ok((($iana->service('daytime'))[0])->port, 13);
ok((($iana->service('daytime'))[1])->port, 13);
ok((($iana->service('discard'))[0])->port, 9);
ok((($iana->service('discard'))[1])->port, 9);
ok((($iana->service('echo'))[0])->port, 7);
ok((($iana->service('echo'))[1])->port, 7);
ok((($iana->service('ftp-data'))[0])->port, 20);
ok((($iana->service('ftp-data'))[1])->port, 20);
ok((($iana->service('msp'))[0])->port, 18);
ok((($iana->service('msp'))[1])->port, 18);
ok((($iana->service('msp'))[2])->port, 2438);
ok((($iana->service('msp'))[3])->port, 2438);
ok((($iana->service('qotd'))[0])->port, 17);
ok((($iana->service('qotd'))[1])->port, 17);
ok((($iana->service('rje'))[0])->port, 5);
ok((($iana->service('rje'))[1])->port, 5);
ok((($iana->service('systat'))[0])->port, 11);
ok((($iana->service('systat'))[1])->port, 11);
ok((($iana->service('tcpmux'))[0])->port, 1);
