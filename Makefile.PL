# $Id: Makefile.PL,v 1.6 2003/07/06 11:17:11 afoxson Exp $
# $Revision: 1.6 $

use inc::Module::Install;

name('Net-IANA-PortNumbers');
version_from('lib/Net/IANA/PortNumbers.pm');
abstract('translate ports to services and vice versa');
author('Adam J. Foxson <afoxson@pobox.com>');
license('gpl');

features(
	'Support for the IANA registry "over-the-wire"' => [
		-default => 0,
		recommends('LWP::Simple'),
		recommends('File::Temp'),
		recommends('File::Spec'),
	],
);

include('ExtUtils::AutoInstall');
check_nmake();
auto_install();

&Meta->write;
&Build->write if lc($0) eq 'build.pl';
&Makefile->write if lc($0) eq 'makefile.pl';
