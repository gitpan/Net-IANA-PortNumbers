#!/usr/bin/perl -w

# $Id: mktests.pl,v 1.3 2003/07/06 12:22:11 afoxson Exp $
# $Revision: 1.3 $

# mktests.pl - programatically generate test suite for Net::IANA::PortNumbers
# Copyright (c) 2003 Adam J. Foxson <afoxson@pobox.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

use strict;
use blib;
use Net::IANA::PortNumbers;

my %services;
my $limit = shift or die "Usage: $0 [tests per file]\n";
my $iana = Net::IANA::PortNumbers->new();
my $PREAMBLE = <<"PREAMBLE";
#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumbers;

BEGIN { plan tests => ${\($limit + 1)} };

my \$iana = Net::IANA::PortNumbers->new();
ok(ref \$iana, 'Net::IANA::PortNumbers');
PREAMBLE

open_files();
write_preambles();
port2();
svc2();
close_files();

sub open_files {
	open PORT2DESC, ">../t/port2desc.t" or die $!;
	open PORT2PORT, ">../t/port2port.t" or die $!;
	open PORT2PROTO, ">../t/port2proto.t" or die $!;
	open PORT2RANGE, ">../t/port2range.t" or die $!;
	open PORT2SVC, ">../t/port2svc.t" or die $!;
	open SVC2DESC, ">../t/svc2desc.t" or die $!;
	open SVC2PORT, ">../t/svc2port.t" or die $!;
	open SVC2PROTO, ">../t/svc2proto.t" or die $!;
	open SVC2RANGE, ">../t/svc2range.t" or die $!;
	open SVC2SVC, ">../t/svc2svc.t" or die $!;
}

sub write_preambles {
	for my $fh (*PORT2DESC, *PORT2PORT, *PORT2PROTO, *PORT2RANGE, *PORT2SVC,
		*SVC2DESC, *SVC2PORT, *SVC2PROTO, *SVC2RANGE, *SVC2SVC) {
		print $fh $PREAMBLE;
	}
}

sub port2 { 
	my $cnt = 0;
	PORT: for my $port (0..65535) {
		my $count = 0;
		for my $port ($iana->port($port)) {
			my ($svc, $range, $proto, $port, $desc) = ($port->svc, $port->range,
				$port->proto, $port->port, $port->desc);
			$services{$svc}++;
			print PORT2DESC "ok(((\$iana->port($port))[$count])->desc, '$desc');\n";
			print PORT2PORT "ok(((\$iana->port($port))[$count])->port, $port);\n";
			print PORT2PROTO "ok(((\$iana->port($port))[$count])->proto, '$proto');\n";
			print PORT2RANGE "ok(((\$iana->port($port))[$count])->range, '$range');\n";
			print PORT2SVC "ok(((\$iana->port($port))[$count])->svc, '$svc');\n";
			$count++;
			$cnt++;
			last PORT if $cnt == $limit;
		}
	}
}

sub svc2 {
	my $cnt = 0;
	SVC: for my $svc (sort keys %services) {
		my $count = 0;
		for my $svc ($iana->service($svc)) {
			my ($svc, $range, $proto, $port, $desc) = ($svc->svc, $svc->range,
				$svc->proto, $svc->port, $svc->desc);
			print SVC2DESC "ok(((\$iana->service('$svc'))[$count])->desc, '$desc');\n";
			print SVC2PORT "ok(((\$iana->service('$svc'))[$count])->port, $port);\n";
			print SVC2PROTO "ok(((\$iana->service('$svc'))[$count])->proto, '$proto');\n";
			print SVC2RANGE "ok(((\$iana->service('$svc'))[$count])->range, '$range');\n";
			print SVC2SVC "ok(((\$iana->service('$svc'))[$count])->svc, '$svc');\n";
			$count++;
			$cnt++;
			last SVC if $cnt == $limit;
		}
	}
}

sub close_files {
	close SVC2SVC or die $!;
	close SVC2RANGE or die $!;
	close SVC2PROTO or die $!;
	close SVC2PORT or die $!;
	close SVC2DESC or die $!;
	close PORT2SVC or die $!;
	close PORT2RANGE or die $!;
	close PORT2PROTO or die $!;
	close PORT2PORT or die $!;
	close PORT2DESC or die $!;
}
