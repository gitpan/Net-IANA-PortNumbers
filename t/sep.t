#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::Registry;

BEGIN { plan tests => 2 };

my $registry = Net::IANA::Registry->new();
ok(ref $registry, 'Net::IANA::Registry');
ok(length($registry->sep) == 1);
