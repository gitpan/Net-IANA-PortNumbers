#!/usr/bin/perl -w

use strict;
use Test;
use Net::IANA::PortNumber;
use Net::IANA::PortNumbers;
use Net::IANA::Registry;

BEGIN { plan tests => 17 };

eval {
	my $pn = Net::IANA::PortNumber->new();
};
ok($@ and $@ =~ /class provides no/);

eval {
	my $pn = Net::IANA::PortNumber->create();
};
ok($@ and $@ =~ /must be specified/);

eval {
	my $pn = Net::IANA::PortNumber->create(5);
};
ok($@ and $@ =~ /requires an even number/);

eval {
	my $pn = Net::IANA::PortNumber->create(foo => 'bar');
};
ok($@ and $@ =~ /is an unrecognized argument/);

eval {
	Net::IANA::PortNumber->wibble(foo => 'bar');
};
ok($@ and $@ =~ /does not provide a/);

eval {
	my $pn = Net::IANA::PortNumber->create(svc => 'ssh', desc => 'ssh',
		port => 'bar');
};
ok($@ and $@ =~ /must be integral/);

my $pn = Net::IANA::PortNumber->create(svc => 'ssh', desc => 'ssh',
	proto => 'tcp', port => 22);
ok(ref $pn, 'Net::IANA::PortNumber');

my $pns = Net::IANA::PortNumbers->new();
ok(ref $pns, 'Net::IANA::PortNumbers');

eval {
	$pns = Net::IANA::PortNumbers->new(5);
};
ok($@ and $@ =~ /Expects either no argument or a registry object/);

eval {
	$pns = Net::IANA::PortNumbers->new(Foo->new);
};
ok($@ and $@ =~ /Received an invalid registry object/);

eval {
	$pns->svc();
};
ok($@ and $@ =~ /Requires a service as an argument/);

eval {
	$pns->port();
};
ok($@ and $@ =~ /Requires a numeric port as an argument/);

eval {
	$pns->port('foo');
};
ok($@ and $@ =~ /Requires a numeric port as an argument/);

eval {
	Net::IANA::PortNumbers->wibble(foo => 'bar');
};
ok($@ and $@ =~ /does not provide a/);

my $registry = Net::IANA::Registry->new();
ok(ref $registry, 'Net::IANA::Registry');

eval {
	$registry->generate_new_registry_module();
};
ok($@ and $@ =~ /Requires a package name/);

eval {
	Net::IANA::Registry->wibble(foo => 'bar');
};
ok($@ and $@ =~ /does not provide a/);

# -----

package Foo;

sub new {
	return bless {}, 'Foo';
}

sub load {
	return 5;
}
