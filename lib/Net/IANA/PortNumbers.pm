# $Id: PortNumbers.pm,v 1.16 2003/07/10 05:11:22 afoxson Exp $
# $Revision: 1.16 $

# Net::IANA::PortNumbers - translate ports to services and vice versa
# Copyright (c) 2003 Adam J. Foxson <afoxson@pobox.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

package Net::IANA::PortNumbers;

use strict;
use vars qw($VERSION $AUTOLOAD);
use Carp;

($VERSION) = '$Revision: 1.16 $' =~ /\s+(\d+\.\d+)\s+/;

local $^W;

sub new {
	my $type = shift;
	my $registry = shift;
	my $class = ref($type) || $type;
	my $self = {
		ports => [],
	};

	bless $self, $class;

	unless (defined $registry) {
		require Net::IANA::Registry;
		$registry = Net::IANA::Registry->new();
	}

	if (ref $registry and $registry->can('load')) {
		my $reg = $registry->load();

		if (defined $reg and ref $reg eq 'ARRAY') {
			$self->{ports} = $reg;
		}
		else {
			croak __PACKAGE__ . "->new(): " .
				"Received an invalid registry object";
		}
	}
	else {
		croak __PACKAGE__ . "->new(): " .
			"Expects either no argument or a registry object";
	}

	return $self;
}

*service = *svc{CODE};
sub svc {
	my ($self, $svc, $proto) = @_;
	my @services;

	croak __PACKAGE__ . "->svc(): Requires a service as an argument" if
		not defined $svc;

	$svc = lc $svc;
	$proto = lc $proto if defined $proto;

	if (not defined $proto) {
		for my $svcobj (@{$self->{ports}}) {
			push @services, $svcobj if $svcobj->svc() eq $svc;
		}
	}
	else {
		for my $svcobj (@{$self->{ports}}) {
			push @services, $svcobj if $svcobj->svc() eq $svc and
				$svcobj->proto() eq $proto;
		}
	}

	return @services;
}

sub port {
	my ($self, $port, $proto) = @_;
	my @ports;

	croak __PACKAGE__ . "->port(): Requires a numeric port as an argument" if
		not defined $port or $port !~ /^\d+$/;

	$proto = lc $proto if defined $proto;

	if (not defined $proto) {
		for my $portobj (@{$self->{ports}}) {
			my $FOO = $portobj->port();
			push @ports, $portobj if $portobj->port() == $port;
		}
	}
	else {
		for my $portobj (@{$self->{ports}}) {
			push @ports, $portobj if $portobj->port() == $port and
				$portobj->proto() eq $proto;
		}
	}

	return @ports;
}

sub AUTOLOAD {
	my ($method) = $AUTOLOAD =~ /.+::(.+)/;
	return if $method =~ /DESTROY$/;
	croak __PACKAGE__ . " does not provide a '$method' object method";
}

1;

__END__

=pod

=head1 NAME

Net::IANA::PortNumbers - translate ports to services and vice versa

=head1 SYNOPSIS

  use Net::IANA::PortNumbers;

  my $iana = Net::IANA::PortNumbers->new(); # or: ->new(MyRegistry->new());

  ($iana->port(22, 'tcp'))[0]->svc; # returns 'ssh'
  ($iana->port(22, 'tcp'))[0]->port; # returns 22
  ($iana->port(22, 'tcp'))[0]->desc; # returns 'SSH Remote Login Protocol'
  ($iana->port(22, 'tcp'))[0]->proto; # returns 'tcp'
  ($iana->port(22, 'tcp'))[0]->range; # returns 'Well known'

  ($iana->svc('ssh', 'tcp'))[0]->svc; # returns 'ssh'
  ($iana->svc('ssh', 'tcp'))[0]->port; # returns 22
  ($iana->svc('ssh', 'tcp'))[0]->desc; # returns 'SSH Remote Login Protocol'
  ($iana->svc('ssh', 'tcp'))[0]->proto; # returns 'tcp'
  ($iana->svc('ssh', 'tcp'))[0]->range; # returns 'Well known'

  # prints: ident auth
  for my $port ($iana->port(113, 'tcp')) {
      print $port->svc(), " ";
  }

  # prints: 6000 6001 6002 6003 6004 6005 6006 6007 6008 6009 6010 6011 6012
  # 6013 6014 6015 6016 6017 6018 6019 6020 6021 6022 6023 6024 6025 6026
  # 6027 6028 6029 6030 6031 6032 6033 6034 6035 6036 6037 6038 6039 6040
  # 6041 6042 6043 6044 6045 6046 6047 6048 6049 6050 6051 6052 6053 6054
  # 6055 6056 6057 6058 6059 6060 6061
  for my $service ($iana->svc('x11', 'tcp')) {
      print $service->port(), " ";
  }

  # prints: ISO Transport Class 2 Non-Control over TCP, ISO Transport Class
  # 2 Non-Control over UDP
  print join ', ', map {$_->desc} $iana->port(399);

  # prints: Management Utility, Compression Process
  print join ', ', map {$_->desc} $iana->svc('compressnet', 'udp');

=head1 DESCRIPTION

Net::IANA::PortNumbers translates port numbers and services to ports, services,
descriptions, protocols, and ranges.

=head1 METHODS

=over 4

=item * B<new>

This constructor returns a Net::IANA::PortNumbers object. It accepts an
optional parameter of a registry object, otherwise it defaults to using
Net::IANA::Registry.

=item * B<svc>

Takes one mandatory argument of a service, i.e., 'ssh', and one optional
argument of a protocol, i.e., 'tcp'. It will returns a list of port objects
that match.

=item * B<port>

Takes one mandatory argument of a port, i.e., 22, and one optional argument of
a protocol, i.e., 'tcp'. It will returns a list of port objects that match.

=back

=head1 COPYRIGHT

Copyright (c) 2003 Adam J. Foxson. All rights reserved.

=head1 LICENSE

See COPYING

=head1 SEE ALSO

=over 4

=item * L<perl>

=item * L<Net::servent>

=back

=head1 AUTHOR

Adam J. Foxson E<lt>F<afoxson@pobox.com>E<gt>, with special thanks to Kurt
Starsinic E<lt>F<kstar@cpan.org>E<gt> for many suggestions.

=cut
