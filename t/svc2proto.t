#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->service('chargen'))[0])->proto, 'tcp');
ok((($iana->service('chargen'))[1])->proto, 'udp');
ok((($iana->service('compressnet'))[0])->proto, 'tcp');
ok((($iana->service('compressnet'))[1])->proto, 'udp');
ok((($iana->service('compressnet'))[2])->proto, 'tcp');
ok((($iana->service('compressnet'))[3])->proto, 'udp');
ok((($iana->service('daytime'))[0])->proto, 'tcp');
ok((($iana->service('daytime'))[1])->proto, 'udp');
ok((($iana->service('discard'))[0])->proto, 'tcp');
ok((($iana->service('discard'))[1])->proto, 'udp');
ok((($iana->service('echo'))[0])->proto, 'tcp');
ok((($iana->service('echo'))[1])->proto, 'udp');
ok((($iana->service('ftp-data'))[0])->proto, 'tcp');
ok((($iana->service('ftp-data'))[1])->proto, 'udp');
ok((($iana->service('msp'))[0])->proto, 'tcp');
ok((($iana->service('msp'))[1])->proto, 'udp');
ok((($iana->service('msp'))[2])->proto, 'tcp');
ok((($iana->service('msp'))[3])->proto, 'udp');
ok((($iana->service('qotd'))[0])->proto, 'tcp');
ok((($iana->service('qotd'))[1])->proto, 'udp');
ok((($iana->service('rje'))[0])->proto, 'tcp');
ok((($iana->service('rje'))[1])->proto, 'udp');
ok((($iana->service('systat'))[0])->proto, 'tcp');
ok((($iana->service('systat'))[1])->proto, 'udp');
ok((($iana->service('tcpmux'))[0])->proto, 'tcp');
