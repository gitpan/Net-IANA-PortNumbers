# $Id: Makefile.PL,v 1.2 2003/06/07 06:54:35 afoxson Exp $
# $Revision: 1.2 $

use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME' => 'Net::IANA::PortNumbers',
	'PM' => {
		'lib/Net/IANA/PortNumbers.pm' => '$(INST_LIBDIR)/PortNumbers.pm',
		'lib/Net/IANA/PortNumber.pm' => '$(INST_LIBDIR)/PortNumber.pm',
	},
	'VERSION_FROM' => 'lib/Net/IANA/PortNumbers.pm',
	'dist' => {
		'COMPRESS' => 'gzip --best',
		'SUFFIX' => '.gz',
	},
	(   
		$] >= 5.005 ?  (   
			ABSTRACT_FROM => 'lib/Net/IANA/PortNumbers.pm',
			AUTHOR => 'Adam J. Foxson <afoxson@pobox.com>',
		) : ()
	),
);
