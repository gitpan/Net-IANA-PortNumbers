# $Id: PortNumbers.pm,v 1.6 2003/06/07 06:54:36 afoxson Exp $
# $Revision: 1.6 $

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
use vars qw($VERSION);
use Net::IANA::PortNumber;

($VERSION) = '$Revision: 1.6 $' =~ /\s+(\d+\.\d+)\s+/;

local $^W;

sub new {
	my $type  = shift;
	my $class = ref($type) || $type;
	my $self  = {
		ports        => [],
		last_updated => '2003-05-20',
	};

	bless $self, $class;
	$self->_init_db();
	return $self;
}

sub _init_db {
	my $self = shift;

	while (<DATA>) {
		chomp;

		if (/^([^\|]+)\|([^\|]+)\|([^\|]+)\|([^\|]+)$/) {
			my ($svc, $port, $proto, $desc) = ($1, $2, $3, $4);
			push @{$self->{ports}},
				Net::IANA::PortNumber->new($svc, $port, $proto, $desc);
		}
	}
}

sub last_updated {
	my $self = shift;
	return $self->{last_updated};
}

*svc2ports = *svc2port{CODE};
sub svc2port {
	my ($self, $svc, $proto) = @_;
	my @ports = ();

	$svc   = lc $svc;
	$proto = lc $proto;

	for my $port (@{$self->{ports}}) {
		push @ports,  $port->port() if
			$port->svc eq $svc and $port->proto eq $proto;
	}

	return \@ports;
}

sub svc2desc {
	my ($self, $svc, $proto) = @_;

	$svc   = lc $svc;
	$proto = lc $proto;

	for my $port (@{$self->{ports}}) {
		return $port->desc() if $port->svc eq $svc and $port->proto eq $proto;
	}

	return undef;
}

sub port2svc {
	my ($self, $prt, $proto) = @_;

	$proto = lc $proto;

	for my $port (@{$self->{ports}}) {
		return $port->svc() if $port->port == $prt and $port->proto eq $proto;
	}

	return undef;
}

sub port2desc {
	my ($self, $prt, $proto) = @_;

	$proto = lc $proto;

	for my $port (@{$self->{ports}}) {
		return $port->desc() if $port->port == $prt and $port->proto eq $proto;
	}

	return undef;
}

# this subroutine generates the data (to STDOUT) that appears in __DATA__
sub _create_db {
	my ($self, $input_file) = @_;

	open PORTS, $input_file or die $!;
	while (<PORTS>) {
		chomp;

		next if /^#/;

		# tcpmux 1/tcp TCP Port Service Multiplexer
		if (/^([^\s]+)\s+(\d+)\/([^\s]+)(:?\s+(.*))?\s+?$/) {
			my ($svc, $port, $proto, $desc) = ($1, $2, $3, $5);
			$desc = $svc if not $desc;
			$desc =~ s/\s+$//g;

			print "$svc|$port|$proto|$desc\n";
		}
		# x11 6000-6063/tcp X Window System
		elsif (/^([^\s]+)\s+(\d+-\d+)\/([^\s]+)(:?\s+(.*))?$/) {
			my ($svc, $port, $proto, $desc) = ($1, $2, $3, $5);
			$desc = $svc if not $desc;
			$desc =~ s/\s+$//g;

			my ($start_port, $end_port) = split /-/, $port;

			for my $port ($start_port .. $end_port) {
				print "$svc|$port|$proto|$desc\n";
			}
		}
		# 0/tcp Reserved
		elsif (/^\s+(\d+)\/([^\s]+)(:?\s+(.*))?\s+?$/) {
			my ($port, $proto, $desc) = ($1, $2, $4);
			my $svc = "unnamed-port-$port-service";
			$desc = $svc if not $desc;
			$desc =~ s/\s+$//g;

			print "$svc|$port|$proto|$desc\n";
		}
	}
	close PORTS or die $!;
}

1;

__DATA__
unnamed-port-0-service|0|tcp|Reserved
unnamed-port-0-service|0|udp|Reserved
tcpmux|1|tcp|TCP Port Service Multiplexer
tcpmux|1|udp|TCP Port Service Multiplexer
compressnet|2|tcp|Management Utility
compressnet|2|udp|Management Utility
compressnet|3|tcp|Compression Process
compressnet|3|udp|Compression Process
rje|5|tcp|Remote Job Entry
rje|5|udp|Remote Job Entry
echo|7|tcp|Echo
echo|7|udp|Echo
discard|9|tcp|Discard
discard|9|udp|Discard
systat|11|tcp|Active Users
systat|11|udp|Active Users
daytime|13|tcp|Daytime (RFC 867)
daytime|13|udp|Daytime (RFC 867)
qotd|17|tcp|Quote of the Day
qotd|17|udp|Quote of the Day
msp|18|tcp|Message Send Protocol
msp|18|udp|Message Send Protocol
chargen|19|tcp|Character Generator
chargen|19|udp|Character Generator
ftp-data|20|tcp|File Transfer [Default Data]
ftp-data|20|udp|File Transfer [Default Data]
ftp|21|tcp|File Transfer [Control]
ftp|21|udp|File Transfer [Control]
ssh|22|tcp|SSH Remote Login Protocol
ssh|22|udp|SSH Remote Login Protocol
telnet|23|tcp|Telnet
telnet|23|udp|Telnet
unnamed-port-24-service|24|tcp|any private mail system
unnamed-port-24-service|24|udp|any private mail system
smtp|25|tcp|Simple Mail Transfer
smtp|25|udp|Simple Mail Transfer
nsw-fe|27|tcp|NSW User System FE
nsw-fe|27|udp|NSW User System FE
msg-icp|29|tcp|MSG ICP
msg-icp|29|udp|MSG ICP
msg-auth|31|tcp|MSG Authentication
msg-auth|31|udp|MSG Authentication
dsp|33|tcp|Display Support Protocol
dsp|33|udp|Display Support Protocol
unnamed-port-35-service|35|tcp|any private printer server
unnamed-port-35-service|35|udp|any private printer server
time|37|tcp|Time
time|37|udp|Time
rap|38|tcp|Route Access Protocol
rap|38|udp|Route Access Protocol
rlp|39|tcp|Resource Location Protocol
rlp|39|udp|Resource Location Protocol
graphics|41|tcp|Graphics
graphics|41|udp|Graphics
name|42|tcp|Host Name Server
name|42|udp|Host Name Server
nameserver|42|tcp|Host Name Server
nameserver|42|udp|Host Name Server
nicname|43|tcp|Who Is
nicname|43|udp|Who Is
mpm-flags|44|tcp|MPM FLAGS Protocol
mpm-flags|44|udp|MPM FLAGS Protocol
mpm|45|tcp|Message Processing Module [recv]
mpm|45|udp|Message Processing Module [recv]
mpm-snd|46|tcp|MPM [default send]
mpm-snd|46|udp|MPM [default send]
ni-ftp|47|tcp|NI FTP
ni-ftp|47|udp|NI FTP
auditd|48|tcp|Digital Audit Daemon
auditd|48|udp|Digital Audit Daemon
tacacs|49|tcp|Login Host Protocol (TACACS)
tacacs|49|udp|Login Host Protocol (TACACS)
re-mail-ck|50|tcp|Remote Mail Checking Protocol
re-mail-ck|50|udp|Remote Mail Checking Protocol
la-maint|51|tcp|IMP Logical Address Maintenance
la-maint|51|udp|IMP Logical Address Maintenance
xns-time|52|tcp|XNS Time Protocol
xns-time|52|udp|XNS Time Protocol
domain|53|tcp|Domain Name Server
domain|53|udp|Domain Name Server
xns-ch|54|tcp|XNS Clearinghouse
xns-ch|54|udp|XNS Clearinghouse
isi-gl|55|tcp|ISI Graphics Language
isi-gl|55|udp|ISI Graphics Language
xns-auth|56|tcp|XNS Authentication
xns-auth|56|udp|XNS Authentication
unnamed-port-57-service|57|tcp|any private terminal access
unnamed-port-57-service|57|udp|any private terminal access
xns-mail|58|tcp|XNS Mail
xns-mail|58|udp|XNS Mail
unnamed-port-59-service|59|tcp|any private file service
unnamed-port-59-service|59|udp|any private file service
unnamed-port-60-service|60|tcp|Unassigned
unnamed-port-60-service|60|udp|Unassigned
ni-mail|61|tcp|NI MAIL
ni-mail|61|udp|NI MAIL
acas|62|tcp|ACA Services
acas|62|udp|ACA Services
whois++|63|tcp|whois++
whois++|63|udp|whois++
covia|64|tcp|Communications Integrator (CI)
covia|64|udp|Communications Integrator (CI)
tacacs-ds|65|tcp|TACACS-Database Service
tacacs-ds|65|udp|TACACS-Database Service
sql*net|66|tcp|Oracle SQL*NET
sql*net|66|udp|Oracle SQL*NET
bootps|67|tcp|Bootstrap Protocol Server
bootps|67|udp|Bootstrap Protocol Server
bootpc|68|tcp|Bootstrap Protocol Client
bootpc|68|udp|Bootstrap Protocol Client
tftp|69|tcp|Trivial File Transfer
tftp|69|udp|Trivial File Transfer
gopher|70|tcp|Gopher
gopher|70|udp|Gopher
netrjs-1|71|tcp|Remote Job Service
netrjs-1|71|udp|Remote Job Service
netrjs-2|72|tcp|Remote Job Service
netrjs-2|72|udp|Remote Job Service
netrjs-3|73|tcp|Remote Job Service
netrjs-3|73|udp|Remote Job Service
netrjs-4|74|tcp|Remote Job Service
netrjs-4|74|udp|Remote Job Service
unnamed-port-75-service|75|tcp|any private dial out service
unnamed-port-75-service|75|udp|any private dial out service
deos|76|tcp|Distributed External Object Store
deos|76|udp|Distributed External Object Store
unnamed-port-77-service|77|tcp|any private RJE service
unnamed-port-77-service|77|udp|any private RJE service
vettcp|78|tcp|vettcp
vettcp|78|udp|vettcp
finger|79|tcp|Finger
finger|79|udp|Finger
http|80|tcp|World Wide Web HTTP
http|80|udp|World Wide Web HTTP
www|80|tcp|World Wide Web HTTP
www|80|udp|World Wide Web HTTP
www-http|80|tcp|World Wide Web HTTP
www-http|80|udp|World Wide Web HTTP
hosts2-ns|81|tcp|HOSTS2 Name Server
hosts2-ns|81|udp|HOSTS2 Name Server
xfer|82|tcp|XFER Utility
xfer|82|udp|XFER Utility
mit-ml-dev|83|tcp|MIT ML Device
mit-ml-dev|83|udp|MIT ML Device
ctf|84|tcp|Common Trace Facility
ctf|84|udp|Common Trace Facility
mit-ml-dev|85|tcp|MIT ML Device
mit-ml-dev|85|udp|MIT ML Device
mfcobol|86|tcp|Micro Focus Cobol
mfcobol|86|udp|Micro Focus Cobol
unnamed-port-87-service|87|tcp|any private terminal link
unnamed-port-87-service|87|udp|any private terminal link
kerberos|88|tcp|Kerberos
kerberos|88|udp|Kerberos
su-mit-tg|89|tcp|SU/MIT Telnet Gateway
su-mit-tg|89|udp|SU/MIT Telnet Gateway
dnsix|90|tcp|DNSIX Securit Attribute Token Map
dnsix|90|udp|DNSIX Securit Attribute Token Map
mit-dov|91|tcp|MIT Dover Spooler
mit-dov|91|udp|MIT Dover Spooler
npp|92|tcp|Network Printing Protocol
npp|92|udp|Network Printing Protocol
dcp|93|tcp|Device Control Protocol
dcp|93|udp|Device Control Protocol
objcall|94|tcp|Tivoli Object Dispatcher
objcall|94|udp|Tivoli Object Dispatcher
supdup|95|tcp|SUPDUP
supdup|95|udp|SUPDUP
dixie|96|tcp|DIXIE Protocol Specification
dixie|96|udp|DIXIE Protocol Specification
swift-rvf|97|tcp|Swift Remote Virtural File Protocol
swift-rvf|97|udp|Swift Remote Virtural File Protocol
tacnews|98|tcp|TAC News
tacnews|98|udp|TAC News
metagram|99|tcp|Metagram Relay
metagram|99|udp|Metagram Relay
newacct|100|tcp|[unauthorized use]
hostname|101|tcp|NIC Host Name Server
hostname|101|udp|NIC Host Name Server
iso-tsap|102|tcp|ISO-TSAP Class 0
iso-tsap|102|udp|ISO-TSAP Class 0
gppitnp|103|tcp|Genesis Point-to-Point Trans Net
gppitnp|103|udp|Genesis Point-to-Point Trans Net
acr-nema|104|tcp|ACR-NEMA Digital Imag. & Comm. 300
acr-nema|104|udp|ACR-NEMA Digital Imag. & Comm. 300
cso|105|tcp|CCSO name server protocol
cso|105|udp|CCSO name server protocol
csnet-ns|105|tcp|Mailbox Name Nameserver
csnet-ns|105|udp|Mailbox Name Nameserver
3com-tsmux|106|tcp|3COM-TSMUX
3com-tsmux|106|udp|3COM-TSMUX
rtelnet|107|tcp|Remote Telnet Service
rtelnet|107|udp|Remote Telnet Service
snagas|108|tcp|SNA Gateway Access Server
snagas|108|udp|SNA Gateway Access Server
pop2|109|tcp|Post Office Protocol - Version 2
pop2|109|udp|Post Office Protocol - Version 2
pop3|110|tcp|Post Office Protocol - Version 3
pop3|110|udp|Post Office Protocol - Version 3
sunrpc|111|tcp|SUN Remote Procedure Call
sunrpc|111|udp|SUN Remote Procedure Call
mcidas|112|tcp|McIDAS Data Transmission Protocol
mcidas|112|udp|McIDAS Data Transmission Protocol
ident|113|tcp|ident
auth|113|tcp|Authentication Service
auth|113|udp|Authentication Service
audionews|114|tcp|Audio News Multicast
audionews|114|udp|Audio News Multicast
sftp|115|tcp|Simple File Transfer Protocol
sftp|115|udp|Simple File Transfer Protocol
ansanotify|116|tcp|ANSA REX Notify
ansanotify|116|udp|ANSA REX Notify
uucp-path|117|tcp|UUCP Path Service
uucp-path|117|udp|UUCP Path Service
sqlserv|118|tcp|SQL Services
sqlserv|118|udp|SQL Services
nntp|119|tcp|Network News Transfer Protocol
nntp|119|udp|Network News Transfer Protocol
cfdptkt|120|tcp|CFDPTKT
cfdptkt|120|udp|CFDPTKT
erpc|121|tcp|Encore Expedited Remote Pro.Call
erpc|121|udp|Encore Expedited Remote Pro.Call
smakynet|122|tcp|SMAKYNET
smakynet|122|udp|SMAKYNET
ntp|123|tcp|Network Time Protocol
ntp|123|udp|Network Time Protocol
ansatrader|124|tcp|ANSA REX Trader
ansatrader|124|udp|ANSA REX Trader
locus-map|125|tcp|Locus PC-Interface Net Map Ser
locus-map|125|udp|Locus PC-Interface Net Map Ser
nxedit|126|tcp|NXEdit
nxedit|126|udp|NXEdit
locus-con|127|tcp|Locus PC-Interface Conn Server
locus-con|127|udp|Locus PC-Interface Conn Server
gss-xlicen|128|tcp|GSS X License Verification
gss-xlicen|128|udp|GSS X License Verification
pwdgen|129|tcp|Password Generator Protocol
pwdgen|129|udp|Password Generator Protocol
cisco-fna|130|tcp|cisco FNATIVE
cisco-fna|130|udp|cisco FNATIVE
cisco-tna|131|tcp|cisco TNATIVE
cisco-tna|131|udp|cisco TNATIVE
cisco-sys|132|tcp|cisco SYSMAINT
cisco-sys|132|udp|cisco SYSMAINT
statsrv|133|tcp|Statistics Service
statsrv|133|udp|Statistics Service
ingres-net|134|tcp|INGRES-NET Service
ingres-net|134|udp|INGRES-NET Service
epmap|135|tcp|DCE endpoint resolution
epmap|135|udp|DCE endpoint resolution
profile|136|tcp|PROFILE Naming System
profile|136|udp|PROFILE Naming System
netbios-ns|137|tcp|NETBIOS Name Service
netbios-ns|137|udp|NETBIOS Name Service
netbios-dgm|138|tcp|NETBIOS Datagram Service
netbios-dgm|138|udp|NETBIOS Datagram Service
netbios-ssn|139|tcp|NETBIOS Session Service
netbios-ssn|139|udp|NETBIOS Session Service
emfis-data|140|tcp|EMFIS Data Service
emfis-data|140|udp|EMFIS Data Service
emfis-cntl|141|tcp|EMFIS Control Service
emfis-cntl|141|udp|EMFIS Control Service
bl-idm|142|tcp|Britton-Lee IDM
bl-idm|142|udp|Britton-Lee IDM
imap|143|tcp|Internet Message Access Protocol
imap|143|udp|Internet Message Access Protocol
uma|144|tcp|Universal Management Architecture
uma|144|udp|Universal Management Architecture
uaac|145|tcp|UAAC Protocol
uaac|145|udp|UAAC Protocol
iso-tp0|146|tcp|ISO-IP0
iso-tp0|146|udp|ISO-IP0
iso-ip|147|tcp|ISO-IP
iso-ip|147|udp|ISO-IP
jargon|148|tcp|Jargon
jargon|148|udp|Jargon
aed-512|149|tcp|AED 512 Emulation Service
aed-512|149|udp|AED 512 Emulation Service
sql-net|150|tcp|SQL-NET
sql-net|150|udp|SQL-NET
hems|151|tcp|HEMS
hems|151|udp|HEMS
bftp|152|tcp|Background File Transfer Program
bftp|152|udp|Background File Transfer Program
sgmp|153|tcp|SGMP
sgmp|153|udp|SGMP
netsc-prod|154|tcp|NETSC
netsc-prod|154|udp|NETSC
netsc-dev|155|tcp|NETSC
netsc-dev|155|udp|NETSC
sqlsrv|156|tcp|SQL Service
sqlsrv|156|udp|SQL Service
knet-cmp|157|tcp|KNET/VM Command/Message Protocol
knet-cmp|157|udp|KNET/VM Command/Message Protocol
pcmail-srv|158|tcp|PCMail Server
pcmail-srv|158|udp|PCMail Server
nss-routing|159|tcp|NSS-Routing
nss-routing|159|udp|NSS-Routing
sgmp-traps|160|tcp|SGMP-TRAPS
sgmp-traps|160|udp|SGMP-TRAPS
snmp|161|tcp|SNMP
snmp|161|udp|SNMP
snmptrap|162|tcp|SNMPTRAP
snmptrap|162|udp|SNMPTRAP
cmip-man|163|tcp|CMIP/TCP Manager
cmip-man|163|udp|CMIP/TCP Manager
cmip-agent|164|tcp|CMIP/TCP Agent
cmip-agent|164|udp|CMIP/TCP Agent
xns-courier|165|tcp|Xerox
xns-courier|165|udp|Xerox
s-net|166|tcp|Sirius Systems
s-net|166|udp|Sirius Systems
namp|167|tcp|NAMP
namp|167|udp|NAMP
rsvd|168|tcp|RSVD
rsvd|168|udp|RSVD
send|169|tcp|SEND
send|169|udp|SEND
print-srv|170|tcp|Network PostScript
print-srv|170|udp|Network PostScript
multiplex|171|tcp|Network Innovations Multiplex
multiplex|171|udp|Network Innovations Multiplex
cl/1|172|tcp|Network Innovations CL/1
cl/1|172|udp|Network Innovations CL/1
xyplex-mux|173|tcp|Xyplex
xyplex-mux|173|udp|Xyplex
mailq|174|tcp|MAILQ
mailq|174|udp|MAILQ
vmnet|175|tcp|VMNET
vmnet|175|udp|VMNET
genrad-mux|176|tcp|GENRAD-MUX
genrad-mux|176|udp|GENRAD-MUX
xdmcp|177|tcp|X Display Manager Control Protocol
xdmcp|177|udp|X Display Manager Control Protocol
nextstep|178|tcp|NextStep Window Server
nextstep|178|udp|NextStep Window Server
bgp|179|tcp|Border Gateway Protocol
bgp|179|udp|Border Gateway Protocol
ris|180|tcp|Intergraph
ris|180|udp|Intergraph
unify|181|tcp|Unify
unify|181|udp|Unify
audit|182|tcp|Unisys Audit SITP
audit|182|udp|Unisys Audit SITP
ocbinder|183|tcp|OCBinder
ocbinder|183|udp|OCBinder
ocserver|184|tcp|OCServer
ocserver|184|udp|OCServer
remote-kis|185|tcp|Remote-KIS
remote-kis|185|udp|Remote-KIS
kis|186|tcp|KIS Protocol
kis|186|udp|KIS Protocol
aci|187|tcp|Application Communication Interface
aci|187|udp|Application Communication Interface
mumps|188|tcp|Plus Five's MUMPS
mumps|188|udp|Plus Five's MUMPS
qft|189|tcp|Queued File Transport
qft|189|udp|Queued File Transport
gacp|190|tcp|Gateway Access Control Protocol
gacp|190|udp|Gateway Access Control Protocol
prospero|191|tcp|Prospero Directory Service
prospero|191|udp|Prospero Directory Service
osu-nms|192|tcp|OSU Network Monitoring System
osu-nms|192|udp|OSU Network Monitoring System
srmp|193|tcp|Spider Remote Monitoring Protocol
srmp|193|udp|Spider Remote Monitoring Protocol
irc|194|tcp|Internet Relay Chat Protocol
irc|194|udp|Internet Relay Chat Protocol
dn6-nlm-aud|195|tcp|DNSIX Network Level Module Audit
dn6-nlm-aud|195|udp|DNSIX Network Level Module Audit
dn6-smm-red|196|tcp|DNSIX Session Mgt Module Audit Redir
dn6-smm-red|196|udp|DNSIX Session Mgt Module Audit Redir
dls|197|tcp|Directory Location Service
dls|197|udp|Directory Location Service
dls-mon|198|tcp|Directory Location Service Monitor
dls-mon|198|udp|Directory Location Service Monitor
smux|199|tcp|SMUX
smux|199|udp|SMUX
src|200|tcp|IBM System Resource Controller
src|200|udp|IBM System Resource Controller
at-rtmp|201|tcp|AppleTalk Routing Maintenance
at-rtmp|201|udp|AppleTalk Routing Maintenance
at-nbp|202|tcp|AppleTalk Name Binding
at-nbp|202|udp|AppleTalk Name Binding
at-3|203|tcp|AppleTalk Unused
at-3|203|udp|AppleTalk Unused
at-echo|204|tcp|AppleTalk Echo
at-echo|204|udp|AppleTalk Echo
at-5|205|tcp|AppleTalk Unused
at-5|205|udp|AppleTalk Unused
at-zis|206|tcp|AppleTalk Zone Information
at-zis|206|udp|AppleTalk Zone Information
at-7|207|tcp|AppleTalk Unused
at-7|207|udp|AppleTalk Unused
at-8|208|tcp|AppleTalk Unused
at-8|208|udp|AppleTalk Unused
qmtp|209|tcp|The Quick Mail Transfer Protocol
qmtp|209|udp|The Quick Mail Transfer Protocol
z39.50|210|tcp|ANSI Z39.50
z39.50|210|udp|ANSI Z39.50
914c/g|211|tcp|Texas Instruments 914C/G Terminal
914c/g|211|udp|Texas Instruments 914C/G Terminal
anet|212|tcp|ATEXSSTR
anet|212|udp|ATEXSSTR
ipx|213|tcp|IPX
ipx|213|udp|IPX
vmpwscs|214|tcp|VM PWSCS
vmpwscs|214|udp|VM PWSCS
softpc|215|tcp|Insignia Solutions
softpc|215|udp|Insignia Solutions
CAIlic|216|tcp|Computer Associates Int'l License Server
CAIlic|216|udp|Computer Associates Int'l License Server
dbase|217|tcp|dBASE Unix
dbase|217|udp|dBASE Unix
mpp|218|tcp|Netix Message Posting Protocol
mpp|218|udp|Netix Message Posting Protocol
uarps|219|tcp|Unisys ARPs
uarps|219|udp|Unisys ARPs
imap3|220|tcp|Interactive Mail Access Protocol v3
imap3|220|udp|Interactive Mail Access Protocol v3
fln-spx|221|tcp|Berkeley rlogind with SPX auth
fln-spx|221|udp|Berkeley rlogind with SPX auth
rsh-spx|222|tcp|Berkeley rshd with SPX auth
rsh-spx|222|udp|Berkeley rshd with SPX auth
cdc|223|tcp|Certificate Distribution Center
cdc|223|udp|Certificate Distribution Center
masqdialer|224|tcp|masqdialer
masqdialer|224|udp|masqdialer
direct|242|tcp|Direct
direct|242|udp|Direct
sur-meas|243|tcp|Survey Measurement
sur-meas|243|udp|Survey Measurement
inbusiness|244|tcp|inbusiness
inbusiness|244|udp|inbusiness
link|245|tcp|LINK
link|245|udp|LINK
dsp3270|246|tcp|Display Systems Protocol
dsp3270|246|udp|Display Systems Protocol
subntbcst_tftp|247|tcp|SUBNTBCST_TFTP
subntbcst_tftp|247|udp|SUBNTBCST_TFTP
bhfhs|248|tcp|bhfhs
bhfhs|248|udp|bhfhs
rap|256|tcp|RAP
rap|256|udp|RAP
set|257|tcp|Secure Electronic Transaction
set|257|udp|Secure Electronic Transaction
yak-chat|258|tcp|Yak Winsock Personal Chat
yak-chat|258|udp|Yak Winsock Personal Chat
esro-gen|259|tcp|Efficient Short Remote Operations
esro-gen|259|udp|Efficient Short Remote Operations
openport|260|tcp|Openport
openport|260|udp|Openport
nsiiops|261|tcp|IIOP Name Service over TLS/SSL
nsiiops|261|udp|IIOP Name Service over TLS/SSL
arcisdms|262|tcp|Arcisdms
arcisdms|262|udp|Arcisdms
hdap|263|tcp|HDAP
hdap|263|udp|HDAP
bgmp|264|tcp|BGMP
bgmp|264|udp|BGMP
x-bone-ctl|265|tcp|X-Bone CTL
x-bone-ctl|265|udp|X-Bone CTL
sst|266|tcp|SCSI on ST
sst|266|udp|SCSI on ST
td-service|267|tcp|Tobit David Service Layer
td-service|267|udp|Tobit David Service Layer
td-replica|268|tcp|Tobit David Replica
td-replica|268|udp|Tobit David Replica
http-mgmt|280|tcp|http-mgmt
http-mgmt|280|udp|http-mgmt
personal-link|281|tcp|Personal Link
personal-link|281|udp|Personal Link
cableport-ax|282|tcp|Cable Port A/X
cableport-ax|282|udp|Cable Port A/X
rescap|283|tcp|rescap
rescap|283|udp|rescap
corerjd|284|tcp|corerjd
corerjd|284|udp|corerjd
fxp-1|286|tcp|FXP-1
fxp-1|286|udp|FXP-1
k-block|287|tcp|K-BLOCK
k-block|287|udp|K-BLOCK
novastorbakcup|308|tcp|Novastor Backup
novastorbakcup|308|udp|Novastor Backup
entrusttime|309|tcp|EntrustTime
entrusttime|309|udp|EntrustTime
bhmds|310|tcp|bhmds
bhmds|310|udp|bhmds
asip-webadmin|311|tcp|AppleShare IP WebAdmin
asip-webadmin|311|udp|AppleShare IP WebAdmin
vslmp|312|tcp|VSLMP
vslmp|312|udp|VSLMP
magenta-logic|313|tcp|Magenta Logic
magenta-logic|313|udp|Magenta Logic
opalis-robot|314|tcp|Opalis Robot
opalis-robot|314|udp|Opalis Robot
dpsi|315|tcp|DPSI
dpsi|315|udp|DPSI
decauth|316|tcp|decAuth
decauth|316|udp|decAuth
zannet|317|tcp|Zannet
zannet|317|udp|Zannet
pkix-timestamp|318|tcp|PKIX TimeStamp
pkix-timestamp|318|udp|PKIX TimeStamp
ptp-event|319|tcp|PTP Event
ptp-event|319|udp|PTP Event
ptp-general|320|tcp|PTP General
ptp-general|320|udp|PTP General
pip|321|tcp|PIP
pip|321|udp|PIP
rtsps|322|tcp|RTSPS
rtsps|322|udp|RTSPS
texar|333|tcp|Texar Security Port
texar|333|udp|Texar Security Port
pdap|344|tcp|Prospero Data Access Protocol
pdap|344|udp|Prospero Data Access Protocol
pawserv|345|tcp|Perf Analysis Workbench
pawserv|345|udp|Perf Analysis Workbench
zserv|346|tcp|Zebra server
zserv|346|udp|Zebra server
fatserv|347|tcp|Fatmen Server
fatserv|347|udp|Fatmen Server
csi-sgwp|348|tcp|Cabletron Management Protocol
csi-sgwp|348|udp|Cabletron Management Protocol
mftp|349|tcp|mftp
mftp|349|udp|mftp
matip-type-a|350|tcp|MATIP Type A
matip-type-a|350|udp|MATIP Type A
matip-type-b|351|tcp|MATIP Type B
matip-type-b|351|udp|MATIP Type B
bhoetty|351|tcp|bhoetty (added 5/21/97)
bhoetty|351|udp|bhoetty
dtag-ste-sb|352|tcp|DTAG (assigned long ago)
dtag-ste-sb|352|udp|DTAG
bhoedap4|352|tcp|bhoedap4 (added 5/21/97)
bhoedap4|352|udp|bhoedap4
ndsauth|353|tcp|NDSAUTH
ndsauth|353|udp|NDSAUTH
bh611|354|tcp|bh611
bh611|354|udp|bh611
datex-asn|355|tcp|DATEX-ASN
datex-asn|355|udp|DATEX-ASN
cloanto-net-1|356|tcp|Cloanto Net 1
cloanto-net-1|356|udp|Cloanto Net 1
bhevent|357|tcp|bhevent
bhevent|357|udp|bhevent
shrinkwrap|358|tcp|Shrinkwrap
shrinkwrap|358|udp|Shrinkwrap
nsrmp|359|tcp|Network Security Risk Management Protocol
nsrmp|359|udp|Network Security Risk Management Protocol
scoi2odialog|360|tcp|scoi2odialog
scoi2odialog|360|udp|scoi2odialog
semantix|361|tcp|Semantix
semantix|361|udp|Semantix
srssend|362|tcp|SRS Send
srssend|362|udp|SRS Send
rsvp_tunnel|363|tcp|RSVP Tunnel
rsvp_tunnel|363|udp|RSVP Tunnel
aurora-cmgr|364|tcp|Aurora CMGR
aurora-cmgr|364|udp|Aurora CMGR
dtk|365|tcp|DTK
dtk|365|udp|DTK
odmr|366|tcp|ODMR
odmr|366|udp|ODMR
mortgageware|367|tcp|MortgageWare
mortgageware|367|udp|MortgageWare
qbikgdp|368|tcp|QbikGDP
qbikgdp|368|udp|QbikGDP
rpc2portmap|369|tcp|rpc2portmap
rpc2portmap|369|udp|rpc2portmap
codaauth2|370|tcp|codaauth2
codaauth2|370|udp|codaauth2
clearcase|371|tcp|Clearcase
clearcase|371|udp|Clearcase
ulistproc|372|tcp|ListProcessor
ulistproc|372|udp|ListProcessor
legent-1|373|tcp|Legent Corporation
legent-1|373|udp|Legent Corporation
legent-2|374|tcp|Legent Corporation
legent-2|374|udp|Legent Corporation
hassle|375|tcp|Hassle
hassle|375|udp|Hassle
nip|376|tcp|Amiga Envoy Network Inquiry Proto
nip|376|udp|Amiga Envoy Network Inquiry Proto
tnETOS|377|tcp|NEC Corporation
tnETOS|377|udp|NEC Corporation
dsETOS|378|tcp|NEC Corporation
dsETOS|378|udp|NEC Corporation
is99c|379|tcp|TIA/EIA/IS-99 modem client
is99c|379|udp|TIA/EIA/IS-99 modem client
is99s|380|tcp|TIA/EIA/IS-99 modem server
is99s|380|udp|TIA/EIA/IS-99 modem server
hp-collector|381|tcp|hp performance data collector
hp-collector|381|udp|hp performance data collector
hp-managed-node|382|tcp|hp performance data managed node
hp-managed-node|382|udp|hp performance data managed node
hp-alarm-mgr|383|tcp|hp performance data alarm manager
hp-alarm-mgr|383|udp|hp performance data alarm manager
arns|384|tcp|A Remote Network Server System
arns|384|udp|A Remote Network Server System
ibm-app|385|tcp|IBM Application
ibm-app|385|udp|IBM Application
asa|386|tcp|ASA Message Router Object Def.
asa|386|udp|ASA Message Router Object Def.
aurp|387|tcp|Appletalk Update-Based Routing Pro.
aurp|387|udp|Appletalk Update-Based Routing Pro.
unidata-ldm|388|tcp|Unidata LDM
unidata-ldm|388|udp|Unidata LDM
ldap|389|tcp|Lightweight Directory Access Protocol
ldap|389|udp|Lightweight Directory Access Protocol
uis|390|tcp|UIS
uis|390|udp|UIS
synotics-relay|391|tcp|SynOptics SNMP Relay Port
synotics-relay|391|udp|SynOptics SNMP Relay Port
synotics-broker|392|tcp|SynOptics Port Broker Port
synotics-broker|392|udp|SynOptics Port Broker Port
meta5|393|tcp|Meta5
meta5|393|udp|Meta5
embl-ndt|394|tcp|EMBL Nucleic Data Transfer
embl-ndt|394|udp|EMBL Nucleic Data Transfer
netcp|395|tcp|NETscout Control Protocol
netcp|395|udp|NETscout Control Protocol
netware-ip|396|tcp|Novell Netware over IP
netware-ip|396|udp|Novell Netware over IP
mptn|397|tcp|Multi Protocol Trans. Net.
mptn|397|udp|Multi Protocol Trans. Net.
kryptolan|398|tcp|Kryptolan
kryptolan|398|udp|Kryptolan
iso-tsap-c2|399|tcp|ISO Transport Class 2 Non-Control over TCP
iso-tsap-c2|399|udp|ISO Transport Class 2 Non-Control over UDP
work-sol|400|tcp|Workstation Solutions
work-sol|400|udp|Workstation Solutions
ups|401|tcp|Uninterruptible Power Supply
ups|401|udp|Uninterruptible Power Supply
genie|402|tcp|Genie Protocol
genie|402|udp|Genie Protocol
decap|403|tcp|decap
decap|403|udp|decap
nced|404|tcp|nced
nced|404|udp|nced
ncld|405|tcp|ncld
ncld|405|udp|ncld
imsp|406|tcp|Interactive Mail Support Protocol
imsp|406|udp|Interactive Mail Support Protocol
timbuktu|407|tcp|Timbuktu
timbuktu|407|udp|Timbuktu
prm-sm|408|tcp|Prospero Resource Manager Sys. Man.
prm-sm|408|udp|Prospero Resource Manager Sys. Man.
prm-nm|409|tcp|Prospero Resource Manager Node Man.
prm-nm|409|udp|Prospero Resource Manager Node Man.
decladebug|410|tcp|DECLadebug Remote Debug Protocol
decladebug|410|udp|DECLadebug Remote Debug Protocol
rmt|411|tcp|Remote MT Protocol
rmt|411|udp|Remote MT Protocol
synoptics-trap|412|tcp|Trap Convention Port
synoptics-trap|412|udp|Trap Convention Port
smsp|413|tcp|Storage Management Services Protocol
smsp|413|udp|Storage Management Services Protocol
infoseek|414|tcp|InfoSeek
infoseek|414|udp|InfoSeek
bnet|415|tcp|BNet
bnet|415|udp|BNet
silverplatter|416|tcp|Silverplatter
silverplatter|416|udp|Silverplatter
onmux|417|tcp|Onmux
onmux|417|udp|Onmux
hyper-g|418|tcp|Hyper-G
hyper-g|418|udp|Hyper-G
ariel1|419|tcp|Ariel 1
ariel1|419|udp|Ariel 1
smpte|420|tcp|SMPTE
smpte|420|udp|SMPTE
ariel2|421|tcp|Ariel 2
ariel2|421|udp|Ariel 2
ariel3|422|tcp|Ariel 3
ariel3|422|udp|Ariel 3
opc-job-start|423|tcp|IBM Operations Planning and Control Start
opc-job-start|423|udp|IBM Operations Planning and Control Start
opc-job-track|424|tcp|IBM Operations Planning and Control Track
opc-job-track|424|udp|IBM Operations Planning and Control Track
icad-el|425|tcp|ICAD
icad-el|425|udp|ICAD
smartsdp|426|tcp|smartsdp
smartsdp|426|udp|smartsdp
svrloc|427|tcp|Server Location
svrloc|427|udp|Server Location
ocs_cmu|428|tcp|OCS_CMU
ocs_cmu|428|udp|OCS_CMU
ocs_amu|429|tcp|OCS_AMU
ocs_amu|429|udp|OCS_AMU
utmpsd|430|tcp|UTMPSD
utmpsd|430|udp|UTMPSD
utmpcd|431|tcp|UTMPCD
utmpcd|431|udp|UTMPCD
iasd|432|tcp|IASD
iasd|432|udp|IASD
nnsp|433|tcp|NNSP
nnsp|433|udp|NNSP
mobileip-agent|434|tcp|MobileIP-Agent
mobileip-agent|434|udp|MobileIP-Agent
mobilip-mn|435|tcp|MobilIP-MN
mobilip-mn|435|udp|MobilIP-MN
dna-cml|436|tcp|DNA-CML
dna-cml|436|udp|DNA-CML
comscm|437|tcp|comscm
comscm|437|udp|comscm
dsfgw|438|tcp|dsfgw
dsfgw|438|udp|dsfgw
dasp|439|tcp|dasp      Thomas Obermair
dasp|439|udp|dasp      tommy@inlab.m.eunet.de
sgcp|440|tcp|sgcp
sgcp|440|udp|sgcp
decvms-sysmgt|441|tcp|decvms-sysmgt
decvms-sysmgt|441|udp|decvms-sysmgt
cvc_hostd|442|tcp|cvc_hostd
cvc_hostd|442|udp|cvc_hostd
https|443|tcp|http protocol over TLS/SSL
https|443|udp|http protocol over TLS/SSL
snpp|444|tcp|Simple Network Paging Protocol
snpp|444|udp|Simple Network Paging Protocol
microsoft-ds|445|tcp|Microsoft-DS
microsoft-ds|445|udp|Microsoft-DS
ddm-rdb|446|tcp|DDM-RDB
ddm-rdb|446|udp|DDM-RDB
ddm-dfm|447|tcp|DDM-RFM
ddm-dfm|447|udp|DDM-RFM
ddm-ssl|448|tcp|DDM-SSL
ddm-ssl|448|udp|DDM-SSL
as-servermap|449|tcp|AS Server Mapper
as-servermap|449|udp|AS Server Mapper
tserver|450|tcp|Computer Supported Telecomunication Applications
tserver|450|udp|Computer Supported Telecomunication Applications
sfs-smp-net|451|tcp|Cray Network Semaphore server
sfs-smp-net|451|udp|Cray Network Semaphore server
sfs-config|452|tcp|Cray SFS config server
sfs-config|452|udp|Cray SFS config server
creativeserver|453|tcp|CreativeServer
creativeserver|453|udp|CreativeServer
contentserver|454|tcp|ContentServer
contentserver|454|udp|ContentServer
creativepartnr|455|tcp|CreativePartnr
creativepartnr|455|udp|CreativePartnr
macon-tcp|456|tcp|macon-tcp
macon-udp|456|udp|macon-udp
scohelp|457|tcp|scohelp
scohelp|457|udp|scohelp
appleqtc|458|tcp|apple quick time
appleqtc|458|udp|apple quick time
ampr-rcmd|459|tcp|ampr-rcmd
ampr-rcmd|459|udp|ampr-rcmd
skronk|460|tcp|skronk
skronk|460|udp|skronk
datasurfsrv|461|tcp|DataRampSrv
datasurfsrv|461|udp|DataRampSrv
datasurfsrvsec|462|tcp|DataRampSrvSec
datasurfsrvsec|462|udp|DataRampSrvSec
alpes|463|tcp|alpes
alpes|463|udp|alpes
kpasswd|464|tcp|kpasswd
kpasswd|464|udp|kpasswd
urd|465|tcp|URL Rendesvous Directory for SSM
igmpv3lite|465|udp|IGMP over UDP for SSM
digital-vrc|466|tcp|digital-vrc
digital-vrc|466|udp|digital-vrc
mylex-mapd|467|tcp|mylex-mapd
mylex-mapd|467|udp|mylex-mapd
photuris|468|tcp|proturis
photuris|468|udp|proturis
rcp|469|tcp|Radio Control Protocol
rcp|469|udp|Radio Control Protocol
scx-proxy|470|tcp|scx-proxy
scx-proxy|470|udp|scx-proxy
mondex|471|tcp|Mondex
mondex|471|udp|Mondex
ljk-login|472|tcp|ljk-login
ljk-login|472|udp|ljk-login
hybrid-pop|473|tcp|hybrid-pop
hybrid-pop|473|udp|hybrid-pop
tn-tl-w1|474|tcp|tn-tl-w1
tn-tl-w2|474|udp|tn-tl-w2
tcpnethaspsrv|475|tcp|tcpnethaspsrv
tcpnethaspsrv|475|udp|tcpnethaspsrv
tn-tl-fd1|476|tcp|tn-tl-fd1
tn-tl-fd1|476|udp|tn-tl-fd1
ss7ns|477|tcp|ss7ns
ss7ns|477|udp|ss7ns
spsc|478|tcp|spsc
spsc|478|udp|spsc
iafserver|479|tcp|iafserver
iafserver|479|udp|iafserver
iafdbase|480|tcp|iafdbase
iafdbase|480|udp|iafdbase
ph|481|tcp|Ph service
ph|481|udp|Ph service
bgs-nsi|482|tcp|bgs-nsi
bgs-nsi|482|udp|bgs-nsi
ulpnet|483|tcp|ulpnet
ulpnet|483|udp|ulpnet
integra-sme|484|tcp|Integra Software Management Environment
integra-sme|484|udp|Integra Software Management Environment
powerburst|485|tcp|Air Soft Power Burst
powerburst|485|udp|Air Soft Power Burst
avian|486|tcp|avian
avian|486|udp|avian
saft|487|tcp|saft Simple Asynchronous File Transfer
saft|487|udp|saft Simple Asynchronous File Transfer
gss-http|488|tcp|gss-http
gss-http|488|udp|gss-http
nest-protocol|489|tcp|nest-protocol
nest-protocol|489|udp|nest-protocol
micom-pfs|490|tcp|micom-pfs
micom-pfs|490|udp|micom-pfs
go-login|491|tcp|go-login
go-login|491|udp|go-login
ticf-1|492|tcp|Transport Independent Convergence for FNA
ticf-1|492|udp|Transport Independent Convergence for FNA
ticf-2|493|tcp|Transport Independent Convergence for FNA
ticf-2|493|udp|Transport Independent Convergence for FNA
pov-ray|494|tcp|POV-Ray
pov-ray|494|udp|POV-Ray
intecourier|495|tcp|intecourier
intecourier|495|udp|intecourier
pim-rp-disc|496|tcp|PIM-RP-DISC
pim-rp-disc|496|udp|PIM-RP-DISC
dantz|497|tcp|dantz
dantz|497|udp|dantz
siam|498|tcp|siam
siam|498|udp|siam
iso-ill|499|tcp|ISO ILL Protocol
iso-ill|499|udp|ISO ILL Protocol
isakmp|500|tcp|isakmp
isakmp|500|udp|isakmp
stmf|501|tcp|STMF
stmf|501|udp|STMF
asa-appl-proto|502|tcp|asa-appl-proto
asa-appl-proto|502|udp|asa-appl-proto
intrinsa|503|tcp|Intrinsa
intrinsa|503|udp|Intrinsa
citadel|504|tcp|citadel
citadel|504|udp|citadel
mailbox-lm|505|tcp|mailbox-lm
mailbox-lm|505|udp|mailbox-lm
ohimsrv|506|tcp|ohimsrv
ohimsrv|506|udp|ohimsrv
crs|507|tcp|crs
crs|507|udp|crs
xvttp|508|tcp|xvttp
xvttp|508|udp|xvttp
snare|509|tcp|snare
snare|509|udp|snare
fcp|510|tcp|FirstClass Protocol
fcp|510|udp|FirstClass Protocol
passgo|511|tcp|PassGo
passgo|511|udp|PassGo
exec|512|tcp|remote process execution;
comsat|512|udp|comsat
biff|512|udp|used by mail system to notify users
login|513|tcp|remote login a la telnet;
who|513|udp|maintains data bases showing who's
shell|514|tcp|cmd
syslog|514|udp|syslog
printer|515|tcp|spooler
printer|515|udp|spooler
videotex|516|tcp|videotex
videotex|516|udp|videotex
talk|517|tcp|like tenex link, but across
talk|517|udp|like tenex link, but across
ntalk|518|tcp|ntalk
ntalk|518|udp|ntalk
utime|519|tcp|unixtime
utime|519|udp|unixtime
efs|520|tcp|extended file name server
router|520|udp|local routing process (on site);
ripng|521|tcp|ripng
ripng|521|udp|ripng
ulp|522|tcp|ULP
ulp|522|udp|ULP
ibm-db2|523|tcp|IBM-DB2
ibm-db2|523|udp|IBM-DB2
ncp|524|tcp|NCP
ncp|524|udp|NCP
timed|525|tcp|timeserver
timed|525|udp|timeserver
tempo|526|tcp|newdate
tempo|526|udp|newdate
stx|527|tcp|Stock IXChange
stx|527|udp|Stock IXChange
custix|528|tcp|Customer IXChange
custix|528|udp|Customer IXChange
irc-serv|529|tcp|IRC-SERV
irc-serv|529|udp|IRC-SERV
courier|530|tcp|rpc
courier|530|udp|rpc
conference|531|tcp|chat
conference|531|udp|chat
netnews|532|tcp|readnews
netnews|532|udp|readnews
netwall|533|tcp|for emergency broadcasts
netwall|533|udp|for emergency broadcasts
mm-admin|534|tcp|MegaMedia Admin
mm-admin|534|udp|MegaMedia Admin
iiop|535|tcp|iiop
iiop|535|udp|iiop
opalis-rdv|536|tcp|opalis-rdv
opalis-rdv|536|udp|opalis-rdv
nmsp|537|tcp|Networked Media Streaming Protocol
nmsp|537|udp|Networked Media Streaming Protocol
gdomap|538|tcp|gdomap
gdomap|538|udp|gdomap
apertus-ldp|539|tcp|Apertus Technologies Load Determination
apertus-ldp|539|udp|Apertus Technologies Load Determination
uucp|540|tcp|uucpd
uucp|540|udp|uucpd
uucp-rlogin|541|tcp|uucp-rlogin
uucp-rlogin|541|udp|uucp-rlogin
commerce|542|tcp|commerce
commerce|542|udp|commerce
klogin|543|tcp|klogin
klogin|543|udp|klogin
kshell|544|tcp|krcmd
kshell|544|udp|krcmd
appleqtcsrvr|545|tcp|appleqtcsrvr
appleqtcsrvr|545|udp|appleqtcsrvr
dhcpv6-client|546|tcp|DHCPv6 Client
dhcpv6-client|546|udp|DHCPv6 Client
dhcpv6-server|547|tcp|DHCPv6 Server
dhcpv6-server|547|udp|DHCPv6 Server
afpovertcp|548|tcp|AFP over TCP
afpovertcp|548|udp|AFP over TCP
idfp|549|tcp|IDFP
idfp|549|udp|IDFP
new-rwho|550|tcp|new-who
new-rwho|550|udp|new-who
cybercash|551|tcp|cybercash
cybercash|551|udp|cybercash
devshr-nts|552|tcp|DeviceShare
devshr-nts|552|udp|DeviceShare
pirp|553|tcp|pirp
pirp|553|udp|pirp
rtsp|554|tcp|Real Time Stream Control Protocol
rtsp|554|udp|Real Time Stream Control Protocol
dsf|555|tcp|dsf
dsf|555|udp|dsf
remotefs|556|tcp|rfs server
remotefs|556|udp|rfs server
openvms-sysipc|557|tcp|openvms-sysipc
openvms-sysipc|557|udp|openvms-sysipc
sdnskmp|558|tcp|SDNSKMP
sdnskmp|558|udp|SDNSKMP
teedtap|559|tcp|TEEDTAP
teedtap|559|udp|TEEDTAP
rmonitor|560|tcp|rmonitord
rmonitor|560|udp|rmonitord
monitor|561|tcp|monitor
monitor|561|udp|monitor
chshell|562|tcp|chcmd
chshell|562|udp|chcmd
nntps|563|tcp|nntp protocol over TLS/SSL (was snntp)
nntps|563|udp|nntp protocol over TLS/SSL (was snntp)
9pfs|564|tcp|plan 9 file service
9pfs|564|udp|plan 9 file service
whoami|565|tcp|whoami
whoami|565|udp|whoami
streettalk|566|tcp|streettalk
streettalk|566|udp|streettalk
banyan-rpc|567|tcp|banyan-rpc
banyan-rpc|567|udp|banyan-rpc
ms-shuttle|568|tcp|microsoft shuttle
ms-shuttle|568|udp|microsoft shuttle
ms-rome|569|tcp|microsoft rome
ms-rome|569|udp|microsoft rome
meter|570|tcp|demon
meter|570|udp|demon
meter|571|tcp|udemon
meter|571|udp|udemon
sonar|572|tcp|sonar
sonar|572|udp|sonar
banyan-vip|573|tcp|banyan-vip
banyan-vip|573|udp|banyan-vip
ftp-agent|574|tcp|FTP Software Agent System
ftp-agent|574|udp|FTP Software Agent System
vemmi|575|tcp|VEMMI
vemmi|575|udp|VEMMI
ipcd|576|tcp|ipcd
ipcd|576|udp|ipcd
vnas|577|tcp|vnas
vnas|577|udp|vnas
ipdd|578|tcp|ipdd
ipdd|578|udp|ipdd
decbsrv|579|tcp|decbsrv
decbsrv|579|udp|decbsrv
sntp-heartbeat|580|tcp|SNTP HEARTBEAT
sntp-heartbeat|580|udp|SNTP HEARTBEAT
bdp|581|tcp|Bundle Discovery Protocol
bdp|581|udp|Bundle Discovery Protocol
scc-security|582|tcp|SCC Security
scc-security|582|udp|SCC Security
philips-vc|583|tcp|Philips Video-Conferencing
philips-vc|583|udp|Philips Video-Conferencing
keyserver|584|tcp|Key Server
keyserver|584|udp|Key Server
imap4-ssl|585|tcp|IMAP4+SSL (use 993 instead)
imap4-ssl|585|udp|IMAP4+SSL (use 993 instead)
password-chg|586|tcp|Password Change
password-chg|586|udp|Password Change
submission|587|tcp|Submission
submission|587|udp|Submission
cal|588|tcp|CAL
cal|588|udp|CAL
eyelink|589|tcp|EyeLink
eyelink|589|udp|EyeLink
tns-cml|590|tcp|TNS CML
tns-cml|590|udp|TNS CML
http-alt|591|tcp|FileMaker, Inc. - HTTP Alternate (see Port 80)
http-alt|591|udp|FileMaker, Inc. - HTTP Alternate (see Port 80)
eudora-set|592|tcp|Eudora Set
eudora-set|592|udp|Eudora Set
http-rpc-epmap|593|tcp|HTTP RPC Ep Map
http-rpc-epmap|593|udp|HTTP RPC Ep Map
tpip|594|tcp|TPIP
tpip|594|udp|TPIP
cab-protocol|595|tcp|CAB Protocol
cab-protocol|595|udp|CAB Protocol
smsd|596|tcp|SMSD
smsd|596|udp|SMSD
ptcnameservice|597|tcp|PTC Name Service
ptcnameservice|597|udp|PTC Name Service
sco-websrvrmg3|598|tcp|SCO Web Server Manager 3
sco-websrvrmg3|598|udp|SCO Web Server Manager 3
acp|599|tcp|Aeolon Core Protocol
acp|599|udp|Aeolon Core Protocol
ipcserver|600|tcp|Sun IPC server
ipcserver|600|udp|Sun IPC server
syslog-conn|601|tcp|Reliable Syslog Service
syslog-conn|601|udp|Reliable Syslog Service
xmlrpc-beep|602|tcp|XML-RPC over BEEP
xmlrpc-beep|602|udp|XML-RPC over BEEP
idxp|603|tcp|IDXP
idxp|603|udp|IDXP
tunnel|604|tcp|TUNNEL
tunnel|604|udp|TUNNEL
soap-beep|605|tcp|SOAP over BEEP
soap-beep|605|udp|SOAP over BEEP
urm|606|tcp|Cray Unified Resource Manager
urm|606|udp|Cray Unified Resource Manager
nqs|607|tcp|nqs
nqs|607|udp|nqs
sift-uft|608|tcp|Sender-Initiated/Unsolicited File Transfer
sift-uft|608|udp|Sender-Initiated/Unsolicited File Transfer
npmp-trap|609|tcp|npmp-trap
npmp-trap|609|udp|npmp-trap
npmp-local|610|tcp|npmp-local
npmp-local|610|udp|npmp-local
npmp-gui|611|tcp|npmp-gui
npmp-gui|611|udp|npmp-gui
hmmp-ind|612|tcp|HMMP Indication
hmmp-ind|612|udp|HMMP Indication
hmmp-op|613|tcp|HMMP Operation
hmmp-op|613|udp|HMMP Operation
sshell|614|tcp|SSLshell
sshell|614|udp|SSLshell
sco-inetmgr|615|tcp|Internet Configuration Manager
sco-inetmgr|615|udp|Internet Configuration Manager
sco-sysmgr|616|tcp|SCO System Administration Server
sco-sysmgr|616|udp|SCO System Administration Server
sco-dtmgr|617|tcp|SCO Desktop Administration Server
sco-dtmgr|617|udp|SCO Desktop Administration Server
dei-icda|618|tcp|DEI-ICDA
dei-icda|618|udp|DEI-ICDA
compaq-evm|619|tcp|Compaq EVM
compaq-evm|619|udp|Compaq EVM
sco-websrvrmgr|620|tcp|SCO WebServer Manager
sco-websrvrmgr|620|udp|SCO WebServer Manager
escp-ip|621|tcp|ESCP
escp-ip|621|udp|ESCP
collaborator|622|tcp|Collaborator
collaborator|622|udp|Collaborator
asf-rmcp|623|tcp|ASF Remote Management and Control Protocol
asf-rmcp|623|udp|ASF Remote Management and Control Protocol
cryptoadmin|624|tcp|Crypto Admin
cryptoadmin|624|udp|Crypto Admin
dec_dlm|625|tcp|DEC DLM
dec_dlm|625|udp|DEC DLM
asia|626|tcp|ASIA
asia|626|udp|ASIA
passgo-tivoli|627|tcp|PassGo Tivoli
passgo-tivoli|627|udp|PassGo Tivoli
qmqp|628|tcp|QMQP
qmqp|628|udp|QMQP
3com-amp3|629|tcp|3Com AMP3
3com-amp3|629|udp|3Com AMP3
rda|630|tcp|RDA
rda|630|udp|RDA
ipp|631|tcp|IPP (Internet Printing Protocol)
ipp|631|udp|IPP (Internet Printing Protocol)
bmpp|632|tcp|bmpp
bmpp|632|udp|bmpp
servstat|633|tcp|Service Status update (Sterling Software)
servstat|633|udp|Service Status update (Sterling Software)
ginad|634|tcp|ginad
ginad|634|udp|ginad
rlzdbase|635|tcp|RLZ DBase
rlzdbase|635|udp|RLZ DBase
ldaps|636|tcp|ldap protocol over TLS/SSL (was sldap)
ldaps|636|udp|ldap protocol over TLS/SSL (was sldap)
lanserver|637|tcp|lanserver
lanserver|637|udp|lanserver
mcns-sec|638|tcp|mcns-sec
mcns-sec|638|udp|mcns-sec
msdp|639|tcp|MSDP
msdp|639|udp|MSDP
entrust-sps|640|tcp|entrust-sps
entrust-sps|640|udp|entrust-sps
repcmd|641|tcp|repcmd
repcmd|641|udp|repcmd
esro-emsdp|642|tcp|ESRO-EMSDP V1.3
esro-emsdp|642|udp|ESRO-EMSDP V1.3
sanity|643|tcp|SANity
sanity|643|udp|SANity
dwr|644|tcp|dwr
dwr|644|udp|dwr
pssc|645|tcp|PSSC
pssc|645|udp|PSSC
ldp|646|tcp|LDP
ldp|646|udp|LDP
dhcp-failover|647|tcp|DHCP Failover
dhcp-failover|647|udp|DHCP Failover
rrp|648|tcp|Registry Registrar Protocol (RRP)
rrp|648|udp|Registry Registrar Protocol (RRP)
cadview-3d|649|tcp|Cadview-3d - streaming 3d models over the internet
cadview-3d|649|udp|Cadview-3d - streaming 3d models over the internet
obex|650|tcp|OBEX
obex|650|udp|OBEX
ieee-mms|651|tcp|IEEE MMS
ieee-mms|651|udp|IEEE MMS
hello-port|652|tcp|HELLO_PORT
hello-port|652|udp|HELLO_PORT
repscmd|653|tcp|RepCmd
repscmd|653|udp|RepCmd
aodv|654|tcp|AODV
aodv|654|udp|AODV
tinc|655|tcp|TINC
tinc|655|udp|TINC
spmp|656|tcp|SPMP
spmp|656|udp|SPMP
rmc|657|tcp|RMC
rmc|657|udp|RMC
tenfold|658|tcp|TenFold
tenfold|658|udp|TenFold
mac-srvr-admin|660|tcp|MacOS Server Admin
mac-srvr-admin|660|udp|MacOS Server Admin
hap|661|tcp|HAP
hap|661|udp|HAP
pftp|662|tcp|PFTP
pftp|662|udp|PFTP
purenoise|663|tcp|PureNoise
purenoise|663|udp|PureNoise
asf-secure-rmcp|664|tcp|ASF Secure Remote Management and Control Protocol
asf-secure-rmcp|664|udp|ASF Secure Remote Management and Control Protocol
sun-dr|665|tcp|Sun DR
sun-dr|665|udp|Sun DR
mdqs|666|tcp|mdqs
mdqs|666|udp|mdqs
doom|666|tcp|doom Id Software
doom|666|udp|doom Id Software
disclose|667|tcp|campaign contribution disclosures - SDR Technologies
disclose|667|udp|campaign contribution disclosures - SDR Technologies
mecomm|668|tcp|MeComm
mecomm|668|udp|MeComm
meregister|669|tcp|MeRegister
meregister|669|udp|MeRegister
vacdsm-sws|670|tcp|VACDSM-SWS
vacdsm-sws|670|udp|VACDSM-SWS
vacdsm-app|671|tcp|VACDSM-APP
vacdsm-app|671|udp|VACDSM-APP
vpps-qua|672|tcp|VPPS-QUA
vpps-qua|672|udp|VPPS-QUA
cimplex|673|tcp|CIMPLEX
cimplex|673|udp|CIMPLEX
acap|674|tcp|ACAP
acap|674|udp|ACAP
dctp|675|tcp|DCTP
dctp|675|udp|DCTP
vpps-via|676|tcp|VPPS Via
vpps-via|676|udp|VPPS Via
vpp|677|tcp|Virtual Presence Protocol
vpp|677|udp|Virtual Presence Protocol
ggf-ncp|678|tcp|GNU Generation Foundation NCP
ggf-ncp|678|udp|GNU Generation Foundation NCP
mrm|679|tcp|MRM
mrm|679|udp|MRM
entrust-aaas|680|tcp|entrust-aaas
entrust-aaas|680|udp|entrust-aaas
entrust-aams|681|tcp|entrust-aams
entrust-aams|681|udp|entrust-aams
xfr|682|tcp|XFR
xfr|682|udp|XFR
corba-iiop|683|tcp|CORBA IIOP
corba-iiop|683|udp|CORBA IIOP
corba-iiop-ssl|684|tcp|CORBA IIOP SSL
corba-iiop-ssl|684|udp|CORBA IIOP SSL
mdc-portmapper|685|tcp|MDC Port Mapper
mdc-portmapper|685|udp|MDC Port Mapper
hcp-wismar|686|tcp|Hardware Control Protocol Wismar
hcp-wismar|686|udp|Hardware Control Protocol Wismar
asipregistry|687|tcp|asipregistry
asipregistry|687|udp|asipregistry
realm-rusd|688|tcp|REALM-RUSD
realm-rusd|688|udp|REALM-RUSD
nmap|689|tcp|NMAP
nmap|689|udp|NMAP
vatp|690|tcp|VATP
vatp|690|udp|VATP
msexch-routing|691|tcp|MS Exchange Routing
msexch-routing|691|udp|MS Exchange Routing
hyperwave-isp|692|tcp|Hyperwave-ISP
hyperwave-isp|692|udp|Hyperwave-ISP
connendp|693|tcp|connendp
connendp|693|udp|connendp
ha-cluster|694|tcp|ha-cluster
ha-cluster|694|udp|ha-cluster
ieee-mms-ssl|695|tcp|IEEE-MMS-SSL
ieee-mms-ssl|695|udp|IEEE-MMS-SSL
rushd|696|tcp|RUSHD
rushd|696|udp|RUSHD
uuidgen|697|tcp|UUIDGEN
uuidgen|697|udp|UUIDGEN
olsr|698|tcp|OLSR
olsr|698|udp|OLSR
accessnetwork|699|tcp|Access Network
accessnetwork|699|udp|Access Network
elcsd|704|tcp|errlog copy/server daemon
elcsd|704|udp|errlog copy/server daemon
agentx|705|tcp|AgentX
agentx|705|udp|AgentX
silc|706|tcp|SILC
silc|706|udp|SILC
borland-dsj|707|tcp|Borland DSJ
borland-dsj|707|udp|Borland DSJ
entrust-kmsh|709|tcp|Entrust Key Management Service Handler
entrust-kmsh|709|udp|Entrust Key Management Service Handler
entrust-ash|710|tcp|Entrust Administration Service Handler
entrust-ash|710|udp|Entrust Administration Service Handler
cisco-tdp|711|tcp|Cisco TDP
cisco-tdp|711|udp|Cisco TDP
netviewdm1|729|tcp|IBM NetView DM/6000 Server/Client
netviewdm1|729|udp|IBM NetView DM/6000 Server/Client
netviewdm2|730|tcp|IBM NetView DM/6000 send/tcp
netviewdm2|730|udp|IBM NetView DM/6000 send/tcp
netviewdm3|731|tcp|IBM NetView DM/6000 receive/tcp
netviewdm3|731|udp|IBM NetView DM/6000 receive/tcp
netgw|741|tcp|netGW
netgw|741|udp|netGW
netrcs|742|tcp|Network based Rev. Cont. Sys.
netrcs|742|udp|Network based Rev. Cont. Sys.
flexlm|744|tcp|Flexible License Manager
flexlm|744|udp|Flexible License Manager
fujitsu-dev|747|tcp|Fujitsu Device Control
fujitsu-dev|747|udp|Fujitsu Device Control
ris-cm|748|tcp|Russell Info Sci Calendar Manager
ris-cm|748|udp|Russell Info Sci Calendar Manager
kerberos-adm|749|tcp|kerberos administration
kerberos-adm|749|udp|kerberos administration
rfile|750|tcp|rfile
loadav|750|udp|loadav
kerberos-iv|750|udp|kerberos version iv
pump|751|tcp|pump
pump|751|udp|pump
qrh|752|tcp|qrh
qrh|752|udp|qrh
rrh|753|tcp|rrh
rrh|753|udp|rrh
tell|754|tcp|send
tell|754|udp|send
nlogin|758|tcp|nlogin
nlogin|758|udp|nlogin
con|759|tcp|con
con|759|udp|con
ns|760|tcp|ns
ns|760|udp|ns
rxe|761|tcp|rxe
rxe|761|udp|rxe
quotad|762|tcp|quotad
quotad|762|udp|quotad
cycleserv|763|tcp|cycleserv
cycleserv|763|udp|cycleserv
omserv|764|tcp|omserv
omserv|764|udp|omserv
webster|765|tcp|webster
webster|765|udp|webster
phonebook|767|tcp|phone
phonebook|767|udp|phone
vid|769|tcp|vid
vid|769|udp|vid
cadlock|770|tcp|cadlock
cadlock|770|udp|cadlock
rtip|771|tcp|rtip
rtip|771|udp|rtip
cycleserv2|772|tcp|cycleserv2
cycleserv2|772|udp|cycleserv2
submit|773|tcp|submit
notify|773|udp|notify
rpasswd|774|tcp|rpasswd
acmaint_dbd|774|udp|acmaint_dbd
entomb|775|tcp|entomb
acmaint_transd|775|udp|acmaint_transd
wpages|776|tcp|wpages
wpages|776|udp|wpages
multiling-http|777|tcp|Multiling HTTP
multiling-http|777|udp|Multiling HTTP
wpgs|780|tcp|wpgs
wpgs|780|udp|wpgs
mdbs_daemon|800|tcp|mdbs_daemon
mdbs_daemon|800|udp|mdbs_daemon
device|801|tcp|device
device|801|udp|device
fcp-udp|810|tcp|FCP
fcp-udp|810|udp|FCP Datagram
itm-mcell-s|828|tcp|itm-mcell-s
itm-mcell-s|828|udp|itm-mcell-s
pkix-3-ca-ra|829|tcp|PKIX-3 CA/RA
pkix-3-ca-ra|829|udp|PKIX-3 CA/RA
dhcp-failover2|847|tcp|dhcp-failover 2
dhcp-failover2|847|udp|dhcp-failover 2
gdoi|848|tcp|GDOI
gdoi|848|udp|GDOI
iscsi|860|tcp|iSCSI
iscsi|860|udp|iSCSI
rsync|873|tcp|rsync
rsync|873|udp|rsync
iclcnet-locate|886|tcp|ICL coNETion locate server
iclcnet-locate|886|udp|ICL coNETion locate server
iclcnet_svinfo|887|tcp|ICL coNETion server info
iclcnet_svinfo|887|udp|ICL coNETion server info
accessbuilder|888|tcp|AccessBuilder
accessbuilder|888|udp|AccessBuilder
cddbp|888|tcp|CD Database Protocol
omginitialrefs|900|tcp|OMG Initial Refs
omginitialrefs|900|udp|OMG Initial Refs
smpnameres|901|tcp|SMPNAMERES
smpnameres|901|udp|SMPNAMERES
ideafarm-chat|902|tcp|IDEAFARM-CHAT
ideafarm-chat|902|udp|IDEAFARM-CHAT
ideafarm-catch|903|tcp|IDEAFARM-CATCH
ideafarm-catch|903|udp|IDEAFARM-CATCH
xact-backup|911|tcp|xact-backup
xact-backup|911|udp|xact-backup
apex-mesh|912|tcp|APEX relay-relay service
apex-mesh|912|udp|APEX relay-relay service
apex-edge|913|tcp|APEX endpoint-relay service
apex-edge|913|udp|APEX endpoint-relay service
ftps-data|989|tcp|ftp protocol, data, over TLS/SSL
ftps-data|989|udp|ftp protocol, data, over TLS/SSL
ftps|990|tcp|ftp protocol, control, over TLS/SSL
ftps|990|udp|ftp protocol, control, over TLS/SSL
nas|991|tcp|Netnews Administration System
nas|991|udp|Netnews Administration System
telnets|992|tcp|telnet protocol over TLS/SSL
telnets|992|udp|telnet protocol over TLS/SSL
imaps|993|tcp|imap4 protocol over TLS/SSL
imaps|993|udp|imap4 protocol over TLS/SSL
ircs|994|tcp|irc protocol over TLS/SSL
ircs|994|udp|irc protocol over TLS/SSL
pop3s|995|tcp|pop3 protocol over TLS/SSL (was spop3)
pop3s|995|udp|pop3 protocol over TLS/SSL (was spop3)
vsinet|996|tcp|vsinet
vsinet|996|udp|vsinet
maitrd|997|tcp|maitrd
maitrd|997|udp|maitrd
busboy|998|tcp|busboy
puparp|998|udp|puparp
garcon|999|tcp|garcon
applix|999|udp|Applix ac
puprouter|999|tcp|puprouter
puprouter|999|udp|puprouter
cadlock2|1000|tcp|cadlock2
cadlock2|1000|udp|cadlock2
surf|1010|tcp|surf
surf|1010|udp|surf
unnamed-port-1023-service|1023|tcp|Reserved
unnamed-port-1023-service|1023|udp|Reserved
unnamed-port-1024-service|1024|tcp|Reserved
unnamed-port-1024-service|1024|udp|Reserved
blackjack|1025|tcp|network blackjack
blackjack|1025|udp|network blackjack
cap|1026|tcp|Calender Access Protocol
cap|1026|udp|Calender Access Protocol
iad1|1030|tcp|BBN IAD
iad1|1030|udp|BBN IAD
iad2|1031|tcp|BBN IAD
iad2|1031|udp|BBN IAD
iad3|1032|tcp|BBN IAD
iad3|1032|udp|BBN IAD
netinfo-local|1033|tcp|local netinfo port
netinfo-local|1033|udp|local netinfo port
activesync|1034|tcp|ActiveSync Notifications
activesync|1034|udp|ActiveSync Notifications
mxxrlogin|1035|tcp|MX-XR RPC
mxxrlogin|1035|udp|MX-XR RPC
pcg-radar|1036|tcp|RADAR Service Protocol
pcg-radar|1036|udp|RADAR Service Protocol
netarx|1040|tcp|Netarx
netarx|1040|udp|Netarx
fpitp|1045|tcp|Fingerprint Image Transfer Protocol
fpitp|1045|udp|Fingerprint Image Transfer Protocol
neod1|1047|tcp|Sun's NEO Object Request Broker
neod1|1047|udp|Sun's NEO Object Request Broker
neod2|1048|tcp|Sun's NEO Object Request Broker
neod2|1048|udp|Sun's NEO Object Request Broker
td-postman|1049|tcp|Tobit David Postman VPMN
td-postman|1049|udp|Tobit David Postman VPMN
cma|1050|tcp|CORBA Management Agent
cma|1050|udp|CORBA Management Agent
optima-vnet|1051|tcp|Optima VNET
optima-vnet|1051|udp|Optima VNET
ddt|1052|tcp|Dynamic DNS Tools
ddt|1052|udp|Dynamic DNS Tools
remote-as|1053|tcp|Remote Assistant (RA)
remote-as|1053|udp|Remote Assistant (RA)
brvread|1054|tcp|BRVREAD
brvread|1054|udp|BRVREAD
ansyslmd|1055|tcp|ANSYS - License Manager
ansyslmd|1055|udp|ANSYS - License Manager
vfo|1056|tcp|VFO
vfo|1056|udp|VFO
startron|1057|tcp|STARTRON
startron|1057|udp|STARTRON
nim|1058|tcp|nim
nim|1058|udp|nim
nimreg|1059|tcp|nimreg
nimreg|1059|udp|nimreg
polestar|1060|tcp|POLESTAR
polestar|1060|udp|POLESTAR
kiosk|1061|tcp|KIOSK
kiosk|1061|udp|KIOSK
veracity|1062|tcp|Veracity
veracity|1062|udp|Veracity
kyoceranetdev|1063|tcp|KyoceraNetDev
kyoceranetdev|1063|udp|KyoceraNetDev
jstel|1064|tcp|JSTEL
jstel|1064|udp|JSTEL
syscomlan|1065|tcp|SYSCOMLAN
syscomlan|1065|udp|SYSCOMLAN
fpo-fns|1066|tcp|FPO-FNS
fpo-fns|1066|udp|FPO-FNS
instl_boots|1067|tcp|Installation Bootstrap Proto. Serv.
instl_boots|1067|udp|Installation Bootstrap Proto. Serv.
instl_bootc|1068|tcp|Installation Bootstrap Proto. Cli.
instl_bootc|1068|udp|Installation Bootstrap Proto. Cli.
cognex-insight|1069|tcp|COGNEX-INSIGHT
cognex-insight|1069|udp|COGNEX-INSIGHT
gmrupdateserv|1070|tcp|GMRUpdateSERV
gmrupdateserv|1070|udp|GMRUpdateSERV
bsquare-voip|1071|tcp|BSQUARE-VOIP
bsquare-voip|1071|udp|BSQUARE-VOIP
cardax|1072|tcp|CARDAX
cardax|1072|udp|CARDAX
bridgecontrol|1073|tcp|Bridge Control
bridgecontrol|1073|udp|Bridge Control
fastechnologlm|1074|tcp|FASTechnologies License Manager
fastechnologlm|1074|udp|FASTechnologies License Manager
rdrmshc|1075|tcp|RDRMSHC
rdrmshc|1075|udp|RDRMSHC
dab-sti-c|1076|tcp|DAB STI-C
dab-sti-c|1076|udp|DAB STI-C
imgames|1077|tcp|IMGames
imgames|1077|udp|IMGames
avocent-proxy|1078|tcp|Avocent Proxy Protocol
avocent-proxy|1078|udp|Avocent Proxy Protocol
asprovatalk|1079|tcp|ASPROVATalk
asprovatalk|1079|udp|ASPROVATalk
socks|1080|tcp|Socks
socks|1080|udp|Socks
pvuniwien|1081|tcp|PVUNIWIEN
pvuniwien|1081|udp|PVUNIWIEN
amt-esd-prot|1082|tcp|AMT-ESD-PROT
amt-esd-prot|1082|udp|AMT-ESD-PROT
ansoft-lm-1|1083|tcp|Anasoft License Manager
ansoft-lm-1|1083|udp|Anasoft License Manager
ansoft-lm-2|1084|tcp|Anasoft License Manager
ansoft-lm-2|1084|udp|Anasoft License Manager
webobjects|1085|tcp|Web Objects
webobjects|1085|udp|Web Objects
cplscrambler-lg|1086|tcp|CPL Scrambler Logging
cplscrambler-lg|1086|udp|CPL Scrambler Logging
cplscrambler-in|1087|tcp|CPL Scrambler Internal
cplscrambler-in|1087|udp|CPL Scrambler Internal
cplscrambler-al|1088|tcp|CPL Scrambler Alarm Log
cplscrambler-al|1088|udp|CPL Scrambler Alarm Log
ff-annunc|1089|tcp|FF Annunciation
ff-annunc|1089|udp|FF Annunciation
ff-fms|1090|tcp|FF Fieldbus Message Specification
ff-fms|1090|udp|FF Fieldbus Message Specification
ff-sm|1091|tcp|FF System Management
ff-sm|1091|udp|FF System Management
obrpd|1092|tcp|Open Business Reporting Protocol
obrpd|1092|udp|Open Business Reporting Protocol
proofd|1093|tcp|PROOFD
proofd|1093|udp|PROOFD
rootd|1094|tcp|ROOTD
rootd|1094|udp|ROOTD
nicelink|1095|tcp|NICELink
nicelink|1095|udp|NICELink
cnrprotocol|1096|tcp|Common Name Resolution Protocol
cnrprotocol|1096|udp|Common Name Resolution Protocol
sunclustermgr|1097|tcp|Sun Cluster Manager
sunclustermgr|1097|udp|Sun Cluster Manager
rmiactivation|1098|tcp|RMI Activation
rmiactivation|1098|udp|RMI Activation
rmiregistry|1099|tcp|RMI Registry
rmiregistry|1099|udp|RMI Registry
mctp|1100|tcp|MCTP
mctp|1100|udp|MCTP
pt2-discover|1101|tcp|PT2-DISCOVER
pt2-discover|1101|udp|PT2-DISCOVER
adobeserver-1|1102|tcp|ADOBE SERVER 1
adobeserver-1|1102|udp|ADOBE SERVER 1
adobeserver-2|1103|tcp|ADOBE SERVER 2
adobeserver-2|1103|udp|ADOBE SERVER 2
xrl|1104|tcp|XRL
xrl|1104|udp|XRL
ftranhc|1105|tcp|FTRANHC
ftranhc|1105|udp|FTRANHC
isoipsigport-1|1106|tcp|ISOIPSIGPORT-1
isoipsigport-1|1106|udp|ISOIPSIGPORT-1
isoipsigport-2|1107|tcp|ISOIPSIGPORT-2
isoipsigport-2|1107|udp|ISOIPSIGPORT-2
ratio-adp|1108|tcp|ratio-adp
ratio-adp|1108|udp|ratio-adp
nfsd-status|1110|tcp|Cluster status info
nfsd-keepalive|1110|udp|Client status info
lmsocialserver|1111|tcp|LM Social Server
lmsocialserver|1111|udp|LM Social Server
icp|1112|tcp|Intelligent Communication Protocol
icp|1112|udp|Intelligent Communication Protocol
mini-sql|1114|tcp|Mini SQL
mini-sql|1114|udp|Mini SQL
ardus-trns|1115|tcp|ARDUS Transfer
ardus-trns|1115|udp|ARDUS Transfer
ardus-cntl|1116|tcp|ARDUS Control
ardus-cntl|1116|udp|ARDUS Control
ardus-mtrns|1117|tcp|ARDUS Multicast Transfer
ardus-mtrns|1117|udp|ARDUS Multicast Transfer
availant-mgr|1122|tcp|availant-mgr
availant-mgr|1122|udp|availant-mgr
murray|1123|tcp|Murray
murray|1123|udp|Murray
nfa|1155|tcp|Network File Access
nfa|1155|udp|Network File Access
health-polling|1161|tcp|Health Polling
health-polling|1161|udp|Health Polling
health-trap|1162|tcp|Health Trap
health-trap|1162|udp|Health Trap
vchat|1168|tcp|VChat Conference Service
vchat|1168|udp|VChat Conference Service
tripwire|1169|tcp|TRIPWIRE
tripwire|1169|udp|TRIPWIRE
mc-client|1180|tcp|Millicent Client Proxy
mc-client|1180|udp|Millicent Client Proxy
llsurfup-http|1183|tcp|LL Surfup HTTP
llsurfup-http|1183|udp|LL Surfup HTTP
llsurfup-https|1184|tcp|LL Surfup HTTPS
llsurfup-https|1184|udp|LL Surfup HTTPS
catchpole|1185|tcp|Catchpole port
catchpole|1185|udp|Catchpole port
hp-webadmin|1188|tcp|HP Web Admin
hp-webadmin|1188|udp|HP Web Admin
dmidi|1199|tcp|DMIDI
dmidi|1199|udp|DMIDI
scol|1200|tcp|SCOL
scol|1200|udp|SCOL
nucleus-sand|1201|tcp|Nucleus Sand
nucleus-sand|1201|udp|Nucleus Sand
caiccipc|1202|tcp|caiccipc
caiccipc|1202|udp|caiccipc
ssslic-mgr|1203|tcp|License Validation
ssslic-mgr|1203|udp|License Validation
ssslog-mgr|1204|tcp|Log Request Listener
ssslog-mgr|1204|udp|Log Request Listener
accord-mgc|1205|tcp|Accord-MGC
accord-mgc|1205|udp|Accord-MGC
anthony-data|1206|tcp|Anthony Data
anthony-data|1206|udp|Anthony Data
metasage|1207|tcp|MetaSage
metasage|1207|udp|MetaSage
seagull-ais|1208|tcp|SEAGULL AIS
seagull-ais|1208|udp|SEAGULL AIS
ipcd3|1209|tcp|IPCD3
ipcd3|1209|udp|IPCD3
eoss|1210|tcp|EOSS
eoss|1210|udp|EOSS
groove-dpp|1211|tcp|Groove DPP
groove-dpp|1211|udp|Groove DPP
lupa|1212|tcp|lupa
lupa|1212|udp|lupa
mpc-lifenet|1213|tcp|MPC LIFENET
mpc-lifenet|1213|udp|MPC LIFENET
kazaa|1214|tcp|KAZAA
kazaa|1214|udp|KAZAA
scanstat-1|1215|tcp|scanSTAT 1.0
scanstat-1|1215|udp|scanSTAT 1.0
etebac5|1216|tcp|ETEBAC 5
etebac5|1216|udp|ETEBAC 5
hpss-ndapi|1217|tcp|HPSS-NDAPI
hpss-ndapi|1217|udp|HPSS-NDAPI
aeroflight-ads|1218|tcp|AeroFlight-ADs
aeroflight-ads|1218|udp|AeroFlight-ADs
aeroflight-ret|1219|tcp|AeroFlight-Ret
aeroflight-ret|1219|udp|AeroFlight-Ret
qt-serveradmin|1220|tcp|QT SERVER ADMIN
qt-serveradmin|1220|udp|QT SERVER ADMIN
sweetware-apps|1221|tcp|SweetWARE Apps
sweetware-apps|1221|udp|SweetWARE Apps
nerv|1222|tcp|SNI R&D network
nerv|1222|udp|SNI R&D network
tgp|1223|tcp|TGP
tgp|1223|udp|TGP
vpnz|1224|tcp|VPNz
vpnz|1224|udp|VPNz
slinkysearch|1225|tcp|SLINKYSEARCH
slinkysearch|1225|udp|SLINKYSEARCH
stgxfws|1226|tcp|STGXFWS
stgxfws|1226|udp|STGXFWS
dns2go|1227|tcp|DNS2Go
dns2go|1227|udp|DNS2Go
florence|1228|tcp|FLORENCE
florence|1228|udp|FLORENCE
novell-zfs|1229|tcp|Novell ZFS
novell-zfs|1229|udp|Novell ZFS
periscope|1230|tcp|Periscope
periscope|1230|udp|Periscope
menandmice-lpm|1231|tcp|menandmice-lpm
menandmice-lpm|1231|udp|menandmice-lpm
univ-appserver|1233|tcp|Universal App Server
univ-appserver|1233|udp|Universal App Server
search-agent|1234|tcp|Infoseek Search Agent
search-agent|1234|udp|Infoseek Search Agent
mosaicsyssvc1|1235|tcp|mosaicsyssvc1
mosaicsyssvc1|1235|udp|mosaicsyssvc1
bvcontrol|1236|tcp|bvcontrol
bvcontrol|1236|udp|bvcontrol
tsdos390|1237|tcp|tsdos390
tsdos390|1237|udp|tsdos390
hacl-qs|1238|tcp|hacl-qs
hacl-qs|1238|udp|hacl-qs
nmsd|1239|tcp|NMSD
nmsd|1239|udp|NMSD
instantia|1240|tcp|Instantia
instantia|1240|udp|Instantia
nessus|1241|tcp|nessus
nessus|1241|udp|nessus
nmasoverip|1242|tcp|NMAS over IP
nmasoverip|1242|udp|NMAS over IP
serialgateway|1243|tcp|SerialGateway
serialgateway|1243|udp|SerialGateway
isbconference1|1244|tcp|isbconference1
isbconference1|1244|udp|isbconference1
isbconference2|1245|tcp|isbconference2
isbconference2|1245|udp|isbconference2
payrouter|1246|tcp|payrouter
payrouter|1246|udp|payrouter
visionpyramid|1247|tcp|VisionPyramid
visionpyramid|1247|udp|VisionPyramid
hermes|1248|tcp|hermes
hermes|1248|udp|hermes
mesavistaco|1249|tcp|Mesa Vista Co
mesavistaco|1249|udp|Mesa Vista Co
swldy-sias|1250|tcp|swldy-sias
swldy-sias|1250|udp|swldy-sias
servergraph|1251|tcp|servergraph
servergraph|1251|udp|servergraph
bspne-pcc|1252|tcp|bspne-pcc
bspne-pcc|1252|udp|bspne-pcc
q55-pcc|1253|tcp|q55-pcc
q55-pcc|1253|udp|q55-pcc
de-noc|1254|tcp|de-noc
de-noc|1254|udp|de-noc
de-cache-query|1255|tcp|de-cache-query
de-cache-query|1255|udp|de-cache-query
de-server|1256|tcp|de-server
de-server|1256|udp|de-server
shockwave2|1257|tcp|Shockwave 2
shockwave2|1257|udp|Shockwave 2
opennl|1258|tcp|Open Network Library
opennl|1258|udp|Open Network Library
opennl-voice|1259|tcp|Open Network Library Voice
opennl-voice|1259|udp|Open Network Library Voice
ibm-ssd|1260|tcp|ibm-ssd
ibm-ssd|1260|udp|ibm-ssd
mpshrsv|1261|tcp|mpshrsv
mpshrsv|1261|udp|mpshrsv
qnts-orb|1262|tcp|QNTS-ORB
qnts-orb|1262|udp|QNTS-ORB
dka|1263|tcp|dka
dka|1263|udp|dka
prat|1264|tcp|PRAT
prat|1264|udp|PRAT
dssiapi|1265|tcp|DSSIAPI
dssiapi|1265|udp|DSSIAPI
dellpwrappks|1266|tcp|DELLPWRAPPKS
dellpwrappks|1266|udp|DELLPWRAPPKS
epc|1267|tcp|eTrust Policy Compliance
epc|1267|udp|eTrust Policy Compliance
propel-msgsys|1268|tcp|PROPEL-MSGSYS
propel-msgsys|1268|udp|PROPEL-MSGSYS
watilapp|1269|tcp|WATiLaPP
watilapp|1269|udp|WATiLaPP
opsmgr|1270|tcp|Microsoft Operations Manager
opsmgr|1270|udp|Microsoft Operations Manager
dabew|1271|tcp|Dabew
dabew|1271|udp|Dabew
cspmlockmgr|1272|tcp|CSPMLockMgr
cspmlockmgr|1272|udp|CSPMLockMgr
emc-gateway|1273|tcp|EMC-Gateway
emc-gateway|1273|udp|EMC-Gateway
t1distproc|1274|tcp|t1distproc
t1distproc|1274|udp|t1distproc
ivcollector|1275|tcp|ivcollector
ivcollector|1275|udp|ivcollector
ivmanager|1276|tcp|ivmanager
ivmanager|1276|udp|ivmanager
miva-mqs|1277|tcp|mqs
miva-mqs|1277|udp|mqs
dellwebadmin-1|1278|tcp|Dell Web Admin 1
dellwebadmin-1|1278|udp|Dell Web Admin 1
dellwebadmin-2|1279|tcp|Dell Web Admin 2
dellwebadmin-2|1279|udp|Dell Web Admin 2
pictrography|1280|tcp|Pictrography
pictrography|1280|udp|Pictrography
healthd|1281|tcp|healthd
healthd|1281|udp|healthd
emperion|1282|tcp|Emperion
emperion|1282|udp|Emperion
productinfo|1283|tcp|ProductInfo
productinfo|1283|udp|ProductInfo
iee-qfx|1284|tcp|IEE-QFX
iee-qfx|1284|udp|IEE-QFX
neoiface|1285|tcp|neoiface
neoiface|1285|udp|neoiface
netuitive|1286|tcp|netuitive
netuitive|1286|udp|netuitive
navbuddy|1288|tcp|NavBuddy
navbuddy|1288|udp|NavBuddy
jwalkserver|1289|tcp|JWalkServer
jwalkserver|1289|udp|JWalkServer
winjaserver|1290|tcp|WinJaServer
winjaserver|1290|udp|WinJaServer
seagulllms|1291|tcp|SEAGULLLMS
seagulllms|1291|udp|SEAGULLLMS
dsdn|1292|tcp|dsdn
dsdn|1292|udp|dsdn
pkt-krb-ipsec|1293|tcp|PKT-KRB-IPSec
pkt-krb-ipsec|1293|udp|PKT-KRB-IPSec
cmmdriver|1294|tcp|CMMdriver
cmmdriver|1294|udp|CMMdriver
ehtp|1295|tcp|End-by-Hop Transmission Protocol
ehtp|1295|udp|End-by-Hop Transmission Protocol
dproxy|1296|tcp|dproxy
dproxy|1296|udp|dproxy
sdproxy|1297|tcp|sdproxy
sdproxy|1297|udp|sdproxy
lpcp|1298|tcp|lpcp
lpcp|1298|udp|lpcp
hp-sci|1299|tcp|hp-sci
hp-sci|1299|udp|hp-sci
h323hostcallsc|1300|tcp|H323 Host Call Secure
h323hostcallsc|1300|udp|H323 Host Call Secure
ci3-software-1|1301|tcp|CI3-Software-1
ci3-software-1|1301|udp|CI3-Software-1
ci3-software-2|1302|tcp|CI3-Software-2
ci3-software-2|1302|udp|CI3-Software-2
sftsrv|1303|tcp|sftsrv
sftsrv|1303|udp|sftsrv
boomerang|1304|tcp|Boomerang
boomerang|1304|udp|Boomerang
pe-mike|1305|tcp|pe-mike
pe-mike|1305|udp|pe-mike
re-conn-proto|1306|tcp|RE-Conn-Proto
re-conn-proto|1306|udp|RE-Conn-Proto
pacmand|1307|tcp|Pacmand
pacmand|1307|udp|Pacmand
odsi|1308|tcp|Optical Domain Service Interconnect (ODSI)
odsi|1308|udp|Optical Domain Service Interconnect (ODSI)
jtag-server|1309|tcp|JTAG server
jtag-server|1309|udp|JTAG server
husky|1310|tcp|Husky
husky|1310|udp|Husky
rxmon|1311|tcp|RxMon
rxmon|1311|udp|RxMon
sti-envision|1312|tcp|STI Envision
sti-envision|1312|udp|STI Envision
bmc_patroldb|1313|tcp|BMC_PATROLDB
bmc_patroldb|1313|udp|BMC_PATROLDB
pdps|1314|tcp|Photoscript Distributed Printing System
pdps|1314|udp|Photoscript Distributed Printing System
els|1315|tcp|E.L.S., Event Listener Service
els|1315|udp|E.L.S., Event Listener Service
exbit-escp|1316|tcp|Exbit-ESCP
exbit-escp|1316|udp|Exbit-ESCP
vrts-ipcserver|1317|tcp|vrts-ipcserver
vrts-ipcserver|1317|udp|vrts-ipcserver
krb5gatekeeper|1318|tcp|krb5gatekeeper
krb5gatekeeper|1318|udp|krb5gatekeeper
panja-icsp|1319|tcp|Panja-ICSP
panja-icsp|1319|udp|Panja-ICSP
panja-axbnet|1320|tcp|Panja-AXBNET
panja-axbnet|1320|udp|Panja-AXBNET
pip|1321|tcp|PIP
pip|1321|udp|PIP
novation|1322|tcp|Novation
novation|1322|udp|Novation
brcd|1323|tcp|brcd
brcd|1323|udp|brcd
delta-mcp|1324|tcp|delta-mcp
delta-mcp|1324|udp|delta-mcp
dx-instrument|1325|tcp|DX-Instrument
dx-instrument|1325|udp|DX-Instrument
wimsic|1326|tcp|WIMSIC
wimsic|1326|udp|WIMSIC
ultrex|1327|tcp|Ultrex
ultrex|1327|udp|Ultrex
ewall|1328|tcp|EWALL
ewall|1328|udp|EWALL
netdb-export|1329|tcp|netdb-export
netdb-export|1329|udp|netdb-export
streetperfect|1330|tcp|StreetPerfect
streetperfect|1330|udp|StreetPerfect
intersan|1331|tcp|intersan
intersan|1331|udp|intersan
pcia-rxp-b|1332|tcp|PCIA RXP-B
pcia-rxp-b|1332|udp|PCIA RXP-B
passwrd-policy|1333|tcp|Password Policy
passwrd-policy|1333|udp|Password Policy
writesrv|1334|tcp|writesrv
writesrv|1334|udp|writesrv
digital-notary|1335|tcp|Digital Notary Protocol
digital-notary|1335|udp|Digital Notary Protocol
ischat|1336|tcp|Instant Service Chat
ischat|1336|udp|Instant Service Chat
menandmice-dns|1337|tcp|menandmice DNS
menandmice-dns|1337|udp|menandmice DNS
wmc-log-svc|1338|tcp|WMC-log-svr
wmc-log-svc|1338|udp|WMC-log-svr
kjtsiteserver|1339|tcp|kjtsiteserver
kjtsiteserver|1339|udp|kjtsiteserver
naap|1340|tcp|NAAP
naap|1340|udp|NAAP
qubes|1341|tcp|QuBES
qubes|1341|udp|QuBES
esbroker|1342|tcp|ESBroker
esbroker|1342|udp|ESBroker
re101|1343|tcp|re101
re101|1343|udp|re101
icap|1344|tcp|ICAP
icap|1344|udp|ICAP
vpjp|1345|tcp|VPJP
vpjp|1345|udp|VPJP
alta-ana-lm|1346|tcp|Alta Analytics License Manager
alta-ana-lm|1346|udp|Alta Analytics License Manager
bbn-mmc|1347|tcp|multi media conferencing
bbn-mmc|1347|udp|multi media conferencing
bbn-mmx|1348|tcp|multi media conferencing
bbn-mmx|1348|udp|multi media conferencing
sbook|1349|tcp|Registration Network Protocol
sbook|1349|udp|Registration Network Protocol
editbench|1350|tcp|Registration Network Protocol
editbench|1350|udp|Registration Network Protocol
equationbuilder|1351|tcp|Digital Tool Works (MIT)
equationbuilder|1351|udp|Digital Tool Works (MIT)
lotusnote|1352|tcp|Lotus Note
lotusnote|1352|udp|Lotus Note
relief|1353|tcp|Relief Consulting
relief|1353|udp|Relief Consulting
rightbrain|1354|tcp|RightBrain Software
rightbrain|1354|udp|RightBrain Software
intuitive-edge|1355|tcp|Intuitive Edge
intuitive-edge|1355|udp|Intuitive Edge
cuillamartin|1356|tcp|CuillaMartin Company
cuillamartin|1356|udp|CuillaMartin Company
pegboard|1357|tcp|Electronic PegBoard
pegboard|1357|udp|Electronic PegBoard
connlcli|1358|tcp|CONNLCLI
connlcli|1358|udp|CONNLCLI
ftsrv|1359|tcp|FTSRV
ftsrv|1359|udp|FTSRV
mimer|1360|tcp|MIMER
mimer|1360|udp|MIMER
linx|1361|tcp|LinX
linx|1361|udp|LinX
timeflies|1362|tcp|TimeFlies
timeflies|1362|udp|TimeFlies
ndm-requester|1363|tcp|Network DataMover Requester
ndm-requester|1363|udp|Network DataMover Requester
ndm-server|1364|tcp|Network DataMover Server
ndm-server|1364|udp|Network DataMover Server
adapt-sna|1365|tcp|Network Software Associates
adapt-sna|1365|udp|Network Software Associates
netware-csp|1366|tcp|Novell NetWare Comm Service Platform
netware-csp|1366|udp|Novell NetWare Comm Service Platform
dcs|1367|tcp|DCS
dcs|1367|udp|DCS
screencast|1368|tcp|ScreenCast
screencast|1368|udp|ScreenCast
gv-us|1369|tcp|GlobalView to Unix Shell
gv-us|1369|udp|GlobalView to Unix Shell
us-gv|1370|tcp|Unix Shell to GlobalView
us-gv|1370|udp|Unix Shell to GlobalView
fc-cli|1371|tcp|Fujitsu Config Protocol
fc-cli|1371|udp|Fujitsu Config Protocol
fc-ser|1372|tcp|Fujitsu Config Protocol
fc-ser|1372|udp|Fujitsu Config Protocol
chromagrafx|1373|tcp|Chromagrafx
chromagrafx|1373|udp|Chromagrafx
molly|1374|tcp|EPI Software Systems
molly|1374|udp|EPI Software Systems
bytex|1375|tcp|Bytex
bytex|1375|udp|Bytex
ibm-pps|1376|tcp|IBM Person to Person Software
ibm-pps|1376|udp|IBM Person to Person Software
cichlid|1377|tcp|Cichlid License Manager
cichlid|1377|udp|Cichlid License Manager
elan|1378|tcp|Elan License Manager
elan|1378|udp|Elan License Manager
dbreporter|1379|tcp|Integrity Solutions
dbreporter|1379|udp|Integrity Solutions
telesis-licman|1380|tcp|Telesis Network License Manager
telesis-licman|1380|udp|Telesis Network License Manager
apple-licman|1381|tcp|Apple Network License Manager
apple-licman|1381|udp|Apple Network License Manager
udt_os|1382|tcp|udt_os
udt_os|1382|udp|udt_os
gwha|1383|tcp|GW Hannaway Network License Manager
gwha|1383|udp|GW Hannaway Network License Manager
os-licman|1384|tcp|Objective Solutions License Manager
os-licman|1384|udp|Objective Solutions License Manager
atex_elmd|1385|tcp|Atex Publishing License Manager
atex_elmd|1385|udp|Atex Publishing License Manager
checksum|1386|tcp|CheckSum License Manager
checksum|1386|udp|CheckSum License Manager
cadsi-lm|1387|tcp|Computer Aided Design Software Inc LM
cadsi-lm|1387|udp|Computer Aided Design Software Inc LM
objective-dbc|1388|tcp|Objective Solutions DataBase Cache
objective-dbc|1388|udp|Objective Solutions DataBase Cache
iclpv-dm|1389|tcp|Document Manager
iclpv-dm|1389|udp|Document Manager
iclpv-sc|1390|tcp|Storage Controller
iclpv-sc|1390|udp|Storage Controller
iclpv-sas|1391|tcp|Storage Access Server
iclpv-sas|1391|udp|Storage Access Server
iclpv-pm|1392|tcp|Print Manager
iclpv-pm|1392|udp|Print Manager
iclpv-nls|1393|tcp|Network Log Server
iclpv-nls|1393|udp|Network Log Server
iclpv-nlc|1394|tcp|Network Log Client
iclpv-nlc|1394|udp|Network Log Client
iclpv-wsm|1395|tcp|PC Workstation Manager software
iclpv-wsm|1395|udp|PC Workstation Manager software
dvl-activemail|1396|tcp|DVL Active Mail
dvl-activemail|1396|udp|DVL Active Mail
audio-activmail|1397|tcp|Audio Active Mail
audio-activmail|1397|udp|Audio Active Mail
video-activmail|1398|tcp|Video Active Mail
video-activmail|1398|udp|Video Active Mail
cadkey-licman|1399|tcp|Cadkey License Manager
cadkey-licman|1399|udp|Cadkey License Manager
cadkey-tablet|1400|tcp|Cadkey Tablet Daemon
cadkey-tablet|1400|udp|Cadkey Tablet Daemon
goldleaf-licman|1401|tcp|Goldleaf License Manager
goldleaf-licman|1401|udp|Goldleaf License Manager
prm-sm-np|1402|tcp|Prospero Resource Manager
prm-sm-np|1402|udp|Prospero Resource Manager
prm-nm-np|1403|tcp|Prospero Resource Manager
prm-nm-np|1403|udp|Prospero Resource Manager
igi-lm|1404|tcp|Infinite Graphics License Manager
igi-lm|1404|udp|Infinite Graphics License Manager
ibm-res|1405|tcp|IBM Remote Execution Starter
ibm-res|1405|udp|IBM Remote Execution Starter
netlabs-lm|1406|tcp|NetLabs License Manager
netlabs-lm|1406|udp|NetLabs License Manager
dbsa-lm|1407|tcp|DBSA License Manager
dbsa-lm|1407|udp|DBSA License Manager
sophia-lm|1408|tcp|Sophia License Manager
sophia-lm|1408|udp|Sophia License Manager
here-lm|1409|tcp|Here License Manager
here-lm|1409|udp|Here License Manager
hiq|1410|tcp|HiQ License Manager
hiq|1410|udp|HiQ License Manager
af|1411|tcp|AudioFile
af|1411|udp|AudioFile
innosys|1412|tcp|InnoSys
innosys|1412|udp|InnoSys
innosys-acl|1413|tcp|Innosys-ACL
innosys-acl|1413|udp|Innosys-ACL
ibm-mqseries|1414|tcp|IBM MQSeries
ibm-mqseries|1414|udp|IBM MQSeries
dbstar|1415|tcp|DBStar
dbstar|1415|udp|DBStar
novell-lu6.2|1416|tcp|Novell LU6.2
novell-lu6.2|1416|udp|Novell LU6.2
timbuktu-srv1|1417|tcp|Timbuktu Service 1 Port
timbuktu-srv1|1417|udp|Timbuktu Service 1 Port
timbuktu-srv2|1418|tcp|Timbuktu Service 2 Port
timbuktu-srv2|1418|udp|Timbuktu Service 2 Port
timbuktu-srv3|1419|tcp|Timbuktu Service 3 Port
timbuktu-srv3|1419|udp|Timbuktu Service 3 Port
timbuktu-srv4|1420|tcp|Timbuktu Service 4 Port
timbuktu-srv4|1420|udp|Timbuktu Service 4 Port
gandalf-lm|1421|tcp|Gandalf License Manager
gandalf-lm|1421|udp|Gandalf License Manager
autodesk-lm|1422|tcp|Autodesk License Manager
autodesk-lm|1422|udp|Autodesk License Manager
essbase|1423|tcp|Essbase Arbor Software
essbase|1423|udp|Essbase Arbor Software
hybrid|1424|tcp|Hybrid Encryption Protocol
hybrid|1424|udp|Hybrid Encryption Protocol
zion-lm|1425|tcp|Zion Software License Manager
zion-lm|1425|udp|Zion Software License Manager
sais|1426|tcp|Satellite-data Acquisition System 1
sais|1426|udp|Satellite-data Acquisition System 1
mloadd|1427|tcp|mloadd monitoring tool
mloadd|1427|udp|mloadd monitoring tool
informatik-lm|1428|tcp|Informatik License Manager
informatik-lm|1428|udp|Informatik License Manager
nms|1429|tcp|Hypercom NMS
nms|1429|udp|Hypercom NMS
tpdu|1430|tcp|Hypercom TPDU
tpdu|1430|udp|Hypercom TPDU
rgtp|1431|tcp|Reverse Gossip Transport
rgtp|1431|udp|Reverse Gossip Transport
blueberry-lm|1432|tcp|Blueberry Software License Manager
blueberry-lm|1432|udp|Blueberry Software License Manager
ms-sql-s|1433|tcp|Microsoft-SQL-Server
ms-sql-s|1433|udp|Microsoft-SQL-Server
ms-sql-m|1434|tcp|Microsoft-SQL-Monitor
ms-sql-m|1434|udp|Microsoft-SQL-Monitor
ibm-cics|1435|tcp|IBM CICS
ibm-cics|1435|udp|IBM CICS
saism|1436|tcp|Satellite-data Acquisition System 2
saism|1436|udp|Satellite-data Acquisition System 2
tabula|1437|tcp|Tabula
tabula|1437|udp|Tabula
eicon-server|1438|tcp|Eicon Security Agent/Server
eicon-server|1438|udp|Eicon Security Agent/Server
eicon-x25|1439|tcp|Eicon X25/SNA Gateway
eicon-x25|1439|udp|Eicon X25/SNA Gateway
eicon-slp|1440|tcp|Eicon Service Location Protocol
eicon-slp|1440|udp|Eicon Service Location Protocol
cadis-1|1441|tcp|Cadis License Management
cadis-1|1441|udp|Cadis License Management
cadis-2|1442|tcp|Cadis License Management
cadis-2|1442|udp|Cadis License Management
ies-lm|1443|tcp|Integrated Engineering Software
ies-lm|1443|udp|Integrated Engineering Software
marcam-lm|1444|tcp|Marcam  License Management
marcam-lm|1444|udp|Marcam  License Management
proxima-lm|1445|tcp|Proxima License Manager
proxima-lm|1445|udp|Proxima License Manager
ora-lm|1446|tcp|Optical Research Associates License Manager
ora-lm|1446|udp|Optical Research Associates License Manager
apri-lm|1447|tcp|Applied Parallel Research LM
apri-lm|1447|udp|Applied Parallel Research LM
oc-lm|1448|tcp|OpenConnect License Manager
oc-lm|1448|udp|OpenConnect License Manager
peport|1449|tcp|PEport
peport|1449|udp|PEport
dwf|1450|tcp|Tandem Distributed Workbench Facility
dwf|1450|udp|Tandem Distributed Workbench Facility
infoman|1451|tcp|IBM Information Management
infoman|1451|udp|IBM Information Management
gtegsc-lm|1452|tcp|GTE Government Systems License Man
gtegsc-lm|1452|udp|GTE Government Systems License Man
genie-lm|1453|tcp|Genie License Manager
genie-lm|1453|udp|Genie License Manager
interhdl_elmd|1454|tcp|interHDL License Manager
interhdl_elmd|1454|udp|interHDL License Manager
esl-lm|1455|tcp|ESL License Manager
esl-lm|1455|udp|ESL License Manager
dca|1456|tcp|DCA
dca|1456|udp|DCA
valisys-lm|1457|tcp|Valisys License Manager
valisys-lm|1457|udp|Valisys License Manager
nrcabq-lm|1458|tcp|Nichols Research Corp.
nrcabq-lm|1458|udp|Nichols Research Corp.
proshare1|1459|tcp|Proshare Notebook Application
proshare1|1459|udp|Proshare Notebook Application
proshare2|1460|tcp|Proshare Notebook Application
proshare2|1460|udp|Proshare Notebook Application
ibm_wrless_lan|1461|tcp|IBM Wireless LAN
ibm_wrless_lan|1461|udp|IBM Wireless LAN
world-lm|1462|tcp|World License Manager
world-lm|1462|udp|World License Manager
nucleus|1463|tcp|Nucleus
nucleus|1463|udp|Nucleus
msl_lmd|1464|tcp|MSL License Manager
msl_lmd|1464|udp|MSL License Manager
pipes|1465|tcp|Pipes Platform
pipes|1465|udp|Pipes Platform  mfarlin@peerlogic.com
oceansoft-lm|1466|tcp|Ocean Software License Manager
oceansoft-lm|1466|udp|Ocean Software License Manager
csdmbase|1467|tcp|CSDMBASE
csdmbase|1467|udp|CSDMBASE
csdm|1468|tcp|CSDM
csdm|1468|udp|CSDM
aal-lm|1469|tcp|Active Analysis Limited License Manager
aal-lm|1469|udp|Active Analysis Limited License Manager
uaiact|1470|tcp|Universal Analytics
uaiact|1470|udp|Universal Analytics
csdmbase|1471|tcp|csdmbase
csdmbase|1471|udp|csdmbase
csdm|1472|tcp|csdm
csdm|1472|udp|csdm
openmath|1473|tcp|OpenMath
openmath|1473|udp|OpenMath
telefinder|1474|tcp|Telefinder
telefinder|1474|udp|Telefinder
taligent-lm|1475|tcp|Taligent License Manager
taligent-lm|1475|udp|Taligent License Manager
clvm-cfg|1476|tcp|clvm-cfg
clvm-cfg|1476|udp|clvm-cfg
ms-sna-server|1477|tcp|ms-sna-server
ms-sna-server|1477|udp|ms-sna-server
ms-sna-base|1478|tcp|ms-sna-base
ms-sna-base|1478|udp|ms-sna-base
dberegister|1479|tcp|dberegister
dberegister|1479|udp|dberegister
pacerforum|1480|tcp|PacerForum
pacerforum|1480|udp|PacerForum
airs|1481|tcp|AIRS
airs|1481|udp|AIRS
miteksys-lm|1482|tcp|Miteksys License Manager
miteksys-lm|1482|udp|Miteksys License Manager
afs|1483|tcp|AFS License Manager
afs|1483|udp|AFS License Manager
confluent|1484|tcp|Confluent License Manager
confluent|1484|udp|Confluent License Manager
lansource|1485|tcp|LANSource
lansource|1485|udp|LANSource
nms_topo_serv|1486|tcp|nms_topo_serv
nms_topo_serv|1486|udp|nms_topo_serv
localinfosrvr|1487|tcp|LocalInfoSrvr
localinfosrvr|1487|udp|LocalInfoSrvr
docstor|1488|tcp|DocStor
docstor|1488|udp|DocStor
dmdocbroker|1489|tcp|dmdocbroker
dmdocbroker|1489|udp|dmdocbroker
insitu-conf|1490|tcp|insitu-conf
insitu-conf|1490|udp|insitu-conf
anynetgateway|1491|tcp|anynetgateway
anynetgateway|1491|udp|anynetgateway
stone-design-1|1492|tcp|stone-design-1
stone-design-1|1492|udp|stone-design-1
netmap_lm|1493|tcp|netmap_lm
netmap_lm|1493|udp|netmap_lm
ica|1494|tcp|ica
ica|1494|udp|ica
cvc|1495|tcp|cvc
cvc|1495|udp|cvc
liberty-lm|1496|tcp|liberty-lm
liberty-lm|1496|udp|liberty-lm
rfx-lm|1497|tcp|rfx-lm
rfx-lm|1497|udp|rfx-lm
sybase-sqlany|1498|tcp|Sybase SQL Any
sybase-sqlany|1498|udp|Sybase SQL Any
fhc|1499|tcp|Federico Heinz Consultora
fhc|1499|udp|Federico Heinz Consultora
vlsi-lm|1500|tcp|VLSI License Manager
vlsi-lm|1500|udp|VLSI License Manager
saiscm|1501|tcp|Satellite-data Acquisition System 3
saiscm|1501|udp|Satellite-data Acquisition System 3
shivadiscovery|1502|tcp|Shiva
shivadiscovery|1502|udp|Shiva
imtc-mcs|1503|tcp|Databeam
imtc-mcs|1503|udp|Databeam
evb-elm|1504|tcp|EVB Software Engineering License Manager
evb-elm|1504|udp|EVB Software Engineering License Manager
funkproxy|1505|tcp|Funk Software, Inc.
funkproxy|1505|udp|Funk Software, Inc.
utcd|1506|tcp|Universal Time daemon (utcd)
utcd|1506|udp|Universal Time daemon (utcd)
symplex|1507|tcp|symplex
symplex|1507|udp|symplex
diagmond|1508|tcp|diagmond
diagmond|1508|udp|diagmond
robcad-lm|1509|tcp|Robcad, Ltd. License Manager
robcad-lm|1509|udp|Robcad, Ltd. License Manager
mvx-lm|1510|tcp|Midland Valley Exploration Ltd. Lic. Man.
mvx-lm|1510|udp|Midland Valley Exploration Ltd. Lic. Man.
3l-l1|1511|tcp|3l-l1
3l-l1|1511|udp|3l-l1
wins|1512|tcp|Microsoft's Windows Internet Name Service
wins|1512|udp|Microsoft's Windows Internet Name Service
fujitsu-dtc|1513|tcp|Fujitsu Systems Business of America, Inc
fujitsu-dtc|1513|udp|Fujitsu Systems Business of America, Inc
fujitsu-dtcns|1514|tcp|Fujitsu Systems Business of America, Inc
fujitsu-dtcns|1514|udp|Fujitsu Systems Business of America, Inc
ifor-protocol|1515|tcp|ifor-protocol
ifor-protocol|1515|udp|ifor-protocol
vpad|1516|tcp|Virtual Places Audio data
vpad|1516|udp|Virtual Places Audio data
vpac|1517|tcp|Virtual Places Audio control
vpac|1517|udp|Virtual Places Audio control
vpvd|1518|tcp|Virtual Places Video data
vpvd|1518|udp|Virtual Places Video data
vpvc|1519|tcp|Virtual Places Video control
vpvc|1519|udp|Virtual Places Video control
atm-zip-office|1520|tcp|atm zip office
atm-zip-office|1520|udp|atm zip office
ncube-lm|1521|tcp|nCube License Manager
ncube-lm|1521|udp|nCube License Manager
ricardo-lm|1522|tcp|Ricardo North America License Manager
ricardo-lm|1522|udp|Ricardo North America License Manager
cichild-lm|1523|tcp|cichild
cichild-lm|1523|udp|cichild
ingreslock|1524|tcp|ingres
ingreslock|1524|udp|ingres
orasrv|1525|tcp|oracle
orasrv|1525|udp|oracle
prospero-np|1525|tcp|Prospero Directory Service non-priv
prospero-np|1525|udp|Prospero Directory Service non-priv
pdap-np|1526|tcp|Prospero Data Access Prot non-priv
pdap-np|1526|udp|Prospero Data Access Prot non-priv
tlisrv|1527|tcp|oracle
tlisrv|1527|udp|oracle
mciautoreg|1528|tcp|micautoreg
mciautoreg|1528|udp|micautoreg
coauthor|1529|tcp|oracle
coauthor|1529|udp|oracle
rap-service|1530|tcp|rap-service
rap-service|1530|udp|rap-service
rap-listen|1531|tcp|rap-listen
rap-listen|1531|udp|rap-listen
miroconnect|1532|tcp|miroconnect
miroconnect|1532|udp|miroconnect
virtual-places|1533|tcp|Virtual Places Software
virtual-places|1533|udp|Virtual Places Software
micromuse-lm|1534|tcp|micromuse-lm
micromuse-lm|1534|udp|micromuse-lm
ampr-info|1535|tcp|ampr-info
ampr-info|1535|udp|ampr-info
ampr-inter|1536|tcp|ampr-inter
ampr-inter|1536|udp|ampr-inter
sdsc-lm|1537|tcp|isi-lm
sdsc-lm|1537|udp|isi-lm
3ds-lm|1538|tcp|3ds-lm
3ds-lm|1538|udp|3ds-lm
intellistor-lm|1539|tcp|Intellistor License Manager
intellistor-lm|1539|udp|Intellistor License Manager
rds|1540|tcp|rds
rds|1540|udp|rds
rds2|1541|tcp|rds2
rds2|1541|udp|rds2
gridgen-elmd|1542|tcp|gridgen-elmd
gridgen-elmd|1542|udp|gridgen-elmd
simba-cs|1543|tcp|simba-cs
simba-cs|1543|udp|simba-cs
aspeclmd|1544|tcp|aspeclmd
aspeclmd|1544|udp|aspeclmd
vistium-share|1545|tcp|vistium-share
vistium-share|1545|udp|vistium-share
abbaccuray|1546|tcp|abbaccuray
abbaccuray|1546|udp|abbaccuray
laplink|1547|tcp|laplink
laplink|1547|udp|laplink
axon-lm|1548|tcp|Axon License Manager
axon-lm|1548|udp|Axon License Manager
shivahose|1549|tcp|Shiva Hose
shivasound|1549|udp|Shiva Sound
3m-image-lm|1550|tcp|Image Storage license manager 3M Company
3m-image-lm|1550|udp|Image Storage license manager 3M Company
hecmtl-db|1551|tcp|HECMTL-DB
hecmtl-db|1551|udp|HECMTL-DB
pciarray|1552|tcp|pciarray
pciarray|1552|udp|pciarray
sna-cs|1553|tcp|sna-cs
sna-cs|1553|udp|sna-cs
caci-lm|1554|tcp|CACI Products Company License Manager
caci-lm|1554|udp|CACI Products Company License Manager
livelan|1555|tcp|livelan
livelan|1555|udp|livelan
ashwin|1556|tcp|AshWin CI Tecnologies
ashwin|1556|udp|AshWin CI Tecnologies
arbortext-lm|1557|tcp|ArborText License Manager
arbortext-lm|1557|udp|ArborText License Manager
xingmpeg|1558|tcp|xingmpeg
xingmpeg|1558|udp|xingmpeg
web2host|1559|tcp|web2host
web2host|1559|udp|web2host
asci-val|1560|tcp|ASCI-RemoteSHADOW
asci-val|1560|udp|ASCI-RemoteSHADOW
facilityview|1561|tcp|facilityview
facilityview|1561|udp|facilityview
pconnectmgr|1562|tcp|pconnectmgr
pconnectmgr|1562|udp|pconnectmgr
cadabra-lm|1563|tcp|Cadabra License Manager
cadabra-lm|1563|udp|Cadabra License Manager
pay-per-view|1564|tcp|Pay-Per-View
pay-per-view|1564|udp|Pay-Per-View
winddlb|1565|tcp|WinDD
winddlb|1565|udp|WinDD
corelvideo|1566|tcp|CORELVIDEO
corelvideo|1566|udp|CORELVIDEO
jlicelmd|1567|tcp|jlicelmd
jlicelmd|1567|udp|jlicelmd
tsspmap|1568|tcp|tsspmap
tsspmap|1568|udp|tsspmap
ets|1569|tcp|ets
ets|1569|udp|ets
orbixd|1570|tcp|orbixd
orbixd|1570|udp|orbixd
rdb-dbs-disp|1571|tcp|Oracle Remote Data Base
rdb-dbs-disp|1571|udp|Oracle Remote Data Base
chip-lm|1572|tcp|Chipcom License Manager
chip-lm|1572|udp|Chipcom License Manager
itscomm-ns|1573|tcp|itscomm-ns
itscomm-ns|1573|udp|itscomm-ns
mvel-lm|1574|tcp|mvel-lm
mvel-lm|1574|udp|mvel-lm
oraclenames|1575|tcp|oraclenames
oraclenames|1575|udp|oraclenames
moldflow-lm|1576|tcp|moldflow-lm
moldflow-lm|1576|udp|moldflow-lm
hypercube-lm|1577|tcp|hypercube-lm
hypercube-lm|1577|udp|hypercube-lm
jacobus-lm|1578|tcp|Jacobus License Manager
jacobus-lm|1578|udp|Jacobus License Manager
ioc-sea-lm|1579|tcp|ioc-sea-lm
ioc-sea-lm|1579|udp|ioc-sea-lm
tn-tl-r1|1580|tcp|tn-tl-r1
tn-tl-r2|1580|udp|tn-tl-r2
mil-2045-47001|1581|tcp|MIL-2045-47001
mil-2045-47001|1581|udp|MIL-2045-47001
msims|1582|tcp|MSIMS
msims|1582|udp|MSIMS
simbaexpress|1583|tcp|simbaexpress
simbaexpress|1583|udp|simbaexpress
tn-tl-fd2|1584|tcp|tn-tl-fd2
tn-tl-fd2|1584|udp|tn-tl-fd2
intv|1585|tcp|intv
intv|1585|udp|intv
ibm-abtact|1586|tcp|ibm-abtact
ibm-abtact|1586|udp|ibm-abtact
pra_elmd|1587|tcp|pra_elmd
pra_elmd|1587|udp|pra_elmd
triquest-lm|1588|tcp|triquest-lm
triquest-lm|1588|udp|triquest-lm
vqp|1589|tcp|VQP
vqp|1589|udp|VQP
gemini-lm|1590|tcp|gemini-lm
gemini-lm|1590|udp|gemini-lm
ncpm-pm|1591|tcp|ncpm-pm
ncpm-pm|1591|udp|ncpm-pm
commonspace|1592|tcp|commonspace
commonspace|1592|udp|commonspace
mainsoft-lm|1593|tcp|mainsoft-lm
mainsoft-lm|1593|udp|mainsoft-lm
sixtrak|1594|tcp|sixtrak
sixtrak|1594|udp|sixtrak
radio|1595|tcp|radio
radio|1595|udp|radio
radio-sm|1596|tcp|radio-sm
radio-bc|1596|udp|radio-bc
orbplus-iiop|1597|tcp|orbplus-iiop
orbplus-iiop|1597|udp|orbplus-iiop
picknfs|1598|tcp|picknfs
picknfs|1598|udp|picknfs
simbaservices|1599|tcp|simbaservices
simbaservices|1599|udp|simbaservices
issd|1600|tcp|issd
issd|1600|udp|issd
aas|1601|tcp|aas
aas|1601|udp|aas
inspect|1602|tcp|inspect
inspect|1602|udp|inspect
picodbc|1603|tcp|pickodbc
picodbc|1603|udp|pickodbc
icabrowser|1604|tcp|icabrowser
icabrowser|1604|udp|icabrowser
slp|1605|tcp|Salutation Manager (Salutation Protocol)
slp|1605|udp|Salutation Manager (Salutation Protocol)
slm-api|1606|tcp|Salutation Manager (SLM-API)
slm-api|1606|udp|Salutation Manager (SLM-API)
stt|1607|tcp|stt
stt|1607|udp|stt
smart-lm|1608|tcp|Smart Corp. License Manager
smart-lm|1608|udp|Smart Corp. License Manager
isysg-lm|1609|tcp|isysg-lm
isysg-lm|1609|udp|isysg-lm
taurus-wh|1610|tcp|taurus-wh
taurus-wh|1610|udp|taurus-wh
ill|1611|tcp|Inter Library Loan
ill|1611|udp|Inter Library Loan
netbill-trans|1612|tcp|NetBill Transaction Server
netbill-trans|1612|udp|NetBill Transaction Server
netbill-keyrep|1613|tcp|NetBill Key Repository
netbill-keyrep|1613|udp|NetBill Key Repository
netbill-cred|1614|tcp|NetBill Credential Server
netbill-cred|1614|udp|NetBill Credential Server
netbill-auth|1615|tcp|NetBill Authorization Server
netbill-auth|1615|udp|NetBill Authorization Server
netbill-prod|1616|tcp|NetBill Product Server
netbill-prod|1616|udp|NetBill Product Server
nimrod-agent|1617|tcp|Nimrod Inter-Agent Communication
nimrod-agent|1617|udp|Nimrod Inter-Agent Communication
skytelnet|1618|tcp|skytelnet
skytelnet|1618|udp|skytelnet
xs-openstorage|1619|tcp|xs-openstorage
xs-openstorage|1619|udp|xs-openstorage
faxportwinport|1620|tcp|faxportwinport
faxportwinport|1620|udp|faxportwinport
softdataphone|1621|tcp|softdataphone
softdataphone|1621|udp|softdataphone
ontime|1622|tcp|ontime
ontime|1622|udp|ontime
jaleosnd|1623|tcp|jaleosnd
jaleosnd|1623|udp|jaleosnd
udp-sr-port|1624|tcp|udp-sr-port
udp-sr-port|1624|udp|udp-sr-port
svs-omagent|1625|tcp|svs-omagent
svs-omagent|1625|udp|svs-omagent
shockwave|1626|tcp|Shockwave
shockwave|1626|udp|Shockwave
t128-gateway|1627|tcp|T.128 Gateway
t128-gateway|1627|udp|T.128 Gateway
lontalk-norm|1628|tcp|LonTalk normal
lontalk-norm|1628|udp|LonTalk normal
lontalk-urgnt|1629|tcp|LonTalk urgent
lontalk-urgnt|1629|udp|LonTalk urgent
oraclenet8cman|1630|tcp|Oracle Net8 Cman
oraclenet8cman|1630|udp|Oracle Net8 Cman
visitview|1631|tcp|Visit view
visitview|1631|udp|Visit view
pammratc|1632|tcp|PAMMRATC
pammratc|1632|udp|PAMMRATC
pammrpc|1633|tcp|PAMMRPC
pammrpc|1633|udp|PAMMRPC
loaprobe|1634|tcp|Log On America Probe
loaprobe|1634|udp|Log On America Probe
edb-server1|1635|tcp|EDB Server 1
edb-server1|1635|udp|EDB Server 1
cncp|1636|tcp|CableNet Control Protocol
cncp|1636|udp|CableNet Control Protocol
cnap|1637|tcp|CableNet Admin Protocol
cnap|1637|udp|CableNet Admin Protocol
cnip|1638|tcp|CableNet Info Protocol
cnip|1638|udp|CableNet Info Protocol
cert-initiator|1639|tcp|cert-initiator
cert-initiator|1639|udp|cert-initiator
cert-responder|1640|tcp|cert-responder
cert-responder|1640|udp|cert-responder
invision|1641|tcp|InVision
invision|1641|udp|InVision
isis-am|1642|tcp|isis-am
isis-am|1642|udp|isis-am
isis-ambc|1643|tcp|isis-ambc
isis-ambc|1643|udp|isis-ambc
saiseh|1644|tcp|Satellite-data Acquisition System 4
sightline|1645|tcp|SightLine
sightline|1645|udp|SightLine
sa-msg-port|1646|tcp|sa-msg-port
sa-msg-port|1646|udp|sa-msg-port
rsap|1647|tcp|rsap
rsap|1647|udp|rsap
concurrent-lm|1648|tcp|concurrent-lm
concurrent-lm|1648|udp|concurrent-lm
kermit|1649|tcp|kermit
kermit|1649|udp|kermit
nkd|1650|tcp|nkdn
nkd|1650|udp|nkd
shiva_confsrvr|1651|tcp|shiva_confsrvr
shiva_confsrvr|1651|udp|shiva_confsrvr
xnmp|1652|tcp|xnmp
xnmp|1652|udp|xnmp
alphatech-lm|1653|tcp|alphatech-lm
alphatech-lm|1653|udp|alphatech-lm
stargatealerts|1654|tcp|stargatealerts
stargatealerts|1654|udp|stargatealerts
dec-mbadmin|1655|tcp|dec-mbadmin
dec-mbadmin|1655|udp|dec-mbadmin
dec-mbadmin-h|1656|tcp|dec-mbadmin-h
dec-mbadmin-h|1656|udp|dec-mbadmin-h
fujitsu-mmpdc|1657|tcp|fujitsu-mmpdc
fujitsu-mmpdc|1657|udp|fujitsu-mmpdc
sixnetudr|1658|tcp|sixnetudr
sixnetudr|1658|udp|sixnetudr
sg-lm|1659|tcp|Silicon Grail License Manager
sg-lm|1659|udp|Silicon Grail License Manager
skip-mc-gikreq|1660|tcp|skip-mc-gikreq
skip-mc-gikreq|1660|udp|skip-mc-gikreq
netview-aix-1|1661|tcp|netview-aix-1
netview-aix-1|1661|udp|netview-aix-1
netview-aix-2|1662|tcp|netview-aix-2
netview-aix-2|1662|udp|netview-aix-2
netview-aix-3|1663|tcp|netview-aix-3
netview-aix-3|1663|udp|netview-aix-3
netview-aix-4|1664|tcp|netview-aix-4
netview-aix-4|1664|udp|netview-aix-4
netview-aix-5|1665|tcp|netview-aix-5
netview-aix-5|1665|udp|netview-aix-5
netview-aix-6|1666|tcp|netview-aix-6
netview-aix-6|1666|udp|netview-aix-6
netview-aix-7|1667|tcp|netview-aix-7
netview-aix-7|1667|udp|netview-aix-7
netview-aix-8|1668|tcp|netview-aix-8
netview-aix-8|1668|udp|netview-aix-8
netview-aix-9|1669|tcp|netview-aix-9
netview-aix-9|1669|udp|netview-aix-9
netview-aix-10|1670|tcp|netview-aix-10
netview-aix-10|1670|udp|netview-aix-10
netview-aix-11|1671|tcp|netview-aix-11
netview-aix-11|1671|udp|netview-aix-11
netview-aix-12|1672|tcp|netview-aix-12
netview-aix-12|1672|udp|netview-aix-12
proshare-mc-1|1673|tcp|Intel Proshare Multicast
proshare-mc-1|1673|udp|Intel Proshare Multicast
proshare-mc-2|1674|tcp|Intel Proshare Multicast
proshare-mc-2|1674|udp|Intel Proshare Multicast
pdp|1675|tcp|Pacific Data Products
pdp|1675|udp|Pacific Data Products
netcomm1|1676|tcp|netcomm1
netcomm2|1676|udp|netcomm2
groupwise|1677|tcp|groupwise
groupwise|1677|udp|groupwise
prolink|1678|tcp|prolink
prolink|1678|udp|prolink
darcorp-lm|1679|tcp|darcorp-lm
darcorp-lm|1679|udp|darcorp-lm
microcom-sbp|1680|tcp|microcom-sbp
microcom-sbp|1680|udp|microcom-sbp
sd-elmd|1681|tcp|sd-elmd
sd-elmd|1681|udp|sd-elmd
lanyon-lantern|1682|tcp|lanyon-lantern
lanyon-lantern|1682|udp|lanyon-lantern
ncpm-hip|1683|tcp|ncpm-hip
ncpm-hip|1683|udp|ncpm-hip
snaresecure|1684|tcp|SnareSecure
snaresecure|1684|udp|SnareSecure
n2nremote|1685|tcp|n2nremote
n2nremote|1685|udp|n2nremote
cvmon|1686|tcp|cvmon
cvmon|1686|udp|cvmon
nsjtp-ctrl|1687|tcp|nsjtp-ctrl
nsjtp-ctrl|1687|udp|nsjtp-ctrl
nsjtp-data|1688|tcp|nsjtp-data
nsjtp-data|1688|udp|nsjtp-data
firefox|1689|tcp|firefox
firefox|1689|udp|firefox
ng-umds|1690|tcp|ng-umds
ng-umds|1690|udp|ng-umds
empire-empuma|1691|tcp|empire-empuma
empire-empuma|1691|udp|empire-empuma
sstsys-lm|1692|tcp|sstsys-lm
sstsys-lm|1692|udp|sstsys-lm
rrirtr|1693|tcp|rrirtr
rrirtr|1693|udp|rrirtr
rrimwm|1694|tcp|rrimwm
rrimwm|1694|udp|rrimwm
rrilwm|1695|tcp|rrilwm
rrilwm|1695|udp|rrilwm
rrifmm|1696|tcp|rrifmm
rrifmm|1696|udp|rrifmm
rrisat|1697|tcp|rrisat
rrisat|1697|udp|rrisat
rsvp-encap-1|1698|tcp|RSVP-ENCAPSULATION-1
rsvp-encap-1|1698|udp|RSVP-ENCAPSULATION-1
rsvp-encap-2|1699|tcp|RSVP-ENCAPSULATION-2
rsvp-encap-2|1699|udp|RSVP-ENCAPSULATION-2
mps-raft|1700|tcp|mps-raft
mps-raft|1700|udp|mps-raft
l2f|1701|tcp|l2f
l2f|1701|udp|l2f
l2tp|1701|tcp|l2tp
l2tp|1701|udp|l2tp
deskshare|1702|tcp|deskshare
deskshare|1702|udp|deskshare
hb-engine|1703|tcp|hb-engine
hb-engine|1703|udp|hb-engine
bcs-broker|1704|tcp|bcs-broker
bcs-broker|1704|udp|bcs-broker
slingshot|1705|tcp|slingshot
slingshot|1705|udp|slingshot
jetform|1706|tcp|jetform
jetform|1706|udp|jetform
vdmplay|1707|tcp|vdmplay
vdmplay|1707|udp|vdmplay
gat-lmd|1708|tcp|gat-lmd
gat-lmd|1708|udp|gat-lmd
centra|1709|tcp|centra
centra|1709|udp|centra
impera|1710|tcp|impera
impera|1710|udp|impera
pptconference|1711|tcp|pptconference
pptconference|1711|udp|pptconference
registrar|1712|tcp|resource monitoring service
registrar|1712|udp|resource monitoring service
conferencetalk|1713|tcp|ConferenceTalk
conferencetalk|1713|udp|ConferenceTalk
sesi-lm|1714|tcp|sesi-lm
sesi-lm|1714|udp|sesi-lm
houdini-lm|1715|tcp|houdini-lm
houdini-lm|1715|udp|houdini-lm
xmsg|1716|tcp|xmsg
xmsg|1716|udp|xmsg
fj-hdnet|1717|tcp|fj-hdnet
fj-hdnet|1717|udp|fj-hdnet
h323gatedisc|1718|tcp|h323gatedisc
h323gatedisc|1718|udp|h323gatedisc
h323gatestat|1719|tcp|h323gatestat
h323gatestat|1719|udp|h323gatestat
h323hostcall|1720|tcp|h323hostcall
h323hostcall|1720|udp|h323hostcall
caicci|1721|tcp|caicci
caicci|1721|udp|caicci
hks-lm|1722|tcp|HKS License Manager
hks-lm|1722|udp|HKS License Manager
pptp|1723|tcp|pptp
pptp|1723|udp|pptp
csbphonemaster|1724|tcp|csbphonemaster
csbphonemaster|1724|udp|csbphonemaster
iden-ralp|1725|tcp|iden-ralp
iden-ralp|1725|udp|iden-ralp
iberiagames|1726|tcp|IBERIAGAMES
iberiagames|1726|udp|IBERIAGAMES
winddx|1727|tcp|winddx
winddx|1727|udp|winddx
telindus|1728|tcp|TELINDUS
telindus|1728|udp|TELINDUS
citynl|1729|tcp|CityNL License Management
citynl|1729|udp|CityNL License Management
roketz|1730|tcp|roketz
roketz|1730|udp|roketz
msiccp|1731|tcp|MSICCP
msiccp|1731|udp|MSICCP
proxim|1732|tcp|proxim
proxim|1732|udp|proxim
siipat|1733|tcp|SIMS - SIIPAT Protocol for Alarm Transmission
siipat|1733|udp|SIMS - SIIPAT Protocol for Alarm Transmission
cambertx-lm|1734|tcp|Camber Corporation License Management
cambertx-lm|1734|udp|Camber Corporation License Management
privatechat|1735|tcp|PrivateChat
privatechat|1735|udp|PrivateChat
street-stream|1736|tcp|street-stream
street-stream|1736|udp|street-stream
ultimad|1737|tcp|ultimad
ultimad|1737|udp|ultimad
gamegen1|1738|tcp|GameGen1
gamegen1|1738|udp|GameGen1
webaccess|1739|tcp|webaccess
webaccess|1739|udp|webaccess
encore|1740|tcp|encore
encore|1740|udp|encore
cisco-net-mgmt|1741|tcp|cisco-net-mgmt
cisco-net-mgmt|1741|udp|cisco-net-mgmt
3Com-nsd|1742|tcp|3Com-nsd
3Com-nsd|1742|udp|3Com-nsd
cinegrfx-lm|1743|tcp|Cinema Graphics License Manager
cinegrfx-lm|1743|udp|Cinema Graphics License Manager
ncpm-ft|1744|tcp|ncpm-ft
ncpm-ft|1744|udp|ncpm-ft
remote-winsock|1745|tcp|remote-winsock
remote-winsock|1745|udp|remote-winsock
ftrapid-1|1746|tcp|ftrapid-1
ftrapid-1|1746|udp|ftrapid-1
ftrapid-2|1747|tcp|ftrapid-2
ftrapid-2|1747|udp|ftrapid-2
oracle-em1|1748|tcp|oracle-em1
oracle-em1|1748|udp|oracle-em1
aspen-services|1749|tcp|aspen-services
aspen-services|1749|udp|aspen-services
sslp|1750|tcp|Simple Socket Library's PortMaster
sslp|1750|udp|Simple Socket Library's PortMaster
swiftnet|1751|tcp|SwiftNet
swiftnet|1751|udp|SwiftNet
lofr-lm|1752|tcp|Leap of Faith Research License Manager
lofr-lm|1752|udp|Leap of Faith Research License Manager
translogic-lm|1753|tcp|Translogic License Manager
translogic-lm|1753|udp|Translogic License Manager
oracle-em2|1754|tcp|oracle-em2
oracle-em2|1754|udp|oracle-em2
ms-streaming|1755|tcp|ms-streaming
ms-streaming|1755|udp|ms-streaming
capfast-lmd|1756|tcp|capfast-lmd
capfast-lmd|1756|udp|capfast-lmd
cnhrp|1757|tcp|cnhrp
cnhrp|1757|udp|cnhrp
tftp-mcast|1758|tcp|tftp-mcast
tftp-mcast|1758|udp|tftp-mcast
spss-lm|1759|tcp|SPSS License Manager
spss-lm|1759|udp|SPSS License Manager
www-ldap-gw|1760|tcp|www-ldap-gw
www-ldap-gw|1760|udp|www-ldap-gw
cft-0|1761|tcp|cft-0
cft-0|1761|udp|cft-0
cft-1|1762|tcp|cft-1
cft-1|1762|udp|cft-1
cft-2|1763|tcp|cft-2
cft-2|1763|udp|cft-2
cft-3|1764|tcp|cft-3
cft-3|1764|udp|cft-3
cft-4|1765|tcp|cft-4
cft-4|1765|udp|cft-4
cft-5|1766|tcp|cft-5
cft-5|1766|udp|cft-5
cft-6|1767|tcp|cft-6
cft-6|1767|udp|cft-6
cft-7|1768|tcp|cft-7
cft-7|1768|udp|cft-7
bmc-net-adm|1769|tcp|bmc-net-adm
bmc-net-adm|1769|udp|bmc-net-adm
bmc-net-svc|1770|tcp|bmc-net-svc
bmc-net-svc|1770|udp|bmc-net-svc
vaultbase|1771|tcp|vaultbase
vaultbase|1771|udp|vaultbase
essweb-gw|1772|tcp|EssWeb Gateway
essweb-gw|1772|udp|EssWeb Gateway
kmscontrol|1773|tcp|KMSControl
kmscontrol|1773|udp|KMSControl
global-dtserv|1774|tcp|global-dtserv
global-dtserv|1774|udp|global-dtserv
femis|1776|tcp|Federal Emergency Management Information System
femis|1776|udp|Federal Emergency Management Information System
powerguardian|1777|tcp|powerguardian
powerguardian|1777|udp|powerguardian
prodigy-intrnet|1778|tcp|prodigy-internet
prodigy-intrnet|1778|udp|prodigy-internet
pharmasoft|1779|tcp|pharmasoft
pharmasoft|1779|udp|pharmasoft
dpkeyserv|1780|tcp|dpkeyserv
dpkeyserv|1780|udp|dpkeyserv
answersoft-lm|1781|tcp|answersoft-lm
answersoft-lm|1781|udp|answersoft-lm
hp-hcip|1782|tcp|hp-hcip
hp-hcip|1782|udp|hp-hcip
finle-lm|1784|tcp|Finle License Manager
finle-lm|1784|udp|Finle License Manager
windlm|1785|tcp|Wind River Systems License Manager
windlm|1785|udp|Wind River Systems License Manager
funk-logger|1786|tcp|funk-logger
funk-logger|1786|udp|funk-logger
funk-license|1787|tcp|funk-license
funk-license|1787|udp|funk-license
psmond|1788|tcp|psmond
psmond|1788|udp|psmond
hello|1789|tcp|hello
hello|1789|udp|hello
nmsp|1790|tcp|Narrative Media Streaming Protocol
nmsp|1790|udp|Narrative Media Streaming Protocol
ea1|1791|tcp|EA1
ea1|1791|udp|EA1
ibm-dt-2|1792|tcp|ibm-dt-2
ibm-dt-2|1792|udp|ibm-dt-2
rsc-robot|1793|tcp|rsc-robot
rsc-robot|1793|udp|rsc-robot
cera-bcm|1794|tcp|cera-bcm
cera-bcm|1794|udp|cera-bcm
dpi-proxy|1795|tcp|dpi-proxy
dpi-proxy|1795|udp|dpi-proxy
vocaltec-admin|1796|tcp|Vocaltec Server Administration
vocaltec-admin|1796|udp|Vocaltec Server Administration
uma|1797|tcp|UMA
uma|1797|udp|UMA
etp|1798|tcp|Event Transfer Protocol
etp|1798|udp|Event Transfer Protocol
netrisk|1799|tcp|NETRISK
netrisk|1799|udp|NETRISK
ansys-lm|1800|tcp|ANSYS-License manager
ansys-lm|1800|udp|ANSYS-License manager
msmq|1801|tcp|Microsoft Message Que
msmq|1801|udp|Microsoft Message Que
concomp1|1802|tcp|ConComp1
concomp1|1802|udp|ConComp1
hp-hcip-gwy|1803|tcp|HP-HCIP-GWY
hp-hcip-gwy|1803|udp|HP-HCIP-GWY
enl|1804|tcp|ENL
enl|1804|udp|ENL
enl-name|1805|tcp|ENL-Name
enl-name|1805|udp|ENL-Name
musiconline|1806|tcp|Musiconline
musiconline|1806|udp|Musiconline
fhsp|1807|tcp|Fujitsu Hot Standby Protocol
fhsp|1807|udp|Fujitsu Hot Standby Protocol
oracle-vp2|1808|tcp|Oracle-VP2
oracle-vp2|1808|udp|Oracle-VP2
oracle-vp1|1809|tcp|Oracle-VP1
oracle-vp1|1809|udp|Oracle-VP1
jerand-lm|1810|tcp|Jerand License Manager
jerand-lm|1810|udp|Jerand License Manager
scientia-sdb|1811|tcp|Scientia-SDB
scientia-sdb|1811|udp|Scientia-SDB
radius|1812|tcp|RADIUS
radius|1812|udp|RADIUS
radius-acct|1813|tcp|RADIUS Accounting
radius-acct|1813|udp|RADIUS Accounting
tdp-suite|1814|tcp|TDP Suite
tdp-suite|1814|udp|TDP Suite
mmpft|1815|tcp|MMPFT
mmpft|1815|udp|MMPFT
harp|1816|tcp|HARP
harp|1816|udp|HARP
rkb-oscs|1817|tcp|RKB-OSCS
rkb-oscs|1817|udp|RKB-OSCS
etftp|1818|tcp|Enhanced Trivial File Transfer Protocol
etftp|1818|udp|Enhanced Trivial File Transfer Protocol
plato-lm|1819|tcp|Plato License Manager
plato-lm|1819|udp|Plato License Manager
mcagent|1820|tcp|mcagent
mcagent|1820|udp|mcagent
donnyworld|1821|tcp|donnyworld
donnyworld|1821|udp|donnyworld
es-elmd|1822|tcp|es-elmd
es-elmd|1822|udp|es-elmd
unisys-lm|1823|tcp|Unisys Natural Language License Manager
unisys-lm|1823|udp|Unisys Natural Language License Manager
metrics-pas|1824|tcp|metrics-pas
metrics-pas|1824|udp|metrics-pas
direcpc-video|1825|tcp|DirecPC Video
direcpc-video|1825|udp|DirecPC Video
ardt|1826|tcp|ARDT
ardt|1826|udp|ARDT
asi|1827|tcp|ASI
asi|1827|udp|ASI
itm-mcell-u|1828|tcp|itm-mcell-u
itm-mcell-u|1828|udp|itm-mcell-u
optika-emedia|1829|tcp|Optika eMedia
optika-emedia|1829|udp|Optika eMedia
net8-cman|1830|tcp|Oracle Net8 CMan Admin
net8-cman|1830|udp|Oracle Net8 CMan Admin
myrtle|1831|tcp|Myrtle
myrtle|1831|udp|Myrtle
tht-treasure|1832|tcp|ThoughtTreasure
tht-treasure|1832|udp|ThoughtTreasure
udpradio|1833|tcp|udpradio
udpradio|1833|udp|udpradio
ardusuni|1834|tcp|ARDUS Unicast
ardusuni|1834|udp|ARDUS Unicast
ardusmul|1835|tcp|ARDUS Multicast
ardusmul|1835|udp|ARDUS Multicast
ste-smsc|1836|tcp|ste-smsc
ste-smsc|1836|udp|ste-smsc
csoft1|1837|tcp|csoft1
csoft1|1837|udp|csoft1
talnet|1838|tcp|TALNET
talnet|1838|udp|TALNET
netopia-vo1|1839|tcp|netopia-vo1
netopia-vo1|1839|udp|netopia-vo1
netopia-vo2|1840|tcp|netopia-vo2
netopia-vo2|1840|udp|netopia-vo2
netopia-vo3|1841|tcp|netopia-vo3
netopia-vo3|1841|udp|netopia-vo3
netopia-vo4|1842|tcp|netopia-vo4
netopia-vo4|1842|udp|netopia-vo4
netopia-vo5|1843|tcp|netopia-vo5
netopia-vo5|1843|udp|netopia-vo5
direcpc-dll|1844|tcp|DirecPC-DLL
direcpc-dll|1844|udp|DirecPC-DLL
altalink|1845|tcp|altalink
altalink|1845|udp|altalink
tunstall-pnc|1846|tcp|Tunstall PNC
tunstall-pnc|1846|udp|Tunstall PNC
slp-notify|1847|tcp|SLP Notification
slp-notify|1847|udp|SLP Notification
fjdocdist|1848|tcp|fjdocdist
fjdocdist|1848|udp|fjdocdist
alpha-sms|1849|tcp|ALPHA-SMS
alpha-sms|1849|udp|ALPHA-SMS
gsi|1850|tcp|GSI
gsi|1850|udp|GSI
ctcd|1851|tcp|ctcd
ctcd|1851|udp|ctcd
virtual-time|1852|tcp|Virtual Time
virtual-time|1852|udp|Virtual Time
vids-avtp|1853|tcp|VIDS-AVTP
vids-avtp|1853|udp|VIDS-AVTP
buddy-draw|1854|tcp|Buddy Draw
buddy-draw|1854|udp|Buddy Draw
fiorano-rtrsvc|1855|tcp|Fiorano RtrSvc
fiorano-rtrsvc|1855|udp|Fiorano RtrSvc
fiorano-msgsvc|1856|tcp|Fiorano MsgSvc
fiorano-msgsvc|1856|udp|Fiorano MsgSvc
datacaptor|1857|tcp|DataCaptor
datacaptor|1857|udp|DataCaptor
privateark|1858|tcp|PrivateArk
privateark|1858|udp|PrivateArk
gammafetchsvr|1859|tcp|Gamma Fetcher Server
gammafetchsvr|1859|udp|Gamma Fetcher Server
sunscalar-svc|1860|tcp|SunSCALAR Services
sunscalar-svc|1860|udp|SunSCALAR Services
lecroy-vicp|1861|tcp|LeCroy VICP
lecroy-vicp|1861|udp|LeCroy VICP
techra-server|1862|tcp|techra-server
techra-server|1862|udp|techra-server
msnp|1863|tcp|MSNP
msnp|1863|udp|MSNP
paradym-31port|1864|tcp|Paradym 31 Port
paradym-31port|1864|udp|Paradym 31 Port
entp|1865|tcp|ENTP
entp|1865|udp|ENTP
swrmi|1866|tcp|swrmi
swrmi|1866|udp|swrmi
udrive|1867|tcp|UDRIVE
udrive|1867|udp|UDRIVE
viziblebrowser|1868|tcp|VizibleBrowser
viziblebrowser|1868|udp|VizibleBrowser
yestrader|1869|tcp|YesTrader
yestrader|1869|udp|YesTrader
sunscalar-dns|1870|tcp|SunSCALAR DNS Service
sunscalar-dns|1870|udp|SunSCALAR DNS Service
canocentral0|1871|tcp|Cano Central 0
canocentral0|1871|udp|Cano Central 0
canocentral1|1872|tcp|Cano Central 1
canocentral1|1872|udp|Cano Central 1
fjmpjps|1873|tcp|Fjmpjps
fjmpjps|1873|udp|Fjmpjps
fjswapsnp|1874|tcp|Fjswapsnp
fjswapsnp|1874|udp|Fjswapsnp
westell-stats|1875|tcp|westell stats
westell-stats|1875|udp|westell stats
ewcappsrv|1876|tcp|ewcappsrv
ewcappsrv|1876|udp|ewcappsrv
hp-webqosdb|1877|tcp|hp-webqosdb
hp-webqosdb|1877|udp|hp-webqosdb
drmsmc|1878|tcp|drmsmc
drmsmc|1878|udp|drmsmc
nettgain-nms|1879|tcp|NettGain NMS
nettgain-nms|1879|udp|NettGain NMS
vsat-control|1880|tcp|Gilat VSAT Control
vsat-control|1880|udp|Gilat VSAT Control
ibm-mqseries2|1881|tcp|IBM WebSphere MQ
ibm-mqseries2|1881|udp|IBM WebSphere MQ
ecsqdmn|1882|tcp|ecsqdmn
ecsqdmn|1882|udp|ecsqdmn
ibm-mqisdp|1883|tcp|IBM MQSeries SCADA
ibm-mqisdp|1883|udp|IBM MQSeries SCADA
idmaps|1884|tcp|Internet Distance Map Svc
idmaps|1884|udp|Internet Distance Map Svc
vrtstrapserver|1885|tcp|Veritas Trap Server
vrtstrapserver|1885|udp|Veritas Trap Server
leoip|1886|tcp|Leonardo over IP
leoip|1886|udp|Leonardo over IP
filex-lport|1887|tcp|FileX Listening Port
filex-lport|1887|udp|FileX Listening Port
ncconfig|1888|tcp|NC Config Port
ncconfig|1888|udp|NC Config Port
unify-adapter|1889|tcp|Unify Web Adapter Service
unify-adapter|1889|udp|Unify Web Adapter Service
wilkenlistener|1890|tcp|wilkenListener
wilkenlistener|1890|udp|wilkenListener
childkey-notif|1891|tcp|ChildKey Notification
childkey-notif|1891|udp|ChildKey Notification
childkey-ctrl|1892|tcp|ChildKey Control
childkey-ctrl|1892|udp|ChildKey Control
elad|1893|tcp|ELAD Protocol
elad|1893|udp|ELAD Protocol
o2server-port|1894|tcp|O2Server Port
o2server-port|1894|udp|O2Server Port
b-novative-ls|1896|tcp|b-novative license server
b-novative-ls|1896|udp|b-novative license server
metaagent|1897|tcp|MetaAgent
metaagent|1897|udp|MetaAgent
cymtec-port|1898|tcp|Cymtec secure management
cymtec-port|1898|udp|Cymtec secure management
mc2studios|1899|tcp|MC2Studios
mc2studios|1899|udp|MC2Studios
ssdp|1900|tcp|SSDP
ssdp|1900|udp|SSDP
fjicl-tep-a|1901|tcp|Fujitsu ICL Terminal Emulator Program A
fjicl-tep-a|1901|udp|Fujitsu ICL Terminal Emulator Program A
fjicl-tep-b|1902|tcp|Fujitsu ICL Terminal Emulator Program B
fjicl-tep-b|1902|udp|Fujitsu ICL Terminal Emulator Program B
linkname|1903|tcp|Local Link Name Resolution
linkname|1903|udp|Local Link Name Resolution
fjicl-tep-c|1904|tcp|Fujitsu ICL Terminal Emulator Program C
fjicl-tep-c|1904|udp|Fujitsu ICL Terminal Emulator Program C
sugp|1905|tcp|Secure UP.Link Gateway Protocol
sugp|1905|udp|Secure UP.Link Gateway Protocol
tpmd|1906|tcp|TPortMapperReq
tpmd|1906|udp|TPortMapperReq
intrastar|1907|tcp|IntraSTAR
intrastar|1907|udp|IntraSTAR
dawn|1908|tcp|Dawn
dawn|1908|udp|Dawn
global-wlink|1909|tcp|Global World Link
global-wlink|1909|udp|Global World Link
ultrabac|1910|tcp|UltraBac Software communications port
ultrabac|1910|udp|UltraBac Software communications port
mtp|1911|tcp|Starlight Networks Multimedia Transport Protocol
mtp|1911|udp|Starlight Networks Multimedia Transport Protocol
rhp-iibp|1912|tcp|rhp-iibp
rhp-iibp|1912|udp|rhp-iibp
armadp|1913|tcp|armadp
armadp|1913|udp|armadp
elm-momentum|1914|tcp|Elm-Momentum
elm-momentum|1914|udp|Elm-Momentum
facelink|1915|tcp|FACELINK
facelink|1915|udp|FACELINK
persona|1916|tcp|Persoft Persona
persona|1916|udp|Persoft Persona
noagent|1917|tcp|nOAgent
noagent|1917|udp|nOAgent
can-nds|1918|tcp|Candle Directory Service - NDS
can-nds|1918|udp|Candle Directory Service - NDS
can-dch|1919|tcp|Candle Directory Service - DCH
can-dch|1919|udp|Candle Directory Service - DCH
can-ferret|1920|tcp|Candle Directory Service - FERRET
can-ferret|1920|udp|Candle Directory Service - FERRET
noadmin|1921|tcp|NoAdmin
noadmin|1921|udp|NoAdmin
tapestry|1922|tcp|Tapestry
tapestry|1922|udp|Tapestry
spice|1923|tcp|SPICE
spice|1923|udp|SPICE
xiip|1924|tcp|XIIP
xiip|1924|udp|XIIP
discovery-port|1925|tcp|Surrogate Discovery Port
discovery-port|1925|udp|Surrogate Discovery Port
egs|1926|tcp|Evolution Game Server
egs|1926|udp|Evolution Game Server
videte-cipc|1927|tcp|Videte CIPC Port
videte-cipc|1927|udp|Videte CIPC Port
emsd-port|1928|tcp|Expnd Maui Srvr Dscovr
emsd-port|1928|udp|Expnd Maui Srvr Dscovr
bandwiz-system|1929|tcp|Bandwiz System - Server
bandwiz-system|1929|udp|Bandwiz System - Server
driveappserver|1930|tcp|Drive AppServer
driveappserver|1930|udp|Drive AppServer
amdsched|1931|tcp|AMD SCHED
amdsched|1931|udp|AMD SCHED
ctt-broker|1932|tcp|CTT Broker
ctt-broker|1932|udp|CTT Broker
xmapi|1933|tcp|IBM LM MT Agent
xmapi|1933|udp|IBM LM MT Agent
xaapi|1934|tcp|IBM LM Appl Agent
xaapi|1934|udp|IBM LM Appl Agent
macromedia-fcs|1935|tcp|Macromedia Flash Communications Server MX
macromedia-fcs|1935|udp|Macromedia Flash Communications server MX
jetcmeserver|1936|tcp|JetCmeServer Server Port
jetcmeserver|1936|udp|JetCmeServer Server Port
jwserver|1937|tcp|JetVWay Server Port
jwserver|1937|udp|JetVWay Server Port
jwclient|1938|tcp|JetVWay Client Port
jwclient|1938|udp|JetVWay Client Port
jvserver|1939|tcp|JetVision Server Port
jvserver|1939|udp|JetVision Server Port
jvclient|1940|tcp|JetVision Client Port
jvclient|1940|udp|JetVision Client Port
dic-aida|1941|tcp|DIC-Aida
dic-aida|1941|udp|DIC-Aida
res|1942|tcp|Real Enterprise Service
res|1942|udp|Real Enterprise Service
beeyond-media|1943|tcp|Beeyond Media
beeyond-media|1943|udp|Beeyond Media
close-combat|1944|tcp|close-combat
close-combat|1944|udp|close-combat
dialogic-elmd|1945|tcp|dialogic-elmd
dialogic-elmd|1945|udp|dialogic-elmd
tekpls|1946|tcp|tekpls
tekpls|1946|udp|tekpls
hlserver|1947|tcp|hlserver
hlserver|1947|udp|hlserver
eye2eye|1948|tcp|eye2eye
eye2eye|1948|udp|eye2eye
ismaeasdaqlive|1949|tcp|ISMA Easdaq Live
ismaeasdaqlive|1949|udp|ISMA Easdaq Live
ismaeasdaqtest|1950|tcp|ISMA Easdaq Test
ismaeasdaqtest|1950|udp|ISMA Easdaq Test
bcs-lmserver|1951|tcp|bcs-lmserver
bcs-lmserver|1951|udp|bcs-lmserver
mpnjsc|1952|tcp|mpnjsc
mpnjsc|1952|udp|mpnjsc
rapidbase|1953|tcp|Rapid Base
rapidbase|1953|udp|Rapid Base
abr-basic|1954|tcp|ABR-Basic Data
abr-basic|1954|udp|ABR-Basic Data
abr-secure|1955|tcp|ABR-Secure Data
abr-secure|1955|udp|ABR-Secure Data
vrtl-vmf-ds|1956|tcp|Vertel VMF DS
vrtl-vmf-ds|1956|udp|Vertel VMF DS
unix-status|1957|tcp|unix-status
unix-status|1957|udp|unix-status
dxadmind|1958|tcp|CA Administration Daemon
dxadmind|1958|udp|CA Administration Daemon
simp-all|1959|tcp|SIMP Channel
simp-all|1959|udp|SIMP Channel
nasmanager|1960|tcp|Merit DAC NASmanager
nasmanager|1960|udp|Merit DAC NASmanager
bts-appserver|1961|tcp|BTS APPSERVER
bts-appserver|1961|udp|BTS APPSERVER
biap-mp|1962|tcp|BIAP-MP
biap-mp|1962|udp|BIAP-MP
webmachine|1963|tcp|WebMachine
webmachine|1963|udp|WebMachine
solid-e-engine|1964|tcp|SOLID E ENGINE
solid-e-engine|1964|udp|SOLID E ENGINE
tivoli-npm|1965|tcp|Tivoli NPM
tivoli-npm|1965|udp|Tivoli NPM
slush|1966|tcp|Slush
slush|1966|udp|Slush
sns-quote|1967|tcp|SNS Quote
sns-quote|1967|udp|SNS Quote
lipsinc|1968|tcp|LIPSinc
lipsinc|1968|udp|LIPSinc
lipsinc1|1969|tcp|LIPSinc 1
lipsinc1|1969|udp|LIPSinc 1
netop-rc|1970|tcp|NetOp Remote Control
netop-rc|1970|udp|NetOp Remote Control
netop-school|1971|tcp|NetOp School
netop-school|1971|udp|NetOp School
intersys-cache|1972|tcp|Cache
intersys-cache|1972|udp|Cache
dlsrap|1973|tcp|Data Link Switching Remote Access Protocol
dlsrap|1973|udp|Data Link Switching Remote Access Protocol
drp|1974|tcp|DRP
drp|1974|udp|DRP
tcoflashagent|1975|tcp|TCO Flash Agent
tcoflashagent|1975|udp|TCO Flash Agent
tcoregagent|1976|tcp|TCO Reg Agent
tcoregagent|1976|udp|TCO Reg Agent
tcoaddressbook|1977|tcp|TCO Address Book
tcoaddressbook|1977|udp|TCO Address Book
unisql|1978|tcp|UniSQL
unisql|1978|udp|UniSQL
unisql-java|1979|tcp|UniSQL Java
unisql-java|1979|udp|UniSQL Java
pearldoc-xact|1980|tcp|PearlDoc XACT
pearldoc-xact|1980|udp|PearlDoc XACT
p2pq|1981|tcp|p2pQ
p2pq|1981|udp|p2pQ
estamp|1982|tcp|Evidentiary Timestamp
estamp|1982|udp|Evidentiary Timestamp
lhtp|1983|tcp|Loophole Test Protocol
lhtp|1983|udp|Loophole Test Protocol
bb|1984|tcp|BB
bb|1984|udp|BB
hsrp|1985|tcp|Hot Standby Router Protocol
hsrp|1985|udp|Hot Standby Router Protocol
licensedaemon|1986|tcp|cisco license management
licensedaemon|1986|udp|cisco license management
tr-rsrb-p1|1987|tcp|cisco RSRB Priority 1 port
tr-rsrb-p1|1987|udp|cisco RSRB Priority 1 port
tr-rsrb-p2|1988|tcp|cisco RSRB Priority 2 port
tr-rsrb-p2|1988|udp|cisco RSRB Priority 2 port
tr-rsrb-p3|1989|tcp|cisco RSRB Priority 3 port
tr-rsrb-p3|1989|udp|cisco RSRB Priority 3 port
mshnet|1989|tcp|MHSnet system
mshnet|1989|udp|MHSnet system
stun-p1|1990|tcp|cisco STUN Priority 1 port
stun-p1|1990|udp|cisco STUN Priority 1 port
stun-p2|1991|tcp|cisco STUN Priority 2 port
stun-p2|1991|udp|cisco STUN Priority 2 port
stun-p3|1992|tcp|cisco STUN Priority 3 port
stun-p3|1992|udp|cisco STUN Priority 3 port
ipsendmsg|1992|tcp|IPsendmsg
ipsendmsg|1992|udp|IPsendmsg
snmp-tcp-port|1993|tcp|cisco SNMP TCP port
snmp-tcp-port|1993|udp|cisco SNMP TCP port
stun-port|1994|tcp|cisco serial tunnel port
stun-port|1994|udp|cisco serial tunnel port
perf-port|1995|tcp|cisco perf port
perf-port|1995|udp|cisco perf port
tr-rsrb-port|1996|tcp|cisco Remote SRB port
tr-rsrb-port|1996|udp|cisco Remote SRB port
gdp-port|1997|tcp|cisco Gateway Discovery Protocol
gdp-port|1997|udp|cisco Gateway Discovery Protocol
x25-svc-port|1998|tcp|cisco X.25 service (XOT)
x25-svc-port|1998|udp|cisco X.25 service (XOT)
tcp-id-port|1999|tcp|cisco identification port
tcp-id-port|1999|udp|cisco identification port
callbook|2000|tcp|callbook
callbook|2000|udp|callbook
dc|2001|tcp|dc
wizard|2001|udp|curry
globe|2002|tcp|globe
globe|2002|udp|globe
mailbox|2004|tcp|mailbox
emce|2004|udp|CCWS mm conf
berknet|2005|tcp|berknet
oracle|2005|udp|oracle
invokator|2006|tcp|invokator
raid-cc|2006|udp|raid
dectalk|2007|tcp|dectalk
raid-am|2007|udp|raid-am
conf|2008|tcp|conf
terminaldb|2008|udp|terminaldb
news|2009|tcp|news
whosockami|2009|udp|whosockami
search|2010|tcp|search
pipe_server|2010|udp|pipe_server
raid-cc|2011|tcp|raid
servserv|2011|udp|servserv
ttyinfo|2012|tcp|ttyinfo
raid-ac|2012|udp|raid-ac
raid-am|2013|tcp|raid-am
raid-cd|2013|udp|raid-cd
troff|2014|tcp|troff
raid-sf|2014|udp|raid-sf
cypress|2015|tcp|cypress
raid-cs|2015|udp|raid-cs
bootserver|2016|tcp|bootserver
bootserver|2016|udp|bootserver
cypress-stat|2017|tcp|cypress-stat
bootclient|2017|udp|bootclient
terminaldb|2018|tcp|terminaldb
rellpack|2018|udp|rellpack
whosockami|2019|tcp|whosockami
about|2019|udp|about
xinupageserver|2020|tcp|xinupageserver
xinupageserver|2020|udp|xinupageserver
servexec|2021|tcp|servexec
xinuexpansion1|2021|udp|xinuexpansion1
down|2022|tcp|down
xinuexpansion2|2022|udp|xinuexpansion2
xinuexpansion3|2023|tcp|xinuexpansion3
xinuexpansion3|2023|udp|xinuexpansion3
xinuexpansion4|2024|tcp|xinuexpansion4
xinuexpansion4|2024|udp|xinuexpansion4
ellpack|2025|tcp|ellpack
xribs|2025|udp|xribs
scrabble|2026|tcp|scrabble
scrabble|2026|udp|scrabble
shadowserver|2027|tcp|shadowserver
shadowserver|2027|udp|shadowserver
submitserver|2028|tcp|submitserver
submitserver|2028|udp|submitserver
device2|2030|tcp|device2
device2|2030|udp|device2
blackboard|2032|tcp|blackboard
blackboard|2032|udp|blackboard
glogger|2033|tcp|glogger
glogger|2033|udp|glogger
scoremgr|2034|tcp|scoremgr
scoremgr|2034|udp|scoremgr
imsldoc|2035|tcp|imsldoc
imsldoc|2035|udp|imsldoc
p2plus|2037|tcp|P2plus Application Server
p2plus|2037|udp|P2plus Application Server
objectmanager|2038|tcp|objectmanager
objectmanager|2038|udp|objectmanager
lam|2040|tcp|lam
lam|2040|udp|lam
interbase|2041|tcp|interbase
interbase|2041|udp|interbase
isis|2042|tcp|isis
isis|2042|udp|isis
isis-bcast|2043|tcp|isis-bcast
isis-bcast|2043|udp|isis-bcast
rimsl|2044|tcp|rimsl
rimsl|2044|udp|rimsl
cdfunc|2045|tcp|cdfunc
cdfunc|2045|udp|cdfunc
sdfunc|2046|tcp|sdfunc
sdfunc|2046|udp|sdfunc
dls|2047|tcp|dls
dls|2047|udp|dls
dls-monitor|2048|tcp|dls-monitor
dls-monitor|2048|udp|dls-monitor
shilp|2049|tcp|shilp
shilp|2049|udp|shilp
nfs|2049|tcp|Network File System - Sun Microsystems
nfs|2049|udp|Network File System - Sun Microsystems
av-emb-config|2050|tcp|Avaya EMB Config Port
av-emb-config|2050|udp|Avaya EMB Config Port
epnsdp|2051|tcp|EPNSDP
epnsdp|2051|udp|EPNSDP
clearvisn|2052|tcp|clearVisn Services Port
clearvisn|2052|udp|clearVisn Services Port
lot105-ds-upd|2053|tcp|Lot105 DSuper Updates
lot105-ds-upd|2053|udp|Lot105 DSuper Updates
weblogin|2054|tcp|Weblogin Port
weblogin|2054|udp|Weblogin Port
iop|2055|tcp|Iliad-Odyssey Protocol
iop|2055|udp|Iliad-Odyssey Protocol
omnisky|2056|tcp|OmniSky Port
omnisky|2056|udp|OmniSky Port
rich-cp|2057|tcp|Rich Content Protocol
rich-cp|2057|udp|Rich Content Protocol
newwavesearch|2058|tcp|NewWaveSearchables RMI
newwavesearch|2058|udp|NewWaveSearchables RMI
bmc-messaging|2059|tcp|BMC Messaging Service
bmc-messaging|2059|udp|BMC Messaging Service
teleniumdaemon|2060|tcp|Telenium Daemon IF
teleniumdaemon|2060|udp|Telenium Daemon IF
netmount|2061|tcp|NetMount
netmount|2061|udp|NetMount
icg-swp|2062|tcp|ICG SWP Port
icg-swp|2062|udp|ICG SWP Port
icg-bridge|2063|tcp|ICG Bridge Port
icg-bridge|2063|udp|ICG Bridge Port
icg-iprelay|2064|tcp|ICG IP Relay Port
icg-iprelay|2064|udp|ICG IP Relay Port
dlsrpn|2065|tcp|Data Link Switch Read Port Number
dlsrpn|2065|udp|Data Link Switch Read Port Number
dlswpn|2067|tcp|Data Link Switch Write Port Number
dlswpn|2067|udp|Data Link Switch Write Port Number
avauthsrvprtcl|2068|tcp|Avocent AuthSrv Protocol
avauthsrvprtcl|2068|udp|Avocent AuthSrv Protocol
event-port|2069|tcp|HTTP Event Port
event-port|2069|udp|HTTP Event Port
ah-esp-encap|2070|tcp|AH and ESP Encapsulated in UDP packet
ah-esp-encap|2070|udp|AH and ESP Encapsulated in UDP packet
acp-port|2071|tcp|Axon Control Protocol
acp-port|2071|udp|Axon Control Protocol
msync|2072|tcp|GlobeCast mSync
msync|2072|udp|GlobeCast mSync
gxs-data-port|2073|tcp|DataReel Database Socket
gxs-data-port|2073|udp|DataReel Database Socket
vrtl-vmf-sa|2074|tcp|Vertel VMF SA
vrtl-vmf-sa|2074|udp|Vertel VMF SA
newlixengine|2075|tcp|Newlix ServerWare Engine
newlixengine|2075|udp|Newlix ServerWare Engine
newlixconfig|2076|tcp|Newlix JSPConfig
newlixconfig|2076|udp|Newlix JSPConfig
trellisagt|2077|tcp|TrelliSoft Agent
trellisagt|2077|udp|TrelliSoft Agent
trellissvr|2078|tcp|TrelliSoft Server
trellissvr|2078|udp|TrelliSoft Server
idware-router|2079|tcp|IDWARE Router Port
idware-router|2079|udp|IDWARE Router Port
autodesk-nlm|2080|tcp|Autodesk NLM (FLEXlm)
autodesk-nlm|2080|udp|Autodesk NLM (FLEXlm)
kme-trap-port|2081|tcp|KME PRINTER TRAP PORT
kme-trap-port|2081|udp|KME PRINTER TRAP PORT
infowave|2082|tcp|Infowave Mobility Server
infowave|2082|udp|Infowave Mobiltiy Server
gnunet|2086|tcp|GNUnet
gnunet|2086|udp|GNUnet
eli|2087|tcp|ELI - Event Logging Integration
eli|2087|udp|ELI - Event Logging Integration
sep|2089|tcp|Security Encapsulation Protocol - SEP
sep|2089|udp|Security Encapsulation Protocol - SEP
lrp|2090|tcp|Load Report Protocol
lrp|2090|udp|Load Report Protocol
prp|2091|tcp|PRP
prp|2091|udp|PRP
descent3|2092|tcp|Descent 3
descent3|2092|udp|Descent 3
nbx-cc|2093|tcp|NBX CC
nbx-cc|2093|udp|NBX CC
nbx-au|2094|tcp|NBX AU
nbx-au|2094|udp|NBX AU
nbx-ser|2095|tcp|NBX SER
nbx-ser|2095|udp|NBX SER
nbx-dir|2096|tcp|NBX DIR
nbx-dir|2096|udp|NBX DIR
jetformpreview|2097|tcp|Jet Form Preview
jetformpreview|2097|udp|Jet Form Preview
dialog-port|2098|tcp|Dialog Port
dialog-port|2098|udp|Dialog Port
h2250-annex-g|2099|tcp|H.225.0 Annex G
h2250-annex-g|2099|udp|H.225.0 Annex G
amiganetfs|2100|tcp|Amiga Network Filesystem
amiganetfs|2100|udp|Amiga Network Filesystem
rtcm-sc104|2101|tcp|rtcm-sc104
rtcm-sc104|2101|udp|rtcm-sc104
zephyr-srv|2102|tcp|Zephyr server
zephyr-srv|2102|udp|Zephyr server
zephyr-clt|2103|tcp|Zephyr serv-hm connection
zephyr-clt|2103|udp|Zephyr serv-hm connection
zephyr-hm|2104|tcp|Zephyr hostmanager
zephyr-hm|2104|udp|Zephyr hostmanager
minipay|2105|tcp|MiniPay
minipay|2105|udp|MiniPay
mzap|2106|tcp|MZAP
mzap|2106|udp|MZAP
bintec-admin|2107|tcp|BinTec Admin
bintec-admin|2107|udp|BinTec Admin
comcam|2108|tcp|Comcam
comcam|2108|udp|Comcam
ergolight|2109|tcp|Ergolight
ergolight|2109|udp|Ergolight
umsp|2110|tcp|UMSP
umsp|2110|udp|UMSP
dsatp|2111|tcp|DSATP
dsatp|2111|udp|DSATP
idonix-metanet|2112|tcp|Idonix MetaNet
idonix-metanet|2112|udp|Idonix MetaNet
hsl-storm|2113|tcp|HSL StoRM
hsl-storm|2113|udp|HSL StoRM
newheights|2114|tcp|NEWHEIGHTS
newheights|2114|udp|NEWHEIGHTS
kdm|2115|tcp|Key Distribution Manager
kdm|2115|udp|Key Distribution Manager
ccowcmr|2116|tcp|CCOWCMR
ccowcmr|2116|udp|CCOWCMR
mentaclient|2117|tcp|MENTACLIENT
mentaclient|2117|udp|MENTACLIENT
mentaserver|2118|tcp|MENTASERVER
mentaserver|2118|udp|MENTASERVER
gsigatekeeper|2119|tcp|GSIGATEKEEPER
gsigatekeeper|2119|udp|GSIGATEKEEPER
qencp|2120|tcp|Quick Eagle Networks CP
qencp|2120|udp|Quick Eagle Networks CP
scientia-ssdb|2121|tcp|SCIENTIA-SSDB
scientia-ssdb|2121|udp|SCIENTIA-SSDB
caupc-remote|2122|tcp|CauPC Remote Control
caupc-remote|2122|udp|CauPC Remote Control
gtp-control|2123|tcp|GTP-Control Plane (3GPP)
gtp-control|2123|udp|GTP-Control Plane (3GPP)
elatelink|2124|tcp|ELATELINK
elatelink|2124|udp|ELATELINK
lockstep|2125|tcp|LOCKSTEP
lockstep|2125|udp|LOCKSTEP
pktcable-cops|2126|tcp|PktCable-COPS
pktcable-cops|2126|udp|PktCable-COPS
index-pc-wb|2127|tcp|INDEX-PC-WB
index-pc-wb|2127|udp|INDEX-PC-WB
net-steward|2128|tcp|Net Steward Control
net-steward|2128|udp|Net Steward Control
cs-live|2129|tcp|cs-live.com
cs-live|2129|udp|cs-live.com
swc-xds|2130|tcp|SWC-XDS
swc-xds|2130|udp|SWC-XDS
avantageb2b|2131|tcp|Avantageb2b
avantageb2b|2131|udp|Avantageb2b
avail-epmap|2132|tcp|AVAIL-EPMAP
avail-epmap|2132|udp|AVAIL-EPMAP
zymed-zpp|2133|tcp|ZYMED-ZPP
zymed-zpp|2133|udp|ZYMED-ZPP
avenue|2134|tcp|AVENUE
avenue|2134|udp|AVENUE
gris|2135|tcp|Grid Resource Information Server
gris|2135|udp|Grid Resource Information Server
appworxsrv|2136|tcp|APPWORXSRV
appworxsrv|2136|udp|APPWORXSRV
connect|2137|tcp|CONNECT
connect|2137|udp|CONNECT
unbind-cluster|2138|tcp|UNBIND-CLUSTER
unbind-cluster|2138|udp|UNBIND-CLUSTER
ias-auth|2139|tcp|IAS-AUTH
ias-auth|2139|udp|IAS-AUTH
ias-reg|2140|tcp|IAS-REG
ias-reg|2140|udp|IAS-REG
ias-admind|2141|tcp|IAS-ADMIND
ias-admind|2141|udp|IAS-ADMIND
tdm-over-ip|2142|tcp|TDM-OVER-IP
tdm-over-ip|2142|udp|TDM-OVER-IP
lv-jc|2143|tcp|Live Vault Job Control
lv-jc|2143|udp|Live Vault Job Control
lv-ffx|2144|tcp|Live Vault Fast Object Transfer
lv-ffx|2144|udp|Live Vault Fast Object Transfer
lv-pici|2145|tcp|Live Vault Remote Diagnostic Console Support
lv-pici|2145|udp|Live Vault Remote Diagnostic Console Support
lv-not|2146|tcp|Live Vault Admin Event Notification
lv-not|2146|udp|Live Vault Admin Event Notification
lv-auth|2147|tcp|Live Vault Authentication
lv-auth|2147|udp|Live Vault Authentication
veritas-ucl|2148|tcp|VERITAS UNIVERSAL COMMUNICATION LAYER
veritas-ucl|2148|udp|VERITAS UNIVERSAL COMMUNICATION LAYER
acptsys|2149|tcp|ACPTSYS
acptsys|2149|udp|ACPTSYS
dynamic3d|2150|tcp|DYNAMIC3D
dynamic3d|2150|udp|DYNAMIC3D
docent|2151|tcp|DOCENT
docent|2151|udp|DOCENT
gtp-user|2152|tcp|GTP-User Plane (3GPP)
gtp-user|2152|udp|GTP-User Plane (3GPP)
gdbremote|2159|tcp|GDB Remote Debug Port
gdbremote|2159|udp|GDB Remote Debug Port
apc-2160|2160|tcp|APC 2160
apc-2160|2160|udp|APC 2160
apc-2161|2161|tcp|APC 2161
apc-2161|2161|udp|APC 2161
navisphere|2162|tcp|Navisphere
navisphere|2162|udp|Navisphere
navisphere-sec|2163|tcp|Navisphere Secure
navisphere-sec|2163|udp|Navisphere Secure
ddns-v3|2164|tcp|Dynamic DNS Version 3
ddns-v3|2164|udp|Dynamic DNS Version 3
x-bone-api|2165|tcp|X-Bone API
x-bone-api|2165|udp|X-Bone API
iwserver|2166|tcp|iwserver
iwserver|2166|udp|iwserver
raw-serial|2167|tcp|Raw Async Serial Link
raw-serial|2167|udp|Raw Async Serial Link
mc-gt-srv|2180|tcp|Millicent Vendor Gateway Server
mc-gt-srv|2180|udp|Millicent Vendor Gateway Server
eforward|2181|tcp|eforward
eforward|2181|udp|eforward
tivoconnect|2190|tcp|TiVoConnect Beacon
tivoconnect|2190|udp|TiVoConnect Beacon
tvbus|2191|tcp|TvBus Messaging
tvbus|2191|udp|TvBus Messaging
ici|2200|tcp|ICI
ici|2200|udp|ICI
ats|2201|tcp|Advanced Training System Program
ats|2201|udp|Advanced Training System Program
imtc-map|2202|tcp|Int. Multimedia Teleconferencing Cosortium
imtc-map|2202|udp|Int. Multimedia Teleconferencing Cosortium
kali|2213|tcp|Kali
kali|2213|udp|Kali
netiq|2220|tcp|NetIQ End2End
netiq|2220|udp|NetIQ End2End
rockwell-csp1|2221|tcp|Rockwell CSP1
rockwell-csp1|2221|udp|Rockwell CSP1
rockwell-csp2|2222|tcp|Rockwell CSP2
rockwell-csp2|2222|udp|Rockwell CSP2
rockwell-csp3|2223|tcp|Rockwell CSP3
rockwell-csp3|2223|udp|Rockwell CSP3
ivs-video|2232|tcp|IVS Video default
ivs-video|2232|udp|IVS Video default
infocrypt|2233|tcp|INFOCRYPT
infocrypt|2233|udp|INFOCRYPT
directplay|2234|tcp|DirectPlay
directplay|2234|udp|DirectPlay
sercomm-wlink|2235|tcp|Sercomm-WLink
sercomm-wlink|2235|udp|Sercomm-WLink
nani|2236|tcp|Nani
nani|2236|udp|Nani
optech-port1-lm|2237|tcp|Optech Port1 License Manager
optech-port1-lm|2237|udp|Optech Port1 License Manager
aviva-sna|2238|tcp|AVIVA SNA SERVER
aviva-sna|2238|udp|AVIVA SNA SERVER
imagequery|2239|tcp|Image Query
imagequery|2239|udp|Image Query
recipe|2240|tcp|RECIPe
recipe|2240|udp|RECIPe
ivsd|2241|tcp|IVS Daemon
ivsd|2241|udp|IVS Daemon
foliocorp|2242|tcp|Folio Remote Server
foliocorp|2242|udp|Folio Remote Server
magicom|2243|tcp|Magicom Protocol
magicom|2243|udp|Magicom Protocol
nmsserver|2244|tcp|NMS Server
nmsserver|2244|udp|NMS Server
hao|2245|tcp|HaO
hao|2245|udp|HaO
pc-mta-addrmap|2246|tcp|PacketCable MTA Addr Map
pc-mta-addrmap|2246|udp|PacketCable MTA Addr Map
ums|2248|tcp|User Management Service
ums|2248|udp|User Management Service
rfmp|2249|tcp|RISO File Manager Protocol
rfmp|2249|udp|RISO File Manager Protocol
remote-collab|2250|tcp|remote-collab
remote-collab|2250|udp|remote-collab
dif-port|2251|tcp|Distributed Framework Port
dif-port|2251|udp|Distributed Framework Port
njenet-ssl|2252|tcp|NJENET using SSL
njenet-ssl|2252|udp|NJENET using SSL
dtv-chan-req|2253|tcp|DTV Channel Request
dtv-chan-req|2253|udp|DTV Channel Request
seispoc|2254|tcp|Seismic P.O.C. Port
seispoc|2254|udp|Seismic P.O.C. Port
vrtp|2255|tcp|VRTP - ViRtue Transfer Protocol
vrtp|2255|udp|VRTP - ViRtue Transfer Protocol
apc-2260|2260|tcp|APC 2260
apc-2260|2260|udp|APC 2260
xmquery|2279|tcp|xmquery
xmquery|2279|udp|xmquery
lnvpoller|2280|tcp|LNVPOLLER
lnvpoller|2280|udp|LNVPOLLER
lnvconsole|2281|tcp|LNVCONSOLE
lnvconsole|2281|udp|LNVCONSOLE
lnvalarm|2282|tcp|LNVALARM
lnvalarm|2282|udp|LNVALARM
lnvstatus|2283|tcp|LNVSTATUS
lnvstatus|2283|udp|LNVSTATUS
lnvmaps|2284|tcp|LNVMAPS
lnvmaps|2284|udp|LNVMAPS
lnvmailmon|2285|tcp|LNVMAILMON
lnvmailmon|2285|udp|LNVMAILMON
nas-metering|2286|tcp|NAS-Metering
nas-metering|2286|udp|NAS-Metering
dna|2287|tcp|DNA
dna|2287|udp|DNA
netml|2288|tcp|NETML
netml|2288|udp|NETML
konshus-lm|2294|tcp|Konshus License Manager (FLEX)
konshus-lm|2294|udp|Konshus License Manager (FLEX)
advant-lm|2295|tcp|Advant License Manager
advant-lm|2295|udp|Advant License Manager
theta-lm|2296|tcp|Theta License Manager (Rainbow)
theta-lm|2296|udp|Theta License Manager (Rainbow)
d2k-datamover1|2297|tcp|D2K DataMover 1
d2k-datamover1|2297|udp|D2K DataMover 1
d2k-datamover2|2298|tcp|D2K DataMover 2
d2k-datamover2|2298|udp|D2K DataMover 2
pc-telecommute|2299|tcp|PC Telecommute
pc-telecommute|2299|udp|PC Telecommute
cvmmon|2300|tcp|CVMMON
cvmmon|2300|udp|CVMMON
cpq-wbem|2301|tcp|Compaq HTTP
cpq-wbem|2301|udp|Compaq HTTP
binderysupport|2302|tcp|Bindery Support
binderysupport|2302|udp|Bindery Support
proxy-gateway|2303|tcp|Proxy Gateway
proxy-gateway|2303|udp|Proxy Gateway
attachmate-uts|2304|tcp|Attachmate UTS
attachmate-uts|2304|udp|Attachmate UTS
mt-scaleserver|2305|tcp|MT ScaleServer
mt-scaleserver|2305|udp|MT ScaleServer
tappi-boxnet|2306|tcp|TAPPI BoxNet
tappi-boxnet|2306|udp|TAPPI BoxNet
pehelp|2307|tcp|pehelp
pehelp|2307|udp|pehelp
sdhelp|2308|tcp|sdhelp
sdhelp|2308|udp|sdhelp
sdserver|2309|tcp|SD Server
sdserver|2309|udp|SD Server
sdclient|2310|tcp|SD Client
sdclient|2310|udp|SD Client
messageservice|2311|tcp|Message Service
messageservice|2311|udp|Message Service
iapp|2313|tcp|IAPP (Inter Access Point Protocol)
iapp|2313|udp|IAPP (Inter Access Point Protocol)
cr-websystems|2314|tcp|CR WebSystems
cr-websystems|2314|udp|CR WebSystems
precise-sft|2315|tcp|Precise Sft.
precise-sft|2315|udp|Precise Sft.
sent-lm|2316|tcp|SENT License Manager
sent-lm|2316|udp|SENT License Manager
attachmate-g32|2317|tcp|Attachmate G32
attachmate-g32|2317|udp|Attachmate G32
cadencecontrol|2318|tcp|Cadence Control
cadencecontrol|2318|udp|Cadence Control
infolibria|2319|tcp|InfoLibria
infolibria|2319|udp|InfoLibria
siebel-ns|2320|tcp|Siebel NS
siebel-ns|2320|udp|Siebel NS
rdlap|2321|tcp|RDLAP
rdlap|2321|udp|RDLAP
ofsd|2322|tcp|ofsd
ofsd|2322|udp|ofsd
3d-nfsd|2323|tcp|3d-nfsd
3d-nfsd|2323|udp|3d-nfsd
cosmocall|2324|tcp|Cosmocall
cosmocall|2324|udp|Cosmocall
designspace-lm|2325|tcp|Design Space License Management
designspace-lm|2325|udp|Design Space License Management
idcp|2326|tcp|IDCP
idcp|2326|udp|IDCP
xingcsm|2327|tcp|xingcsm
xingcsm|2327|udp|xingcsm
netrix-sftm|2328|tcp|Netrix SFTM
netrix-sftm|2328|udp|Netrix SFTM
nvd|2329|tcp|NVD
nvd|2329|udp|NVD
tscchat|2330|tcp|TSCCHAT
tscchat|2330|udp|TSCCHAT
agentview|2331|tcp|AGENTVIEW
agentview|2331|udp|AGENTVIEW
rcc-host|2332|tcp|RCC Host
rcc-host|2332|udp|RCC Host
snapp|2333|tcp|SNAPP
snapp|2333|udp|SNAPP
ace-client|2334|tcp|ACE Client Auth
ace-client|2334|udp|ACE Client Auth
ace-proxy|2335|tcp|ACE Proxy
ace-proxy|2335|udp|ACE Proxy
appleugcontrol|2336|tcp|Apple UG Control
appleugcontrol|2336|udp|Apple UG Control
ideesrv|2337|tcp|ideesrv
ideesrv|2337|udp|ideesrv
norton-lambert|2338|tcp|Norton Lambert
norton-lambert|2338|udp|Norton Lambert
3com-webview|2339|tcp|3Com WebView
3com-webview|2339|udp|3Com WebView
wrs_registry|2340|tcp|WRS Registry
wrs_registry|2340|udp|WRS Registry
xiostatus|2341|tcp|XIO Status
xiostatus|2341|udp|XIO Status
manage-exec|2342|tcp|Seagate Manage Exec
manage-exec|2342|udp|Seagate Manage Exec
nati-logos|2343|tcp|nati logos
nati-logos|2343|udp|nati logos
fcmsys|2344|tcp|fcmsys
fcmsys|2344|udp|fcmsys
dbm|2345|tcp|dbm
dbm|2345|udp|dbm
redstorm_join|2346|tcp|Game Connection Port
redstorm_join|2346|udp|Game Connection Port
redstorm_find|2347|tcp|Game Announcement and Location
redstorm_find|2347|udp|Game Announcement and Location
redstorm_info|2348|tcp|Information to query for game status
redstorm_info|2348|udp|Information to query for game status
redstorm_diag|2349|tcp|Diagnostics Port
redstorm_diag|2349|udp|Diagnostics Port
psbserver|2350|tcp|psbserver
psbserver|2350|udp|psbserver
psrserver|2351|tcp|psrserver
psrserver|2351|udp|psrserver
pslserver|2352|tcp|pslserver
pslserver|2352|udp|pslserver
pspserver|2353|tcp|pspserver
pspserver|2353|udp|pspserver
psprserver|2354|tcp|psprserver
psprserver|2354|udp|psprserver
psdbserver|2355|tcp|psdbserver
psdbserver|2355|udp|psdbserver
gxtelmd|2356|tcp|GXT License Managemant
gxtelmd|2356|udp|GXT License Managemant
unihub-server|2357|tcp|UniHub Server
unihub-server|2357|udp|UniHub Server
futrix|2358|tcp|Futrix
futrix|2358|udp|Futrix
flukeserver|2359|tcp|FlukeServer
flukeserver|2359|udp|FlukeServer
nexstorindltd|2360|tcp|NexstorIndLtd
nexstorindltd|2360|udp|NexstorIndLtd
tl1|2361|tcp|TL1
tl1|2361|udp|TL1
digiman|2362|tcp|digiman
digiman|2362|udp|digiman
mediacntrlnfsd|2363|tcp|Media Central NFSD
mediacntrlnfsd|2363|udp|Media Central NFSD
oi-2000|2364|tcp|OI-2000
oi-2000|2364|udp|OI-2000
dbref|2365|tcp|dbref
dbref|2365|udp|dbref
qip-login|2366|tcp|qip-login
qip-login|2366|udp|qip-login
service-ctrl|2367|tcp|Service Control
service-ctrl|2367|udp|Service Control
opentable|2368|tcp|OpenTable
opentable|2368|udp|OpenTable
acs2000-dsp|2369|tcp|ACS2000 DSP
acs2000-dsp|2369|udp|ACS2000 DSP
l3-hbmon|2370|tcp|L3-HBMon
l3-hbmon|2370|udp|L3-HBMon
worldwire|2371|tcp|Compaq WorldWire Port
worldwire|2371|udp|Compaq WorldWire Port
compaq-https|2381|tcp|Compaq HTTPS
compaq-https|2381|udp|Compaq HTTPS
ms-olap3|2382|tcp|Microsoft OLAP
ms-olap3|2382|udp|Microsoft OLAP
ms-olap4|2383|tcp|Microsoft OLAP
ms-olap4|2383|udp|Microsoft OLAP
sd-request|2384|tcp|SD-REQUEST
sd-capacity|2384|udp|SD-CAPACITY
sd-data|2385|tcp|SD-DATA
sd-data|2385|udp|SD-DATA
virtualtape|2386|tcp|Virtual Tape
virtualtape|2386|udp|Virtual Tape
vsamredirector|2387|tcp|VSAM Redirector
vsamredirector|2387|udp|VSAM Redirector
mynahautostart|2388|tcp|MYNAH AutoStart
mynahautostart|2388|udp|MYNAH AutoStart
ovsessionmgr|2389|tcp|OpenView Session Mgr
ovsessionmgr|2389|udp|OpenView Session Mgr
rsmtp|2390|tcp|RSMTP
rsmtp|2390|udp|RSMTP
3com-net-mgmt|2391|tcp|3COM Net Management
3com-net-mgmt|2391|udp|3COM Net Management
tacticalauth|2392|tcp|Tactical Auth
tacticalauth|2392|udp|Tactical Auth
ms-olap1|2393|tcp|MS OLAP 1
ms-olap1|2393|udp|MS OLAP 1
ms-olap2|2394|tcp|MS OLAP 2
ms-olap2|2394|udp|MS OLAP 2
lan900_remote|2395|tcp|LAN900 Remote
lan900_remote|2395|udp|LAN900 Remote
wusage|2396|tcp|Wusage
wusage|2396|udp|Wusage
ncl|2397|tcp|NCL
ncl|2397|udp|NCL
orbiter|2398|tcp|Orbiter
orbiter|2398|udp|Orbiter
fmpro-fdal|2399|tcp|FileMaker, Inc. - Data Access Layer
fmpro-fdal|2399|udp|FileMaker, Inc. - Data Access Layer
opequus-server|2400|tcp|OpEquus Server
opequus-server|2400|udp|OpEquus Server
cvspserver|2401|tcp|cvspserver
cvspserver|2401|udp|cvspserver
taskmaster2000|2402|tcp|TaskMaster 2000 Server
taskmaster2000|2402|udp|TaskMaster 2000 Server
taskmaster2000|2403|tcp|TaskMaster 2000 Web
taskmaster2000|2403|udp|TaskMaster 2000 Web
iec-104|2404|tcp|IEC 60870-5-104 process control over IP
iec-104|2404|udp|IEC 60870-5-104 process control over IP
trc-netpoll|2405|tcp|TRC Netpoll
trc-netpoll|2405|udp|TRC Netpoll
jediserver|2406|tcp|JediServer
jediserver|2406|udp|JediServer
orion|2407|tcp|Orion
orion|2407|udp|Orion
optimanet|2408|tcp|OptimaNet
optimanet|2408|udp|OptimaNet
sns-protocol|2409|tcp|SNS Protocol
sns-protocol|2409|udp|SNS Protocol
vrts-registry|2410|tcp|VRTS Registry
vrts-registry|2410|udp|VRTS Registry
netwave-ap-mgmt|2411|tcp|Netwave AP Management
netwave-ap-mgmt|2411|udp|Netwave AP Management
cdn|2412|tcp|CDN
cdn|2412|udp|CDN
orion-rmi-reg|2413|tcp|orion-rmi-reg
orion-rmi-reg|2413|udp|orion-rmi-reg
beeyond|2414|tcp|Beeyond
beeyond|2414|udp|Beeyond
codima-rtp|2415|tcp|Codima Remote Transaction Protocol
codima-rtp|2415|udp|Codima Remote Transaction Protocol
rmtserver|2416|tcp|RMT Server
rmtserver|2416|udp|RMT Server
composit-server|2417|tcp|Composit Server
composit-server|2417|udp|Composit Server
cas|2418|tcp|cas
cas|2418|udp|cas
attachmate-s2s|2419|tcp|Attachmate S2S
attachmate-s2s|2419|udp|Attachmate S2S
dslremote-mgmt|2420|tcp|DSL Remote Management
dslremote-mgmt|2420|udp|DSL Remote Management
g-talk|2421|tcp|G-Talk
g-talk|2421|udp|G-Talk
crmsbits|2422|tcp|CRMSBITS
crmsbits|2422|udp|CRMSBITS
rnrp|2423|tcp|RNRP
rnrp|2423|udp|RNRP
kofax-svr|2424|tcp|KOFAX-SVR
kofax-svr|2424|udp|KOFAX-SVR
fjitsuappmgr|2425|tcp|Fujitsu App Manager
fjitsuappmgr|2425|udp|Fujitsu App Manager
mgcp-gateway|2427|tcp|Media Gateway Control Protocol Gateway
mgcp-gateway|2427|udp|Media Gateway Control Protocol Gateway
ott|2428|tcp|One Way Trip Time
ott|2428|udp|One Way Trip Time
ft-role|2429|tcp|FT-ROLE
ft-role|2429|udp|FT-ROLE
venus|2430|tcp|venus
venus|2430|udp|venus
venus-se|2431|tcp|venus-se
venus-se|2431|udp|venus-se
codasrv|2432|tcp|codasrv
codasrv|2432|udp|codasrv
codasrv-se|2433|tcp|codasrv-se
codasrv-se|2433|udp|codasrv-se
pxc-epmap|2434|tcp|pxc-epmap
pxc-epmap|2434|udp|pxc-epmap
optilogic|2435|tcp|OptiLogic
optilogic|2435|udp|OptiLogic
topx|2436|tcp|TOP/X
topx|2436|udp|TOP/X
unicontrol|2437|tcp|UniControl
unicontrol|2437|udp|UniControl
msp|2438|tcp|MSP
msp|2438|udp|MSP
sybasedbsynch|2439|tcp|SybaseDBSynch
sybasedbsynch|2439|udp|SybaseDBSynch
spearway|2440|tcp|Spearway Lockers
spearway|2440|udp|Spearway Lockers
pvsw-inet|2441|tcp|Pervasive I*net Data Server
pvsw-inet|2441|udp|Pervasive I*net Data Server
netangel|2442|tcp|Netangel
netangel|2442|udp|Netangel
powerclientcsf|2443|tcp|PowerClient Central Storage Facility
powerclientcsf|2443|udp|PowerClient Central Storage Facility
btpp2sectrans|2444|tcp|BT PP2 Sectrans
btpp2sectrans|2444|udp|BT PP2 Sectrans
dtn1|2445|tcp|DTN1
dtn1|2445|udp|DTN1
bues_service|2446|tcp|bues_service
bues_service|2446|udp|bues_service
ovwdb|2447|tcp|OpenView NNM daemon
ovwdb|2447|udp|OpenView NNM daemon
hpppssvr|2448|tcp|hpppsvr
hpppssvr|2448|udp|hpppsvr
ratl|2449|tcp|RATL
ratl|2449|udp|RATL
netadmin|2450|tcp|netadmin
netadmin|2450|udp|netadmin
netchat|2451|tcp|netchat
netchat|2451|udp|netchat
snifferclient|2452|tcp|SnifferClient
snifferclient|2452|udp|SnifferClient
madge-om|2453|tcp|madge-om
madge-om|2453|udp|madge-om
indx-dds|2454|tcp|IndX-DDS
indx-dds|2454|udp|IndX-DDS
wago-io-system|2455|tcp|WAGO-IO-SYSTEM
wago-io-system|2455|udp|WAGO-IO-SYSTEM
altav-remmgt|2456|tcp|altav-remmgt
altav-remmgt|2456|udp|altav-remmgt
rapido-ip|2457|tcp|Rapido_IP
rapido-ip|2457|udp|Rapido_IP
griffin|2458|tcp|griffin
griffin|2458|udp|griffin
community|2459|tcp|Community
community|2459|udp|Community
ms-theater|2460|tcp|ms-theater
ms-theater|2460|udp|ms-theater
qadmifoper|2461|tcp|qadmifoper
qadmifoper|2461|udp|qadmifoper
qadmifevent|2462|tcp|qadmifevent
qadmifevent|2462|udp|qadmifevent
symbios-raid|2463|tcp|Symbios Raid
symbios-raid|2463|udp|Symbios Raid
direcpc-si|2464|tcp|DirecPC SI
direcpc-si|2464|udp|DirecPC SI
lbm|2465|tcp|Load Balance Management
lbm|2465|udp|Load Balance Management
lbf|2466|tcp|Load Balance Forwarding
lbf|2466|udp|Load Balance Forwarding
high-criteria|2467|tcp|High Criteria
high-criteria|2467|udp|High Criteria
qip-msgd|2468|tcp|qip_msgd
qip-msgd|2468|udp|qip_msgd
mti-tcs-comm|2469|tcp|MTI-TCS-COMM
mti-tcs-comm|2469|udp|MTI-TCS-COMM
taskman-port|2470|tcp|taskman port
taskman-port|2470|udp|taskman port
seaodbc|2471|tcp|SeaODBC
seaodbc|2471|udp|SeaODBC
c3|2472|tcp|C3
c3|2472|udp|C3
aker-cdp|2473|tcp|Aker-cdp
aker-cdp|2473|udp|Aker-cdp
vitalanalysis|2474|tcp|Vital Analysis
vitalanalysis|2474|udp|Vital Analysis
ace-server|2475|tcp|ACE Server
ace-server|2475|udp|ACE Server
ace-svr-prop|2476|tcp|ACE Server Propagation
ace-svr-prop|2476|udp|ACE Server Propagation
ssm-cvs|2477|tcp|SecurSight Certificate Valifation Service
ssm-cvs|2477|udp|SecurSight Certificate Valifation Service
ssm-cssps|2478|tcp|SecurSight Authentication Server (SSL)
ssm-cssps|2478|udp|SecurSight Authentication Server (SSL)
ssm-els|2479|tcp|SecurSight Event Logging Server (SSL)
ssm-els|2479|udp|SecurSight Event Logging Server (SSL)
lingwood|2480|tcp|Lingwood's Detail
lingwood|2480|udp|Lingwood's Detail
giop|2481|tcp|Oracle GIOP
giop|2481|udp|Oracle GIOP
giop-ssl|2482|tcp|Oracle GIOP SSL
giop-ssl|2482|udp|Oracle GIOP SSL
ttc|2483|tcp|Oracle TTC
ttc|2483|udp|Oracle TTC
ttc-ssl|2484|tcp|Oracle TTC SSL
ttc-ssl|2484|udp|Oracle TTC SSL
netobjects1|2485|tcp|Net Objects1
netobjects1|2485|udp|Net Objects1
netobjects2|2486|tcp|Net Objects2
netobjects2|2486|udp|Net Objects2
pns|2487|tcp|Policy Notice Service
pns|2487|udp|Policy Notice Service
moy-corp|2488|tcp|Moy Corporation
moy-corp|2488|udp|Moy Corporation
tsilb|2489|tcp|TSILB
tsilb|2489|udp|TSILB
qip-qdhcp|2490|tcp|qip_qdhcp
qip-qdhcp|2490|udp|qip_qdhcp
conclave-cpp|2491|tcp|Conclave CPP
conclave-cpp|2491|udp|Conclave CPP
groove|2492|tcp|GROOVE
groove|2492|udp|GROOVE
talarian-mqs|2493|tcp|Talarian MQS
talarian-mqs|2493|udp|Talarian MQS
bmc-ar|2494|tcp|BMC AR
bmc-ar|2494|udp|BMC AR
fast-rem-serv|2495|tcp|Fast Remote Services
fast-rem-serv|2495|udp|Fast Remote Services
dirgis|2496|tcp|DIRGIS
dirgis|2496|udp|DIRGIS
quaddb|2497|tcp|Quad DB
quaddb|2497|udp|Quad DB
odn-castraq|2498|tcp|ODN-CasTraq
odn-castraq|2498|udp|ODN-CasTraq
unicontrol|2499|tcp|UniControl
unicontrol|2499|udp|UniControl
rtsserv|2500|tcp|Resource Tracking system server
rtsserv|2500|udp|Resource Tracking system server
rtsclient|2501|tcp|Resource Tracking system client
rtsclient|2501|udp|Resource Tracking system client
kentrox-prot|2502|tcp|Kentrox Protocol
kentrox-prot|2502|udp|Kentrox Protocol
nms-dpnss|2503|tcp|NMS-DPNSS
nms-dpnss|2503|udp|NMS-DPNSS
wlbs|2504|tcp|WLBS
wlbs|2504|udp|WLBS
jbroker|2506|tcp|jbroker
jbroker|2506|udp|jbroker
spock|2507|tcp|spock
spock|2507|udp|spock
jdatastore|2508|tcp|JDataStore
jdatastore|2508|udp|JDataStore
fjmpss|2509|tcp|fjmpss
fjmpss|2509|udp|fjmpss
fjappmgrbulk|2510|tcp|fjappmgrbulk
fjappmgrbulk|2510|udp|fjappmgrbulk
metastorm|2511|tcp|Metastorm
metastorm|2511|udp|Metastorm
citrixima|2512|tcp|Citrix IMA
citrixima|2512|udp|Citrix IMA
citrixadmin|2513|tcp|Citrix ADMIN
citrixadmin|2513|udp|Citrix ADMIN
facsys-ntp|2514|tcp|Facsys NTP
facsys-ntp|2514|udp|Facsys NTP
facsys-router|2515|tcp|Facsys Router
facsys-router|2515|udp|Facsys Router
maincontrol|2516|tcp|Main Control
maincontrol|2516|udp|Main Control
call-sig-trans|2517|tcp|H.323 Annex E call signaling transport
call-sig-trans|2517|udp|H.323 Annex E call signaling transport
willy|2518|tcp|Willy
willy|2518|udp|Willy
globmsgsvc|2519|tcp|globmsgsvc
globmsgsvc|2519|udp|globmsgsvc
pvsw|2520|tcp|Pervasive Listener
pvsw|2520|udp|Pervasive Listener
adaptecmgr|2521|tcp|Adaptec Manager
adaptecmgr|2521|udp|Adaptec Manager
windb|2522|tcp|WinDb
windb|2522|udp|WinDb
qke-llc-v3|2523|tcp|Qke LLC V.3
qke-llc-v3|2523|udp|Qke LLC V.3
optiwave-lm|2524|tcp|Optiwave License Management
optiwave-lm|2524|udp|Optiwave License Management
ms-v-worlds|2525|tcp|MS V-Worlds
ms-v-worlds|2525|udp|MS V-Worlds
ema-sent-lm|2526|tcp|EMA License Manager
ema-sent-lm|2526|udp|EMA License Manager
iqserver|2527|tcp|IQ Server
iqserver|2527|udp|IQ Server
ncr_ccl|2528|tcp|NCR CCL
ncr_ccl|2528|udp|NCR CCL
utsftp|2529|tcp|UTS FTP
utsftp|2529|udp|UTS FTP
vrcommerce|2530|tcp|VR Commerce
vrcommerce|2530|udp|VR Commerce
ito-e-gui|2531|tcp|ITO-E GUI
ito-e-gui|2531|udp|ITO-E GUI
ovtopmd|2532|tcp|OVTOPMD
ovtopmd|2532|udp|OVTOPMD
snifferserver|2533|tcp|SnifferServer
snifferserver|2533|udp|SnifferServer
combox-web-acc|2534|tcp|Combox Web Access
combox-web-acc|2534|udp|Combox Web Access
madcap|2535|tcp|MADCAP
madcap|2535|udp|MADCAP
btpp2audctr1|2536|tcp|btpp2audctr1
btpp2audctr1|2536|udp|btpp2audctr1
upgrade|2537|tcp|Upgrade Protocol
upgrade|2537|udp|Upgrade Protocol
vnwk-prapi|2538|tcp|vnwk-prapi
vnwk-prapi|2538|udp|vnwk-prapi
vsiadmin|2539|tcp|VSI Admin
vsiadmin|2539|udp|VSI Admin
lonworks|2540|tcp|LonWorks
lonworks|2540|udp|LonWorks
lonworks2|2541|tcp|LonWorks2
lonworks2|2541|udp|LonWorks2
davinci|2542|tcp|daVinci Presenter
davinci|2542|udp|daVinci Presenter
reftek|2543|tcp|REFTEK
reftek|2543|udp|REFTEK
novell-zen|2544|tcp|Novell ZEN
novell-zen|2544|udp|Novell ZEN
sis-emt|2545|tcp|sis-emt
sis-emt|2545|udp|sis-emt
vytalvaultbrtp|2546|tcp|vytalvaultbrtp
vytalvaultbrtp|2546|udp|vytalvaultbrtp
vytalvaultvsmp|2547|tcp|vytalvaultvsmp
vytalvaultvsmp|2547|udp|vytalvaultvsmp
vytalvaultpipe|2548|tcp|vytalvaultpipe
vytalvaultpipe|2548|udp|vytalvaultpipe
ipass|2549|tcp|IPASS
ipass|2549|udp|IPASS
ads|2550|tcp|ADS
ads|2550|udp|ADS
isg-uda-server|2551|tcp|ISG UDA Server
isg-uda-server|2551|udp|ISG UDA Server
call-logging|2552|tcp|Call Logging
call-logging|2552|udp|Call Logging
efidiningport|2553|tcp|efidiningport
efidiningport|2553|udp|efidiningport
vcnet-link-v10|2554|tcp|VCnet-Link v10
vcnet-link-v10|2554|udp|VCnet-Link v10
compaq-wcp|2555|tcp|Compaq WCP
compaq-wcp|2555|udp|Compaq WCP
nicetec-nmsvc|2556|tcp|nicetec-nmsvc
nicetec-nmsvc|2556|udp|nicetec-nmsvc
nicetec-mgmt|2557|tcp|nicetec-mgmt
nicetec-mgmt|2557|udp|nicetec-mgmt
pclemultimedia|2558|tcp|PCLE Multi Media
pclemultimedia|2558|udp|PCLE Multi Media
lstp|2559|tcp|LSTP
lstp|2559|udp|LSTP
labrat|2560|tcp|labrat
labrat|2560|udp|labrat
mosaixcc|2561|tcp|MosaixCC
mosaixcc|2561|udp|MosaixCC
delibo|2562|tcp|Delibo
delibo|2562|udp|Delibo
cti-redwood|2563|tcp|CTI Redwood
cti-redwood|2563|udp|CTI Redwood
hp-3000-telnet|2564|tcp|HP 3000 NS/VT block mode telnet
coord-svr|2565|tcp|Coordinator Server
coord-svr|2565|udp|Coordinator Server
pcs-pcw|2566|tcp|pcs-pcw
pcs-pcw|2566|udp|pcs-pcw
clp|2567|tcp|Cisco Line Protocol
clp|2567|udp|Cisco Line Protocol
spamtrap|2568|tcp|SPAM TRAP
spamtrap|2568|udp|SPAM TRAP
sonuscallsig|2569|tcp|Sonus Call Signal
sonuscallsig|2569|udp|Sonus Call Signal
hs-port|2570|tcp|HS Port
hs-port|2570|udp|HS Port
cecsvc|2571|tcp|CECSVC
cecsvc|2571|udp|CECSVC
ibp|2572|tcp|IBP
ibp|2572|udp|IBP
trustestablish|2573|tcp|Trust Establish
trustestablish|2573|udp|Trust Establish
blockade-bpsp|2574|tcp|Blockade BPSP
blockade-bpsp|2574|udp|Blockade BPSP
hl7|2575|tcp|HL7
hl7|2575|udp|HL7
tclprodebugger|2576|tcp|TCL Pro Debugger
tclprodebugger|2576|udp|TCL Pro Debugger
scipticslsrvr|2577|tcp|Scriptics Lsrvr
scipticslsrvr|2577|udp|Scriptics Lsrvr
rvs-isdn-dcp|2578|tcp|RVS ISDN DCP
rvs-isdn-dcp|2578|udp|RVS ISDN DCP
mpfoncl|2579|tcp|mpfoncl
mpfoncl|2579|udp|mpfoncl
tributary|2580|tcp|Tributary
tributary|2580|udp|Tributary
argis-te|2581|tcp|ARGIS TE
argis-te|2581|udp|ARGIS TE
argis-ds|2582|tcp|ARGIS DS
argis-ds|2582|udp|ARGIS DS
mon|2583|tcp|MON
mon|2583|udp|MON
cyaserv|2584|tcp|cyaserv
cyaserv|2584|udp|cyaserv
netx-server|2585|tcp|NETX Server
netx-server|2585|udp|NETX Server
netx-agent|2586|tcp|NETX Agent
netx-agent|2586|udp|NETX Agent
masc|2587|tcp|MASC
masc|2587|udp|MASC
privilege|2588|tcp|Privilege
privilege|2588|udp|Privilege
quartus-tcl|2589|tcp|quartus tcl
quartus-tcl|2589|udp|quartus tcl
idotdist|2590|tcp|idotdist
idotdist|2590|udp|idotdist
maytagshuffle|2591|tcp|Maytag Shuffle
maytagshuffle|2591|udp|Maytag Shuffle
netrek|2592|tcp|netrek
netrek|2592|udp|netrek
mns-mail|2593|tcp|MNS Mail Notice Service
mns-mail|2593|udp|MNS Mail Notice Service
dts|2594|tcp|Data Base Server
dts|2594|udp|Data Base Server
worldfusion1|2595|tcp|World Fusion 1
worldfusion1|2595|udp|World Fusion 1
worldfusion2|2596|tcp|World Fusion 2
worldfusion2|2596|udp|World Fusion 2
homesteadglory|2597|tcp|Homestead Glory
homesteadglory|2597|udp|Homestead Glory
citriximaclient|2598|tcp|Citrix MA Client
citriximaclient|2598|udp|Citrix MA Client
snapd|2599|tcp|Snap Discovery
snapd|2599|udp|Snap Discovery
hpstgmgr|2600|tcp|HPSTGMGR
hpstgmgr|2600|udp|HPSTGMGR
discp-client|2601|tcp|discp client
discp-client|2601|udp|discp client
discp-server|2602|tcp|discp server
discp-server|2602|udp|discp server
servicemeter|2603|tcp|Service Meter
servicemeter|2603|udp|Service Meter
nsc-ccs|2604|tcp|NSC CCS
nsc-ccs|2604|udp|NSC CCS
nsc-posa|2605|tcp|NSC POSA
nsc-posa|2605|udp|NSC POSA
netmon|2606|tcp|Dell Netmon
netmon|2606|udp|Dell Netmon
connection|2607|tcp|Dell Connection
connection|2607|udp|Dell Connection
wag-service|2608|tcp|Wag Service
wag-service|2608|udp|Wag Service
system-monitor|2609|tcp|System Monitor
system-monitor|2609|udp|System Monitor
versa-tek|2610|tcp|VersaTek
versa-tek|2610|udp|VersaTek
lionhead|2611|tcp|LIONHEAD
lionhead|2611|udp|LIONHEAD
qpasa-agent|2612|tcp|Qpasa Agent
qpasa-agent|2612|udp|Qpasa Agent
smntubootstrap|2613|tcp|SMNTUBootstrap
smntubootstrap|2613|udp|SMNTUBootstrap
neveroffline|2614|tcp|Never Offline
neveroffline|2614|udp|Never Offline
firepower|2615|tcp|firepower
firepower|2615|udp|firepower
appswitch-emp|2616|tcp|appswitch-emp
appswitch-emp|2616|udp|appswitch-emp
cmadmin|2617|tcp|Clinical Context Managers
cmadmin|2617|udp|Clinical Context Managers
priority-e-com|2618|tcp|Priority E-Com
priority-e-com|2618|udp|Priority E-Com
bruce|2619|tcp|bruce
bruce|2619|udp|bruce
lpsrecommender|2620|tcp|LPSRecommender
lpsrecommender|2620|udp|LPSRecommender
miles-apart|2621|tcp|Miles Apart Jukebox Server
miles-apart|2621|udp|Miles Apart Jukebox Server
metricadbc|2622|tcp|MetricaDBC
metricadbc|2622|udp|MetricaDBC
lmdp|2623|tcp|LMDP
lmdp|2623|udp|LMDP
aria|2624|tcp|Aria
aria|2624|udp|Aria
blwnkl-port|2625|tcp|Blwnkl Port
blwnkl-port|2625|udp|Blwnkl Port
gbjd816|2626|tcp|gbjd816
gbjd816|2626|udp|gbjd816
moshebeeri|2627|tcp|Moshe Beeri
moshebeeri|2627|udp|Moshe Beeri
dict|2628|tcp|DICT
dict|2628|udp|DICT
sitaraserver|2629|tcp|Sitara Server
sitaraserver|2629|udp|Sitara Server
sitaramgmt|2630|tcp|Sitara Management
sitaramgmt|2630|udp|Sitara Management
sitaradir|2631|tcp|Sitara Dir
sitaradir|2631|udp|Sitara Dir
irdg-post|2632|tcp|IRdg Post
irdg-post|2632|udp|IRdg Post
interintelli|2633|tcp|InterIntelli
interintelli|2633|udp|InterIntelli
pk-electronics|2634|tcp|PK Electronics
pk-electronics|2634|udp|PK Electronics
backburner|2635|tcp|Back Burner
backburner|2635|udp|Back Burner
solve|2636|tcp|Solve
solve|2636|udp|Solve
imdocsvc|2637|tcp|Import Document Service
imdocsvc|2637|udp|Import Document Service
sybaseanywhere|2638|tcp|Sybase Anywhere
sybaseanywhere|2638|udp|Sybase Anywhere
aminet|2639|tcp|AMInet
aminet|2639|udp|AMInet
sai_sentlm|2640|tcp|Sabbagh Associates Licence Manager
sai_sentlm|2640|udp|Sabbagh Associates Licence Manager
hdl-srv|2641|tcp|HDL Server
hdl-srv|2641|udp|HDL Server
tragic|2642|tcp|Tragic
tragic|2642|udp|Tragic
gte-samp|2643|tcp|GTE-SAMP
gte-samp|2643|udp|GTE-SAMP
travsoft-ipx-t|2644|tcp|Travsoft IPX Tunnel
travsoft-ipx-t|2644|udp|Travsoft IPX Tunnel
novell-ipx-cmd|2645|tcp|Novell IPX CMD
novell-ipx-cmd|2645|udp|Novell IPX CMD
and-lm|2646|tcp|AND License Manager
and-lm|2646|udp|AND License Manager
syncserver|2647|tcp|SyncServer
syncserver|2647|udp|SyncServer
upsnotifyprot|2648|tcp|Upsnotifyprot
upsnotifyprot|2648|udp|Upsnotifyprot
vpsipport|2649|tcp|VPSIPPORT
vpsipport|2649|udp|VPSIPPORT
eristwoguns|2650|tcp|eristwoguns
eristwoguns|2650|udp|eristwoguns
ebinsite|2651|tcp|EBInSite
ebinsite|2651|udp|EBInSite
interpathpanel|2652|tcp|InterPathPanel
interpathpanel|2652|udp|InterPathPanel
sonus|2653|tcp|Sonus
sonus|2653|udp|Sonus
corel_vncadmin|2654|tcp|Corel VNC Admin
corel_vncadmin|2654|udp|Corel VNC Admin
unglue|2655|tcp|UNIX Nt Glue
unglue|2655|udp|UNIX Nt Glue
kana|2656|tcp|Kana
kana|2656|udp|Kana
sns-dispatcher|2657|tcp|SNS Dispatcher
sns-dispatcher|2657|udp|SNS Dispatcher
sns-admin|2658|tcp|SNS Admin
sns-admin|2658|udp|SNS Admin
sns-query|2659|tcp|SNS Query
sns-query|2659|udp|SNS Query
gcmonitor|2660|tcp|GC Monitor
gcmonitor|2660|udp|GC Monitor
olhost|2661|tcp|OLHOST
olhost|2661|udp|OLHOST
bintec-capi|2662|tcp|BinTec-CAPI
bintec-capi|2662|udp|BinTec-CAPI
bintec-tapi|2663|tcp|BinTec-TAPI
bintec-tapi|2663|udp|BinTec-TAPI
patrol-mq-gm|2664|tcp|Patrol for MQ GM
patrol-mq-gm|2664|udp|Patrol for MQ GM
patrol-mq-nm|2665|tcp|Patrol for MQ NM
patrol-mq-nm|2665|udp|Patrol for MQ NM
extensis|2666|tcp|extensis
extensis|2666|udp|extensis
alarm-clock-s|2667|tcp|Alarm Clock Server
alarm-clock-s|2667|udp|Alarm Clock Server
alarm-clock-c|2668|tcp|Alarm Clock Client
alarm-clock-c|2668|udp|Alarm Clock Client
toad|2669|tcp|TOAD
toad|2669|udp|TOAD
tve-announce|2670|tcp|TVE Announce
tve-announce|2670|udp|TVE Announce
newlixreg|2671|tcp|newlixreg
newlixreg|2671|udp|newlixreg
nhserver|2672|tcp|nhserver
nhserver|2672|udp|nhserver
firstcall42|2673|tcp|First Call 42
firstcall42|2673|udp|First Call 42
ewnn|2674|tcp|ewnn
ewnn|2674|udp|ewnn
ttc-etap|2675|tcp|TTC ETAP
ttc-etap|2675|udp|TTC ETAP
simslink|2676|tcp|SIMSLink
simslink|2676|udp|SIMSLink
gadgetgate1way|2677|tcp|Gadget Gate 1 Way
gadgetgate1way|2677|udp|Gadget Gate 1 Way
gadgetgate2way|2678|tcp|Gadget Gate 2 Way
gadgetgate2way|2678|udp|Gadget Gate 2 Way
syncserverssl|2679|tcp|Sync Server SSL
syncserverssl|2679|udp|Sync Server SSL
pxc-sapxom|2680|tcp|pxc-sapxom
pxc-sapxom|2680|udp|pxc-sapxom
mpnjsomb|2681|tcp|mpnjsomb
mpnjsomb|2681|udp|mpnjsomb
ncdloadbalance|2683|tcp|NCDLoadBalance
ncdloadbalance|2683|udp|NCDLoadBalance
mpnjsosv|2684|tcp|mpnjsosv
mpnjsosv|2684|udp|mpnjsosv
mpnjsocl|2685|tcp|mpnjsocl
mpnjsocl|2685|udp|mpnjsocl
mpnjsomg|2686|tcp|mpnjsomg
mpnjsomg|2686|udp|mpnjsomg
pq-lic-mgmt|2687|tcp|pq-lic-mgmt
pq-lic-mgmt|2687|udp|pq-lic-mgmt
md-cg-http|2688|tcp|md-cf-http
md-cg-http|2688|udp|md-cf-http
fastlynx|2689|tcp|FastLynx
fastlynx|2689|udp|FastLynx
hp-nnm-data|2690|tcp|HP NNM Embedded Database
hp-nnm-data|2690|udp|HP NNM Embedded Database
itinternet|2691|tcp|ITInternet ISM Server
itinternet|2691|udp|ITInternet ISM Server
admins-lms|2692|tcp|Admins LMS
admins-lms|2692|udp|Admins LMS
belarc-http|2693|tcp|belarc-http
belarc-http|2693|udp|belarc-http
pwrsevent|2694|tcp|pwrsevent
pwrsevent|2694|udp|pwrsevent
vspread|2695|tcp|VSPREAD
vspread|2695|udp|VSPREAD
unifyadmin|2696|tcp|Unify Admin
unifyadmin|2696|udp|Unify Admin
oce-snmp-trap|2697|tcp|Oce SNMP Trap Port
oce-snmp-trap|2697|udp|Oce SNMP Trap Port
mck-ivpip|2698|tcp|MCK-IVPIP
mck-ivpip|2698|udp|MCK-IVPIP
csoft-plusclnt|2699|tcp|Csoft Plus Client
csoft-plusclnt|2699|udp|Csoft Plus Client
tqdata|2700|tcp|tqdata
tqdata|2700|udp|tqdata
sms-rcinfo|2701|tcp|SMS RCINFO
sms-rcinfo|2701|udp|SMS RCINFO
sms-xfer|2702|tcp|SMS XFER
sms-xfer|2702|udp|SMS XFER
sms-chat|2703|tcp|SMS CHAT
sms-chat|2703|udp|SMS CHAT
sms-remctrl|2704|tcp|SMS REMCTRL
sms-remctrl|2704|udp|SMS REMCTRL
sds-admin|2705|tcp|SDS Admin
sds-admin|2705|udp|SDS Admin
ncdmirroring|2706|tcp|NCD Mirroring
ncdmirroring|2706|udp|NCD Mirroring
emcsymapiport|2707|tcp|EMCSYMAPIPORT
emcsymapiport|2707|udp|EMCSYMAPIPORT
banyan-net|2708|tcp|Banyan-Net
banyan-net|2708|udp|Banyan-Net
supermon|2709|tcp|Supermon
supermon|2709|udp|Supermon
sso-service|2710|tcp|SSO Service
sso-service|2710|udp|SSO Service
sso-control|2711|tcp|SSO Control
sso-control|2711|udp|SSO Control
aocp|2712|tcp|Axapta Object Communication Protocol
aocp|2712|udp|Axapta Object Communication Protocol
raven1|2713|tcp|Raven1
raven1|2713|udp|Raven1
raven2|2714|tcp|Raven2
raven2|2714|udp|Raven2
hpstgmgr2|2715|tcp|HPSTGMGR2
hpstgmgr2|2715|udp|HPSTGMGR2
inova-ip-disco|2716|tcp|Inova IP Disco
inova-ip-disco|2716|udp|Inova IP Disco
pn-requester|2717|tcp|PN REQUESTER
pn-requester|2717|udp|PN REQUESTER
pn-requester2|2718|tcp|PN REQUESTER 2
pn-requester2|2718|udp|PN REQUESTER 2
scan-change|2719|tcp|Scan & Change
scan-change|2719|udp|Scan & Change
wkars|2720|tcp|wkars
wkars|2720|udp|wkars
smart-diagnose|2721|tcp|Smart Diagnose
smart-diagnose|2721|udp|Smart Diagnose
proactivesrvr|2722|tcp|Proactive Server
proactivesrvr|2722|udp|Proactive Server
watchdognt|2723|tcp|WatchDog NT
watchdognt|2723|udp|WatchDog NT
qotps|2724|tcp|qotps
qotps|2724|udp|qotps
msolap-ptp2|2725|tcp|MSOLAP PTP2
msolap-ptp2|2725|udp|MSOLAP PTP2
tams|2726|tcp|TAMS
tams|2726|udp|TAMS
mgcp-callagent|2727|tcp|Media Gateway Control Protocol Call Agent
mgcp-callagent|2727|udp|Media Gateway Control Protocol Call Agent
sqdr|2728|tcp|SQDR
sqdr|2728|udp|SQDR
tcim-control|2729|tcp|TCIM Control
tcim-control|2729|udp|TCIM Control
nec-raidplus|2730|tcp|NEC RaidPlus
nec-raidplus|2730|udp|NEC RaidPlus
fyre-messanger|2731|tcp|Fyre Messanger
fyre-messanger|2731|udp|Fyre Messagner
g5m|2732|tcp|G5M
g5m|2732|udp|G5M
signet-ctf|2733|tcp|Signet CTF
signet-ctf|2733|udp|Signet CTF
ccs-software|2734|tcp|CCS Software
ccs-software|2734|udp|CCS Software
netiq-mc|2735|tcp|NetIQ Monitor Console
netiq-mc|2735|udp|NetIQ Monitor Console
radwiz-nms-srv|2736|tcp|RADWIZ NMS SRV
radwiz-nms-srv|2736|udp|RADWIZ NMS SRV
srp-feedback|2737|tcp|SRP Feedback
srp-feedback|2737|udp|SRP Feedback
ndl-tcp-ois-gw|2738|tcp|NDL TCP-OSI Gateway
ndl-tcp-ois-gw|2738|udp|NDL TCP-OSI Gateway
tn-timing|2739|tcp|TN Timing
tn-timing|2739|udp|TN Timing
alarm|2740|tcp|Alarm
alarm|2740|udp|Alarm
tsb|2741|tcp|TSB
tsb|2741|udp|TSB
tsb2|2742|tcp|TSB2
tsb2|2742|udp|TSB2
murx|2743|tcp|murx
murx|2743|udp|murx
honyaku|2744|tcp|honyaku
honyaku|2744|udp|honyaku
urbisnet|2745|tcp|URBISNET
urbisnet|2745|udp|URBISNET
cpudpencap|2746|tcp|CPUDPENCAP
cpudpencap|2746|udp|CPUDPENCAP
fjippol-swrly|2747|tcp|fjippol-swrly
fjippol-swrly|2747|udp|fjippol-swrly
fjippol-polsvr|2748|tcp|fjippol-polsvr
fjippol-polsvr|2748|udp|fjippol-polsvr
fjippol-cnsl|2749|tcp|fjippol-cnsl
fjippol-cnsl|2749|udp|fjippol-cnsl
fjippol-port1|2750|tcp|fjippol-port1
fjippol-port1|2750|udp|fjippol-port1
fjippol-port2|2751|tcp|fjippol-port2
fjippol-port2|2751|udp|fjippol-port2
rsisysaccess|2752|tcp|RSISYS ACCESS
rsisysaccess|2752|udp|RSISYS ACCESS
de-spot|2753|tcp|de-spot
de-spot|2753|udp|de-spot
apollo-cc|2754|tcp|APOLLO CC
apollo-cc|2754|udp|APOLLO CC
expresspay|2755|tcp|Express Pay
expresspay|2755|udp|Express Pay
simplement-tie|2756|tcp|simplement-tie
simplement-tie|2756|udp|simplement-tie
cnrp|2757|tcp|CNRP
cnrp|2757|udp|CNRP
apollo-status|2758|tcp|APOLLO Status
apollo-status|2758|udp|APOLLO Status
apollo-gms|2759|tcp|APOLLO GMS
apollo-gms|2759|udp|APOLLO GMS
sabams|2760|tcp|Saba MS
sabams|2760|udp|Saba MS
dicom-iscl|2761|tcp|DICOM ISCL
dicom-iscl|2761|udp|DICOM ISCL
dicom-tls|2762|tcp|DICOM TLS
dicom-tls|2762|udp|DICOM TLS
desktop-dna|2763|tcp|Desktop DNA
desktop-dna|2763|udp|Desktop DNA
data-insurance|2764|tcp|Data Insurance
data-insurance|2764|udp|Data Insurance
qip-audup|2765|tcp|qip-audup
qip-audup|2765|udp|qip-audup
compaq-scp|2766|tcp|Compaq SCP
compaq-scp|2766|udp|Compaq SCP
uadtc|2767|tcp|UADTC
uadtc|2767|udp|UADTC
uacs|2768|tcp|UACS
uacs|2768|udp|UACS
singlept-mvs|2769|tcp|Single Point MVS
singlept-mvs|2769|udp|Single Point MVS
veronica|2770|tcp|Veronica
veronica|2770|udp|Veronica
vergencecm|2771|tcp|Vergence CM
vergencecm|2771|udp|Vergence CM
auris|2772|tcp|auris
auris|2772|udp|auris
rbakcup1|2773|tcp|RBackup Remote Backup
rbakcup1|2773|udp|RBackup Remote Backup
rbakcup2|2774|tcp|RBackup Remote Backup
rbakcup2|2774|udp|RBackup Remote Backup
smpp|2775|tcp|SMPP
smpp|2775|udp|SMPP
ridgeway1|2776|tcp|Ridgeway Systems & Software
ridgeway1|2776|udp|Ridgeway Systems & Software
ridgeway2|2777|tcp|Ridgeway Systems & Software
ridgeway2|2777|udp|Ridgeway Systems & Software
gwen-sonya|2778|tcp|Gwen-Sonya
gwen-sonya|2778|udp|Gwen-Sonya
lbc-sync|2779|tcp|LBC Sync
lbc-sync|2779|udp|LBC Sync
lbc-control|2780|tcp|LBC Control
lbc-control|2780|udp|LBC Control
whosells|2781|tcp|whosells
whosells|2781|udp|whosells
everydayrc|2782|tcp|everydayrc
everydayrc|2782|udp|everydayrc
aises|2783|tcp|AISES
aises|2783|udp|AISES
www-dev|2784|tcp|world wide web - development
www-dev|2784|udp|world wide web - development
aic-np|2785|tcp|aic-np
aic-np|2785|udp|aic-np
aic-oncrpc|2786|tcp|aic-oncrpc - Destiny MCD database
aic-oncrpc|2786|udp|aic-oncrpc - Destiny MCD database
piccolo|2787|tcp|piccolo - Cornerstone Software
piccolo|2787|udp|piccolo - Cornerstone Software
fryeserv|2788|tcp|NetWare Loadable Module - Seagate Software
fryeserv|2788|udp|NetWare Loadable Module - Seagate Software
media-agent|2789|tcp|Media Agent
media-agent|2789|udp|Media Agent
plgproxy|2790|tcp|PLG Proxy
plgproxy|2790|udp|PLG Proxy
mtport-regist|2791|tcp|MT Port Registrator
mtport-regist|2791|udp|MT Port Registrator
f5-globalsite|2792|tcp|f5-globalsite
f5-globalsite|2792|udp|f5-globalsite
initlsmsad|2793|tcp|initlsmsad
initlsmsad|2793|udp|initlsmsad
aaftp|2794|tcp|aaftp
aaftp|2794|udp|aaftp
livestats|2795|tcp|LiveStats
livestats|2795|udp|LiveStats
ac-tech|2796|tcp|ac-tech
ac-tech|2796|udp|ac-tech
esp-encap|2797|tcp|esp-encap
esp-encap|2797|udp|esp-encap
tmesis-upshot|2798|tcp|TMESIS-UPShot
tmesis-upshot|2798|udp|TMESIS-UPShot
icon-discover|2799|tcp|ICON Discover
icon-discover|2799|udp|ICON Discover
acc-raid|2800|tcp|ACC RAID
acc-raid|2800|udp|ACC RAID
igcp|2801|tcp|IGCP
igcp|2801|udp|IGCP
veritas-tcp1|2802|tcp|Veritas TCP1
veritas-udp1|2802|udp|Veritas UDP1
btprjctrl|2803|tcp|btprjctrl
btprjctrl|2803|udp|btprjctrl
telexis-vtu|2804|tcp|Telexis VTU
telexis-vtu|2804|udp|Telexis VTU
wta-wsp-s|2805|tcp|WTA WSP-S
wta-wsp-s|2805|udp|WTA WSP-S
cspuni|2806|tcp|cspuni
cspuni|2806|udp|cspuni
cspmulti|2807|tcp|cspmulti
cspmulti|2807|udp|cspmulti
j-lan-p|2808|tcp|J-LAN-P
j-lan-p|2808|udp|J-LAN-P
corbaloc|2809|tcp|CORBA LOC
corbaloc|2809|udp|CORBA LOC
netsteward|2810|tcp|Active Net Steward
netsteward|2810|udp|Active Net Steward
gsiftp|2811|tcp|GSI FTP
gsiftp|2811|udp|GSI FTP
atmtcp|2812|tcp|atmtcp
atmtcp|2812|udp|atmtcp
llm-pass|2813|tcp|llm-pass
llm-pass|2813|udp|llm-pass
llm-csv|2814|tcp|llm-csv
llm-csv|2814|udp|llm-csv
lbc-measure|2815|tcp|LBC Measurement
lbc-measure|2815|udp|LBC Measurement
lbc-watchdog|2816|tcp|LBC Watchdog
lbc-watchdog|2816|udp|LBC Watchdog
nmsigport|2817|tcp|NMSig Port
nmsigport|2817|udp|NMSig Port
rmlnk|2818|tcp|rmlnk
rmlnk|2818|udp|rmlnk
fc-faultnotify|2819|tcp|FC Fault Notification
fc-faultnotify|2819|udp|FC Fault Notification
univision|2820|tcp|UniVision
univision|2820|udp|UniVision
vrts-at-port|2821|tcp|VERITAS Authentication Service
vrts-at-port|2821|udp|VERITAS Authentication Service
ka0wuc|2822|tcp|ka0wuc
ka0wuc|2822|udp|ka0wuc
cqg-netlan|2823|tcp|CQG Net/LAN
cqg-netlan|2823|udp|CQG Net/LAN
cqg-netlan-1|2824|tcp|CQG Net/LAN 1
cqg-netlan-1|2824|udp|CQG Net/Lan 1
slc-systemlog|2826|tcp|slc systemlog
slc-systemlog|2826|udp|slc systemlog
slc-ctrlrloops|2827|tcp|slc ctrlrloops
slc-ctrlrloops|2827|udp|slc ctrlrloops
itm-lm|2828|tcp|ITM License Manager
itm-lm|2828|udp|ITM License Manager
silkp1|2829|tcp|silkp1
silkp1|2829|udp|silkp1
silkp2|2830|tcp|silkp2
silkp2|2830|udp|silkp2
silkp3|2831|tcp|silkp3
silkp3|2831|udp|silkp3
silkp4|2832|tcp|silkp4
silkp4|2832|udp|silkp4
glishd|2833|tcp|glishd
glishd|2833|udp|glishd
evtp|2834|tcp|EVTP
evtp|2834|udp|EVTP
evtp-data|2835|tcp|EVTP-DATA
evtp-data|2835|udp|EVTP-DATA
catalyst|2836|tcp|catalyst
catalyst|2836|udp|catalyst
repliweb|2837|tcp|Repliweb
repliweb|2837|udp|Repliweb
starbot|2838|tcp|Starbot
starbot|2838|udp|Starbot
nmsigport|2839|tcp|NMSigPort
nmsigport|2839|udp|NMSigPort
l3-exprt|2840|tcp|l3-exprt
l3-exprt|2840|udp|l3-exprt
l3-ranger|2841|tcp|l3-ranger
l3-ranger|2841|udp|l3-ranger
l3-hawk|2842|tcp|l3-hawk
l3-hawk|2842|udp|l3-hawk
pdnet|2843|tcp|PDnet
pdnet|2843|udp|PDnet
bpcp-poll|2844|tcp|BPCP POLL
bpcp-poll|2844|udp|BPCP POLL
bpcp-trap|2845|tcp|BPCP TRAP
bpcp-trap|2845|udp|BPCP TRAP
aimpp-hello|2846|tcp|AIMPP Hello
aimpp-hello|2846|udp|AIMPP Hello
aimpp-port-req|2847|tcp|AIMPP Port Req
aimpp-port-req|2847|udp|AIMPP Port Req
amt-blc-port|2848|tcp|AMT-BLC-PORT
amt-blc-port|2848|udp|AMT-BLC-PORT
fxp|2849|tcp|FXP
fxp|2849|udp|FXP
metaconsole|2850|tcp|MetaConsole
metaconsole|2850|udp|MetaConsole
webemshttp|2851|tcp|webemshttp
webemshttp|2851|udp|webemshttp
bears-01|2852|tcp|bears-01
bears-01|2852|udp|bears-01
ispipes|2853|tcp|ISPipes
ispipes|2853|udp|ISPipes
infomover|2854|tcp|InfoMover
infomover|2854|udp|InfoMover
cesdinv|2856|tcp|cesdinv
cesdinv|2856|udp|cesdinv
simctlp|2857|tcp|SimCtIP
simctlp|2857|udp|SimCtIP
ecnp|2858|tcp|ECNP
ecnp|2858|udp|ECNP
activememory|2859|tcp|Active Memory
activememory|2859|udp|Active Memory
dialpad-voice1|2860|tcp|Dialpad Voice 1
dialpad-voice1|2860|udp|Dialpad Voice 1
dialpad-voice2|2861|tcp|Dialpad Voice 2
dialpad-voice2|2861|udp|Dialpad Voice 2
ttg-protocol|2862|tcp|TTG Protocol
ttg-protocol|2862|udp|TTG Protocol
sonardata|2863|tcp|Sonar Data
sonardata|2863|udp|Sonar Data
astromed-main|2864|tcp|main 5001 cmd
astromed-main|2864|udp|main 5001 cmd
pit-vpn|2865|tcp|pit-vpn
pit-vpn|2865|udp|pit-vpn
iwlistener|2866|tcp|iwlistener
iwlistener|2866|udp|iwlistener
esps-portal|2867|tcp|esps-portal
esps-portal|2867|udp|esps-portal
npep-messaging|2868|tcp|NPEP Messaging
npep-messaging|2868|udp|NPEP Messaging
icslap|2869|tcp|ICSLAP
icslap|2869|udp|ICSLAP
daishi|2870|tcp|daishi
daishi|2870|udp|daishi
msi-selectplay|2871|tcp|MSI Select Play
msi-selectplay|2871|udp|MSI Select Play
radix|2872|tcp|RADIX
radix|2872|udp|RADIX
paspar2-zoomin|2873|tcp|PASPAR2 ZoomIn
paspar2-zoomin|2873|udp|PASPAR2 ZoomIn
dxmessagebase1|2874|tcp|dxmessagebase1
dxmessagebase1|2874|udp|dxmessagebase1
dxmessagebase2|2875|tcp|dxmessagebase2
dxmessagebase2|2875|udp|dxmessagebase2
sps-tunnel|2876|tcp|SPS Tunnel
sps-tunnel|2876|udp|SPS Tunnel
bluelance|2877|tcp|BLUELANCE
bluelance|2877|udp|BLUELANCE
aap|2878|tcp|AAP
aap|2878|udp|AAP
ucentric-ds|2879|tcp|ucentric-ds
ucentric-ds|2879|udp|ucentric-ds
synapse|2880|tcp|Synapse Transport
synapse|2880|udp|Synapse Transport
ndsp|2881|tcp|NDSP
ndsp|2881|udp|NDSP
ndtp|2882|tcp|NDTP
ndtp|2882|udp|NDTP
ndnp|2883|tcp|NDNP
ndnp|2883|udp|NDNP
flashmsg|2884|tcp|Flash Msg
flashmsg|2884|udp|Flash Msg
topflow|2885|tcp|TopFlow
topflow|2885|udp|TopFlow
responselogic|2886|tcp|RESPONSELOGIC
responselogic|2886|udp|RESPONSELOGIC
aironetddp|2887|tcp|aironet
aironetddp|2887|udp|aironet
spcsdlobby|2888|tcp|SPCSDLOBBY
spcsdlobby|2888|udp|SPCSDLOBBY
rsom|2889|tcp|RSOM
rsom|2889|udp|RSOM
cspclmulti|2890|tcp|CSPCLMULTI
cspclmulti|2890|udp|CSPCLMULTI
cinegrfx-elmd|2891|tcp|CINEGRFX-ELMD License Manager
cinegrfx-elmd|2891|udp|CINEGRFX-ELMD License Manager
snifferdata|2892|tcp|SNIFFERDATA
snifferdata|2892|udp|SNIFFERDATA
vseconnector|2893|tcp|VSECONNECTOR
vseconnector|2893|udp|VSECONNECTOR
abacus-remote|2894|tcp|ABACUS-REMOTE
abacus-remote|2894|udp|ABACUS-REMOTE
natuslink|2895|tcp|NATUS LINK
natuslink|2895|udp|NATUS LINK
ecovisiong6-1|2896|tcp|ECOVISIONG6-1
ecovisiong6-1|2896|udp|ECOVISIONG6-1
citrix-rtmp|2897|tcp|Citrix RTMP
citrix-rtmp|2897|udp|Citrix RTMP
appliance-cfg|2898|tcp|APPLIANCE-CFG
appliance-cfg|2898|udp|APPLIANCE-CFG
powergemplus|2899|tcp|POWERGEMPLUS
powergemplus|2899|udp|POWERGEMPLUS
quicksuite|2900|tcp|QUICKSUITE
quicksuite|2900|udp|QUICKSUITE
allstorcns|2901|tcp|ALLSTORCNS
allstorcns|2901|udp|ALLSTORCNS
netaspi|2902|tcp|NET ASPI
netaspi|2902|udp|NET ASPI
suitcase|2903|tcp|SUITCASE
suitcase|2903|udp|SUITCASE
m2ua|2904|tcp|M2UA
m2ua|2904|udp|M2UA
m2ua|2904|sctp|M2UA
m3ua|2905|tcp|M3UA
m3ua|2905|udp|De-registered (2001 June 07)
m3ua|2905|sctp|M3UA
caller9|2906|tcp|CALLER9
caller9|2906|udp|CALLER9
webmethods-b2b|2907|tcp|WEBMETHODS B2B
webmethods-b2b|2907|udp|WEBMETHODS B2B
mao|2908|tcp|mao
mao|2908|udp|mao
funk-dialout|2909|tcp|Funk Dialout
funk-dialout|2909|udp|Funk Dialout
tdaccess|2910|tcp|TDAccess
tdaccess|2910|udp|TDAccess
blockade|2911|tcp|Blockade
blockade|2911|udp|Blockade
epicon|2912|tcp|Epicon
epicon|2912|udp|Epicon
boosterware|2913|tcp|Booster Ware
boosterware|2913|udp|Booster Ware
gamelobby|2914|tcp|Game Lobby
gamelobby|2914|udp|Game Lobby
tksocket|2915|tcp|TK Socket
tksocket|2915|udp|TK Socket
elvin_server|2916|tcp|Elvin Server
elvin_server|2916|udp|Elvin Server
elvin_client|2917|tcp|Elvin Client
elvin_client|2917|udp|Elvin Client
kastenchasepad|2918|tcp|Kasten Chase Pad
kastenchasepad|2918|udp|Kasten Chase Pad
roboer|2919|tcp|ROBOER
roboer|2919|udp|ROBOER
roboeda|2920|tcp|ROBOEDA
roboeda|2920|udp|ROBOEDA
cesdcdman|2921|tcp|CESD Contents Delivery Management
cesdcdman|2921|udp|CESD Contents Delivery Management
cesdcdtrn|2922|tcp|CESD Contents Delivery Data Transfer
cesdcdtrn|2922|udp|CESD Contents Delivery Data Transfer
wta-wsp-wtp-s|2923|tcp|WTA-WSP-WTP-S
wta-wsp-wtp-s|2923|udp|WTA-WSP-WTP-S
precise-vip|2924|tcp|PRECISE-VIP
precise-vip|2924|udp|PRECISE-VIP
mobile-file-dl|2926|tcp|MOBILE-FILE-DL
mobile-file-dl|2926|udp|MOBILE-FILE-DL
unimobilectrl|2927|tcp|UNIMOBILECTRL
unimobilectrl|2927|udp|UNIMOBILECTRL
redstone-cpss|2928|tcp|REDSTONE-CPSS
redstone-cpss|2928|udp|REDSTONE-CPSS
amx-webadmin|2929|tcp|AMX-WEBADMIN
amx-webadmin|2929|udp|AMX-WEBADMIN
amx-weblinx|2930|tcp|AMX-WEBLINX
amx-weblinx|2930|udp|AMX-WEBLINX
circle-x|2931|tcp|Circle-X
circle-x|2931|udp|Circle-X
incp|2932|tcp|INCP
incp|2932|udp|INCP
4-tieropmgw|2933|tcp|4-TIER OPM GW
4-tieropmgw|2933|udp|4-TIER OPM GW
4-tieropmcli|2934|tcp|4-TIER OPM CLI
4-tieropmcli|2934|udp|4-TIER OPM CLI
qtp|2935|tcp|QTP
qtp|2935|udp|QTP
otpatch|2936|tcp|OTPatch
otpatch|2936|udp|OTPatch
pnaconsult-lm|2937|tcp|PNACONSULT-LM
pnaconsult-lm|2937|udp|PNACONSULT-LM
sm-pas-1|2938|tcp|SM-PAS-1
sm-pas-1|2938|udp|SM-PAS-1
sm-pas-2|2939|tcp|SM-PAS-2
sm-pas-2|2939|udp|SM-PAS-2
sm-pas-3|2940|tcp|SM-PAS-3
sm-pas-3|2940|udp|SM-PAS-3
sm-pas-4|2941|tcp|SM-PAS-4
sm-pas-4|2941|udp|SM-PAS-4
sm-pas-5|2942|tcp|SM-PAS-5
sm-pas-5|2942|udp|SM-PAS-5
ttnrepository|2943|tcp|TTNRepository
ttnrepository|2943|udp|TTNRepository
megaco-h248|2944|tcp|Megaco H-248
megaco-h248|2944|udp|Megaco H-248
h248-binary|2945|tcp|H248 Binary
h248-binary|2945|udp|H248 Binary
fjsvmpor|2946|tcp|FJSVmpor
fjsvmpor|2946|udp|FJSVmpor
gpsd|2947|tcp|GPSD
gpsd|2947|udp|GPSD
wap-push|2948|tcp|WAP PUSH
wap-push|2948|udp|WAP PUSH
wap-pushsecure|2949|tcp|WAP PUSH SECURE
wap-pushsecure|2949|udp|WAP PUSH SECURE
esip|2950|tcp|ESIP
esip|2950|udp|ESIP
ottp|2951|tcp|OTTP
ottp|2951|udp|OTTP
mpfwsas|2952|tcp|MPFWSAS
mpfwsas|2952|udp|MPFWSAS
ovalarmsrv|2953|tcp|OVALARMSRV
ovalarmsrv|2953|udp|OVALARMSRV
ovalarmsrv-cmd|2954|tcp|OVALARMSRV-CMD
ovalarmsrv-cmd|2954|udp|OVALARMSRV-CMD
csnotify|2955|tcp|CSNOTIFY
csnotify|2955|udp|CSNOTIFY
ovrimosdbman|2956|tcp|OVRIMOSDBMAN
ovrimosdbman|2956|udp|OVRIMOSDBMAN
jmact5|2957|tcp|JAMCT5
jmact5|2957|udp|JAMCT5
jmact6|2958|tcp|JAMCT6
jmact6|2958|udp|JAMCT6
rmopagt|2959|tcp|RMOPAGT
rmopagt|2959|udp|RMOPAGT
dfoxserver|2960|tcp|DFOXSERVER
dfoxserver|2960|udp|DFOXSERVER
boldsoft-lm|2961|tcp|BOLDSOFT-LM
boldsoft-lm|2961|udp|BOLDSOFT-LM
iph-policy-cli|2962|tcp|IPH-POLICY-CLI
iph-policy-cli|2962|udp|IPH-POLICY-CLI
iph-policy-adm|2963|tcp|IPH-POLICY-ADM
iph-policy-adm|2963|udp|IPH-POLICY-ADM
bullant-srap|2964|tcp|BULLANT SRAP
bullant-srap|2964|udp|BULLANT SRAP
bullant-rap|2965|tcp|BULLANT RAP
bullant-rap|2965|udp|BULLANT RAP
idp-infotrieve|2966|tcp|IDP-INFOTRIEVE
idp-infotrieve|2966|udp|IDP-INFOTRIEVE
ssc-agent|2967|tcp|SSC-AGENT
ssc-agent|2967|udp|SSC-AGENT
enpp|2968|tcp|ENPP
enpp|2968|udp|ENPP
essp|2969|tcp|ESSP
essp|2969|udp|ESSP
index-net|2970|tcp|INDEX-NET
index-net|2970|udp|INDEX-NET
netclip|2971|tcp|NetClip clipboard daemon
netclip|2971|udp|NetClip clipboard daemon
pmsm-webrctl|2972|tcp|PMSM Webrctl
pmsm-webrctl|2972|udp|PMSM Webrctl
svnetworks|2973|tcp|SV Networks
svnetworks|2973|udp|SV Networks
signal|2974|tcp|Signal
signal|2974|udp|Signal
fjmpcm|2975|tcp|Fujitsu Configuration Management Service
fjmpcm|2975|udp|Fujitsu Configuration Management Service
cns-srv-port|2976|tcp|CNS Server Port
cns-srv-port|2976|udp|CNS Server Port
ttc-etap-ns|2977|tcp|TTCs Enterprise Test Access Protocol - NS
ttc-etap-ns|2977|udp|TTCs Enterprise Test Access Protocol - NS
ttc-etap-ds|2978|tcp|TTCs Enterprise Test Access Protocol - DS
ttc-etap-ds|2978|udp|TTCs Enterprise Test Access Protocol - DS
h263-video|2979|tcp|H.263 Video Streaming
h263-video|2979|udp|H.263 Video Streaming
wimd|2980|tcp|Instant Messaging Service
wimd|2980|udp|Instant Messaging Service
mylxamport|2981|tcp|MYLXAMPORT
mylxamport|2981|udp|MYLXAMPORT
iwb-whiteboard|2982|tcp|IWB-WHITEBOARD
iwb-whiteboard|2982|udp|IWB-WHITEBOARD
netplan|2983|tcp|NETPLAN
netplan|2983|udp|NETPLAN
hpidsadmin|2984|tcp|HPIDSADMIN
hpidsadmin|2984|udp|HPIDSADMIN
hpidsagent|2985|tcp|HPIDSAGENT
hpidsagent|2985|udp|HPIDSAGENT
stonefalls|2986|tcp|STONEFALLS
stonefalls|2986|udp|STONEFALLS
identify|2987|tcp|identify
identify|2987|udp|identify
hippad|2988|tcp|HIPPA Reporting Protocol
hippad|2988|udp|HIPPA Reporting Protocol
zarkov|2989|tcp|ZARKOV Intelligent Agent Communication
zarkov|2989|udp|ZARKOV Intelligent Agent Communication
boscap|2990|tcp|BOSCAP
boscap|2990|udp|BOSCAP
wkstn-mon|2991|tcp|WKSTN-MON
wkstn-mon|2991|udp|WKSTN-MON
itb301|2992|tcp|ITB301
itb301|2992|udp|ITB301
veritas-vis1|2993|tcp|VERITAS VIS1
veritas-vis1|2993|udp|VERITAS VIS1
veritas-vis2|2994|tcp|VERITAS VIS2
veritas-vis2|2994|udp|VERITAS VIS2
idrs|2995|tcp|IDRS
idrs|2995|udp|IDRS
vsixml|2996|tcp|vsixml
vsixml|2996|udp|vsixml
rebol|2997|tcp|REBOL
rebol|2997|udp|REBOL
realsecure|2998|tcp|Real Secure
realsecure|2998|udp|Real Secure
remoteware-un|2999|tcp|RemoteWare Unassigned
remoteware-un|2999|udp|RemoteWare Unassigned
hbci|3000|tcp|HBCI
hbci|3000|udp|HBCI
remoteware-cl|3000|tcp|RemoteWare Client
remoteware-cl|3000|udp|RemoteWare Client
redwood-broker|3001|tcp|Redwood Broker
redwood-broker|3001|udp|Redwood Broker
exlm-agent|3002|tcp|EXLM Agent
exlm-agent|3002|udp|EXLM Agent
remoteware-srv|3002|tcp|RemoteWare Server
remoteware-srv|3002|udp|RemoteWare Server
cgms|3003|tcp|CGMS
cgms|3003|udp|CGMS
csoftragent|3004|tcp|Csoft Agent
csoftragent|3004|udp|Csoft Agent
geniuslm|3005|tcp|Genius License Manager
geniuslm|3005|udp|Genius License Manager
ii-admin|3006|tcp|Instant Internet Admin
ii-admin|3006|udp|Instant Internet Admin
lotusmtap|3007|tcp|Lotus Mail Tracking Agent Protocol
lotusmtap|3007|udp|Lotus Mail Tracking Agent Protocol
midnight-tech|3008|tcp|Midnight Technologies
midnight-tech|3008|udp|Midnight Technologies
pxc-ntfy|3009|tcp|PXC-NTFY
pxc-ntfy|3009|udp|PXC-NTFY
gw|3010|tcp|Telerate Workstation
ping-pong|3010|udp|Telerate Workstation
trusted-web|3011|tcp|Trusted Web
trusted-web|3011|udp|Trusted Web
twsdss|3012|tcp|Trusted Web Client
twsdss|3012|udp|Trusted Web Client
gilatskysurfer|3013|tcp|Gilat Sky Surfer
gilatskysurfer|3013|udp|Gilat Sky Surfer
broker_service|3014|tcp|Broker Service
broker_service|3014|udp|Broker Service
nati-dstp|3015|tcp|NATI DSTP
nati-dstp|3015|udp|NATI DSTP
notify_srvr|3016|tcp|Notify Server
notify_srvr|3016|udp|Notify Server
event_listener|3017|tcp|Event Listener
event_listener|3017|udp|Event Listener
srvc_registry|3018|tcp|Service Registry
srvc_registry|3018|udp|Service Registry
resource_mgr|3019|tcp|Resource Manager
resource_mgr|3019|udp|Resource Manager
cifs|3020|tcp|CIFS
cifs|3020|udp|CIFS
agriserver|3021|tcp|AGRI Server
agriserver|3021|udp|AGRI Server
csregagent|3022|tcp|CSREGAGENT
csregagent|3022|udp|CSREGAGENT
magicnotes|3023|tcp|magicnotes
magicnotes|3023|udp|magicnotes
nds_sso|3024|tcp|NDS_SSO
nds_sso|3024|udp|NDS_SSO
arepa-raft|3025|tcp|Arepa Raft
arepa-raft|3025|udp|Arepa Raft
agri-gateway|3026|tcp|AGRI Gateway
agri-gateway|3026|udp|AGRI Gateway
LiebDevMgmt_C|3027|tcp|LiebDevMgmt_C
LiebDevMgmt_C|3027|udp|LiebDevMgmt_C
LiebDevMgmt_DM|3028|tcp|LiebDevMgmt_DM
LiebDevMgmt_DM|3028|udp|LiebDevMgmt_DM
LiebDevMgmt_A|3029|tcp|LiebDevMgmt_A
LiebDevMgmt_A|3029|udp|LiebDevMgmt_A
arepa-cas|3030|tcp|Arepa Cas
arepa-cas|3030|udp|Arepa Cas
eppc|3031|tcp|Remote AppleEvents/PPC Toolbox
eppc|3031|udp|Remote AppleEvents/PPC Toolbox
redwood-chat|3032|tcp|Redwood Chat
redwood-chat|3032|udp|Redwood Chat
pdb|3033|tcp|PDB
pdb|3033|udp|PDB
osmosis-aeea|3034|tcp|Osmosis / Helix (R) AEEA Port
osmosis-aeea|3034|udp|Osmosis / Helix (R) AEEA Port
fjsv-gssagt|3035|tcp|FJSV gssagt
fjsv-gssagt|3035|udp|FJSV gssagt
hagel-dump|3036|tcp|Hagel DUMP
hagel-dump|3036|udp|Hagel DUMP
hp-san-mgmt|3037|tcp|HP SAN Mgmt
hp-san-mgmt|3037|udp|HP SAN Mgmt
santak-ups|3038|tcp|Santak UPS
santak-ups|3038|udp|Santak UPS
cogitate|3039|tcp|Cogitate, Inc.
cogitate|3039|udp|Cogitate, Inc.
tomato-springs|3040|tcp|Tomato Springs
tomato-springs|3040|udp|Tomato Springs
di-traceware|3041|tcp|di-traceware
di-traceware|3041|udp|di-traceware
journee|3042|tcp|journee
journee|3042|udp|journee
brp|3043|tcp|BRP
brp|3043|udp|BRP
epp|3044|tcp|EndPoint Protocol
epp|3044|udp|EndPoint Protocol
responsenet|3045|tcp|ResponseNet
responsenet|3045|udp|ResponseNet
di-ase|3046|tcp|di-ase
di-ase|3046|udp|di-ase
hlserver|3047|tcp|Fast Security HL Server
hlserver|3047|udp|Fast Security HL Server
pctrader|3048|tcp|Sierra Net PC Trader
pctrader|3048|udp|Sierra Net PC Trader
nsws|3049|tcp|NSWS
nsws|3049|udp|NSWS
gds_db|3050|tcp|gds_db
gds_db|3050|udp|gds_db
galaxy-server|3051|tcp|Galaxy Server
galaxy-server|3051|udp|Galaxy Server
apc-3052|3052|tcp|APC 3052
apc-3052|3052|udp|APC 3052
dsom-server|3053|tcp|dsom-server
dsom-server|3053|udp|dsom-server
amt-cnf-prot|3054|tcp|AMT CNF PROT
amt-cnf-prot|3054|udp|AMT CNF PROT
policyserver|3055|tcp|Policy Server
policyserver|3055|udp|Policy Server
cdl-server|3056|tcp|CDL Server
cdl-server|3056|udp|CDL Server
goahead-fldup|3057|tcp|GoAhead FldUp
goahead-fldup|3057|udp|GoAhead FldUp
videobeans|3058|tcp|videobeans
videobeans|3058|udp|videobeans
qsoft|3059|tcp|qsoft
qsoft|3059|udp|qsoft
interserver|3060|tcp|interserver
interserver|3060|udp|interserver
cautcpd|3061|tcp|cautcpd
cautcpd|3061|udp|cautcpd
ncacn-ip-tcp|3062|tcp|ncacn-ip-tcp
ncacn-ip-tcp|3062|udp|ncacn-ip-tcp
ncadg-ip-udp|3063|tcp|ncadg-ip-udp
ncadg-ip-udp|3063|udp|ncadg-ip-udp
rprt|3064|tcp|Remote Port Redirector
rprt|3064|udp|Remote Port Redirector
slinterbase|3065|tcp|slinterbase
slinterbase|3065|udp|slinterbase
netattachsdmp|3066|tcp|NETATTACHSDMP
netattachsdmp|3066|udp|NETATTACHSDMP
fjhpjp|3067|tcp|FJHPJP
fjhpjp|3067|udp|FJHPJP
ls3bcast|3068|tcp|ls3 Broadcast
ls3bcast|3068|udp|ls3 Broadcast
ls3|3069|tcp|ls3
ls3|3069|udp|ls3
mgxswitch|3070|tcp|MGXSWITCH
mgxswitch|3070|udp|MGXSWITCH
csd-mgmt-port|3071|tcp|ContinuStor Manager Port
csd-mgmt-port|3071|udp|ContinuStor Manager Port
csd-monitor|3072|tcp|ContinuStor Monitor Port
csd-monitor|3072|udp|ContinuStor Monitor Port
vcrp|3073|tcp|Very simple chatroom prot
vcrp|3073|udp|Very simple chatroom prot
xbox|3074|tcp|Xbox game port
xbox|3074|udp|Xbox game port
orbix-locator|3075|tcp|Orbix 2000 Locator
orbix-locator|3075|udp|Orbix 2000 Locator
orbix-config|3076|tcp|Orbix 2000 Config
orbix-config|3076|udp|Orbix 2000 Config
orbix-loc-ssl|3077|tcp|Orbix 2000 Locator SSL
orbix-loc-ssl|3077|udp|Orbix 2000 Locator SSL
orbix-cfg-ssl|3078|tcp|Orbix 2000 Locator SSL
orbix-cfg-ssl|3078|udp|Orbix 2000 Locator SSL
lv-frontpanel|3079|tcp|LV Front Panel
lv-frontpanel|3079|udp|LV Front Panel
stm_pproc|3080|tcp|stm_pproc
stm_pproc|3080|udp|stm_pproc
tl1-lv|3081|tcp|TL1-LV
tl1-lv|3081|udp|TL1-LV
tl1-raw|3082|tcp|TL1-RAW
tl1-raw|3082|udp|TL1-RAW
tl1-telnet|3083|tcp|TL1-TELNET
tl1-telnet|3083|udp|TL1-TELNET
itm-mccs|3084|tcp|ITM-MCCS
itm-mccs|3084|udp|ITM-MCCS
pcihreq|3085|tcp|PCIHReq
pcihreq|3085|udp|PCIHReq
jdl-dbkitchen|3086|tcp|JDL-DBKitchen
jdl-dbkitchen|3086|udp|JDL-DBKitchen
asoki-sma|3087|tcp|Asoki SMA
asoki-sma|3087|udp|Asoki SMA
xdtp|3088|tcp|eXtensible Data Transfer Protocol
xdtp|3088|udp|eXtensible Data Transfer Protocol
ptk-alink|3089|tcp|ParaTek Agent Linking
ptk-alink|3089|udp|ParaTek Agent Linking
rtss|3090|tcp|Rappore Session Services
rtss|3090|udp|Rappore Session Services
1ci-smcs|3091|tcp|1Ci Server Management
1ci-smcs|3091|udp|1Ci Server Management
njfss|3092|tcp|Netware sync services
njfss|3092|udp|Netware sync services
rapidmq-center|3093|tcp|Jiiva RapidMQ Center
rapidmq-center|3093|udp|Jiiva RapidMQ Center
rapidmq-reg|3094|tcp|Jiiva RapidMQ Registry
rapidmq-reg|3094|udp|Jiiva RapidMQ Registry
panasas|3095|tcp|Panasas rendevous port
panasas|3095|udp|Panasas rendevous port
ndl-aps|3096|tcp|Active Print Server Port
ndl-aps|3096|udp|Active Print Server Port
itu-bicc-stc|3097|sctp|ITU-T Q.1902.1/Q.2150.3
umm-port|3098|tcp|Universal Message Manager
umm-port|3098|udp|Universal Message Manager
chmd|3099|tcp|CHIPSY Machine Daemon
chmd|3099|udp|CHIPSY Machine Daemon
opcon-xps|3100|tcp|OpCon/xps
opcon-xps|3100|udp|OpCon/xps
hp-pxpib|3101|tcp|HP PolicyXpert PIB Server
hp-pxpib|3101|udp|HP PolicyXpert PIB Server
slslavemon|3102|tcp|SoftlinK Slave Mon Port
slslavemon|3102|udp|SoftlinK Slave Mon Port
autocuesmi|3103|tcp|Autocue SMI Protocol
autocuesmi|3103|udp|Autocue SMI Protocol
autocuelog|3104|tcp|Autocue Logger Protocol
autocuetime|3104|udp|Autocue Time Service
cardbox|3105|tcp|Cardbox
cardbox|3105|udp|Cardbox
cardbox-http|3106|tcp|Cardbox HTTP
cardbox-http|3106|udp|Cardbox HTTP
business|3107|tcp|Business protocol
business|3107|udp|Business protocol
geolocate|3108|tcp|Geolocate protocol
geolocate|3108|udp|Geolocate protocol
personnel|3109|tcp|Personnel protocol
personnel|3109|udp|Personnel protocol
sim-control|3110|tcp|simulator control port
sim-control|3110|udp|simulator control port
wsynch|3111|tcp|Web Synchronous Services
wsynch|3111|udp|Web Synchronous Services
ksysguard|3112|tcp|KDE System Guard
ksysguard|3112|udp|KDE System Guard
cs-auth-svr|3113|tcp|CS-Authenticate Svr Port
cs-auth-svr|3113|udp|CS-Authenticate Svr Port
ccmad|3114|tcp|CCM AutoDiscover
ccmad|3114|udp|CCM AutoDiscover
mctet-master|3115|tcp|MCTET Master
mctet-master|3115|udp|MCTET Master
mctet-gateway|3116|tcp|MCTET Gateway
mctet-gateway|3116|udp|MCTET Gateway
mctet-jserv|3117|tcp|MCTET Jserv
mctet-jserv|3117|udp|MCTET Jserv
pkagent|3118|tcp|PKAgent
pkagent|3118|udp|PKAgent
d2000kernel|3119|tcp|D2000 Kernel Port
d2000kernel|3119|udp|D2000 Kernel Port
d2000webserver|3120|tcp|D2000 Webserver Port
d2000webserver|3120|udp|D2000 Webserver Port
epp-temp|3121|tcp|Extensible Provisioning Protocol
epp-temp|3121|udp|Extensible Provisioning Protocol
vtr-emulator|3122|tcp|MTI VTR Emulator port
vtr-emulator|3122|udp|MTI VTR Emulator port
edix|3123|tcp|EDI Translation Protocol
edix|3123|udp|EDI Translation Protocol
beacon-port|3124|tcp|Beacon Port
beacon-port|3124|udp|Beacon Port
a13-an|3125|tcp|A13-AN Interface
a13-an|3125|udp|A13-AN Interface
ms-dotnetster|3126|tcp|Microsoft .NETster Port
ms-dotnetster|3126|udp|Microsoft .NETster Port
ctx-bridge|3127|tcp|CTX Bridge Port
ctx-bridge|3127|udp|CTX Bridge Port
ndl-aas|3128|tcp|Active API Server Port
ndl-aas|3128|udp|Active API Server Port
netport-id|3129|tcp|NetPort Discovery Port
netport-id|3129|udp|NetPort Discovery Port
icpv2|3130|tcp|ICPv2
icpv2|3130|udp|ICPv2
netbookmark|3131|tcp|Net Book Mark
netbookmark|3131|udp|Net Book Mark
ms-rule-engine|3132|tcp|Microsoft Business Rule Engine Update Service
ms-rule-engine|3132|udp|Microsoft Business Rule Engine Update Service
prism-deploy|3133|tcp|Prism Deploy User Port
prism-deploy|3133|udp|Prism Deploy User Port
ecp|3134|tcp|Extensible Code Protocol
ecp|3134|udp|Extensible Code Protocol
peerbook-port|3135|tcp|PeerBook Port
peerbook-port|3135|udp|PeerBook Port
grubd|3136|tcp|Grub Server Port
grubd|3136|udp|Grub Server Port
rtnt-1|3137|tcp|rtnt-1 data packets
rtnt-1|3137|udp|rtnt-1 data packets
rtnt-2|3138|tcp|rtnt-2 data packets
rtnt-2|3138|udp|rtnt-2 data packets
incognitorv|3139|tcp|Incognito Rendez-Vous
incognitorv|3139|udp|Incognito Rendez-Vous
ariliamulti|3140|tcp|Arilia Multiplexor
ariliamulti|3140|udp|Arilia Multiplexor
vmodem|3141|tcp|VMODEM
vmodem|3141|udp|VMODEM
rdc-wh-eos|3142|tcp|RDC WH EOS
rdc-wh-eos|3142|udp|RDC WH EOS
seaview|3143|tcp|Sea View
seaview|3143|udp|Sea View
tarantella|3144|tcp|Tarantella
tarantella|3144|udp|Tarantella
csi-lfap|3145|tcp|CSI-LFAP
csi-lfap|3145|udp|CSI-LFAP
bears-02|3146|tcp|bears-02
bears-02|3146|udp|bears-02
rfio|3147|tcp|RFIO
rfio|3147|udp|RFIO
nm-game-admin|3148|tcp|NetMike Game Administrator
nm-game-admin|3148|udp|NetMike Game Administrator
nm-game-server|3149|tcp|NetMike Game Server
nm-game-server|3149|udp|NetMike Game Server
nm-asses-admin|3150|tcp|NetMike Assessor Administrator
nm-asses-admin|3150|udp|NetMike Assessor Administrator
nm-assessor|3151|tcp|NetMike Assessor
nm-assessor|3151|udp|NetMike Assessor
feitianrockey|3152|tcp|FeiTian Port
feitianrockey|3152|udp|FeiTian Port
s8-client-port|3153|tcp|S8Cargo Client Port
s8-client-port|3153|udp|S8Cargo Client Port
ccmrmi|3154|tcp|ON RMI Registry
ccmrmi|3154|udp|ON RMI Registry
jpegmpeg|3155|tcp|JpegMpeg Port
jpegmpeg|3155|udp|JpegMpeg Port
indura|3156|tcp|Indura Collector
indura|3156|udp|Indura Collector
e3consultants|3157|tcp|CCC Listener Port
e3consultants|3157|udp|CCC Listener Port
stvp|3158|tcp|SmashTV Protocol
stvp|3158|udp|SmashTV Protocol
navegaweb-port|3159|tcp|NavegaWeb Tarification
navegaweb-port|3159|udp|NavegaWeb Tarification
tip-app-server|3160|tcp|TIP Application Server
tip-app-server|3160|udp|TIP Application Server
doc1lm|3161|tcp|DOC1 License Manager
doc1lm|3161|udp|DOC1 License Manager
sflm|3162|tcp|SFLM
sflm|3162|udp|SFLM
res-sap|3163|tcp|RES-SAP
res-sap|3163|udp|RES-SAP
imprs|3164|tcp|IMPRS
imprs|3164|udp|IMPRS
newgenpay|3165|tcp|Newgenpay Engine Service
newgenpay|3165|udp|Newgenpay Engine Service
qrepos|3166|tcp|Quest Repository
qrepos|3166|udp|Quest Repository
poweroncontact|3167|tcp|poweroncontact
poweroncontact|3167|udp|poweroncontact
poweronnud|3168|tcp|poweronnud
poweronnud|3168|udp|poweronnud
serverview-as|3169|tcp|SERVERVIEW-AS
serverview-as|3169|udp|SERVERVIEW-AS
serverview-asn|3170|tcp|SERVERVIEW-ASN
serverview-asn|3170|udp|SERVERVIEW-ASN
serverview-gf|3171|tcp|SERVERVIEW-GF
serverview-gf|3171|udp|SERVERVIEW-GF
serverview-rm|3172|tcp|SERVERVIEW-RM
serverview-rm|3172|udp|SERVERVIEW-RM
serverview-icc|3173|tcp|SERVERVIEW-ICC
serverview-icc|3173|udp|SERVERVIEW-ICC
armi-server|3174|tcp|ARMI Server
armi-server|3174|udp|ARMI Server
t1-e1-over-ip|3175|tcp|T1_E1_Over_IP
t1-e1-over-ip|3175|udp|T1_E1_Over_IP
ars-master|3176|tcp|ARS Master
ars-master|3176|udp|ARS Master
phonex-port|3177|tcp|Phonex Protocol
phonex-port|3177|udp|Phonex Protocol
radclientport|3178|tcp|Radiance UltraEdge Port
radclientport|3178|udp|Radiance UltraEdge Port
h2gf-w-2m|3179|tcp|H2GF W.2m Handover prot.
h2gf-w-2m|3179|udp|H2GF W.2m Handover prot.
mc-brk-srv|3180|tcp|Millicent Broker Server
mc-brk-srv|3180|udp|Millicent Broker Server
bmcpatrolagent|3181|tcp|BMC Patrol Agent
bmcpatrolagent|3181|udp|BMC Patrol Agent
bmcpatrolrnvu|3182|tcp|BMC Patrol Rendezvous
bmcpatrolrnvu|3182|udp|BMC Patrol Rendezvous
cops-tls|3183|tcp|COPS/TLS
cops-tls|3183|udp|COPS/TLS
apogeex-port|3184|tcp|ApogeeX Port
apogeex-port|3184|udp|ApogeeX Port
smpppd|3185|tcp|SuSE Meta PPPD
smpppd|3185|udp|SuSE Meta PPPD
iiw-port|3186|tcp|IIW Monitor User Port
iiw-port|3186|udp|IIW Monitor User Port
odi-port|3187|tcp|Open Design Listen Port
odi-port|3187|udp|Open Design Listen Port
brcm-comm-port|3188|tcp|Broadcom Port
brcm-comm-port|3188|udp|Broadcom Port
pcle-infex|3189|tcp|Pinnacle Sys InfEx Port
pcle-infex|3189|udp|Pinnacle Sys InfEx Port
csvr-proxy|3190|tcp|ConServR Proxy
csvr-proxy|3190|udp|ConServR Proxy
csvr-sslproxy|3191|tcp|ConServR SSL Proxy
csvr-sslproxy|3191|udp|ConServR SSL Proxy
firemonrcc|3192|tcp|FireMon Revision Control
firemonrcc|3192|udp|FireMon Revision Control
cordataport|3193|tcp|Cordaxis Data Port
cordataport|3193|udp|Cordaxis Data Port
magbind|3194|tcp|Rockstorm MAG protocol
magbind|3194|udp|Rockstorm MAG protocol
ncu-1|3195|tcp|Network Control Unit
ncu-1|3195|udp|Network Control Unit
ncu-2|3196|tcp|Network Control Unit
ncu-2|3196|udp|Network Control Unit
embrace-dp-s|3197|tcp|Embrace Device Protocol Server
embrace-dp-s|3197|udp|Embrace Device Protocol Server
embrace-dp-c|3198|tcp|Embrace Device Protocol Client
embrace-dp-c|3198|udp|Embrace Device Protocol Client
dmod-workspace|3199|tcp|DMOD WorkSpace
dmod-workspace|3199|udp|DMOD WorkSpace
tick-port|3200|tcp|Press-sense Tick Port
tick-port|3200|udp|Press-sense Tick Port
cpq-tasksmart|3201|tcp|CPQ-TaskSmart
cpq-tasksmart|3201|udp|CPQ-TaskSmart
intraintra|3202|tcp|IntraIntra
intraintra|3202|udp|IntraIntra
netwatcher-mon|3203|tcp|Network Watcher Monitor
netwatcher-mon|3203|udp|Network Watcher Monitor
netwatcher-db|3204|tcp|Network Watcher DB Access
netwatcher-db|3204|udp|Network Watcher DB Access
isns|3205|tcp|iSNS Server Port
isns|3205|udp|iSNS Server Port
ironmail|3206|tcp|IronMail POP Proxy
ironmail|3206|udp|IronMail POP Proxy
vx-auth-port|3207|tcp|Veritas Authentication Port
vx-auth-port|3207|udp|Veritas Authentication Port
pfu-prcallback|3208|tcp|PFU PR Callback
pfu-prcallback|3208|udp|PFU PR Callback
netwkpathengine|3209|tcp|HP OpenView Network Path Engine Server
netwkpathengine|3209|udp|HP OpenView Network Path Engine Server
flamenco-proxy|3210|tcp|Flamenco Networks Proxy
flamenco-proxy|3210|udp|Flamenco Networks Proxy
avsecuremgmt|3211|tcp|Avocent Secure Management
avsecuremgmt|3211|udp|Avocent Secure Management
surveyinst|3212|tcp|Survey Instrument
surveyinst|3212|udp|Survey Instrument
neon24x7|3213|tcp|NEON 24X7 Mission Control
neon24x7|3213|udp|NEON 24X7 Mission Control
jmq-daemon-1|3214|tcp|JMQ Daemon Port 1
jmq-daemon-1|3214|udp|JMQ Daemon Port 1
jmq-daemon-2|3215|tcp|JMQ Daemon Port 2
jmq-daemon-2|3215|udp|JMQ Daemon Port 2
ferrari-foam|3216|tcp|Ferrari electronic FOAM
ferrari-foam|3216|udp|Ferrari electronic FOAM
unite|3217|tcp|Unified IP & Telecomm Env
unite|3217|udp|Unified IP & Telecomm Env
smartpackets|3218|tcp|EMC SmartPackets
smartpackets|3218|udp|EMC SmartPackets
wms-messenger|3219|tcp|WMS Messenger
wms-messenger|3219|udp|WMS Messenger
xnm-ssl|3220|tcp|XML NM over SSL
xnm-ssl|3220|udp|XML NM over SSL
xnm-clear-text|3221|tcp|XML NM over TCP
xnm-clear-text|3221|udp|XML NM over TCP
glbp|3222|tcp|Gateway Load Balancing Pr
glbp|3222|udp|Gateway Load Balancing Pr
digivote|3223|tcp|DIGIVOTE (R) Vote-Server
digivote|3223|udp|DIGIVOTE (R) Vote-Server
aes-discovery|3224|tcp|AES Discovery Port
aes-discovery|3224|udp|AES Discovery Port
fcip-port|3225|tcp|FCIP
fcip-port|3225|udp|FCIP
isi-irp|3226|tcp|ISI Industry Software IRP
isi-irp|3226|udp|ISI Industry Software IRP
dwnmshttp|3227|tcp|DiamondWave NMS Server
dwnmshttp|3227|udp|DiamondWave NMS Server
dwmsgserver|3228|tcp|DiamondWave MSG Server
dwmsgserver|3228|udp|DiamondWave MSG Server
global-cd-port|3229|tcp|Global CD Port
global-cd-port|3229|udp|Global CD Port
sftdst-port|3230|tcp|Software Distributor Port
sftdst-port|3230|udp|Software Distributor Port
dsnl|3231|tcp|Delta Solutions Direct
dsnl|3231|udp|Delta Solutions Direct
mdtp|3232|tcp|MDT port
mdtp|3232|udp|MDT port
whisker|3233|tcp|WhiskerControl main port
whisker|3233|udp|WhiskerControl main port
alchemy|3234|tcp|Alchemy Server
alchemy|3234|udp|Alchemy Server
mdap-port|3235|tcp|MDAP port
mdap-port|3235|udp|MDAP Port
apparenet-ts|3236|tcp|appareNet Test Server
apparenet-ts|3236|udp|appareNet Test Server
apparenet-tps|3237|tcp|appareNet Test Packet Sequencer
apparenet-tps|3237|udp|appareNet Test Packet Sequencer
apparenet-as|3238|tcp|appareNet Analysis Server
apparenet-as|3238|udp|appareNet Analysis Server
apparenet-ui|3239|tcp|appareNet User Interface
apparenet-ui|3239|udp|appareNet User Interface
triomotion|3240|tcp|Trio Motion Control Port
triomotion|3240|udp|Trio Motion Control Port
sysorb|3241|tcp|SysOrb Monitoring Server
sysorb|3241|udp|SysOrb Monitoring Server
sdp-id-port|3242|tcp|Session Description ID
sdp-id-port|3242|udp|Session Description ID
timelot|3243|tcp|Timelot Port
timelot|3243|udp|Timelot Port
onesaf|3244|tcp|OneSAF
onesaf|3244|udp|OneSAF
vieo-fe|3245|tcp|VIEO Fabric Executive
vieo-fe|3245|udp|VIEO Fabric Executive
dvt-system|3246|tcp|DVT SYSTEM PORT
dvt-system|3246|udp|DVT SYSTEM PORT
dvt-data|3247|tcp|DVT DATA LINK
dvt-data|3247|udp|DVT DATA LINK
procos-lm|3248|tcp|PROCOS LM
procos-lm|3248|udp|PROCOS LM
ssp|3249|tcp|State Sync Protocol
ssp|3249|udp|State Sync Protocol
hicp|3250|tcp|HMS hicp port
hicp|3250|udp|HMS hicp port
sysscanner|3251|tcp|Sys Scanner
sysscanner|3251|udp|Sys Scanner
dhe|3252|tcp|DHE port
dhe|3252|udp|DHE port
pda-data|3253|tcp|PDA Data
pda-data|3253|udp|PDA Data
pda-sys|3254|tcp|PDA System
pda-sys|3254|udp|PDA System
semaphore|3255|tcp|Semaphore Connection Port
semaphore|3255|udp|Semaphore Connection Port
cpqrpm-agent|3256|tcp|Compaq RPM Agent Port
cpqrpm-agent|3256|udp|Compaq RPM Agent Port
cpqrpm-server|3257|tcp|Compaq RPM Server Port
cpqrpm-server|3257|udp|Compaq RPM Server Port
ivecon-port|3258|tcp|Ivecon Server Port
ivecon-port|3258|udp|Ivecon Server Port
epncdp2|3259|tcp|Epson Network Common Devi
epncdp2|3259|udp|Epson Network Common Devi
iscsi-target|3260|tcp|iSCSI port
iscsi-target|3260|udp|iSCSI port
winshadow|3261|tcp|winShadow
winshadow|3261|udp|winShadow
necp|3262|tcp|NECP
necp|3262|udp|NECP
ecolor-imager|3263|tcp|E-Color Enterprise Imager
ecolor-imager|3263|udp|E-Color Enterprise Imager
ccmail|3264|tcp|cc:mail/lotus
ccmail|3264|udp|cc:mail/lotus
altav-tunnel|3265|tcp|Altav Tunnel
altav-tunnel|3265|udp|Altav Tunnel
ns-cfg-server|3266|tcp|NS CFG Server
ns-cfg-server|3266|udp|NS CFG Server
ibm-dial-out|3267|tcp|IBM Dial Out
ibm-dial-out|3267|udp|IBM Dial Out
msft-gc|3268|tcp|Microsoft Global Catalog
msft-gc|3268|udp|Microsoft Global Catalog
msft-gc-ssl|3269|tcp|Microsoft Global Catalog with LDAP/SSL
msft-gc-ssl|3269|udp|Microsoft Global Catalog with LDAP/SSL
verismart|3270|tcp|Verismart
verismart|3270|udp|Verismart
csoft-prev|3271|tcp|CSoft Prev Port
csoft-prev|3271|udp|CSoft Prev Port
user-manager|3272|tcp|Fujitsu User Manager
user-manager|3272|udp|Fujitsu User Manager
sxmp|3273|tcp|Simple Extensible Multiplexed Protocol
sxmp|3273|udp|Simple Extensible Multiplexed Protocol
ordinox-server|3274|tcp|Ordinox Server
ordinox-server|3274|udp|Ordinox Server
samd|3275|tcp|SAMD
samd|3275|udp|SAMD
maxim-asics|3276|tcp|Maxim ASICs
maxim-asics|3276|udp|Maxim ASICs
awg-proxy|3277|tcp|AWG Proxy
awg-proxy|3277|udp|AWG Proxy
lkcmserver|3278|tcp|LKCM Server
lkcmserver|3278|udp|LKCM Server
admind|3279|tcp|admind
admind|3279|udp|admind
vs-server|3280|tcp|VS Server
vs-server|3280|udp|VS Server
sysopt|3281|tcp|SYSOPT
sysopt|3281|udp|SYSOPT
datusorb|3282|tcp|Datusorb
datusorb|3282|udp|Datusorb
net-assistant|3283|tcp|Net Assistant
net-assistant|3283|udp|Net Assistant
4talk|3284|tcp|4Talk
4talk|3284|udp|4Talk
plato|3285|tcp|Plato
plato|3285|udp|Plato
e-net|3286|tcp|E-Net
e-net|3286|udp|E-Net
directvdata|3287|tcp|DIRECTVDATA
directvdata|3287|udp|DIRECTVDATA
cops|3288|tcp|COPS
cops|3288|udp|COPS
enpc|3289|tcp|ENPC
enpc|3289|udp|ENPC
caps-lm|3290|tcp|CAPS LOGISTICS TOOLKIT - LM
caps-lm|3290|udp|CAPS LOGISTICS TOOLKIT - LM
sah-lm|3291|tcp|S A Holditch & Associates - LM
sah-lm|3291|udp|S A Holditch & Associates - LM
cart-o-rama|3292|tcp|Cart O Rama
cart-o-rama|3292|udp|Cart O Rama
fg-fps|3293|tcp|fg-fps
fg-fps|3293|udp|fg-fps
fg-gip|3294|tcp|fg-gip
fg-gip|3294|udp|fg-gip
dyniplookup|3295|tcp|Dynamic IP Lookup
dyniplookup|3295|udp|Dynamic IP Lookup
rib-slm|3296|tcp|Rib License Manager
rib-slm|3296|udp|Rib License Manager
cytel-lm|3297|tcp|Cytel License Manager
cytel-lm|3297|udp|Cytel License Manager
deskview|3298|tcp|DeskView
deskview|3298|udp|DeskView
pdrncs|3299|tcp|pdrncs
pdrncs|3299|udp|pdrncs
mcs-fastmail|3302|tcp|MCS Fastmail
mcs-fastmail|3302|udp|MCS Fastmail
opsession-clnt|3303|tcp|OP Session Client
opsession-clnt|3303|udp|OP Session Client
opsession-srvr|3304|tcp|OP Session Server
opsession-srvr|3304|udp|OP Session Server
odette-ftp|3305|tcp|ODETTE-FTP
odette-ftp|3305|udp|ODETTE-FTP
mysql|3306|tcp|MySQL
mysql|3306|udp|MySQL
opsession-prxy|3307|tcp|OP Session Proxy
opsession-prxy|3307|udp|OP Session Proxy
tns-server|3308|tcp|TNS Server
tns-server|3308|udp|TNS Server
tns-adv|3309|tcp|TNS ADV
tns-adv|3309|udp|TNS ADV
dyna-access|3310|tcp|Dyna Access
dyna-access|3310|udp|Dyna Access
mcns-tel-ret|3311|tcp|MCNS Tel Ret
mcns-tel-ret|3311|udp|MCNS Tel Ret
appman-server|3312|tcp|Application Management Server
appman-server|3312|udp|Application Management Server
uorb|3313|tcp|Unify Object Broker
uorb|3313|udp|Unify Object Broker
uohost|3314|tcp|Unify Object Host
uohost|3314|udp|Unify Object Host
cdid|3315|tcp|CDID
cdid|3315|udp|CDID
aicc-cmi|3316|tcp|AICC/CMI
aicc-cmi|3316|udp|AICC/CMI
vsaiport|3317|tcp|VSAI PORT
vsaiport|3317|udp|VSAI PORT
ssrip|3318|tcp|Swith to Swith Routing Information Protocol
ssrip|3318|udp|Swith to Swith Routing Information Protocol
sdt-lmd|3319|tcp|SDT License Manager
sdt-lmd|3319|udp|SDT License Manager
officelink2000|3320|tcp|Office Link 2000
officelink2000|3320|udp|Office Link 2000
vnsstr|3321|tcp|VNSSTR
vnsstr|3321|udp|VNSSTR
sftu|3326|tcp|SFTU
sftu|3326|udp|SFTU
bbars|3327|tcp|BBARS
bbars|3327|udp|BBARS
egptlm|3328|tcp|Eaglepoint License Manager
egptlm|3328|udp|Eaglepoint License Manager
hp-device-disc|3329|tcp|HP Device Disc
hp-device-disc|3329|udp|HP Device Disc
mcs-calypsoicf|3330|tcp|MCS Calypso ICF
mcs-calypsoicf|3330|udp|MCS Calypso ICF
mcs-messaging|3331|tcp|MCS Messaging
mcs-messaging|3331|udp|MCS Messaging
mcs-mailsvr|3332|tcp|MCS Mail Server
mcs-mailsvr|3332|udp|MCS Mail Server
dec-notes|3333|tcp|DEC Notes
dec-notes|3333|udp|DEC Notes
directv-web|3334|tcp|Direct TV Webcasting
directv-web|3334|udp|Direct TV Webcasting
directv-soft|3335|tcp|Direct TV Software Updates
directv-soft|3335|udp|Direct TV Software Updates
directv-tick|3336|tcp|Direct TV Tickers
directv-tick|3336|udp|Direct TV Tickers
directv-catlg|3337|tcp|Direct TV Data Catalog
directv-catlg|3337|udp|Direct TV Data Catalog
anet-b|3338|tcp|OMF data b
anet-b|3338|udp|OMF data b
anet-l|3339|tcp|OMF data l
anet-l|3339|udp|OMF data l
anet-m|3340|tcp|OMF data m
anet-m|3340|udp|OMF data m
anet-h|3341|tcp|OMF data h
anet-h|3341|udp|OMF data h
webtie|3342|tcp|WebTIE
webtie|3342|udp|WebTIE
ms-cluster-net|3343|tcp|MS Cluster Net
ms-cluster-net|3343|udp|MS Cluster Net
bnt-manager|3344|tcp|BNT Manager
bnt-manager|3344|udp|BNT Manager
influence|3345|tcp|Influence
influence|3345|udp|Influence
trnsprntproxy|3346|tcp|Trnsprnt Proxy
trnsprntproxy|3346|udp|Trnsprnt Proxy
phoenix-rpc|3347|tcp|Phoenix RPC
phoenix-rpc|3347|udp|Phoenix RPC
pangolin-laser|3348|tcp|Pangolin Laser
pangolin-laser|3348|udp|Pangolin Laser
chevinservices|3349|tcp|Chevin Services
chevinservices|3349|udp|Chevin Services
findviatv|3350|tcp|FINDVIATV
findviatv|3350|udp|FINDVIATV
btrieve|3351|tcp|Btrieve port
btrieve|3351|udp|Btrieve port
ssql|3352|tcp|Scalable SQL
ssql|3352|udp|Scalable SQL
fatpipe|3353|tcp|FATPIPE
fatpipe|3353|udp|FATPIPE
suitjd|3354|tcp|SUITJD
suitjd|3354|udp|SUITJD
ordinox-dbase|3355|tcp|Ordinox Dbase
ordinox-dbase|3355|udp|Ordinox Dbase
upnotifyps|3356|tcp|UPNOTIFYPS
upnotifyps|3356|udp|UPNOTIFYPS
adtech-test|3357|tcp|Adtech Test IP
adtech-test|3357|udp|Adtech Test IP
mpsysrmsvr|3358|tcp|Mp Sys Rmsvr
mpsysrmsvr|3358|udp|Mp Sys Rmsvr
wg-netforce|3359|tcp|WG NetForce
wg-netforce|3359|udp|WG NetForce
kv-server|3360|tcp|KV Server
kv-server|3360|udp|KV Server
kv-agent|3361|tcp|KV Agent
kv-agent|3361|udp|KV Agent
dj-ilm|3362|tcp|DJ ILM
dj-ilm|3362|udp|DJ ILM
nati-vi-server|3363|tcp|NATI Vi Server
nati-vi-server|3363|udp|NATI Vi Server
creativeserver|3364|tcp|Creative Server
creativeserver|3364|udp|Creative Server
contentserver|3365|tcp|Content Server
contentserver|3365|udp|Content Server
creativepartnr|3366|tcp|Creative Partner
creativepartnr|3366|udp|Creative Partner
tip2|3372|tcp|TIP 2
tip2|3372|udp|TIP 2
lavenir-lm|3373|tcp|Lavenir License Manager
lavenir-lm|3373|udp|Lavenir License Manager
cluster-disc|3374|tcp|Cluster Disc
cluster-disc|3374|udp|Cluster Disc
vsnm-agent|3375|tcp|VSNM Agent
vsnm-agent|3375|udp|VSNM Agent
cdbroker|3376|tcp|CD Broker
cdbroker|3376|udp|CD Broker
cogsys-lm|3377|tcp|Cogsys Network License Manager
cogsys-lm|3377|udp|Cogsys Network License Manager
wsicopy|3378|tcp|WSICOPY
wsicopy|3378|udp|WSICOPY
socorfs|3379|tcp|SOCORFS
socorfs|3379|udp|SOCORFS
sns-channels|3380|tcp|SNS Channels
sns-channels|3380|udp|SNS Channels
geneous|3381|tcp|Geneous
geneous|3381|udp|Geneous
fujitsu-neat|3382|tcp|Fujitsu Network Enhanced Antitheft function
fujitsu-neat|3382|udp|Fujitsu Network Enhanced Antitheft function
esp-lm|3383|tcp|Enterprise Software Products License Manager
esp-lm|3383|udp|Enterprise Software Products License Manager
hp-clic|3384|tcp|Cluster Management Services
hp-clic|3384|udp|Hardware Management
qnxnetman|3385|tcp|qnxnetman
qnxnetman|3385|udp|qnxnetman
gprs-data|3386|tcp|GPRS Data
gprs-sig|3386|udp|GPRS SIG
backroomnet|3387|tcp|Back Room Net
backroomnet|3387|udp|Back Room Net
cbserver|3388|tcp|CB Server
cbserver|3388|udp|CB Server
ms-wbt-server|3389|tcp|MS WBT Server
ms-wbt-server|3389|udp|MS WBT Server
dsc|3390|tcp|Distributed Service Coordinator
dsc|3390|udp|Distributed Service Coordinator
savant|3391|tcp|SAVANT
savant|3391|udp|SAVANT
efi-lm|3392|tcp|EFI License Management
efi-lm|3392|udp|EFI License Management
d2k-tapestry1|3393|tcp|D2K Tapestry Client to Server
d2k-tapestry1|3393|udp|D2K Tapestry Client to Server
d2k-tapestry2|3394|tcp|D2K Tapestry Server to Server
d2k-tapestry2|3394|udp|D2K Tapestry Server to Server
dyna-lm|3395|tcp|Dyna License Manager (Elam)
dyna-lm|3395|udp|Dyna License Manager (Elam)
printer_agent|3396|tcp|Printer Agent
printer_agent|3396|udp|Printer Agent
cloanto-lm|3397|tcp|Cloanto License Manager
cloanto-lm|3397|udp|Cloanto License Manager
mercantile|3398|tcp|Mercantile
mercantile|3398|udp|Mercantile
csms|3399|tcp|CSMS
csms|3399|udp|CSMS
csms2|3400|tcp|CSMS2
csms2|3400|udp|CSMS2
filecast|3401|tcp|filecast
filecast|3401|udp|filecast
fxaengine-net|3402|tcp|FXa Engine Network Port
fxaengine-net|3402|udp|FXa Engine Network Port
copysnap|3403|tcp|CopySnap Server Port
copysnap|3403|udp|CopySnap Server Port
nokia-ann-ch1|3405|tcp|Nokia Announcement ch 1
nokia-ann-ch1|3405|udp|Nokia Announcement ch 1
nokia-ann-ch2|3406|tcp|Nokia Announcement ch 2
nokia-ann-ch2|3406|udp|Nokia Announcement ch 2
ldap-admin|3407|tcp|LDAP admin server port
ldap-admin|3407|udp|LDAP admin server port
issapi|3408|tcp|POWERpack API Port
issapi|3408|udp|POWERpack API Port
networklens|3409|tcp|NetworkLens Event Port
networklens|3409|udp|NetworkLens Event Port
networklenss|3410|tcp|NetworkLens SSL Event
networklenss|3410|udp|NetworkLens SSL Event
biolink-auth|3411|tcp|BioLink Authenteon server
biolink-auth|3411|udp|BioLink Authenteon server
xmlblaster|3412|tcp|xmlBlaster
xmlblaster|3412|udp|xmlBlaster
svnet|3413|tcp|SpecView Networking
svnet|3413|udp|SpecView Networking
wip-port|3414|tcp|BroadCloud WIP Port
wip-port|3414|udp|BroadCloud WIP Port
bcinameservice|3415|tcp|BCI Name Service
bcinameservice|3415|udp|BCI Name Service
commandport|3416|tcp|AirMobile IS Command Port
commandport|3416|udp|AirMobile IS Command Port
csvr|3417|tcp|ConServR file translation
csvr|3417|udp|ConServR file translation
rnmap|3418|tcp|Remote nmap
rnmap|3418|udp|Remote nmap
softaudit|3419|tcp|Isogon SoftAudit
softaudit|3419|udp|ISogon SoftAudit
ifcp-port|3420|tcp|iFCP User Port
ifcp-port|3420|udp|iFCP User Port
bmap|3421|tcp|Bull Apprise portmapper
bmap|3421|udp|Bull Apprise portmapper
rusb-sys-port|3422|tcp|Remote USB System Port
rusb-sys-port|3422|udp|Remote USB System Port
xtrm|3423|tcp|xTrade Reliable Messaging
xtrm|3423|udp|xTrade Reliable Messaging
xtrms|3424|tcp|xTrade over TLS/SSL
xtrms|3424|udp|xTrade over TLS/SSL
agps-port|3425|tcp|AGPS Access Port
agps-port|3425|udp|AGPS Access Port
arkivio|3426|tcp|Arkivio Storage Protocol
arkivio|3426|udp|Arkivio Storage Protocol
websphere-snmp|3427|tcp|WebSphere SNMP
websphere-snmp|3427|udp|WebSphere SNMP
twcss|3428|tcp|2Wire CSS
twcss|3428|udp|2Wire CSS
gcsp|3429|tcp|GCSP user port
gcsp|3429|udp|GCSP user port
ssdispatch|3430|tcp|Scott Studios Dispatch
ssdispatch|3430|udp|Scott Studios Dispatch
ndl-als|3431|tcp|Active License Server Port
ndl-als|3431|udp|Active License Server Port
osdcp|3432|tcp|Secure Device Protocol
osdcp|3432|udp|Secure Device Protocol
alta-smp|3433|tcp|Altaworks Service Management Platform
alta-smp|3433|udp|Altaworks Service Management Platform
opencm|3434|tcp|OpenCM Server
opencm|3434|udp|OpenCM Server
pacom|3435|tcp|Pacom Security User Port
pacom|3435|udp|Pacom Security User Port
gc-config|3436|tcp|GuardControl Exchange Protocol
gc-config|3436|udp|GuardControl Exchange Protocol
autocueds|3437|tcp|Autocue Directory Service
autocueds|3437|udp|Autocue Directory Service
spiral-admin|3438|tcp|Spiralcraft Admin
spiral-admin|3438|udp|Spiralcraft Admin
hri-port|3439|tcp|HRI Interface Port
hri-port|3439|udp|HRI Interface Port
ans-console|3440|tcp|Net Steward Mgmt Console
ans-console|3440|udp|Net Steward Mgmt Console
connect-client|3441|tcp|OC Connect Client
connect-client|3441|udp|OC Connect Client
connect-server|3442|tcp|OC Connect Server
connect-server|3442|udp|OC Connect Server
ov-nnm-websrv|3443|tcp|OpenView Network Node Manager WEB Server
ov-nnm-websrv|3443|udp|OpenView Network Node Manager WEB Server
denali-server|3444|tcp|Denali Server
denali-server|3444|udp|Denali Server
monp|3445|tcp|Media Object Network
monp|3445|udp|Media Object Network
3comfaxrpc|3446|tcp|3Com FAX RPC port
3comfaxrpc|3446|udp|3Com FAX RPC port
cddn|3447|tcp|CompuDuo DirectNet
cddn|3447|udp|CompuDuo DirectNet
dnc-port|3448|tcp|Discovery and Net Config
dnc-port|3448|udp|Discovery and Net Config
hotu-chat|3449|tcp|HotU Chat
hotu-chat|3449|udp|HotU Chat
castorproxy|3450|tcp|CAStorProxy
castorproxy|3450|udp|CAStorProxy
asam|3451|tcp|ASAM Services
asam|3451|udp|ASAM Services
sabp-signal|3452|tcp|SABP-Signalling Protocol
sabp-signal|3452|udp|SABP-Signalling Protocol
pscupd|3453|tcp|PSC Update Port
pscupd|3453|udp|PSC Update Port
mira|3454|tcp|Apple Remote Access Protocol
prsvp|3455|tcp|RSVP Port
prsvp|3455|udp|RSVP Port
vat|3456|tcp|VAT default data
vat|3456|udp|VAT default data
vat-control|3457|tcp|VAT default control
vat-control|3457|udp|VAT default control
d3winosfi|3458|tcp|D3WinOSFI
d3winosfi|3458|udp|D3WinOSFI
integral|3459|tcp|TIP Integral
integral|3459|udp|TIP Integral
edm-manager|3460|tcp|EDM Manger
edm-manager|3460|udp|EDM Manger
edm-stager|3461|tcp|EDM Stager
edm-stager|3461|udp|EDM Stager
edm-std-notify|3462|tcp|EDM STD Notify
edm-std-notify|3462|udp|EDM STD Notify
edm-adm-notify|3463|tcp|EDM ADM Notify
edm-adm-notify|3463|udp|EDM ADM Notify
edm-mgr-sync|3464|tcp|EDM MGR Sync
edm-mgr-sync|3464|udp|EDM MGR Sync
edm-mgr-cntrl|3465|tcp|EDM MGR Cntrl
edm-mgr-cntrl|3465|udp|EDM MGR Cntrl
workflow|3466|tcp|WORKFLOW
workflow|3466|udp|WORKFLOW
rcst|3467|tcp|RCST
rcst|3467|udp|RCST
ttcmremotectrl|3468|tcp|TTCM Remote Controll
ttcmremotectrl|3468|udp|TTCM Remote Controll
pluribus|3469|tcp|Pluribus
pluribus|3469|udp|Pluribus
jt400|3470|tcp|jt400
jt400|3470|udp|jt400
jt400-ssl|3471|tcp|jt400-ssl
jt400-ssl|3471|udp|jt400-ssl
jaugsremotec-1|3472|tcp|JAUGS N-G Remotec 1
jaugsremotec-1|3472|udp|JAUGS N-G Remotec 1
jaugsremotec-2|3473|tcp|JAUGS N-G Remotec 2
jaugsremotec-2|3473|udp|JAUGS N-G Remotec 2
ttntspauto|3474|tcp|TSP Automation
ttntspauto|3474|udp|TSP Automation
genisar-port|3475|tcp|Genisar Comm Port
genisar-port|3475|udp|Genisar Comm Port
nppmp|3476|tcp|NVIDIA Mgmt Protocol
nppmp|3476|udp|NVIDIA Mgmt Protocol
ecomm|3477|tcp|eComm link port
ecomm|3477|udp|eComm link port
nat-stun-port|3478|tcp|Simple Traversal of UDP Through NAT (STUN) port
nat-stun-port|3478|udp|Simple Traversal of UDP Through NAT (STUN) port
twrpc|3479|tcp|2Wire RPC
twrpc|3479|udp|2Wire RPC
plethora|3480|tcp|Secure Virtual Workspace
plethora|3480|udp|Secure Virtual Workspace
cleanerliverc|3481|tcp|CleanerLive remote ctrl
cleanerliverc|3481|udp|CleanerLive remote ctrl
vulture|3482|tcp|Vulture Monitoring System
vulture|3482|udp|Vulture Monitoring System
slim-devices|3483|tcp|Slim Devices Protocol
slim-devices|3483|udp|Slim Devices Protocol
gbs-stp|3484|tcp|GBS SnapTalk Protocol
gbs-stp|3484|udp|GBS SnapTalk Protocol
celatalk|3485|tcp|CelaTalk
celatalk|3485|udp|CelaTalk
ifsf-hb-port|3486|tcp|IFSF Heartbeat Port
ifsf-hb-port|3486|udp|IFSF Heartbeat Port
ltctcp|3487|tcp|LISA TCP Transfer Channel
ltcudp|3487|udp|LISA UDP Transfer Channel
fs-rh-srv|3488|tcp|FS Remote Host Server
fs-rh-srv|3488|udp|FS Remote Host Server
dtp-dia|3489|tcp|DTP/DIA
dtp-dia|3489|udp|DTP/DIA
colubris|3490|tcp|Colubris Management Port
colubris|3490|udp|Colubris Management Port
swr-port|3491|tcp|SWR Port
swr-port|3491|udp|SWR Port
tvdumtray-port|3492|tcp|TVDUM Tray Port
tvdumtray-port|3492|udp|TVDUM Tray Port
nut|3493|tcp|Network UPS Tools
nut|3493|udp|Network UPS Tools
ibm3494|3494|tcp|IBM 3494
ibm3494|3494|udp|IBM 3494
seclayer-tcp|3495|tcp|securitylayer over tcp
seclayer-tcp|3495|udp|securitylayer over tcp
seclayer-tls|3496|tcp|securitylayer over tls
seclayer-tls|3496|udp|securitylayer over tls
ipether232port|3497|tcp|ipEther232Port
ipether232port|3497|udp|ipEther232Port
dashpas-port|3498|tcp|DASHPAS user port
dashpas-port|3498|udp|DASHPAS user port
sccip-media|3499|tcp|SccIP Media
sccip-media|3499|udp|SccIP Media
rtmp-port|3500|tcp|RTMP Port
rtmp-port|3500|udp|RTMP Port
isoft-p2p|3501|tcp|iSoft-P2P
isoft-p2p|3501|udp|iSoft-P2P
avinstalldisc|3502|tcp|Avocent Install Discovery
avinstalldisc|3502|udp|Avocent Install Discovery
lsp-ping|3503|tcp|MPLS LSP-echo Port
lsp-ping|3503|udp|MPLS LSP-echo Port
ironstorm|3504|tcp|IronStorm game server
ironstorm|3504|udp|IronStorm game server
ccmcomm|3505|tcp|CCM communications port
ccmcomm|3505|udp|CCM communications port
apc-3506|3506|tcp|APC 3506
apc-3506|3506|udp|APC 3506
nesh-broker|3507|tcp|Nesh Broker Port
nesh-broker|3507|udp|Nesh Broker Port
interactionweb|3508|tcp|Interaction Web
interactionweb|3508|udp|Interaction Web
vt-ssl|3509|tcp|Virtual Token SSL Port
vt-ssl|3509|udp|Virtual Token SSL Port
xss-port|3510|tcp|XSS Port
xss-port|3510|udp|XSS Port
webmail-2|3511|tcp|WebMail/2
webmail-2|3511|udp|WebMail/2
aztec|3512|tcp|Aztec Distribution Port
aztec|3512|udp|Aztec Distribution Port
arcpd|3513|tcp|Adaptec Remote Protocol
arcpd|3513|udp|Adaptec Remote Protocol
must-p2p|3514|tcp|MUST Peer to Peer
must-p2p|3514|udp|MUST Peer to Peer
must-backplane|3515|tcp|MUST Backplane
must-backplane|3515|udp|MUST Backplane
smartcard-port|3516|tcp|Smartcard Port
smartcard-port|3516|udp|Smartcard Port
802-11-iapp|3517|tcp|IEEE 802.11 WLANs WG IAPP
802-11-iapp|3517|udp|IEEE 802.11 WLANs WG IAPP
artifact-msg|3518|tcp|Artifact Message Server
artifact-msg|3518|udp|Artifact Message Server
nvmsgd|3519|tcp|Netvion Messenger Port
galileo|3519|udp|Netvion Galileo Port
galileolog|3520|tcp|Netvion Galileo Log Port
galileolog|3520|udp|Netvion Galileo Log Port
mc3ss|3521|tcp|Telequip Labs MC3SS
mc3ss|3521|udp|Telequip Labs MC3SS
nssocketport|3522|tcp|DO over NSSocketPort
nssocketport|3522|udp|DO over NSSocketPort
odeumservlink|3523|tcp|Odeum Serverlink
odeumservlink|3523|udp|Odeum Serverlink
ecmport|3524|tcp|ECM Server port
ecmport|3524|udp|ECM Server port
eisport|3525|tcp|EIS Server port
eisport|3525|udp|EIS Server port
starquiz-port|3526|tcp|starQuiz Port
starquiz-port|3526|udp|starQuiz Port
beserver-msg-q|3527|tcp|VERITAS Backup Exec Server
beserver-msg-q|3527|udp|VERITAS Backup Exec Server
jboss-iiop|3528|tcp|JBoss IIOP
jboss-iiop|3528|udp|JBoss IIOP
jboss-iiop-ssl|3529|tcp|JBoss IIOP/SSL
jboss-iiop-ssl|3529|udp|JBoss IIOP/SSL
gf|3530|tcp|Grid Friendly
gf|3530|udp|Grid Friendly
joltid|3531|tcp|Joltid
joltid|3531|udp|Joltid
raven-rmp|3532|tcp|Raven Remote Management Control
raven-rmp|3532|udp|Raven Remote Management Control
raven-rdp|3533|tcp|Raven Remote Management Data
raven-rdp|3533|udp|Raven Remote Management Data
urld-port|3534|tcp|URL Daemon Port
urld-port|3534|udp|URL Daemon Port
ms-la|3535|tcp|MS-LA
ms-la|3535|udp|MS-LA
snac|3536|tcp|SNAC
snac|3536|udp|SNAC
ni-visa-remote|3537|tcp|Remote NI-VISA port
ni-visa-remote|3537|udp|Remote NI-VISA port
ibm-diradm|3538|tcp|IBM Directory Server
ibm-diradm|3538|udp|IBM Directory Server
ibm-diradm-ssl|3539|tcp|IBM Directory Server SSL
ibm-diradm-ssl|3539|udp|IBM Directory Server SSL
pnrp-port|3540|tcp|PNRP User Port
pnrp-port|3540|udp|PNRP User Port
voispeed-port|3541|tcp|VoiSpeed Port
voispeed-port|3541|udp|VoiSpeed Port
hacl-monitor|3542|tcp|HA cluster monitor
hacl-monitor|3542|udp|HA cluster monitor
qftest-lookup|3543|tcp|qftest Lookup Port
qftest-lookup|3543|udp|qftest Lookup Port
teredo|3544|tcp|Teredo Port
teredo|3544|udp|Teredo Port
camac|3545|tcp|CAMAC equipment
camac|3545|udp|CAMAC equipment
symantec-sim|3547|tcp|Symantec SIM
symantec-sim|3547|udp|Symantec SIM
interworld|3548|tcp|Interworld
interworld|3548|udp|Interworld
tellumat-nms|3549|tcp|Tellumat MDR NMS
tellumat-nms|3549|udp|Tellumat MDR NMS
ssmpp|3550|tcp|Secure SMPP
ssmpp|3550|udp|Secure SMPP
apcupsd|3551|tcp|Apcupsd Information Port
apcupsd|3551|udp|Apcupsd Information Port
taserver|3552|tcp|TeamAgenda Server Port
taserver|3552|udp|TeamAgenda Server Port
rbr-discovery|3553|tcp|Red Box Recorder ADP
rbr-discovery|3553|udp|Red Box Recorder ADP
questnotify|3554|tcp|Quest Notification Server
questnotify|3554|udp|Quest Notification Server
razor|3555|tcp|Vipul's Razor
razor|3555|udp|Vipul's Razor
sky-transport|3556|tcp|Sky Transport Protocol
sky-transport|3556|udp|Sky Transport Protocol
personalos-001|3557|tcp|PersonalOS Comm Port
personalos-001|3557|udp|PersonalOS Comm Port
mcp-port|3558|tcp|MCP user port
mcp-port|3558|udp|MCP user port
cctv-port|3559|tcp|CCTV control port
cctv-port|3559|udp|CCTV control port
iniserve-port|3560|tcp|INIServe port
iniserve-port|3560|udp|INIServe port
bmc-onekey|3561|tcp|BMC-OneKey
bmc-onekey|3561|udp|BMC-OneKey
sdbproxy|3562|tcp|SDBProxy
sdbproxy|3562|udp|SDBProxy
watcomdebug|3563|tcp|Watcom Debug
watcomdebug|3563|udp|Watcom Debug
esimport|3564|tcp|Electromed SIM port
esimport|3564|udp|Electromed SIM port
m2pa|3565|tcp|M2PA
m2pa|3565|sctp|M2PA
quest-launcher|3566|tcp|Quest Agent Manager
quest-launcher|3566|udp|Quest Agent Manager
emware-oft|3567|tcp|emWare OFT Services
emware-oft|3567|udp|emWare OFT Services
emware-epss|3568|tcp|emWare EMIT/Secure
emware-epss|3568|udp|emWare EMIT/Secure
mbg-ctrl|3569|tcp|Meinberg Control Service
mbg-ctrl|3569|udp|Meinberg Control Service
mccwebsvr-port|3570|tcp|MCC Web Server Port
mccwebsvr-port|3570|udp|MCC Web Server Port
megardsvr-port|3571|tcp|MegaRAID Server Port
megardsvr-port|3571|udp|MegaRAID Server Port
megaregsvrport|3572|tcp|Registration Server Port
megaregsvrport|3572|udp|Registration Server Port
tag-ups-1|3573|tcp|Advantage Group UPS Suite
tag-ups-1|3573|udp|Advantage Group UPS Suite
dmaf-server|3574|tcp|DMAF Server
dmaf-caster|3574|udp|DMAF Caster
ccm-port|3575|tcp|Coalsere CCM Port
ccm-port|3575|udp|Coalsere CCM Port
cmc-port|3576|tcp|Coalsere CMC Port
cmc-port|3576|udp|Coalsere CMC Port
config-port|3577|tcp|Configuration Port
config-port|3577|udp|Configuration Port
data-port|3578|tcp|Data Port
data-port|3578|udp|Data Port
ttat3lb|3579|tcp|Tarantella Load Balancing
ttat3lb|3579|udp|Tarantella Load Balancing
nati-svrloc|3580|tcp|NATI-ServiceLocator
nati-svrloc|3580|udp|NATI-ServiceLocator
kfxaclicensing|3581|tcp|Ascent Capture Licensing
kfxaclicensing|3581|udp|Ascent Capture Licensing
press|3582|tcp|PEG PRESS Server
press|3582|udp|PEG PRESS Server
canex-watch|3583|tcp|CANEX Watch System
canex-watch|3583|udp|CANEX Watch System
u-dbap|3584|tcp|U-DBase Access Protocol
u-dbap|3584|udp|U-DBase Access Protocol
emprise-lls|3585|tcp|Emprise License Server
emprise-lls|3585|udp|Emprise License Server
emprise-lsc|3586|tcp|License Server Console
emprise-lsc|3586|udp|License Server Console
p2pgroup|3587|tcp|Peer to Peer Grouping
p2pgroup|3587|udp|Peer to Peer Grouping
sentinel|3588|tcp|Sentinel Server
sentinel|3588|udp|Sentinel Server
isomair|3589|tcp|isomair
isomair|3589|udp|isomair
wv-csp-sms|3590|tcp|WV CSP SMS Binding
wv-csp-sms|3590|udp|WV CSP SMS Binding
gtrack-server|3591|tcp|LOCANIS G-TRACK Server
gtrack-server|3591|udp|LOCANIS G-TRACK Server
gtrack-ne|3592|tcp|LOCANIS G-TRACK NE Port
gtrack-ne|3592|udp|LOCANIS G-TRACK NE Port
bpmd|3593|tcp|BP Model Debugger
bpmd|3593|udp|BP Model Debugger
mediaspace|3594|tcp|MediaSpace
mediaspace|3594|udp|MediaSpace
shareapp|3595|tcp|ShareApp
shareapp|3595|udp|ShareApp
iw-mmogame|3596|tcp|Illusion Wireless MMOG
iw-mmogame|3596|udp|Illusion Wireless MMOG
a14|3597|tcp|A14 (AN-to-SC/MM)
a14|3597|udp|A14 (AN-to-SC/MM)
a15|3598|tcp|A15 (AN-to-AN)
a15|3598|udp|A15 (AN-to-AN)
quasar-server|3599|tcp|Quasar Accounting Server
quasar-server|3599|udp|Quasar Accounting Server
trap-daemon|3600|tcp|text relay-answer
trap-daemon|3600|udp|text relay-answer
visinet-gui|3601|tcp|Visinet Gui
visinet-gui|3601|udp|Visinet Gui
infiniswitchcl|3602|tcp|InfiniSwitch Mgr Client
infiniswitchcl|3602|udp|InfiniSwitch Mgr Client
int-rcv-cntrl|3603|tcp|Integrated Rcvr Control
int-rcv-cntrl|3603|udp|Integrated Rcvr Control
bmc-jmx-port|3604|tcp|BMC JMX Port
bmc-jmx-port|3604|udp|BMC JMX Port
comcam-io|3605|tcp|ComCam IO Port
comcam-io|3605|udp|ComCam IO Port
splitlock|3606|tcp|Splitlock Server
splitlock|3606|udp|Splitlock Server
precise-i3|3607|tcp|Precise I3
precise-i3|3607|udp|Precise I3
trendchip-dcp|3608|tcp|Trendchip control protocol
trendchip-dcp|3608|udp|Trendchip control protocol
cpdi-pidas-cm|3609|tcp|CPDI PIDAS Connection Mon
cpdi-pidas-cm|3609|udp|CPDI PIDAS Connection Mon
echonet|3610|tcp|ECHONET
echonet|3610|udp|ECHONET
six-degrees|3611|tcp|Six Degrees Port
six-degrees|3611|udp|Six Degrees Port
hp-dataprotect|3612|tcp|HP Data Protector
hp-dataprotect|3612|udp|HP Data Protector
alaris-disc|3613|tcp|Alaris Device Discovery
alaris-disc|3613|udp|Alaris Device Discovery
sigma-port|3614|tcp|Invensys Sigma Port
sigma-port|3614|udp|Invensys Sigma Port
start-network|3615|tcp|Start Messaging Network
start-network|3615|udp|Start Messaging Network
cd3o-protocol|3616|tcp|cd3o Control Protocol
cd3o-protocol|3616|udp|cd3o Control Protocol
sharp-server|3617|tcp|ATI SHARP Logic Engine
sharp-server|3617|udp|ATI SHARP Logic Engine
aairnet-1|3618|tcp|AAIR-Network 1
aairnet-1|3618|udp|AAIR-Network 1
aairnet-2|3619|tcp|AAIR-Network 2
aairnet-2|3619|udp|AAIR-Network 2
ep-pcp|3620|tcp|EPSON Projector Control Port
ep-pcp|3620|udp|EPSON Projector Control Port
ep-nsp|3621|tcp|EPSON Network Screen Port
ep-nsp|3621|udp|EPSON Network Screen Port
ff-lr-port|3622|tcp|FF LAN Redundancy Port
ff-lr-port|3622|udp|FF LAN Redundancy Port
haipe-discover|3623|tcp|HAIPIS Dynamic Discovery
haipe-discover|3623|udp|HAIPIS Dynamic Discovery
dist-upgrade|3624|tcp|Distributed Upgrade Port
dist-upgrade|3624|udp|Distributed Upgrade Port
volley|3625|tcp|Volley
volley|3625|udp|Volley
bvcdaemon-port|3626|tcp|bvControl Daemon
bvcdaemon-port|3626|udp|bvControl Daemon
jamserverport|3627|tcp|Jam Server Port
jamserverport|3627|udp|Jam Server Port
ept-machine|3628|tcp|EPT Machine Interface
ept-machine|3628|udp|EPT Machine Interface
escvpnet|3629|tcp|ESC/VP.net
escvpnet|3629|udp|ESC/VP.net
cs-remote-db|3630|tcp|C&S Remote Database Port
cs-remote-db|3630|udp|C&S Remote Database Port
cs-services|3631|tcp|C&S Web Services Port
cs-services|3631|udp|C&S Web Services Port
distcc|3632|tcp|distributed compiler
distcc|3632|udp|distributed complier
wacp|3633|tcp|Wyrnix AIS port
wacp|3633|udp|Wyrnix AIS port
hlibmgr|3634|tcp|hNTSP Library Manager
hlibmgr|3634|udp|hNTSP Library Manager
sdo|3635|tcp|Simple Distributed Objects
sdo|3635|udp|Simple Distributed Objects
opscenter|3636|tcp|OpsCenter
opscenter|3636|udp|OpsCenter
scservp|3637|tcp|Customer Service Port
scservp|3637|udp|Customer Service Port
ehp-backup|3638|tcp|EHP Backup Protocol
ehp-backup|3638|udp|EHP Backup Protocol
xap-ha|3639|tcp|Extensible Automation
xap-ha|3639|udp|Extensible Automation
netplay-port1|3640|tcp|Netplay Port 1
netplay-port1|3640|udp|Netplay Port 1
netplay-port2|3641|tcp|Netplay Port 2
netplay-port2|3641|udp|Netplay Port 2
juxml-port|3642|tcp|Juxml Replication port
juxml-port|3642|udp|Juxml Replication port
audiojuggler|3643|tcp|AudioJuggler
audiojuggler|3643|udp|AudioJuggler
ssowatch|3644|tcp|ssowatch
ssowatch|3644|udp|ssowatch
cyc|3645|tcp|Cyc
cyc|3645|udp|Cyc
xss-srv-port|3646|tcp|XSS Server Port
xss-srv-port|3646|udp|XSS Server Port
splitlock-gw|3647|tcp|Splitlock Gateway
splitlock-gw|3647|udp|Splitlock Gateway
fjcp|3648|tcp|Fujitsu Cooperation Port
fjcp|3648|udp|Fujitsu Cooperation Port
nmmp|3649|tcp|Nishioka Miyuki Msg Protocol
nmmp|3649|udp|Nishioka Miyuki Msg Protocol
prismiq-plugin|3650|tcp|PRISMIQ VOD plug-in
prismiq-plugin|3650|udp|PRISMIQ VOD plug-in
xrpc-registry|3651|tcp|XRPC Registry
xrpc-registry|3651|udp|XRPC Registry
vxcrnbuport|3652|tcp|VxCR NBU Default Port
vxcrnbuport|3652|udp|VxCR NBU Default Port
tsp|3653|tcp|Tunnel Setup Protocol
tsp|3653|udp|Tunnel Setup Protocol
vaprtm|3654|tcp|VAP RealTime Messenger
vaprtm|3654|udp|VAP RealTime Messenger
abatemgr|3655|tcp|ActiveBatch Exec Agent
abatemgr|3655|udp|ActiveBatch Exec Agent
abatjss|3656|tcp|ActiveBatch Job Scheduler
abatjss|3656|udp|ActiveBatch Job Scheduler
immedianet-bcn|3657|tcp|ImmediaNet Beacon
immedianet-bcn|3657|udp|ImmediaNet Beacon
ps-ams|3658|tcp|PlayStation AMS (Secure)
ps-ams|3658|udp|PlayStation AMS (Secure)
apple-sasl|3659|tcp|Apple SASL
apple-sasl|3659|udp|Apple SASL
can-nds-ssl|3660|tcp|Candle Directory Services using SSL
can-nds-ssl|3660|udp|Candle Directory Services using SSL
can-ferret-ssl|3661|tcp|Candle Directory Services using SSL
can-ferret-ssl|3661|udp|Candle Directory Services using SSL
pserver|3662|tcp|pserver
pserver|3662|udp|pserver
dtp|3663|tcp|DIRECWAY Tunnel Protocol
dtp|3663|udp|DIRECWAY Tunnel Protocol
ups-engine|3664|tcp|UPS Engine Port
ups-engine|3664|udp|UPS Engine Port
ent-engine|3665|tcp|Enterprise Engine Port
ent-engine|3665|udp|Enterprise Engine Port
eserver-pap|3666|tcp|IBM eServer PAP
eserver-pap|3666|udp|IBM EServer PAP
infoexch|3667|tcp|IBM Information Exchange
infoexch|3667|udp|IBM Information Exchange
dell-rm-port|3668|tcp|Dell Remote Management
dell-rm-port|3668|udp|Dell Remote Management
casanswmgmt|3669|tcp|CA SAN Switch Management
casanswmgmt|3669|udp|CA SAN Switch Management
smile|3670|tcp|SMILE TCP/UDP Interface
smile|3670|udp|SMILE TCP/UDP Interface
efcp|3671|tcp|e Field Control (EIBnet)
efcp|3671|udp|e Field Control (EIBnet)
lispworks-orb|3672|tcp|LispWorks ORB
lispworks-orb|3672|udp|LispWorks ORB
mediavault-gui|3673|tcp|Openview Media Vault GUI
mediavault-gui|3673|udp|Openview Media Vault GUI
wininstall-ipc|3674|tcp|WinINSTALL IPC Port
wininstall-ipc|3674|udp|WinINSTALL IPC Port
calltrax|3675|tcp|CallTrax Data Port
calltrax|3675|udp|CallTrax Data Port
va-pacbase|3676|tcp|VisualAge Pacbase server
va-pacbase|3676|udp|VisualAge Pacbase server
roverlog|3677|tcp|RoverLog IPC
roverlog|3677|udp|RoverLog IPC
ipr-dglt|3678|tcp|DataGuardianLT
ipr-dglt|3678|udp|DataGuardianLT
newton-dock|3679|tcp|Newton Dock
newton-dock|3679|udp|Newton Dock
npds-tracker|3680|tcp|NPDS Tracker
npds-tracker|3680|udp|NPDS Tracker
bts-x73|3681|tcp|BTS X73 Port
bts-x73|3681|udp|BTS X73 Port
cas-mapi|3682|tcp|EMC SmartPackets-MAPI
cas-mapi|3682|udp|EMC SmartPackets-MAPI
bmc-ea|3683|tcp|BMC EDV/EA
bmc-ea|3683|udp|BMC EDV/EA
faxstfx-port|3684|tcp|FAXstfX
faxstfx-port|3684|udp|FAXstfX
dsx-agent|3685|tcp|DS Expert Agent
dsx-agent|3685|udp|DS Expert Agent
tnmpv2|3686|tcp|Trivial Network Management
tnmpv2|3686|udp|Trivial Network Management
simple-push|3687|tcp|simple-push
simple-push|3687|udp|simple-push
simple-push-s|3688|tcp|simple-push Secure
simple-push-s|3688|udp|simple-push Secure
daap|3689|tcp|Digital Audio Access Protocol
daap|3689|udp|Digital Audio Access Protocol
svn|3690|tcp|Subversion
svn|3690|udp|Subversion
magaya-network|3691|tcp|Magaya Network Port
magaya-network|3691|udp|Magaya Network Port
intelsync|3692|tcp|Brimstone IntelSync
intelsync|3692|udp|Brimstone IntelSync
gttp|3693|tcp|GTTP
gttp|3693|udp|GTTP
vpncpp|3694|tcp|VPN Cookie Prop Protocol
vpncpp|3694|udp|VPN Cookie Prop Protocol
bmc-data-coll|3695|tcp|BMC Data Collection
bmc-data-coll|3695|udp|BMC Data Collection
telnetcpcd|3696|tcp|Telnet Com Port Control
telnetcpcd|3696|udp|Telnet Com Port Control
nw-license|3697|tcp|NavisWorks License System
nw-license|3697|udp|NavisWorks Licnese System
sagectlpanel|3698|tcp|SAGECTLPANEL
sagectlpanel|3698|udp|SAGECTLPANEL
kpn-icw|3699|tcp|Internet Call Waiting
kpn-icw|3699|udp|Internet Call Waiting
lrs-paging|3700|tcp|LRS NetPage
lrs-paging|3700|udp|LRS NetPage
netcelera|3701|tcp|NetCelera
netcelera|3701|udp|NetCelera
upnp-discovery|3702|tcp|UPNP v2 Discovery
upnp-discovery|3702|udp|UPNP v2 Discovery
adobeserver-3|3703|tcp|Adobe Server 3
adobeserver-3|3703|udp|Adobe Server 3
adobeserver-4|3704|tcp|Adobe Server 4
adobeserver-4|3704|udp|Adobe Server 4
adobeserver-5|3705|tcp|Adobe Server 5
adobeserver-5|3705|udp|Adobe Server 5
rt-event|3706|tcp|Real-Time Event Port
rt-event|3706|udp|Real-Time Event Port
rt-event-s|3707|tcp|Real-Time Event Secure Port
rt-event-s|3707|udp|Real-Time Event Secure Port
ca-idms|3709|tcp|CA-IDMS Server
ca-idms|3709|udp|CA-IDMS Server
portgate-auth|3710|tcp|PortGate Authentication
portgate-auth|3710|udp|PortGate Authentication
edb-server2|3711|tcp|EBD Server 2
edb-server2|3711|udp|EBD Server 2
sentinel-ent|3712|tcp|Sentinel Enterprise
sentinel-ent|3712|udp|Sentinel Enterprise
tftps|3713|tcp|TFTP over TLS
tftps|3713|udp|TFTP over TLS
delos-dms|3714|tcp|DELOS Direct Messaging
delos-dms|3714|udp|DELOS Direct Messaging
anoto-rendezv|3715|tcp|Anoto Rendezvous Port
anoto-rendezv|3715|udp|Anoto Rendezvous Port
wv-csp-sms-cir|3716|tcp|WV CSP SMS CIR Channel
wv-csp-sms-cir|3716|udp|WV CSP SMS CIR Channel
wv-csp-udp-cir|3717|tcp|WV CSP UDP/IP CIR Channel
wv-csp-udp-cir|3717|udp|WV CSP UDP/IP CIR Channel
opus-services|3718|tcp|OPUS Server Port
opus-services|3718|udp|OPUS Server Port
itelserverport|3719|tcp|iTel Server Port
itelserverport|3719|udp|iTel Server Port
ufastro-instr|3720|tcp|UF Astro. Instr. Services
ufastro-instr|3720|udp|UF Astro. Instr. Services
xsync|3721|tcp|Xsync
xsync|3721|udp|Xsync
xserveraid|3722|tcp|Xserver RAID
xserveraid|3722|udp|Xserver RAID
sychrond|3723|tcp|Sychron Service Daemon
sychrond|3723|udp|Sychron Service Daemon
battlenet|3724|tcp|Blizzard Battlenet
battlenet|3724|udp|Blizzard Battlenet
na-er-tip|3725|tcp|Netia NA-ER Port
na-er-tip|3725|udp|Netia NA-ER Port
array-manager|3726|tdp|Xyratex Array Manager
array-manager|3726|udp|Xyartex Array Manager
e-mdu|3727|tcp|Ericsson Mobile Data Unit
e-mdu|3727|udp|Ericsson Mobile Data Unit
e-woa|3728|tcp|Ericsson Web on Air
e-woa|3728|udp|Ericsson Web on Air
fksp-audit|3729|tcp|Fireking Audit Port
fksp-audit|3729|udp|Fireking Audit Port
client-ctrl|3730|tcp|Client Control
client-ctrl|3730|udp|Client Control
smap|3731|tcp|Service Manager
smap|3731|udp|Service Manager
m-wnn|3732|tcp|Mobile Wnn
m-wnn|3732|udp|Mobile Wnn
multip-msg|3733|tcp|Multipuesto Msg Port
multip-msg|3733|udp|Multipuesto Msg Port
synel-data|3734|tcp|Synel Data Collection Port
synel-data|3734|udp|Synel Data Collection Port
pwdis|3735|tcp|Password Distribution
pwdis|3735|udp|Password Distribution
rs-rmi|3736|tcp|RealSpace RMI
rs-rmi|3736|udp|RealSpace RMI
versatalk|3738|tcp|versaTalk Server Port
versatalk|3738|udp|versaTalk Server Port
launchbird-lm|3739|tcp|Launchbird LicenseManager
launchbird-lm|3739|udp|Launchbird LicenseManager
heartbeat|3740|tcp|Heartbeat Protocol
heartbeat|3740|udp|Heartbeat Protocol
wysdma|3741|tcp|WysDM Agent
wysdma|3741|udp|WysDM Agent
cst-port|3742|tcp|CST - Configuration & Service Tracker
cst-port|3742|udp|CST - Configuration & Service Tracker
ipcs-command|3743|tcp|IP Control Systems Ltd.
ipcs-command|3743|udp|IP Control Systems Ltd.
sasg|3744|tcp|SASG
sasg|3744|udp|SASG
gw-call-port|3745|tcp|GWRTC Call Port
gw-call-port|3745|udp|GWRTC Call Port
linktest|3746|tcp|LXPRO.COM LinkTest
linktest|3746|udp|LXPRO.COM LinkTest
linktest-s|3747|tcp|LXPRO.COM LinkTest SSL
linktest-s|3747|udp|LXPRO.COM LinkTest SSL
webdata|3748|tcp|webData
webdata|3748|udp|webData
cimtrak|3749|tcp|CimTrak
cimtrak|3749|udp|CimTrak
cbos-ip-port|3750|tcp|CBOS/IP ncapsalation port
cbos-ip-port|3750|udp|CBOS/IP ncapsalatoin port
gprs-cube|3751|tcp|CommLinx GPRS Cube
gprs-cube|3751|udp|CommLinx GPRS Cube
vipremoteagent|3752|tcp|Vigil-IP RemoteAgent
vipremoteagent|3752|udp|Vigil-IP RemoteAgent
nattyserver|3753|tcp|NattyServer Port
nattyserver|3753|udp|NattyServer Port
timestenbroker|3754|tcp|TimesTen Broker Port
timestenbroker|3754|udp|TimesTen Broker Port
sas-remote-hlp|3755|tcp|SAS Remote Help Server
sas-remote-hlp|3755|udp|SAS Remote Help Server
canon-capt|3756|tcp|Canon CAPT Port
canon-capt|3756|udp|Canon CAPT Port
grf-port|3757|tcp|GRF Server Port
grf-port|3757|udp|GRF Server Port
apw-registry|3758|tcp|apw RMI registry
apw-registry|3758|udp|apw RMI registry
exapt-lmgr|3759|tcp|Exapt License Manager
exapt-lmgr|3759|udp|Exapt License Manager
adtempusclient|3760|tcp|adTempus Client
adtempusclient|3760|udp|adTEmpus Client
pwgpsi|3800|tcp|Print Services Interface
pwgpsi|3800|udp|Print Services Interface
vhd|3802|tcp|VHD
vhd|3802|udp|VHD
v-one-spp|3845|tcp|V-ONE Single Port Proxy
v-one-spp|3845|udp|V-ONE Single Port Proxy
winshadow-hd|3861|tcp|winShadow Host Discovery
winshadow-hd|3861|udp|winShadow Host Discovery
giga-pocket|3862|tcp|GIGA-POCKET
giga-pocket|3862|udp|GIGA-POCKET
pnbscada|3875|tcp|PNBSCADA
pnbscada|3875|udp|PNBSCADA
topflow-ssl|3885|tcp|TopFlow SSL
topflow-ssl|3885|udp|TopFlow SSL
udt_os|3900|tcp|Unidata UDT OS
udt_os|3900|udp|Unidata UDT OS
aamp|3939|tcp|Anti-virus Application Management Port
aamp|3939|udp|Anti-virus Application Management Port
mapper-nodemgr|3984|tcp|MAPPER network node manager
mapper-nodemgr|3984|udp|MAPPER network node manager
mapper-mapethd|3985|tcp|MAPPER TCP/IP server
mapper-mapethd|3985|udp|MAPPER TCP/IP server
mapper-ws_ethd|3986|tcp|MAPPER workstation server
mapper-ws_ethd|3986|udp|MAPPER workstation server
centerline|3987|tcp|Centerline
centerline|3987|udp|Centerline
terabase|4000|tcp|Terabase
terabase|4000|udp|Terabase
newoak|4001|tcp|NewOak
newoak|4001|udp|NewOak
pxc-spvr-ft|4002|tcp|pxc-spvr-ft
pxc-spvr-ft|4002|udp|pxc-spvr-ft
pxc-splr-ft|4003|tcp|pxc-splr-ft
pxc-splr-ft|4003|udp|pxc-splr-ft
pxc-roid|4004|tcp|pxc-roid
pxc-roid|4004|udp|pxc-roid
pxc-pin|4005|tcp|pxc-pin
pxc-pin|4005|udp|pxc-pin
pxc-spvr|4006|tcp|pxc-spvr
pxc-spvr|4006|udp|pxc-spvr
pxc-splr|4007|tcp|pxc-splr
pxc-splr|4007|udp|pxc-splr
netcheque|4008|tcp|NetCheque accounting
netcheque|4008|udp|NetCheque accounting
chimera-hwm|4009|tcp|Chimera HWM
chimera-hwm|4009|udp|Chimera HWM
samsung-unidex|4010|tcp|Samsung Unidex
samsung-unidex|4010|udp|Samsung Unidex
altserviceboot|4011|tcp|Alternate Service Boot
altserviceboot|4011|udp|Alternate Service Boot
pda-gate|4012|tcp|PDA Gate
pda-gate|4012|udp|PDA Gate
acl-manager|4013|tcp|ACL Manager
acl-manager|4013|udp|ACL Manager
taiclock|4014|tcp|TAICLOCK
taiclock|4014|udp|TAICLOCK
talarian-mcast1|4015|tcp|Talarian Mcast
talarian-mcast1|4015|udp|Talarian Mcast
talarian-mcast2|4016|tcp|Talarian Mcast
talarian-mcast2|4016|udp|Talarian Mcast
talarian-mcast3|4017|tcp|Talarian Mcast
talarian-mcast3|4017|udp|Talarian Mcast
talarian-mcast4|4018|tcp|Talarian Mcast
talarian-mcast4|4018|udp|Talarian Mcast
talarian-mcast5|4019|tcp|Talarian Mcast
talarian-mcast5|4019|udp|Talarian Mcast
trap|4020|tcp|TRAP Port
trap|4020|udp|TRAP Port
nexus-portal|4021|tcp|Nexus Portal
nexus-portal|4021|udp|Nexus Portal
dnox|4022|tcp|DNOX
dnox|4022|udp|DNOX
esnm-zoning|4023|tcp|ESNM Zoning Port
esnm-zoning|4023|udp|ESNM Zoning Port
tnp1-port|4024|tcp|TNP1 User Port
tnp1-port|4024|udp|TNP1 User Port
partimage|4025|tcp|Partition Image Port
partimage|4025|udp|Partition Image Port
as-debug|4026|tcp|Graphical Debug Server
as-debug|4026|udp|Graphical Debug Server
bxp|4027|tcp|bitxpress
bxp|4027|udp|bitxpress
dtserver-port|4028|tcp|DTServer Port
dtserver-port|4028|udp|DTServer Port
ip-qsig|4029|tcp|IP Q signaling protocol
ip-qsig|4029|udp|IP Q signaling protocol
jdmn-port|4030|tcp|Accell/JSP Daemon Port
jdmn-port|4030|udp|Accell/JSP Daemon Port
suucp|4031|tcp|UUCP over SSL
suucp|4031|udp|UUCP over SSL
vrts-auth-port|4032|tcp|VERITAS Authorization Service
vrts-auth-port|4032|udp|VERITAS Authorization Service
sanavigator|4033|tcp|SANavigator Peer Port
sanavigator|4033|udp|SANavigator Peer Port
ubxd|4034|tcp|Ubiquinox Daemon
ubxd|4034|udp|Ubiquinox Daemon
wap-push-http|4035|tcp|WAP Push OTA-HTTP port
wap-push-http|4035|udp|WAP Push OTA-HTTP port
wap-push-https|4036|tcp|WAP Push OTA-HTTP secure
wap-push-https|4036|udp|WAP Push OTA-HTTP secure
yo-main|4040|tcp|Yo.net main service
yo-main|4040|udp|Yo.net main service
houston|4041|tcp|Rocketeer-Houston
houston|4041|udp|Rocketeer-Houston
ldxp|4042|tcp|LDXP
ldxp|4042|udp|LDXP
bre|4096|tcp|BRE (Bridge Relay Element)
bre|4096|udp|BRE (Bridge Relay Element)
patrolview|4097|tcp|Patrol View
patrolview|4097|udp|Patrol View
drmsfsd|4098|tcp|drmsfsd
drmsfsd|4098|udp|drmsfsd
dpcp|4099|tcp|DPCP
dpcp|4099|udp|DPCP
igo-incognito|4100|tcp|IGo Incognito Data Port
igo-incognito|4100|udp|IGo Incognito Data Port
jomamqmonitor|4114|tcp|JomaMQMonitor
jomamqmonitor|4114|udp|JomaMQMonitor
nuts_dem|4132|tcp|NUTS Daemon
nuts_dem|4132|udp|NUTS Daemon
nuts_bootp|4133|tcp|NUTS Bootp Server
nuts_bootp|4133|udp|NUTS Bootp Server
nifty-hmi|4134|tcp|NIFTY-Serve HMI protocol
nifty-hmi|4134|udp|NIFTY-Serve HMI protocol
nettest|4138|tcp|nettest
nettest|4138|udp|nettest
oirtgsvc|4141|tcp|Workflow Server
oirtgsvc|4141|udp|Workflow Server
oidocsvc|4142|tcp|Document Server
oidocsvc|4142|udp|Document Server
oidsr|4143|tcp|Document Replication
oidsr|4143|udp|Document Replication
vvr-control|4145|tcp|VVR Control
vvr-control|4145|udp|VVR Control
atlinks|4154|tcp|atlinks device discovery
atlinks|4154|udp|atlinks device discovery
jini-discovery|4160|tcp|Jini Discovery
jini-discovery|4160|udp|Jini Discovery
eims-admin|4199|tcp|EIMS ADMIN
eims-admin|4199|udp|EIMS ADMIN
corelccam|4300|tcp|Corel CCam
corelccam|4300|udp|Corel CCam
rwhois|4321|tcp|Remote Who Is
rwhois|4321|udp|Remote Who Is
unicall|4343|tcp|UNICALL
unicall|4343|udp|UNICALL
vinainstall|4344|tcp|VinaInstall
vinainstall|4344|udp|VinaInstall
m4-network-as|4345|tcp|Macro 4 Network AS
m4-network-as|4345|udp|Macro 4 Network AS
elanlm|4346|tcp|ELAN LM
elanlm|4346|udp|ELAN LM
lansurveyor|4347|tcp|LAN Surveyor
lansurveyor|4347|udp|LAN Surveyor
itose|4348|tcp|ITOSE
itose|4348|udp|ITOSE
fsportmap|4349|tcp|File System Port Map
fsportmap|4349|udp|File System Port Map
net-device|4350|tcp|Net Device
net-device|4350|udp|Net Device
plcy-net-svcs|4351|tcp|PLCY Net Services
plcy-net-svcs|4351|udp|PLCY Net Services
f5-iquery|4353|tcp|F5 iQuery
f5-iquery|4353|udp|F5 iQuery
qsnet-trans|4354|tcp|QSNet Transmitter
qsnet-trans|4354|udp|QSNet Transmitter
qsnet-workst|4355|tcp|QSNet Workstation
qsnet-workst|4355|udp|QSNet Workstation
qsnet-assist|4356|tcp|QSNet Assistant
qsnet-assist|4356|udp|QSNet Assistant
qsnet-cond|4357|tcp|QSNet Conductor
qsnet-cond|4357|udp|QSNet Conductor
qsnet-nucl|4358|tcp|QSNet Nucleus
qsnet-nucl|4358|udp|QSNet Nucleus
saris|4442|tcp|Saris
saris|4442|udp|Saris
pharos|4443|tcp|Pharos
pharos|4443|udp|Pharos
krb524|4444|tcp|KRB524
krb524|4444|udp|KRB524
nv-video|4444|tcp|NV Video default
nv-video|4444|udp|NV Video default
upnotifyp|4445|tcp|UPNOTIFYP
upnotifyp|4445|udp|UPNOTIFYP
n1-fwp|4446|tcp|N1-FWP
n1-fwp|4446|udp|N1-FWP
n1-rmgmt|4447|tcp|N1-RMGMT
n1-rmgmt|4447|udp|N1-RMGMT
asc-slmd|4448|tcp|ASC Licence Manager
asc-slmd|4448|udp|ASC Licence Manager
privatewire|4449|tcp|PrivateWire
privatewire|4449|udp|PrivateWire
camp|4450|tcp|Camp
camp|4450|udp|Camp
ctisystemmsg|4451|tcp|CTI System Msg
ctisystemmsg|4451|udp|CTI System Msg
ctiprogramload|4452|tcp|CTI Program Load
ctiprogramload|4452|udp|CTI Program Load
nssalertmgr|4453|tcp|NSS Alert Manager
nssalertmgr|4453|udp|NSS Alert Manager
nssagentmgr|4454|tcp|NSS Agent Manager
nssagentmgr|4454|udp|NSS Agent Manager
prchat-user|4455|tcp|PR Chat User
prchat-user|4455|udp|PR Chat User
prchat-server|4456|tcp|PR Chat Server
prchat-server|4456|udp|PR Chat Server
prRegister|4457|tcp|PR Register
prRegister|4457|udp|PR Register
ipsec-msft|4500|tcp|Microsoft IPsec NAT-T
ipsec-msft|4500|udp|Microsoft IPsec NAT-T
worldscores|4545|tcp|WorldScores
worldscores|4545|udp|WorldScores
sf-lm|4546|tcp|SF License Manager (Sentinel)
sf-lm|4546|udp|SF License Manager (Sentinel)
lanner-lm|4547|tcp|Lanner License Manager
lanner-lm|4547|udp|Lanner License Manager
rsip|4555|tcp|RSIP Port
rsip|4555|udp|RSIP Port
hylafax|4559|tcp|HylaFAX
hylafax|4559|udp|HylaFAX
tram|4567|tcp|TRAM
tram|4567|udp|TRAM
bmc-reporting|4568|tcp|BMC Reporting
bmc-reporting|4568|udp|BMC Reporting
piranha1|4600|tcp|Piranha1
piranha1|4600|udp|Piranha1
piranha2|4601|tcp|Piranha2
piranha2|4601|udp|Piranha2
smaclmgr|4660|tcp|smaclmgr
smaclmgr|4660|udp|smaclmgr
kar2ouche|4661|tcp|Kar2ouche Peer location service
kar2ouche|4661|udp|Kar2ouche Peer location service
rfa|4672|tcp|remote file access server
rfa|4672|udp|remote file access server
snap|4752|tcp|Simple Network Audio Protocol
snap|4752|udp|Simple Network Audio Protocol
iims|4800|tcp|Icona Instant Messenging System
iims|4800|udp|Icona Instant Messenging System
iwec|4801|tcp|Icona Web Embedded Chat
iwec|4801|udp|Icona Web Embedded Chat
ilss|4802|tcp|Icona License System Server
ilss|4802|udp|Icona License System Server
htcp|4827|tcp|HTCP
htcp|4827|udp|HTCP
varadero-0|4837|tcp|Varadero-0
varadero-0|4837|udp|Varadero-0
varadero-1|4838|tcp|Varadero-1
varadero-1|4838|udp|Varadero-1
varadero-2|4839|tcp|Varadero-2
varadero-2|4839|udp|Varadero-2
appserv-http|4848|tcp|App Server - Admin HTTP
appserv-http|4848|udp|App Server - Admin HTTP
appserv-https|4849|tcp|App Server - Admin HTTPS
appserv-https|4849|udp|App Server - Admin HTTPS
phrelay|4868|tcp|Photon Relay
phrelay|4868|udp|Photon Relay
phrelaydbg|4869|tcp|Photon Relay Debug
phrelaydbg|4869|udp|Photon Relay Debug
abbs|4885|tcp|ABBS
abbs|4885|udp|ABBS
lyskom|4894|tcp|LysKOM Protocol A
lyskom|4894|udp|LysKOM Protocol A
radmin-port|4899|tcp|RAdmin Port
radmin-port|4899|udp|RAdmin Port
att-intercom|4983|tcp|AT&T Intercom
att-intercom|4983|udp|AT&T Intercom
smar-se-port1|4987|tcp|SMAR Ethernet Port 1
smar-se-port1|4987|udp|SMAR Ethernet Port 1
smar-se-port2|4988|tcp|SMAR Ethernet Port 2
smar-se-port2|4988|udp|SMAR Ethernet Port 2
parallel|4989|tcp|Parallel for GAUSS (tm)
parallel|4989|udp|Parallel for GAUSS (tm)
commplex-main|5000|tcp|commplex-main
commplex-main|5000|udp|commplex-main
commplex-link|5001|tcp|commplex-link
commplex-link|5001|udp|commplex-link
rfe|5002|tcp|radio free ethernet
rfe|5002|udp|radio free ethernet
fmpro-internal|5003|tcp|FileMaker, Inc. - Proprietary transport
fmpro-internal|5003|udp|FileMaker, Inc. - Proprietary name binding
avt-profile-1|5004|tcp|avt-profile-1
avt-profile-1|5004|udp|avt-profile-1
avt-profile-2|5005|tcp|avt-profile-2
avt-profile-2|5005|udp|avt-profile-2
wsm-server|5006|tcp|wsm server
wsm-server|5006|udp|wsm server
wsm-server-ssl|5007|tcp|wsm server ssl
wsm-server-ssl|5007|udp|wsm server ssl
synapsis-edge|5008|tcp|Synapsis EDGE
synapsis-edge|5008|udp|Synapsis EDGE
telelpathstart|5010|tcp|TelepathStart
telelpathstart|5010|udp|TelepathStart
telelpathattack|5011|tcp|TelepathAttack
telelpathattack|5011|udp|TelepathAttack
zenginkyo-1|5020|tcp|zenginkyo-1
zenginkyo-1|5020|udp|zenginkyo-1
zenginkyo-2|5021|tcp|zenginkyo-2
zenginkyo-2|5021|udp|zenginkyo-2
mice|5022|tcp|mice server
mice|5022|udp|mice server
htuilsrv|5023|tcp|Htuil Server for PLD2
htuilsrv|5023|udp|Htuil Server for PLD2
scpi-telnet|5024|tcp|SCPI-TELNET
scpi-telnet|5024|udp|SCPI-TELNET
scpi-raw|5025|tcp|SCPI-RAW
scpi-raw|5025|udp|SCPI-RAW
asnaacceler8db|5042|tcp|asnaacceler8db
asnaacceler8db|5042|udp|asnaacceler8db
mmcc|5050|tcp|multimedia conference control tool
mmcc|5050|udp|multimedia conference control tool
ita-agent|5051|tcp|ITA Agent
ita-agent|5051|udp|ITA Agent
ita-manager|5052|tcp|ITA Manager
ita-manager|5052|udp|ITA Manager
unot|5055|tcp|UNOT
unot|5055|udp|UNOT
intecom-ps1|5056|tcp|Intecom PS 1
intecom-ps1|5056|udp|Intecom PS 1
intecom-ps2|5057|tcp|Intecom PS 2
intecom-ps2|5057|udp|Intecom PS 2
sip|5060|tcp|SIP
sip|5060|udp|SIP
sip-tls|5061|tcp|SIP-TLS
sip-tls|5061|udp|SIP-TLS
ca-1|5064|tcp|Channel Access 1
ca-1|5064|udp|Channel Access 1
ca-2|5065|tcp|Channel Access 2
ca-2|5065|udp|Channel Access 2
stanag-5066|5066|tcp|STANAG-5066-SUBNET-INTF
stanag-5066|5066|udp|STANAG-5066-SUBNET-INTF
i-net-2000-npr|5069|tcp|I/Net 2000-NPR
i-net-2000-npr|5069|udp|I/Net 2000-NPR
powerschool|5071|tcp|PowerSchool
powerschool|5071|udp|PowerSchool
sdl-ets|5081|tcp|SDL - Ent Trans Server
sdl-ets|5081|udp|SDL - Ent Trans Server
sentinel-lm|5093|tcp|Sentinel LM
sentinel-lm|5093|udp|Sentinel LM
sentlm-srv2srv|5099|tcp|SentLM Srv2Srv
sentlm-srv2srv|5099|udp|SentLM Srv2Srv
talarian-tcp|5101|tcp|Talarian_TCP
talarian-udp|5101|udp|Talarian_UDP
ctsd|5137|tcp|MyCTS server port
ctsd|5137|udp|MyCTS server port
rmonitor_secure|5145|tcp|RMONITOR SECURE
rmonitor_secure|5145|udp|RMONITOR SECURE
atmp|5150|tcp|Ascend Tunnel Management Protocol
atmp|5150|udp|Ascend Tunnel Management Protocol
esri_sde|5151|tcp|ESRI SDE Instance
esri_sde|5151|udp|ESRI SDE Remote Start
sde-discovery|5152|tcp|ESRI SDE Instance Discovery
sde-discovery|5152|udp|ESRI SDE Instance Discovery
ife_icorp|5165|tcp|ife_1corp
ife_icorp|5165|udp|ife_1corp
aol|5190|tcp|America-Online
aol|5190|udp|America-Online
aol-1|5191|tcp|AmericaOnline1
aol-1|5191|udp|AmericaOnline1
aol-2|5192|tcp|AmericaOnline2
aol-2|5192|udp|AmericaOnline2
aol-3|5193|tcp|AmericaOnline3
aol-3|5193|udp|AmericaOnline3
targus-getdata|5200|tcp|TARGUS GetData
targus-getdata|5200|udp|TARGUS GetData
targus-getdata1|5201|tcp|TARGUS GetData 1
targus-getdata1|5201|udp|TARGUS GetData 1
targus-getdata2|5202|tcp|TARGUS GetData 2
targus-getdata2|5202|udp|TARGUS GetData 2
targus-getdata3|5203|tcp|TARGUS GetData 3
targus-getdata3|5203|udp|TARGUS GetData 3
jabber-client|5222|tcp|Jabber Client Connection
jabber-client|5222|udp|Jabber Client Connection
hp-server|5225|tcp|HP Server
hp-server|5225|udp|HP Server
hp-status|5226|tcp|HP Status
hp-status|5226|udp|HP Status
padl2sim|5236|tcp|padl2sim
padl2sim|5236|udp|padl2sim
igateway|5250|tcp|iGateway
igateway|5250|udp|iGateway
3com-njack-1|5264|tcp|3Com Network Jack Port 1
3com-njack-1|5264|udp|3Com Network Jack Port 1
3com-njack-2|5265|tcp|3Com Network Jack Port 2
3com-njack-2|5265|udp|3Com Network Jack Port 2
jabber-server|5269|tcp|Jabber Server Connection
jabber-server|5269|udp|Jabber Server Connection
pk|5272|tcp|PK
pk|5272|udp|PK
transmit-port|5282|tcp|Marimba Transmitter Port
transmit-port|5282|udp|Marimba Transmitter Port
hacl-hb|5300|tcp|# HA cluster heartbeat
hacl-hb|5300|udp|# HA cluster heartbeat
hacl-gs|5301|tcp|# HA cluster general services
hacl-gs|5301|udp|# HA cluster general services
hacl-cfg|5302|tcp|# HA cluster configuration
hacl-cfg|5302|udp|# HA cluster configuration
hacl-probe|5303|tcp|# HA cluster probing
hacl-probe|5303|udp|# HA cluster probing
hacl-local|5304|tcp|# HA Cluster Commands
hacl-local|5304|udp|hacl-local
hacl-test|5305|tcp|# HA Cluster Test
hacl-test|5305|udp|hacl-test
sun-mc-grp|5306|tcp|Sun MC Group
sun-mc-grp|5306|udp|Sun MC Group
sco-aip|5307|tcp|SCO AIP
sco-aip|5307|udp|SCO AIP
cfengine|5308|tcp|CFengine
cfengine|5308|udp|CFengine
jprinter|5309|tcp|J Printer
jprinter|5309|udp|J Printer
outlaws|5310|tcp|Outlaws
outlaws|5310|udp|Outlaws
tmlogin|5311|tcp|TM Login
tmlogin|5311|udp|TM Login
opalis-rbt-ipc|5314|tcp|opalis-rbt-ipc
opalis-rbt-ipc|5314|udp|opalis-rbt-ipc
hacl-poll|5315|tcp|HA Cluster UDP Polling
hacl-poll|5315|udp|HA Cluster UDP Polling
mdns|5353|tcp|Multicast DNS
mdns|5353|udp|Multicast DNS
excerpt|5400|tcp|Excerpt Search
excerpt|5400|udp|Excerpt Search
excerpts|5401|tcp|Excerpt Search Secure
excerpts|5401|udp|Excerpt Search Secure
mftp|5402|tcp|MFTP
mftp|5402|udp|MFTP
hpoms-ci-lstn|5403|tcp|HPOMS-CI-LSTN
hpoms-ci-lstn|5403|udp|HPOMS-CI-LSTN
hpoms-dps-lstn|5404|tcp|HPOMS-DPS-LSTN
hpoms-dps-lstn|5404|udp|HPOMS-DPS-LSTN
netsupport|5405|tcp|NetSupport
netsupport|5405|udp|NetSupport
systemics-sox|5406|tcp|Systemics Sox
systemics-sox|5406|udp|Systemics Sox
foresyte-clear|5407|tcp|Foresyte-Clear
foresyte-clear|5407|udp|Foresyte-Clear
foresyte-sec|5408|tcp|Foresyte-Sec
foresyte-sec|5408|udp|Foresyte-Sec
salient-dtasrv|5409|tcp|Salient Data Server
salient-dtasrv|5409|udp|Salient Data Server
salient-usrmgr|5410|tcp|Salient User Manager
salient-usrmgr|5410|udp|Salient User Manager
actnet|5411|tcp|ActNet
actnet|5411|udp|ActNet
continuus|5412|tcp|Continuus
continuus|5412|udp|Continuus
wwiotalk|5413|tcp|WWIOTALK
wwiotalk|5413|udp|WWIOTALK
statusd|5414|tcp|StatusD
statusd|5414|udp|StatusD
ns-server|5415|tcp|NS Server
ns-server|5415|udp|NS Server
sns-gateway|5416|tcp|SNS Gateway
sns-gateway|5416|udp|SNS Gateway
sns-agent|5417|tcp|SNS Agent
sns-agent|5417|udp|SNS Agent
mcntp|5418|tcp|MCNTP
mcntp|5418|udp|MCNTP
dj-ice|5419|tcp|DJ-ICE
dj-ice|5419|udp|DJ-ICE
cylink-c|5420|tcp|Cylink-C
cylink-c|5420|udp|Cylink-C
netsupport2|5421|tcp|Net Support 2
netsupport2|5421|udp|Net Support 2
salient-mux|5422|tcp|Salient MUX
salient-mux|5422|udp|Salient MUX
virtualuser|5423|tcp|VIRTUALUSER
virtualuser|5423|udp|VIRTUALUSER
devbasic|5426|tcp|DEVBASIC
devbasic|5426|udp|DEVBASIC
sco-peer-tta|5427|tcp|SCO-PEER-TTA
sco-peer-tta|5427|udp|SCO-PEER-TTA
telaconsole|5428|tcp|TELACONSOLE
telaconsole|5428|udp|TELACONSOLE
base|5429|tcp|Billing and Accounting System Exchange
base|5429|udp|Billing and Accounting System Exchange
radec-corp|5430|tcp|RADEC CORP
radec-corp|5430|udp|RADEC CORP
park-agent|5431|tcp|PARK AGENT
park-agent|5431|udp|PARK AGENT
postgresql|5432|tcp|PostgreSQL Database
postgresql|5432|udp|PostgreSQL Database
dttl|5435|tcp|Data Tunneling Transceiver Linking (DTTL)
dttl|5435|udp|Data Tunneling Transceiver Linking (DTTL)
apc-5454|5454|tcp|APC 5454
apc-5454|5454|udp|APC 5454
apc-5455|5455|tcp|APC 5455
apc-5455|5455|udp|APC 5455
apc-5456|5456|tcp|APC 5456
apc-5456|5456|udp|APC 5456
silkmeter|5461|tcp|SILKMETER
silkmeter|5461|udp|SILKMETER
ttl-publisher|5462|tcp|TTL Publisher
ttl-publisher|5462|udp|TTL Publisher
ttlpriceproxy|5463|tcp|TTL Price Proxy
ttlpriceproxy|5463|udp|TTL Price Proxy
netops-broker|5465|tcp|NETOPS-BROKER
netops-broker|5465|udp|NETOPS-BROKER
fcp-addr-srvr1|5500|tcp|fcp-addr-srvr1
fcp-addr-srvr1|5500|udp|fcp-addr-srvr1
fcp-addr-srvr2|5501|tcp|fcp-addr-srvr2
fcp-addr-srvr2|5501|udp|fcp-addr-srvr2
fcp-srvr-inst1|5502|tcp|fcp-srvr-inst1
fcp-srvr-inst1|5502|udp|fcp-srvr-inst1
fcp-srvr-inst2|5503|tcp|fcp-srvr-inst2
fcp-srvr-inst2|5503|udp|fcp-srvr-inst2
fcp-cics-gw1|5504|tcp|fcp-cics-gw1
fcp-cics-gw1|5504|udp|fcp-cics-gw1
sgi-esphttp|5554|tcp|SGI ESP HTTP
sgi-esphttp|5554|udp|SGI ESP HTTP
personal-agent|5555|tcp|Personal Agent
personal-agent|5555|udp|Personal Agent
udpplus|5566|tcp|UDPPlus
udpplus|5566|udp|UDPPlus
esinstall|5599|tcp|Enterprise Security Remote Install
esinstall|5599|udp|Enterprise Security Remote Install
esmmanager|5600|tcp|Enterprise Security Manager
esmmanager|5600|udp|Enterprise Security Manager
esmagent|5601|tcp|Enterprise Security Agent
esmagent|5601|udp|Enterprise Security Agent
a1-msc|5602|tcp|A1-MSC
a1-msc|5602|udp|A1-MSC
a1-bs|5603|tcp|A1-BS
a1-bs|5603|udp|A1-BS
a3-sdunode|5604|tcp|A3-SDUNode
a3-sdunode|5604|udp|A3-SDUNode
a4-sdunode|5605|tcp|A4-SDUNode
a4-sdunode|5605|udp|A4-SDUNode
pcanywheredata|5631|tcp|pcANYWHEREdata
pcanywheredata|5631|udp|pcANYWHEREdata
pcanywherestat|5632|tcp|pcANYWHEREstat
pcanywherestat|5632|udp|pcANYWHEREstat
jms|5673|tcp|JACL Message Server
jms|5673|udp|JACL Message Server
hyperscsi-port|5674|tcp|HyperSCSI Port
hyperscsi-port|5674|udp|HyperSCSI Port
v5ua|5675|tcp|V5UA application port
v5ua|5675|udp|V5UA application port
raadmin|5676|tcp|RA Administration
raadmin|5676|udp|RA Administration
questdb2-lnchr|5677|tcp|Quest Central DB2 Launchr
questdb2-lnchr|5677|udp|Quest Central DB2 Launchr
rrac|5678|tcp|Remote Replication Agent Connection
rrac|5678|udp|Remote Replication Agent Connection
dccm|5679|tcp|Direct Cable Connect Manager
dccm|5679|udp|Direct Cable Connect Manager
ggz|5688|tcp|GGZ Gaming Zone
ggz|5688|udp|GGZ Gaming Zone
proshareaudio|5713|tcp|proshare conf audio
proshareaudio|5713|udp|proshare conf audio
prosharevideo|5714|tcp|proshare conf video
prosharevideo|5714|udp|proshare conf video
prosharedata|5715|tcp|proshare conf data
prosharedata|5715|udp|proshare conf data
prosharerequest|5716|tcp|proshare conf request
prosharerequest|5716|udp|proshare conf request
prosharenotify|5717|tcp|proshare conf notify
prosharenotify|5717|udp|proshare conf notify
ms-licensing|5720|tcp|MS-Licensing
ms-licensing|5720|udp|MS-Licensing
openmail|5729|tcp|Openmail User Agent Layer
openmail|5729|udp|Openmail User Agent Layer
unieng|5730|tcp|Steltor's calendar access
unieng|5730|udp|Steltor's calendar access
ida-discover1|5741|tcp|IDA Discover Port 1
ida-discover1|5741|udp|IDA Discover Port 1
ida-discover2|5742|tcp|IDA Discover Port 2
ida-discover2|5742|udp|IDA Discover Port 2
fcopy-server|5745|tcp|fcopy-server
fcopy-server|5745|udp|fcopy-server
fcopys-server|5746|tcp|fcopys-server
fcopys-server|5746|udp|fcopys-server
openmailg|5755|tcp|OpenMail Desk Gateway server
openmailg|5755|udp|OpenMail Desk Gateway server
x500ms|5757|tcp|OpenMail X.500 Directory Server
x500ms|5757|udp|OpenMail X.500 Directory Server
openmailns|5766|tcp|OpenMail NewMail Server
openmailns|5766|udp|OpenMail NewMail Server
s-openmail|5767|tcp|OpenMail Suer Agent Layer (Secure)
s-openmail|5767|udp|OpenMail Suer Agent Layer (Secure)
openmailpxy|5768|tcp|OpenMail CMTS Server
openmailpxy|5768|udp|OpenMail CMTS Server
netagent|5771|tcp|NetAgent
netagent|5771|udp|NetAgent
icmpd|5813|tcp|ICMPD
icmpd|5813|udp|ICMPD
wherehoo|5859|tcp|WHEREHOO
wherehoo|5859|udp|WHEREHOO
mppolicy-v5|5968|tcp|mppolicy-v5
mppolicy-v5|5968|udp|mppolicy-v5
mppolicy-mgr|5969|tcp|mppolicy-mgr
mppolicy-mgr|5969|udp|mppolicy-mgr
wbem-rmi|5987|tcp|WBEM RMI
wbem-rmi|5987|udp|WBEM RMI
wbem-http|5988|tcp|WBEM HTTP
wbem-http|5988|udp|WBEM HTTP
wbem-https|5989|tcp|WBEM HTTPS
wbem-https|5989|udp|WBEM HTTPS
nuxsl|5991|tcp|NUXSL
nuxsl|5991|udp|NUXSL
cvsup|5999|tcp|CVSup
cvsup|5999|udp|CVSup
x11|6000|tcp|X Window System
x11|6001|tcp|X Window System
x11|6002|tcp|X Window System
x11|6003|tcp|X Window System
x11|6004|tcp|X Window System
x11|6005|tcp|X Window System
x11|6006|tcp|X Window System
x11|6007|tcp|X Window System
x11|6008|tcp|X Window System
x11|6009|tcp|X Window System
x11|6010|tcp|X Window System
x11|6011|tcp|X Window System
x11|6012|tcp|X Window System
x11|6013|tcp|X Window System
x11|6014|tcp|X Window System
x11|6015|tcp|X Window System
x11|6016|tcp|X Window System
x11|6017|tcp|X Window System
x11|6018|tcp|X Window System
x11|6019|tcp|X Window System
x11|6020|tcp|X Window System
x11|6021|tcp|X Window System
x11|6022|tcp|X Window System
x11|6023|tcp|X Window System
x11|6024|tcp|X Window System
x11|6025|tcp|X Window System
x11|6026|tcp|X Window System
x11|6027|tcp|X Window System
x11|6028|tcp|X Window System
x11|6029|tcp|X Window System
x11|6030|tcp|X Window System
x11|6031|tcp|X Window System
x11|6032|tcp|X Window System
x11|6033|tcp|X Window System
x11|6034|tcp|X Window System
x11|6035|tcp|X Window System
x11|6036|tcp|X Window System
x11|6037|tcp|X Window System
x11|6038|tcp|X Window System
x11|6039|tcp|X Window System
x11|6040|tcp|X Window System
x11|6041|tcp|X Window System
x11|6042|tcp|X Window System
x11|6043|tcp|X Window System
x11|6044|tcp|X Window System
x11|6045|tcp|X Window System
x11|6046|tcp|X Window System
x11|6047|tcp|X Window System
x11|6048|tcp|X Window System
x11|6049|tcp|X Window System
x11|6050|tcp|X Window System
x11|6051|tcp|X Window System
x11|6052|tcp|X Window System
x11|6053|tcp|X Window System
x11|6054|tcp|X Window System
x11|6055|tcp|X Window System
x11|6056|tcp|X Window System
x11|6057|tcp|X Window System
x11|6058|tcp|X Window System
x11|6059|tcp|X Window System
x11|6060|tcp|X Window System
x11|6061|tcp|X Window System
x11|6062|tcp|X Window System
x11|6063|tcp|X Window System
x11|6000|udp|X Window System
x11|6001|udp|X Window System
x11|6002|udp|X Window System
x11|6003|udp|X Window System
x11|6004|udp|X Window System
x11|6005|udp|X Window System
x11|6006|udp|X Window System
x11|6007|udp|X Window System
x11|6008|udp|X Window System
x11|6009|udp|X Window System
x11|6010|udp|X Window System
x11|6011|udp|X Window System
x11|6012|udp|X Window System
x11|6013|udp|X Window System
x11|6014|udp|X Window System
x11|6015|udp|X Window System
x11|6016|udp|X Window System
x11|6017|udp|X Window System
x11|6018|udp|X Window System
x11|6019|udp|X Window System
x11|6020|udp|X Window System
x11|6021|udp|X Window System
x11|6022|udp|X Window System
x11|6023|udp|X Window System
x11|6024|udp|X Window System
x11|6025|udp|X Window System
x11|6026|udp|X Window System
x11|6027|udp|X Window System
x11|6028|udp|X Window System
x11|6029|udp|X Window System
x11|6030|udp|X Window System
x11|6031|udp|X Window System
x11|6032|udp|X Window System
x11|6033|udp|X Window System
x11|6034|udp|X Window System
x11|6035|udp|X Window System
x11|6036|udp|X Window System
x11|6037|udp|X Window System
x11|6038|udp|X Window System
x11|6039|udp|X Window System
x11|6040|udp|X Window System
x11|6041|udp|X Window System
x11|6042|udp|X Window System
x11|6043|udp|X Window System
x11|6044|udp|X Window System
x11|6045|udp|X Window System
x11|6046|udp|X Window System
x11|6047|udp|X Window System
x11|6048|udp|X Window System
x11|6049|udp|X Window System
x11|6050|udp|X Window System
x11|6051|udp|X Window System
x11|6052|udp|X Window System
x11|6053|udp|X Window System
x11|6054|udp|X Window System
x11|6055|udp|X Window System
x11|6056|udp|X Window System
x11|6057|udp|X Window System
x11|6058|udp|X Window System
x11|6059|udp|X Window System
x11|6060|udp|X Window System
x11|6061|udp|X Window System
x11|6062|udp|X Window System
x11|6063|udp|X Window System
ndl-ahp-svc|6064|tcp|NDL-AHP-SVC
ndl-ahp-svc|6064|udp|NDL-AHP-SVC
winpharaoh|6065|tcp|WinPharaoh
winpharaoh|6065|udp|WinPharaoh
ewctsp|6066|tcp|EWCTSP
ewctsp|6066|udp|EWCTSP
srb|6067|tcp|SRB
srb|6067|udp|SRB
gsmp|6068|tcp|GSMP
gsmp|6068|udp|GSMP
trip|6069|tcp|TRIP
trip|6069|udp|TRIP
messageasap|6070|tcp|Messageasap
messageasap|6070|udp|Messageasap
ssdtp|6071|tcp|SSDTP
ssdtp|6071|udp|SSDTP
diagnose-proc|6072|tcp|DIAGNOSE-PROC
diagnose-proc|6072|udp|DIAGNOSE-PROC
directplay8|6073|tcp|DirectPlay8
directplay8|6073|udp|DirectPlay8
konspire2b|6085|tcp|konspire2b p2p network
konspire2b|6085|udp|konspire2b p2p network
synchronet-db|6100|tcp|SynchroNet-db
synchronet-db|6100|udp|SynchroNet-db
synchronet-rtc|6101|tcp|SynchroNet-rtc
synchronet-rtc|6101|udp|SynchroNet-rtc
synchronet-upd|6102|tcp|SynchroNet-upd
synchronet-upd|6102|udp|SynchroNet-upd
rets|6103|tcp|RETS
rets|6103|udp|RETS
dbdb|6104|tcp|DBDB
dbdb|6104|udp|DBDB
primaserver|6105|tcp|Prima Server
primaserver|6105|udp|Prima Server
mpsserver|6106|tcp|MPS Server
mpsserver|6106|udp|MPS Server
etc-control|6107|tcp|ETC Control
etc-control|6107|udp|ETC Control
sercomm-scadmin|6108|tcp|Sercomm-SCAdmin
sercomm-scadmin|6108|udp|Sercomm-SCAdmin
globecast-id|6109|tcp|GLOBECAST-ID
globecast-id|6109|udp|GLOBECAST-ID
softcm|6110|tcp|HP SoftBench CM
softcm|6110|udp|HP SoftBench CM
spc|6111|tcp|HP SoftBench Sub-Process Control
spc|6111|udp|HP SoftBench Sub-Process Control
dtspcd|6112|tcp|dtspcd
dtspcd|6112|udp|dtspcd
backup-express|6123|tcp|Backup Express
backup-express|6123|udp|Backup Express
meta-corp|6141|tcp|Meta Corporation License Manager
meta-corp|6141|udp|Meta Corporation License Manager
aspentec-lm|6142|tcp|Aspen Technology License Manager
aspentec-lm|6142|udp|Aspen Technology License Manager
watershed-lm|6143|tcp|Watershed License Manager
watershed-lm|6143|udp|Watershed License Manager
statsci1-lm|6144|tcp|StatSci License Manager - 1
statsci1-lm|6144|udp|StatSci License Manager - 1
statsci2-lm|6145|tcp|StatSci License Manager - 2
statsci2-lm|6145|udp|StatSci License Manager - 2
lonewolf-lm|6146|tcp|Lone Wolf Systems License Manager
lonewolf-lm|6146|udp|Lone Wolf Systems License Manager
montage-lm|6147|tcp|Montage License Manager
montage-lm|6147|udp|Montage License Manager
ricardo-lm|6148|tcp|Ricardo North America License Manager
ricardo-lm|6148|udp|Ricardo North America License Manager
tal-pod|6149|tcp|tal-pod
tal-pod|6149|udp|tal-pod
crip|6253|tcp|CRIP
crip|6253|udp|CRIP
bmc-grx|6300|tcp|BMC GRX
bmc-grx|6300|udp|BMC GRX
emp-server1|6321|tcp|Empress Software Connectivity Server 1
emp-server1|6321|udp|Empress Software Connectivity Server 1
emp-server2|6322|tcp|Empress Software Connectivity Server 2
emp-server2|6322|udp|Empress Software Connectivity Server 2
gnutella-svc|6346|tcp|gnutella-svc
gnutella-svc|6346|udp|gnutella-svc
gnutella-rtr|6347|tcp|gnutella-rtr
gnutella-rtr|6347|udp|gnutella-rtr
metatude-mds|6382|tcp|Metatude Dialogue Server
metatude-mds|6382|udp|Metatude Dialogue Server
clariion-evr01|6389|tcp|clariion-evr01
clariion-evr01|6389|udp|clariion-evr01
skip-cert-recv|6455|tcp|SKIP Certificate Receive
skip-cert-send|6456|tcp|SKIP Certificate Send
lvision-lm|6471|tcp|LVision License Manager
lvision-lm|6471|udp|LVision License Manager
boks|6500|tcp|BoKS Master
boks|6500|udp|BoKS Master
boks_servc|6501|tcp|BoKS Servc
boks_servc|6501|udp|BoKS Servc
boks_servm|6502|tcp|BoKS Servm
boks_servm|6502|udp|BoKS Servm
boks_clntd|6503|tcp|BoKS Clntd
boks_clntd|6503|udp|BoKS Clntd
badm_priv|6505|tcp|BoKS Admin Private Port
badm_priv|6505|udp|BoKS Admin Private Port
badm_pub|6506|tcp|BoKS Admin Public Port
badm_pub|6506|udp|BoKS Admin Public Port
bdir_priv|6507|tcp|BoKS Dir Server, Private Port
bdir_priv|6507|udp|BoKS Dir Server, Private Port
bdir_pub|6508|tcp|BoKS Dir Server, Public Port
bdir_pub|6508|udp|BoKS Dir Server, Public Port
mgcs-mfp-port|6509|tcp|MGCS-MFP Port
mgcs-mfp-port|6509|udp|MGCS-MFP Port
mcer-port|6510|tcp|MCER Port
mcer-port|6510|udp|MCER Port
apc-6547|6547|tcp|APC 6547
apc-6547|6547|udp|APC 6547
apc-6548|6548|tcp|APC 6548
apc-6548|6548|udp|APC 6548
apc-6549|6549|tcp|APC 6549
apc-6549|6549|udp|APC 6549
fg-sysupdate|6550|tcp|fg-sysupdate
fg-sysupdate|6550|udp|fg-sysupdate
xdsxdm|6558|tcp|xdsxdm
xdsxdm|6558|udp|xdsxdm
sane-port|6566|tcp|SANE Control Port
sane-port|6566|udp|SANE Control Port
parsec-master|6580|tcp|Parsec Masterserver
parsec-master|6580|udp|Parsec Masterserver
parsec-peer|6581|tcp|Parsec Peer-to-Peer
parsec-peer|6581|udp|Parsec Peer-to-Peer
parsec-game|6582|tcp|Parsec Gameserver
parsec-game|6582|udp|Parsec Gameserver
afesc-mc|6628|tcp|AFE Stock Channel M/C
afesc-mc|6628|udp|AFE Stock Channel M/C
mach|6631|tcp|Mitchell telecom host
mach|6631|udp|Mitchell telecom host
ircu|6665|tcp|IRCU
ircu|6666|tcp|IRCU
ircu|6667|tcp|IRCU
ircu|6668|tcp|IRCU
ircu|6669|tcp|IRCU
ircu|6665|udp|IRCU
ircu|6666|udp|IRCU
ircu|6667|udp|IRCU
ircu|6668|udp|IRCU
ircu|6669|udp|IRCU
vocaltec-gold|6670|tcp|Vocaltec Global Online Directory
vocaltec-gold|6670|udp|Vocaltec Global Online Directory
vision_server|6672|tcp|vision_server
vision_server|6672|udp|vision_server
vision_elmd|6673|tcp|vision_elmd
vision_elmd|6673|udp|vision_elmd
kti-icad-srvr|6701|tcp|KTI/ICAD Nameserver
kti-icad-srvr|6701|udp|KTI/ICAD Nameserver
ibprotocol|6714|tcp|Internet Backplane Protocol
ibprotocol|6714|udp|Internet Backplane Protocol
bmc-perf-agent|6767|tcp|BMC PERFORM AGENT
bmc-perf-agent|6767|udp|BMC PERFORM AGENT
bmc-perf-mgrd|6768|tcp|BMC PERFORM MGRD
bmc-perf-mgrd|6768|udp|BMC PERFORM MGRD
smc-http|6788|tcp|SMC-HTTP
smc-http|6788|udp|SMC-HTTP
smc-https|6789|tcp|SMC-HTTPS
smc-https|6789|udp|SMC-HTTPS
hnmp|6790|tcp|HNMP
hnmp|6790|udp|HNMP
ambit-lm|6831|tcp|ambit-lm
ambit-lm|6831|udp|ambit-lm
netmo-default|6841|tcp|Netmo Default
netmo-default|6841|udp|Netmo Default
netmo-http|6842|tcp|Netmo HTTP
netmo-http|6842|udp|Netmo HTTP
iccrushmore|6850|tcp|ICCRUSHMORE
iccrushmore|6850|udp|ICCRUSHMORE
muse|6888|tcp|MUSE
muse|6888|udp|MUSE
jmact3|6961|tcp|JMACT3
jmact3|6961|udp|JMACT3
jmevt2|6962|tcp|jmevt2
jmevt2|6962|udp|jmevt2
swismgr1|6963|tcp|swismgr1
swismgr1|6963|udp|swismgr1
swismgr2|6964|tcp|swismgr2
swismgr2|6964|udp|swismgr2
swistrap|6965|tcp|swistrap
swistrap|6965|udp|swistrap
swispol|6966|tcp|swispol
swispol|6966|udp|swispol
acmsoda|6969|tcp|acmsoda
acmsoda|6969|udp|acmsoda
iatp-highpri|6998|tcp|IATP-highPri
iatp-highpri|6998|udp|IATP-highPri
iatp-normalpri|6999|tcp|IATP-normalPri
iatp-normalpri|6999|udp|IATP-normalPri
afs3-fileserver|7000|tcp|file server itself
afs3-fileserver|7000|udp|file server itself
afs3-callback|7001|tcp|callbacks to cache managers
afs3-callback|7001|udp|callbacks to cache managers
afs3-prserver|7002|tcp|users & groups database
afs3-prserver|7002|udp|users & groups database
afs3-vlserver|7003|tcp|volume location database
afs3-vlserver|7003|udp|volume location database
afs3-kaserver|7004|tcp|AFS/Kerberos authentication service
afs3-kaserver|7004|udp|AFS/Kerberos authentication service
afs3-volser|7005|tcp|volume managment server
afs3-volser|7005|udp|volume managment server
afs3-errors|7006|tcp|error interpretation service
afs3-errors|7006|udp|error interpretation service
afs3-bos|7007|tcp|basic overseer process
afs3-bos|7007|udp|basic overseer process
afs3-update|7008|tcp|server-to-server updater
afs3-update|7008|udp|server-to-server updater
afs3-rmtsys|7009|tcp|remote cache manager service
afs3-rmtsys|7009|udp|remote cache manager service
ups-onlinet|7010|tcp|onlinet uninterruptable power supplies
ups-onlinet|7010|udp|onlinet uninterruptable power supplies
talon-disc|7011|tcp|Talon Discovery Port
talon-disc|7011|udp|Talon Discovery Port
talon-engine|7012|tcp|Talon Engine
talon-engine|7012|udp|Talon Engine
microtalon-dis|7013|tcp|Microtalon Discovery
microtalon-dis|7013|udp|Microtalon Discovery
microtalon-com|7014|tcp|Microtalon Communications
microtalon-com|7014|udp|Microtalon Communications
talon-webserver|7015|tcp|Talon Webserver
talon-webserver|7015|udp|Talon Webserver
dpserve|7020|tcp|DP Serve
dpserve|7020|udp|DP Serve
dpserveadmin|7021|tcp|DP Serve Admin
dpserveadmin|7021|udp|DP Serve Admin
op-probe|7030|tcp|ObjectPlanet probe
op-probe|7030|udp|ObjectPlanet probe
arcp|7070|tcp|ARCP
arcp|7070|udp|ARCP
lazy-ptop|7099|tcp|lazy-ptop
lazy-ptop|7099|udp|lazy-ptop
font-service|7100|tcp|X Font Service
font-service|7100|udp|X Font Service
virprot-lm|7121|tcp|Virtual Prototypes License Manager
virprot-lm|7121|udp|Virtual Prototypes License Manager
clutild|7174|tcp|Clutild
clutild|7174|udp|Clutild
fodms|7200|tcp|FODMS FLIP
fodms|7200|udp|FODMS FLIP
dlip|7201|tcp|DLIP
dlip|7201|udp|DLIP
itactionserver1|7280|tcp|ITACTIONSERVER 1
itactionserver1|7280|udp|ITACTIONSERVER 1
itactionserver2|7281|tcp|ITACTIONSERVER 2
itactionserver2|7281|udp|ITACTIONSERVER 2
mindfilesys|7391|tcp|mind-file system server
mindfilesys|7391|udp|mind-file system server
mrssrendezvous|7392|tcp|mrss-rendezvous server
mrssrendezvous|7392|udp|mrss-rendezvous server
winqedit|7395|tcp|winqedit
winqedit|7395|udp|winqedit
pmdmgr|7426|tcp|OpenView DM Postmaster Manager
pmdmgr|7426|udp|OpenView DM Postmaster Manager
oveadmgr|7427|tcp|OpenView DM Event Agent Manager
oveadmgr|7427|udp|OpenView DM Event Agent Manager
ovladmgr|7428|tcp|OpenView DM Log Agent Manager
ovladmgr|7428|udp|OpenView DM Log Agent Manager
opi-sock|7429|tcp|OpenView DM rqt communication
opi-sock|7429|udp|OpenView DM rqt communication
xmpv7|7430|tcp|OpenView DM xmpv7 api pipe
xmpv7|7430|udp|OpenView DM xmpv7 api pipe
pmd|7431|tcp|OpenView DM ovc/xmpv3 api pipe
pmd|7431|udp|OpenView DM ovc/xmpv3 api pipe
faximum|7437|tcp|Faximum
faximum|7437|udp|Faximum
telops-lmd|7491|tcp|telops-lmd
telops-lmd|7491|udp|telops-lmd
ovbus|7501|tcp|HP OpenView Bus Daemon
ovbus|7501|udp|HP OpenView Bus Daemon
ovhpas|7510|tcp|HP OpenView Application Server
ovhpas|7510|udp|HP OpenView Application Server
pafec-lm|7511|tcp|pafec-lm
pafec-lm|7511|udp|pafec-lm
nta-ds|7544|tcp|FlowAnalyzer DisplayServer
nta-ds|7544|udp|FlowAnalyzer DisplayServer
nta-us|7545|tcp|FlowAnalyzer UtilityServer
nta-us|7545|udp|FlowAnalyzer UtilityServer
vsi-omega|7566|tcp|VSI Omega
vsi-omega|7566|udp|VSI Omega
aries-kfinder|7570|tcp|Aries Kfinder
aries-kfinder|7570|udp|Aries Kfinder
sun-lm|7588|tcp|Sun License Manager
sun-lm|7588|udp|Sun License Manager
indi|7624|tcp|Instrument Neutral Distributed Interface
indi|7624|udp|Instrument Neutral Distributed Interface
pmdfmgt|7633|tcp|PMDF Management
pmdfmgt|7633|udp|PMDF Management
imqtunnels|7674|tcp|iMQ SSL tunnel
imqtunnels|7674|udp|iMQ SSL tunnel
imqtunnel|7675|tcp|iMQ Tunnel
imqtunnel|7675|udp|iMQ Tunnel
imqbrokerd|7676|tcp|iMQ Broker Rendezvous
imqbrokerd|7676|udp|iMQ Broker Rendezvous
sstp-1|7743|tcp|Sakura Script Transfer Protocol
sstp-1|7743|udp|Sakura Script Transfer Protocol
cbt|7777|tcp|cbt
cbt|7777|udp|cbt
interwise|7778|tcp|Interwise
interwise|7778|udp|Interwise
vstat|7779|tcp|VSTAT
vstat|7779|udp|VSTAT
accu-lmgr|7781|tcp|accu-lmgr
accu-lmgr|7781|udp|accu-lmgr
minivend|7786|tcp|MINIVEND
minivend|7786|udp|MINIVEND
pnet-conn|7797|tcp|Propel Connector port
pnet-conn|7797|udp|Propel Connector port
pnet-enc|7798|tcp|Propel Encoder port
pnet-enc|7798|udp|Propel Encoder port
apc-7845|7845|tcp|APC 7845
apc-7845|7845|udp|APC 7845
apc-7846|7846|tcp|APC 7846
apc-7846|7846|udp|APC 7846
qo-secure|7913|tcp|QuickObjects secure port
qo-secure|7913|udp|QuickObjects secure port
t2-drm|7932|tcp|Tier 2 Data Resource Manager
t2-drm|7932|udp|Tier 2 Data Resource Manager
t2-brm|7933|tcp|Tier 2 Business Rules Manager
t2-brm|7933|udp|Tier 2 Business Rules Manager
supercell|7967|tcp|Supercell
supercell|7967|udp|Supercell
micromuse-ncps|7979|tcp|Micromuse-ncps
micromuse-ncps|7979|udp|Micromuse-ncps
quest-vista|7980|tcp|Quest Vista
quest-vista|7980|udp|Quest Vista
irdmi2|7999|tcp|iRDMI2
irdmi2|7999|udp|iRDMI2
irdmi|8000|tcp|iRDMI
irdmi|8000|udp|iRDMI
vcom-tunnel|8001|tcp|VCOM Tunnel
vcom-tunnel|8001|udp|VCOM Tunnel
teradataordbms|8002|tcp|Teradata ORDBMS
teradataordbms|8002|udp|Teradata ORDBMS
http-alt|8008|tcp|HTTP Alternate
http-alt|8008|udp|HTTP Alternate
oa-system|8022|tcp|oa-system
oa-system|8022|udp|oa-system
pro-ed|8032|tcp|ProEd
pro-ed|8032|udp|ProEd
mindprint|8033|tcp|MindPrint
mindprint|8033|udp|MindPrint
http-alt|8080|tcp|HTTP Alternate (see port 80)
http-alt|8080|udp|HTTP Alternate (see port 80)
radan-http|8088|tcp|Radan HTTP
radan-http|8088|udp|Radan HTTP
xprint-server|8100|tcp|Xprint Server
xprint-server|8100|udp|Xprint Server
mtl8000-matrix|8115|tcp|MTL8000 Matrix
mtl8000-matrix|8115|udp|MTL8000 Matrix
cp-cluster|8116|tcp|Check Point Clustering
cp-cluster|8116|udp|Check Point Clustering
privoxy|8118|tcp|Privoxy HTTP proxy
privoxy|8118|udp|Privoxy HTTP proxy
indigo-vrmi|8130|tcp|INDIGO-VRMI
indigo-vrmi|8130|udp|INDIGO-VRMI
indigo-vbcp|8131|tcp|INDIGO-VBCP
indigo-vbcp|8131|udp|INDIGO-VBCP
dbabble|8132|tcp|dbabble
dbabble|8132|udp|dbabble
patrol|8160|tcp|Patrol
patrol|8160|udp|Patrol
patrol-snmp|8161|tcp|Patrol SNMP
patrol-snmp|8161|udp|Patrol SNMP
vvr-data|8199|tcp|VVR DATA
vvr-data|8199|udp|VVR DATA
trivnet1|8200|tcp|TRIVNET
trivnet1|8200|udp|TRIVNET
trivnet2|8201|tcp|TRIVNET
trivnet2|8201|udp|TRIVNET
lm-perfworks|8204|tcp|LM Perfworks
lm-perfworks|8204|udp|LM Perfworks
lm-instmgr|8205|tcp|LM Instmgr
lm-instmgr|8205|udp|LM Instmgr
lm-dta|8206|tcp|LM Dta
lm-dta|8206|udp|LM Dta
lm-sserver|8207|tcp|LM SServer
lm-sserver|8207|udp|LM SServer
lm-webwatcher|8208|tcp|LM Webwatcher
lm-webwatcher|8208|udp|LM Webwatcher
server-find|8351|tcp|Server Find
server-find|8351|udp|Server Find
cruise-enum|8376|tcp|Cruise ENUM
cruise-enum|8376|udp|Cruise ENUM
cruise-swroute|8377|tcp|Cruise SWROUTE
cruise-swroute|8377|udp|Cruise SWROUTE
cruise-config|8378|tcp|Cruise CONFIG
cruise-config|8378|udp|Cruise CONFIG
cruise-diags|8379|tcp|Cruise DIAGS
cruise-diags|8379|udp|Cruise DIAGS
cruise-update|8380|tcp|Cruise UPDATE
cruise-update|8380|udp|Cruise UPDATE
cvd|8400|tcp|cvd
cvd|8400|udp|cvd
sabarsd|8401|tcp|sabarsd
sabarsd|8401|udp|sabarsd
abarsd|8402|tcp|abarsd
abarsd|8402|udp|abarsd
admind|8403|tcp|admind
admind|8403|udp|admind
espeech|8416|tcp|eSpeech Session Protocol
espeech|8416|udp|eSpeech Session Protocol
espeech-rtp|8417|tcp|eSpeech RTP Protocol
espeech-rtp|8417|udp|eSpeech RTP Protocol
pcsync-https|8443|tcp|PCsync HTTPS
pcsync-https|8443|udp|PCsync HTTPS
pcsync-http|8444|tcp|PCsync HTTP
pcsync-http|8444|udp|PCsync HTTP
npmp|8450|tcp|npmp
npmp|8450|udp|npmp
vp2p|8473|tcp|Virtual Point to Point
vp2p|8473|udp|Virtual Point to Point
rtsp-alt|8554|tcp|RTSP Alternate (see port 554)
rtsp-alt|8554|udp|RTSP Alternate (see port 554)
d-fence|8555|tcp|SYMAX D-FENCE
d-fence|8555|udp|SYMAX D-FENCE
ibus|8733|tcp|iBus
ibus|8733|udp|iBus
mc-appserver|8763|tcp|MC-APPSERVER
mc-appserver|8763|udp|MC-APPSERVER
openqueue|8764|tcp|OPENQUEUE
openqueue|8764|udp|OPENQUEUE
ultraseek-http|8765|tcp|Ultraseek HTTP
ultraseek-http|8765|udp|Ultraseek HTTP
msgclnt|8786|tcp|Message Client
msgclnt|8786|udp|Message Client
msgsrvr|8787|tcp|Message Server
msgsrvr|8787|udp|Message Server
truecm|8804|tcp|truecm
truecm|8804|udp|truecm
cddbp-alt|8880|tcp|CDDBP
cddbp-alt|8880|udp|CDDBP
ddi-tcp-1|8888|tcp|NewsEDGE server TCP (TCP 1)
ddi-udp-1|8888|udp|NewsEDGE server UDP (UDP 1)
ddi-tcp-2|8889|tcp|Desktop Data TCP 1
ddi-udp-2|8889|udp|NewsEDGE server broadcast
ddi-tcp-3|8890|tcp|Desktop Data TCP 2
ddi-udp-3|8890|udp|NewsEDGE client broadcast
ddi-tcp-4|8891|tcp|Desktop Data TCP 3: NESS application
ddi-udp-4|8891|udp|Desktop Data UDP 3: NESS application
ddi-tcp-5|8892|tcp|Desktop Data TCP 4: FARM product
ddi-udp-5|8892|udp|Desktop Data UDP 4: FARM product
ddi-tcp-6|8893|tcp|Desktop Data TCP 5: NewsEDGE/Web application
ddi-udp-6|8893|udp|Desktop Data UDP 5: NewsEDGE/Web application
ddi-tcp-7|8894|tcp|Desktop Data TCP 6: COAL application
ddi-udp-7|8894|udp|Desktop Data UDP 6: COAL application
jmb-cds1|8900|tcp|JMB-CDS 1
jmb-cds1|8900|udp|JMB-CDS 1
jmb-cds2|8901|tcp|JMB-CDS 2
jmb-cds2|8901|udp|JMB-CDS 2
manyone-http|8910|tcp|manyone-http
manyone-http|8910|udp|manyone-http
manyone-xml|8911|tcp|manyone-xml
manyone-xml|8911|udp|manyone-xml
cumulus-admin|8954|tcp|Cumulus Admin Port
cumulus-admin|8954|udp|Cumulus Admin Port
bctp|8999|tcp|Brodos Crypto Trade Protocol
bctp|8999|udp|Brodos Crypto Trade Protocol
cslistener|9000|tcp|CSlistener
cslistener|9000|udp|CSlistener
etlservicemgr|9001|tcp|ETL Service Manager
etlservicemgr|9001|udp|ETL Service Manager
dynamid|9002|tcp|DynamID authentication
dynamid|9002|udp|DynamID authentication
tambora|9020|tcp|TAMBORA
tambora|9020|udp|TAMBORA
panagolin-ident|9021|tcp|Pangolin Identification
panagolin-ident|9021|udp|Pangolin Identification
paragent|9022|tcp|PrivateArk Remote Agent
paragent|9022|udp|PrivateArk Remote Agent
swa-1|9023|tcp|Secure Web Access - 1
swa-1|9023|udp|Secure Web Access - 1
swa-2|9024|tcp|Secure Web Access - 2
swa-2|9024|udp|Secure Web Access - 2
swa-3|9025|tcp|Secure Web Access - 3
swa-3|9025|udp|Secure Web Access - 3
swa-4|9026|tcp|Secure Web Access - 4
swa-4|9026|udp|Secure Web Access - 4
glrpc|9080|tcp|Groove GLRPC
glrpc|9080|udp|Groove GLRPC
websm|9090|tcp|WebSM
websm|9090|udp|WebSM
xmltec-xmlmail|9091|tcp|xmltec-xmlmail
xmltec-xmlmail|9091|udp|xmltec-xmlmail
hp-pdl-datastr|9100|tcp|PDL Data Streaming Port
hp-pdl-datastr|9100|udp|PDL Data Streaming Port
pdl-datastream|9100|tcp|Printer PDL Data Stream
pdl-datastream|9100|udp|Printer PDL Data Stream
bacula-dir|9101|tcp|Bacula Director
bacula-dir|9101|udp|Bacula Director
bacula-fd|9102|tcp|Bacula File Daemon
bacula-fd|9102|udp|Bacula File Daemon
bacula-sd|9103|tcp|Bacula Storage Daemon
bacula-sd|9103|udp|Bacula Storage Daemon
netlock1|9160|tcp|NetLOCK1
netlock1|9160|udp|NetLOCK1
netlock2|9161|tcp|NetLOCK2
netlock2|9161|udp|NetLOCK2
netlock3|9162|tcp|NetLOCK3
netlock3|9162|udp|NetLOCK3
netlock4|9163|tcp|NetLOCK4
netlock4|9163|udp|NetLOCK4
netlock5|9164|tcp|NetLOCK5
netlock5|9164|udp|NetLOCK5
wap-wsp|9200|tcp|WAP connectionless session service
wap-wsp|9200|udp|WAP connectionless session service
wap-wsp-wtp|9201|tcp|WAP session service
wap-wsp-wtp|9201|udp|WAP session service
wap-wsp-s|9202|tcp|WAP secure connectionless session service
wap-wsp-s|9202|udp|WAP secure connectionless session service
wap-wsp-wtp-s|9203|tcp|WAP secure session service
wap-wsp-wtp-s|9203|udp|WAP secure session service
wap-vcard|9204|tcp|WAP vCard
wap-vcard|9204|udp|WAP vCard
wap-vcal|9205|tcp|WAP vCal
wap-vcal|9205|udp|WAP vCal
wap-vcard-s|9206|tcp|WAP vCard Secure
wap-vcard-s|9206|udp|WAP vCard Secure
wap-vcal-s|9207|tcp|WAP vCal Secure
wap-vcal-s|9207|udp|WAP vCal Secure
lif-mlp|9210|tcp|LIF Mobile Locn Protocol
lif-mlp|9210|udp|LIF Mobile Locn Protocol
lif-mlp-s|9211|tcp|LIF Mobile Locn Secure
lif-mlp-s|9211|udp|LIF Mobile Locn Secure
fsc-port|9217|tcp|FSC Communication Port
fsc-port|9217|udp|FSC Communication Port
swtp-port1|9281|tcp|SofaWare transport port 1
swtp-port1|9281|udp|SofaWare transport port 1
swtp-port2|9282|tcp|SofaWare transport port 2
swtp-port2|9282|udp|SofaWare transport port 2
callwaveiam|9283|tcp|CallWaveIAM
callwaveiam|9283|udp|CallWaveIAM
visd|9284|tcp|VERITAS Information Serve
visd|9284|udp|VERITAS Information Serve
n2h2server|9285|tcp|N2H2 Filter Service Port
n2h2server|9285|udp|N2H2 Filter Service Port
cumulus|9287|tcp|Cumulus
cumulus|9287|udp|Cumulus
armtechdaemon|9292|tcp|ArmTech Daemon
armtechdaemon|9292|udp|ArmTech Daemon
guibase|9321|tcp|guibase
guibase|9321|udp|guibase
mpidcmgr|9343|tcp|MpIdcMgr
mpidcmgr|9343|udp|MpIdcMgr
mphlpdmc|9344|tcp|Mphlpdmc
mphlpdmc|9344|udp|Mphlpdmc
ctechlicensing|9346|tcp|C Tech Licensing
ctechlicensing|9346|udp|C Tech Licensing
fjdmimgr|9374|tcp|fjdmimgr
fjdmimgr|9374|udp|fjdmimgr
fjinvmgr|9396|tcp|fjinvmgr
fjinvmgr|9396|udp|fjinvmgr
mpidcagt|9397|tcp|MpIdcAgt
mpidcagt|9397|udp|MpIdcAgt
ismserver|9500|tcp|ismserver
ismserver|9500|udp|ismserver
mngsuite|9535|tcp|Management Suite Remote Control
mngsuite|9535|udp|Management Suite Remote Control
msgsys|9594|tcp|Message System
msgsys|9594|udp|Message System
pds|9595|tcp|Ping Discovery Service
pds|9595|udp|Ping Discovery Service
micromuse-ncpw|9600|tcp|MICROMUSE-NCPW
micromuse-ncpw|9600|udp|MICROMUSE-NCPW
streamcomm-ds|9612|tcp|StreamComm User Directory
streamcomm-ds|9612|udp|StreamComm User Directory
l5nas-parchan|9747|tcp|L5NAS Parallel Channel
l5nas-parchan|9747|udp|L5NAS Parallel Channel
rasadv|9753|tcp|rasadv
rasadv|9753|udp|rasadv
davsrc|9800|tcp|WebDav Source Port
davsrc|9800|udp|WebDav Source Port
sstp-2|9801|tcp|Sakura Script Transfer Protocol-2
sstp-2|9801|udp|Sakura Script Transfer Protocol-2
sapv1|9875|tcp|Session Announcement v1
sapv1|9875|udp|Session Announcement v1
sd|9876|tcp|Session Director
sd|9876|udp|Session Director
cyborg-systems|9888|tcp|CYBORG Systems
cyborg-systems|9888|udp|CYBORG Systems
monkeycom|9898|tcp|MonkeyCom
monkeycom|9898|udp|MonkeyCom
sctp-tunneling|9899|tcp|SCTP TUNNELING
sctp-tunneling|9899|udp|SCTP TUNNELING
iua|9900|tcp|IUA
iua|9900|udp|IUA
iua|9900|sctp|IUA
domaintime|9909|tcp|domaintime
domaintime|9909|udp|domaintime
sype-transport|9911|tcp|SYPECom Transport Protocol
sype-transport|9911|udp|SYPECom Transport Protocol
apc-9950|9950|tcp|APC 9950
apc-9950|9950|udp|APC 9950
apc-9951|9951|tcp|APC 9951
apc-9951|9951|udp|APC 9951
apc-9952|9952|tcp|APC 9952
apc-9952|9952|udp|APC 9952
palace-1|9992|tcp|OnLive-1
palace-1|9992|udp|OnLive-1
palace-2|9993|tcp|OnLive-2
palace-2|9993|udp|OnLive-2
palace-3|9994|tcp|OnLive-3
palace-3|9994|udp|OnLive-3
palace-4|9995|tcp|Palace-4
palace-4|9995|udp|Palace-4
palace-5|9996|tcp|Palace-5
palace-5|9996|udp|Palace-5
palace-6|9997|tcp|Palace-6
palace-6|9997|udp|Palace-6
distinct32|9998|tcp|Distinct32
distinct32|9998|udp|Distinct32
distinct|9999|tcp|distinct
distinct|9999|udp|distinct
ndmp|10000|tcp|Network Data Management Protocol
ndmp|10000|udp|Network Data Management Protocol
scp-config|10001|tcp|SCP Configuration Port
scp-config|10001|udp|SCP Configuration Port
mvs-capacity|10007|tcp|MVS Capacity
mvs-capacity|10007|udp|MVS Capacity
octopus|10008|tcp|Octopus Multiplexer
octopus|10008|udp|Octopus Multiplexer
amanda|10080|tcp|Amanda
amanda|10080|udp|Amanda
ezmeeting-2|10101|tcp|eZmeeting
ezmeeting-2|10101|udp|eZmeeting
ezproxy-2|10102|tcp|eZproxy
ezproxy-2|10102|udp|eZproxy
ezrelay|10103|tcp|eZrelay
ezrelay|10103|udp|eZrelay
netiq-endpoint|10113|tcp|NetIQ Endpoint
netiq-endpoint|10113|udp|NetIQ Endpoint
netiq-qcheck|10114|tcp|NetIQ Qcheck
netiq-qcheck|10114|udp|NetIQ Qcheck
netiq-endpt|10115|tcp|NetIQ Endpoint
netiq-endpt|10115|udp|NetIQ Endpoint
netiq-voipa|10116|tcp|NetIQ VoIP Assessor
netiq-voipa|10116|udp|NetIQ VoIP Assessor
bmc-perf-sd|10128|tcp|BMC-PERFORM-SERVICE DAEMON
bmc-perf-sd|10128|udp|BMC-PERFORM-SERVICE DAEMON
axis-wimp-port|10260|tcp|Axis WIMP Port
axis-wimp-port|10260|udp|Axis WIMP Port
blocks|10288|tcp|Blocks
blocks|10288|udp|Blocks
rmiaux|10990|tcp|Auxiliary RMI Port
rmiaux|10990|udp|Auxiliary RMI Port
irisa|11000|tcp|IRISA
irisa|11000|udp|IRISA
metasys|11001|tcp|Metasys
metasys|11001|udp|Metasys
vce|11111|tcp|Viral Computing Environment (VCE)
vce|11111|udp|Viral Computing Environment (VCE)
smsqp|11201|tcp|smsqp
smsqp|11201|udp|smsqp
imip|11319|tcp|IMIP
imip|11319|udp|IMIP
imip-channels|11320|tcp|IMIP Channels Port
imip-channels|11320|udp|IMIP Channels Port
arena-server|11321|tcp|Arena Server Listen
arena-server|11321|udp|Arena Server Listen
atm-uhas|11367|tcp|ATM UHAS
atm-uhas|11367|udp|ATM UHAS
hkp|11371|tcp|OpenPGP HTTP Keyserver
hkp|11371|udp|OpenPGP HTTP Keyserver
tempest-port|11600|tcp|Tempest Protocol Port
tempest-port|11600|udp|Tempest Protocol Port
h323callsigalt|11720|tcp|h323 Call Signal Alternate
h323callsigalt|11720|udp|h323 Call Signal Alternate
intrepid-ssl|11751|tcp|Intrepid SSL
intrepid-ssl|11751|udp|Intrepid SSL
sysinfo-sp|11967|tcp|SysInfo Service Protocol
sysinfo-sp|11967|udp|SysInfo Sercice Protocol
entextxid|12000|tcp|IBM Enterprise Extender SNA XID Exchange
entextxid|12000|udp|IBM Enterprise Extender SNA XID Exchange
entextnetwk|12001|tcp|IBM Enterprise Extender SNA COS Network Priority
entextnetwk|12001|udp|IBM Enterprise Extender SNA COS Network Priority
entexthigh|12002|tcp|IBM Enterprise Extender SNA COS High Priority
entexthigh|12002|udp|IBM Enterprise Extender SNA COS High Priority
entextmed|12003|tcp|IBM Enterprise Extender SNA COS Medium Priority
entextmed|12003|udp|IBM Enterprise Extender SNA COS Medium Priority
entextlow|12004|tcp|IBM Enterprise Extender SNA COS Low Priority
entextlow|12004|udp|IBM Enterprise Extender SNA COS Low Priority
dbisamserver1|12005|tcp|DBISAM Database Server - Regular
dbisamserver1|12005|udp|DBISAM Database Server - Regular
dbisamserver2|12006|tcp|DBISAM Database Server - Admin
dbisamserver2|12006|udp|DBISAM Database Server - Admin
rets-ssl|12109|tcp|RETS over SSL
rets-ssl|12109|udp|RETS over SSL
hivep|12172|tcp|HiveP
hivep|12172|udp|HiveP
italk|12345|tcp|Italk Chat System
italk|12345|udp|Italk Chat System
tsaf|12753|tcp|tsaf port
tsaf|12753|udp|tsaf port
i-zipqd|13160|tcp|I-ZIPQD
i-zipqd|13160|udp|I-ZIPQD
powwow-client|13223|tcp|PowWow Client
powwow-client|13223|udp|PowWow Client
powwow-server|13224|tcp|PowWow Server
powwow-server|13224|udp|PowWow Server
bprd|13720|tcp|BPRD Protocol (VERITAS NetBackup)
bprd|13720|udp|BPRD Protocol (VERITAS NetBackup)
bpdbm|13721|tcp|BPDBM Protocol (VERITAS NetBackup)
bpdbm|13721|udp|BPDBM Protocol (VERITAS NetBackup)
bpjava-msvc|13722|tcp|BP Java MSVC Protocol
bpjava-msvc|13722|udp|BP Java MSVC Protocol
vnetd|13724|tcp|Veritas Network Utility
vnetd|13724|udp|Veritas Network Utility
bpcd|13782|tcp|VERITAS NetBackup
bpcd|13782|udp|VERITAS NetBackup
vopied|13783|tcp|VOPIED Protocol
vopied|13783|udp|VOPIED Protocol
dsmcc-config|13818|tcp|DSMCC Config
dsmcc-config|13818|udp|DSMCC Config
dsmcc-session|13819|tcp|DSMCC Session Messages
dsmcc-session|13819|udp|DSMCC Session Messages
dsmcc-passthru|13820|tcp|DSMCC Pass-Thru Messages
dsmcc-passthru|13820|udp|DSMCC Pass-Thru Messages
dsmcc-download|13821|tcp|DSMCC Download Protocol
dsmcc-download|13821|udp|DSMCC Download Protocol
dsmcc-ccp|13822|tcp|DSMCC Channel Change Protocol
dsmcc-ccp|13822|udp|DSMCC Channel Change Protocol
sua|14001|tcp|SUA
sua|14001|udp|De-Registered (2001 June 06)
sua|14001|sctp|SUA
sage-best-com1|14033|tcp|sage Best! Config Server 1
sage-best-com1|14033|udp|sage Best! Config Server 1
sage-best-com2|14034|tcp|sage Best! Config Server 2
sage-best-com2|14034|udp|sage Best! Config Server 2
vcs-app|14141|tcp|VCS Application
vcs-app|14141|udp|VCS Application
gcm-app|14145|tcp|GCM Application
gcm-app|14145|udp|GCM Application
vrts-tdd|14149|tcp|Veritas Traffic Director
vrts-tdd|14149|udp|Veritas Traffic Director
hde-lcesrvr-1|14936|tcp|hde-lcesrvr-1
hde-lcesrvr-1|14936|udp|hde-lcesrvr-1
hde-lcesrvr-2|14937|tcp|hde-lcesrvr-2
hde-lcesrvr-2|14937|udp|hde-lcesrvr-2
hydap|15000|tcp|Hypack Data Aquisition
hydap|15000|udp|Hypack Data Aquisition
xpilot|15345|tcp|XPilot Contact Port
xpilot|15345|udp|XPilot Contact Port
3link|15363|tcp|3Link Negotiation
3link|15363|udp|3Link Negotiation
netserialext1|16360|tcp|netserialext1
netserialext1|16360|udp|netserialext1
netserialext2|16361|tcp|netserialext2
netserialext2|16361|udp|netserialext2
netserialext3|16367|tcp|netserialext3
netserialext3|16367|udp|netserialext3
netserialext4|16368|tcp|netserialext4
netserialext4|16368|udp|netserialext4
intel-rci-mp|16991|tcp|INTEL-RCI-MP
intel-rci-mp|16991|udp|INTEL-RCI-MP
isode-dua|17007|tcp|isode-dua
isode-dua|17007|udp|isode-dua
soundsvirtual|17185|tcp|Sounds Virtual
soundsvirtual|17185|udp|Sounds Virtual
chipper|17219|tcp|Chipper
chipper|17219|udp|Chipper
biimenu|18000|tcp|Beckman Instruments, Inc.
biimenu|18000|udp|Beckman Instruments, Inc.
opsec-cvp|18181|tcp|OPSEC CVP
opsec-cvp|18181|udp|OPSEC CVP
opsec-ufp|18182|tcp|OPSEC UFP
opsec-ufp|18182|udp|OPSEC UFP
opsec-sam|18183|tcp|OPSEC SAM
opsec-sam|18183|udp|OPSEC SAM
opsec-lea|18184|tcp|OPSEC LEA
opsec-lea|18184|udp|OPSEC LEA
opsec-omi|18185|tcp|OPSEC OMI
opsec-omi|18185|udp|OPSEC OMI
opsec-ela|18187|tcp|OPSEC ELA
opsec-ela|18187|udp|OPSEC ELA
checkpoint-rtm|18241|tcp|Check Point RTM
checkpoint-rtm|18241|udp|Check Point RTM
ac-cluster|18463|tcp|AC Cluster
ac-cluster|18463|udp|AC Cluster
ique|18769|tcp|IQue Protocol
ique|18769|udp|IQue Protocol
apc-necmp|18888|tcp|APCNECMP
apc-necmp|18888|udp|APCNECMP
opsec-uaa|19191|tcp|OPSEC UAA
opsec-uaa|19191|udp|OPSEC UAA
ua-secureagent|19194|tcp|UserAuthority SecureAgent
ua-secureagent|19194|udp|UserAuthority SecureAgent
keysrvr|19283|tcp|Key Server for SASSAFRAS
keysrvr|19283|udp|Key Server for SASSAFRAS
keyshadow|19315|tcp|Key Shadow for SASSAFRAS
keyshadow|19315|udp|Key Shadow for SASSAFRAS
mtrgtrans|19398|tcp|mtrgtrans
mtrgtrans|19398|udp|mtrgtrans
hp-sco|19410|tcp|hp-sco
hp-sco|19410|udp|hp-sco
hp-sca|19411|tcp|hp-sca
hp-sca|19411|udp|hp-sca
hp-sessmon|19412|tcp|HP-SESSMON
hp-sessmon|19412|udp|HP-SESSMON
sxuptp|19540|tcp|SXUPTP
sxuptp|19540|udp|SXUPTP
jcp|19541|tcp|JCP Client
jcp|19541|udp|JCP Client
dnp|20000|tcp|DNP
dnp|20000|udp|DNP
ipdtp-port|20202|tcp|IPD Tunneling Port
ipdtp-port|20202|udp|IPD Tunneling Port
ipulse-ics|20222|tcp|iPulse-ICS
ipulse-ics|20222|udp|iPulse-ICS
track|20670|tcp|Track
track|20670|udp|Track
athand-mmp|20999|tcp|At Hand MMP
athand-mmp|20999|udp|AT Hand MMP
vofr-gateway|21590|tcp|VoFR Gateway
vofr-gateway|21590|udp|VoFR Gateway
tvpm|21800|tcp|TVNC Pro Multiplexing
tvpm|21800|udp|TVNC Pro Multiplexing
webphone|21845|tcp|webphone
webphone|21845|udp|webphone
netspeak-is|21846|tcp|NetSpeak Corp. Directory Services
netspeak-is|21846|udp|NetSpeak Corp. Directory Services
netspeak-cs|21847|tcp|NetSpeak Corp. Connection Services
netspeak-cs|21847|udp|NetSpeak Corp. Connection Services
netspeak-acd|21848|tcp|NetSpeak Corp. Automatic Call Distribution
netspeak-acd|21848|udp|NetSpeak Corp. Automatic Call Distribution
netspeak-cps|21849|tcp|NetSpeak Corp. Credit Processing System
netspeak-cps|21849|udp|NetSpeak Corp. Credit Processing System
snapenetio|22000|tcp|SNAPenetIO
snapenetio|22000|udp|SNAPenetIO
optocontrol|22001|tcp|OptoControl
optocontrol|22001|udp|OptoControl
wnn6|22273|tcp|wnn6
wnn6|22273|udp|wnn6
vocaltec-wconf|22555|tcp|Vocaltec Web Conference
vocaltec-phone|22555|udp|Vocaltec Internet Phone
aws-brf|22800|tcp|Telerate Information Platform LAN
aws-brf|22800|udp|Telerate Information Platform LAN
brf-gw|22951|tcp|Telerate Information Platform WAN
brf-gw|22951|udp|Telerate Information Platform WAN
med-ltp|24000|tcp|med-ltp
med-ltp|24000|udp|med-ltp
med-fsp-rx|24001|tcp|med-fsp-rx
med-fsp-rx|24001|udp|med-fsp-rx
med-fsp-tx|24002|tcp|med-fsp-tx
med-fsp-tx|24002|udp|med-fsp-tx
med-supp|24003|tcp|med-supp
med-supp|24003|udp|med-supp
med-ovw|24004|tcp|med-ovw
med-ovw|24004|udp|med-ovw
med-ci|24005|tcp|med-ci
med-ci|24005|udp|med-ci
med-net-svc|24006|tcp|med-net-svc
med-net-svc|24006|udp|med-net-svc
filesphere|24242|tcp|fileSphere
filesphere|24242|udp|fileSphere
vista-4gl|24249|tcp|Vista 4GL
vista-4gl|24249|udp|Vista 4GL
intel_rci|24386|tcp|Intel RCI
intel_rci|24386|udp|Intel RCI
binkp|24554|tcp|BINKP
binkp|24554|udp|BINKP
flashfiler|24677|tcp|FlashFiler
flashfiler|24677|udp|FlashFiler
proactivate|24678|tcp|Turbopower Proactivate
proactivate|24678|udp|Turbopower Proactivate
snip|24922|tcp|Simple Net Ident Protocol
snip|24922|udp|Simple Net Ident Protocol
icl-twobase1|25000|tcp|icl-twobase1
icl-twobase1|25000|udp|icl-twobase1
icl-twobase2|25001|tcp|icl-twobase2
icl-twobase2|25001|udp|icl-twobase2
icl-twobase3|25002|tcp|icl-twobase3
icl-twobase3|25002|udp|icl-twobase3
icl-twobase4|25003|tcp|icl-twobase4
icl-twobase4|25003|udp|icl-twobase4
icl-twobase5|25004|tcp|icl-twobase5
icl-twobase5|25004|udp|icl-twobase5
icl-twobase6|25005|tcp|icl-twobase6
icl-twobase6|25005|udp|icl-twobase6
icl-twobase7|25006|tcp|icl-twobase7
icl-twobase7|25006|udp|icl-twobase7
icl-twobase8|25007|tcp|icl-twobase8
icl-twobase8|25007|udp|icl-twobase8
icl-twobase9|25008|tcp|icl-twobase9
icl-twobase9|25008|udp|icl-twobase9
icl-twobase10|25009|tcp|icl-twobase10
icl-twobase10|25009|udp|icl-twobase10
vocaltec-hos|25793|tcp|Vocaltec Address Server
vocaltec-hos|25793|udp|Vocaltec Address Server
niobserver|25901|tcp|NIObserver
niobserver|25901|udp|NIObserver
niprobe|25903|tcp|NIProbe
niprobe|25903|udp|NIProbe
quake|26000|tcp|quake
quake|26000|udp|quake
wnn6-ds|26208|tcp|wnn6-ds
wnn6-ds|26208|udp|wnn6-ds
ezproxy|26260|tcp|eZproxy
ezproxy|26260|udp|eZproxy
ezmeeting|26261|tcp|eZmeeting
ezmeeting|26261|udp|eZmeeting
k3software-svr|26262|tcp|K3 Software-Server
k3software-svr|26262|udp|K3 Software-Server
k3software-cli|26263|tcp|K3 Software-Client
k3software-cli|26263|udp|K3 Software-Client
gserver|26264|tcp|Gserver
gserver|26264|udp|Gserver
imagepump|27345|tcp|ImagePump
imagepump|27345|udp|ImagePump
kopek-httphead|27504|tcp|Kopek HTTP Head Port
kopek-httphead|27504|udp|Kopek HTTP Head Port
tw-auth-key|27999|tcp|TW Authentication/Key Distribution and
tw-auth-key|27999|udp|Attribute Certificate Services
pago-services1|30001|tcp|Pago Services 1
pago-services1|30001|udp|Pago Services 1
pago-services2|30002|tcp|Pago Services 2
pago-services2|30002|udp|Pago Services 2
xqosd|31416|tcp|XQoS network monitor
xqosd|31416|udp|XQoS network monitor
gamesmith-port|31765|tcp|GameSmith Port
gamesmith-port|31765|udp|GameSmith Port
filenet-tms|32768|tcp|Filenet TMS
filenet-tms|32768|udp|Filenet TMS
filenet-rpc|32769|tcp|Filenet RPC
filenet-rpc|32769|udp|Filenet RPC
filenet-nch|32770|tcp|Filenet NCH
filenet-nch|32770|udp|Filenet NCH
filenet-rmi|32771|tcp|FileNET RMI
filenet-rmi|32771|udp|FileNet RMI
filenet-pa|32772|tcp|FileNET Process Analyzer
filenet-pa|32772|udp|FileNET Process Analyzer
idmgratm|32896|tcp|Attachmate ID Manager
idmgratm|32896|udp|Attachmate ID Manager
diamondport|33331|tcp|DiamondCentral Interface
diamondport|33331|udp|DiamondCentral Interface
traceroute|33434|tcp|traceroute use
traceroute|33434|udp|traceroute use
turbonote-2|34249|tcp|TurboNote Relay Server Default Port
turbonote-2|34249|udp|TurboNote Relay Server Default Port
kastenxpipe|36865|tcp|KastenX Pipe
kastenxpipe|36865|udp|KastenX Pipe
neckar|37475|tcp|science + computing's Venus Administration Port
neckar|37475|udp|science + computing's Venus Administration Port
galaxy7-data|38201|tcp|Galaxy7 Data Tunnel
galaxy7-data|38201|udp|Galaxy7 Data Tunnel
turbonote-1|39681|tcp|TurboNote Default Port
turbonote-1|39681|udp|TurboNote Default Port
cscp|40841|tcp|CSCP
cscp|40841|udp|CSCP
csccredir|40842|tcp|CSCCREDIR
csccredir|40842|udp|CSCCREDIR
csccfirewall|40843|tcp|CSCCFIREWALL
csccfirewall|40843|udp|CSCCFIREWALL
fs-qos|41111|tcp|Foursticks QoS Protocol
fs-qos|41111|udp|Foursticks QoS Protocol
crestron-cip|41794|tcp|Crestron Control Port
crestron-cip|41794|udp|Crestron Control Port
crestron-ctp|41795|tcp|Crestron Terminal Port
crestron-ctp|41795|udp|Crestron Terminal Port
reachout|43188|tcp|REACHOUT
reachout|43188|udp|REACHOUT
ndm-agent-port|43189|tcp|NDM-AGENT-PORT
ndm-agent-port|43189|udp|NDM-AGENT-PORT
ip-provision|43190|tcp|IP-PROVISION
ip-provision|43190|udp|IP-PROVISION
pmcd|44321|tcp|PCP server (pmcd)
pmcd|44321|udp|PCP server (pmcd)
rockwell-encap|44818|tcp|Rockwell Encapsulation
rockwell-encap|44818|udp|Rockwell Encapsulation
invision-ag|45054|tcp|InVision AG
invision-ag|45054|udp|InVision AG
eba|45678|tcp|EBA PRISE
eba|45678|udp|EBA PRISE
ssr-servermgr|45966|tcp|SSRServerMgr
ssr-servermgr|45966|udp|SSRServerMgr
mbus|47000|tcp|Message Bus
mbus|47000|udp|Message Bus
dbbrowse|47557|tcp|Databeam Corporation
dbbrowse|47557|udp|Databeam Corporation
directplaysrvr|47624|tcp|Direct Play Server
directplaysrvr|47624|udp|Direct Play Server
ap|47806|tcp|ALC Protocol
ap|47806|udp|ALC Protocol
bacnet|47808|tcp|Building Automation and Control Networks
bacnet|47808|udp|Building Automation and Control Networks
nimcontroller|48000|tcp|Nimbus Controller
nimcontroller|48000|udp|Nimbus Controller
nimspooler|48001|tcp|Nimbus Spooler
nimspooler|48001|udp|Nimbus Spooler
nimhub|48002|tcp|Nimbus Hub
nimhub|48002|udp|Nimbus Hub
nimgtw|48003|tcp|Nimbus Gateway
nimgtw|48003|udp|Nimbus Gateway
com-bardac-dw|48556|tcp|com-bardac-dw
com-bardac-dw|48556|udp|com-bardac-dw
__END__

=pod

=head1 NAME

Net::IANA::PortNumbers - translate ports to services and vice versa

=head1 SYNOPSIS

  use Net::IANA::PortNumbers;

  my $iana = Net::IANA::PortNumbers->new();

  my $svc2port = $iana->svc2port('http', 'tcp') || 'No such service';
  my $svc2desc = $iana->svc2desc('http', 'tcp') || 'No such service';
  my $port2svc = $iana->port2svc(53, 'udp') || 'Unassigned port';
  my $port2desc = $iana->port2desc(53, 'udp') || 'Unassigned port';

  print @{$svc2port}, "\n";  # 80
  print $svc2desc, "\n";  # World Wide Web HTTP
  print $port2svc, "\n";  # domain
  print $port2desc, "\n"; # Domain Name Server

=head1 DESCRIPTION

Net::IANA::PortNumbers uses the official IANA port number registry at the
protocol/number assignments directory located at:

http://www.iana.org/assignments/port-numbers

Net::IANA::PortNumbers translates port numbers to services and descriptions,
and services to port numbers and descriptions.

=head1 METHODS

=over 4

=item * B<new>

This constructor returns a Net::IANA::PortNumbers object. It accepts no
arguments and will initialize its internal database.

=item * B<last_updated>

This object method takes no arguments. Net::IANA::PortNumbers' internal
database is primed from the IANA port registry. This method returns the date
that the IANA port registry stated that it was last updated. Note that this is
not necessarily the same date that Net::IANA::PortNumbers was last updated.

=item * B<svc2port>

This object method takes two mandatory arguments of a service and a protocol.
It will return an array reference. It will either be empty or populated
depending on if the service exists. The method is also aliased to svc2ports.

=item * B<svc2desc>

This object method takes two mandatory arguments of a service and a protocol.
It will return a service description or undefined if there is no such service.

=item * B<port2svc>

This object method takes two mandatory arguments of a port and a protocol.
It will return a service or undefined if the port is unassigned.

=item * B<port2desc>

This object method takes two mandatory arguments of a port and a protocol.
It will return a service description or undefined if the port is unassigned.

=back

=head1 COPYRIGHT

Copyright (c) 2003 Adam J. Foxson. All rights reserved.

=head1 LICENSE

See COPYING

=head1 CAVEATS

See CAVEATS

=head1 SEE ALSO

=over 4

=item * L<perl>

=item * L<Net::servent>

=back

=head1 AUTHOR

Adam J. Foxson

=cut
