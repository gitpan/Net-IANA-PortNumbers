#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::Registry;
use Net::IANA::PortNumber;

BEGIN { plan tests => 2 };

my $registry = Net::IANA::Registry->new();
ok(ref $registry, 'Net::IANA::Registry');
ok(scalar @{$registry->load}, 8432);
