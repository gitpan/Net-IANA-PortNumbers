# $Id: PortNumber.pm,v 1.1 2003/06/07 06:54:36 afoxson Exp $
# $Revision: 1.1 $

# Net::IANA::PortNumber - helper class for Net::IANA::PortNumber
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
use vars qw($VERSION);
use Carp;

($VERSION) = '$Revision: 1.1 $' =~ /\s+(\d+\.\d+)\s+/;

local $^W;

sub new {
	croak "\nNet::IANA::PortNumber is a helper class. " .
			"Use Net::IANA::PortNumbers instead.\n" .
			"See 'perldoc Net::IANA::PortNumbers' for details.\n\n" if
				caller ne 'Net::IANA::PortNumbers';

	my ($type, $svc, $port, $proto, $desc) = @_;
	my $class = ref($type) || $type;
	my $self  = {
		svc   => $svc,
		port  => $port,
		proto => $proto,
		desc  => $desc,
	};

	return bless $self, $class;
}

sub svc {shift->{svc}}
sub port {shift->{port}}
sub proto {shift->{proto}}
sub desc {shift->{desc}}

1;

__END__

=pod

=head1 NAME

Net::IANA::PortNumber - helper class for Net::IANA::PortNumbers

=head1 SYNOPSIS

  use Net::IANA::PortNumber;

  my $port =
    Net::IANA::PortNumber->new('ssh', 22, 'tcp', 'SSH Remote Login Protocol');

  print $port->svc, "\n";   # ssh
  print $port->port, "\n";  # 22
  print $port->proto, "\n"; # tcp
  print $port->desc, "\n";  # SSH Remote Login Protocol

=head1 DESCRIPTION

Net::IANA::PortNumber is a helper class for Net::IANA::PortNumbers, and is not
intended or available for public use.

=head1 COPYRIGHT

Copyright (c) 2003 Adam J. Foxson. All rights reserved.

=head1 LICENSE

See COPYING

=head1 AUTHOR

Adam J. Foxson

=cut
