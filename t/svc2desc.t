#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => 26 };

my $iana = Net::IANA::PortNumbers->new();
ok(ref $iana, 'Net::IANA::PortNumbers');
ok((($iana->service('chargen'))[0])->desc, 'Character Generator');
ok((($iana->service('chargen'))[1])->desc, 'Character Generator');
ok((($iana->service('compressnet'))[0])->desc, 'Management Utility');
ok((($iana->service('compressnet'))[1])->desc, 'Management Utility');
ok((($iana->service('compressnet'))[2])->desc, 'Compression Process');
ok((($iana->service('compressnet'))[3])->desc, 'Compression Process');
ok((($iana->service('daytime'))[0])->desc, 'Daytime (RFC 867)');
ok((($iana->service('daytime'))[1])->desc, 'Daytime (RFC 867)');
ok((($iana->service('discard'))[0])->desc, 'Discard');
ok((($iana->service('discard'))[1])->desc, 'Discard');
ok((($iana->service('echo'))[0])->desc, 'Echo');
ok((($iana->service('echo'))[1])->desc, 'Echo');
ok((($iana->service('ftp-data'))[0])->desc, 'File Transfer [Default Data]');
ok((($iana->service('ftp-data'))[1])->desc, 'File Transfer [Default Data]');
ok((($iana->service('msp'))[0])->desc, 'Message Send Protocol');
ok((($iana->service('msp'))[1])->desc, 'Message Send Protocol');
ok((($iana->service('msp'))[2])->desc, 'MSP');
ok((($iana->service('msp'))[3])->desc, 'MSP');
ok((($iana->service('qotd'))[0])->desc, 'Quote of the Day');
ok((($iana->service('qotd'))[1])->desc, 'Quote of the Day');
ok((($iana->service('rje'))[0])->desc, 'Remote Job Entry');
ok((($iana->service('rje'))[1])->desc, 'Remote Job Entry');
ok((($iana->service('systat'))[0])->desc, 'Active Users');
ok((($iana->service('systat'))[1])->desc, 'Active Users');
ok((($iana->service('tcpmux'))[0])->desc, 'TCP Port Service Multiplexer');
