# $Id: PortNumber.pm,v 1.7 2003/07/07 04:42:19 afoxson Exp $
# $Revision: 1.7 $

# Net::IANA::PortNumber - object-based representation of a specific port
# Copyright (c) 2003 Adam J. Foxson <afoxson@pobox.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

package Net::IANA::PortNumber;

use strict;
use vars qw($VERSION $AUTOLOAD);
use Carp;

($VERSION) = '$Revision: 1.7 $' =~ /\s+(\d+\.\d+)\s+/;

local $^W;

sub new {
	croak __PACKAGE__ .
		"->new(): This class provides no 'new' constructor. You probably " .
		"meant to do Net::IANA::PortNumbers->new() instead of " .
		"Net::IANA::PortNumber->new()";
}

sub create {
	my $type = shift;
	my $class = ref($type) || $type;
	my %defaults = (
		svc => undef,
		port => undef,
		proto => undef,
		desc => undef,
	);

	croak __PACKAGE__ . "->create(): This method requires an even number of " .
		"arguments" if scalar @_ % 2 != 0;

	my $self = {@_};

	for my $param (keys %{$self}) {
		croak __PACKAGE__ . "->create(): '$param' is an unrecognized argument"
			if not exists $defaults{$param}
	}

	for my $param (keys %defaults) {   
		$self->{$param} = $defaults{$param} if not exists $self->{$param};
	}

	for my $param (qw(svc port desc)) {
		croak __PACKAGE__ . "->create(): '$param' must be specified" if not
			defined $self->{$param};
	}

	croak __PACKAGE__ . "->create(): 'port' must be integral" if
		$self->{port} !~ /^\d+$/;

	for my $param (keys %{$self}) {
		$self->{$param} = '' unless defined $self->{$param};
	}

	return bless $self, $class;
}

sub range {
	my $self = shift;
	my $port = $self->port();

	if ($port >=0 and $port <= 1023) {
		return "Well known";
	}
	elsif ($port >= 1024 and $port <= 49151) {
		return "Registered";
	}
	elsif ($port >= 49152 and $port <= 65535) {
		return "Dynamic and/or Private";
	}
	else {
		return "Out of range";
	}
}

*service = *svc{CODE};
sub svc {shift->{svc}}

sub port {shift->{port}}

*protocol = *proto{CODE};
sub proto {shift->{proto}}

*description = *desc{CODE};
sub desc {shift->{desc}}

sub AUTOLOAD {
	my ($method) = $AUTOLOAD =~ /.+::(.+)/;
	return if $method =~ /DESTROY$/;
	croak __PACKAGE__ . " does not provide a '$method' object method";
}

1;

__END__

=pod

=head1 NAME

Net::IANA::PortNumber - object-based representation of a specific port

=head1 SYNOPSIS

  use Net::IANA::PortNumber;

  my $port =
    Net::IANA::PortNumber->create
    (
      svc => 'ssh',
      port => 22,
      proto => 'tcp',
      desc => 'SSH Remote Login Protocol',
    );

  print $port->svc, "\n";   # ssh
  print $port->port, "\n";  # 22
  print $port->proto, "\n"; # tcp
  print $port->desc, "\n";  # SSH Remote Login Protocol
  print $port->range, "\n"; # Well known

=head1 DESCRIPTION

Net::IANA::PortNumber is a helper class for Net::IANA::PortNumbers, that
creates objects representing one specific port.

=head1 METHODS

=over 4

=item * B<create>

Constructor. Takes four arguments: svc, port, proto and desc. Returns a port
object. All arguments are mandatory except proto.

=item * B<svc>

Returns the port's service identifier, i.e., 'ssh'.

=item * B<port>

Returns the port's port, i.e., 22.

=item * B<proto>

Returns the port's protocol, i.e., 'tcp'.

=item * B<desc>

Returns the port's description, i.e., 'SSH Remote Login Protocol'.

=item * B<range>

Returns the port's range, i.e., one of: Well known, Registered, Dynamic and/or
private, or Out of range.

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

Adam J. Foxson E<lt>F<afoxson@pobox.com>E<gt>.

=cut
