# -*- cperl -*-
use strict;
use warnings;
use utf8;
no warnings 'utf8';

use Test::More tests => 55;
use Test::Differences;
unified_diff;

use Biber;
use Biber::Output::bbl;
use Log::Log4perl;
use Unicode::Normalize;
use Encode;
chdir("t/tdata");

# Set up Biber object
my $biber = Biber->new(noconf => 1);
my $LEVEL = 'ERROR';
my $l4pconf = qq|
    log4perl.category.main                             = $LEVEL, Screen
    log4perl.category.screen                           = $LEVEL, Screen
    log4perl.appender.Screen                           = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.utf8                      = 1
    log4perl.appender.Screen.Threshold                 = $LEVEL
    log4perl.appender.Screen.stderr                    = 0
    log4perl.appender.Screen.layout                    = Log::Log4perl::Layout::SimpleLayout
|;
Log::Log4perl->init(\$l4pconf);

$biber->parse_ctrlfile('names.bcf');
$biber->set_output_obj(Biber::Output::bbl->new());

# Options - we could set these in the control file but it's nice to see what we're
# relying on here for tests

# Biber options
Biber::Config->setoption('namesep', 'und'); # Testing custom name splitting string
Biber::Config->setoption('others_string', 'andere'); # Testing custom implied "et al"
Biber::Config->setoption('sortlocale', 'en_GB.UTF-8');
Biber::Config->setoption('fastsort', 1);
Biber::Config->setblxoption('mincitenames', 3);

# Now generate the information
$biber->prepare;
my $out = $biber->get_output_obj;
my $section = $biber->sections->get_section(0);
my $main = $biber->sortlists->get_list(0, 'nty', 'entry', 'nty');
my $bibentries = $section->bibentries;

my $name1 =
    { firstname      => 'John',
      firstname_i    => ['J'],
      lastname       => 'Doe',
      lastname_i     => ['D'],
      nameinitstring => 'Doe_J',
      namestring     => 'Doe, John',
      prefix         => undef,
      prefix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      suffix         => undef,
      suffix_i       => undef};
my $name2 =
    { firstname      => 'John',
      firstname_i    => ['J'],
      lastname       => 'Doe',
      lastname_i     => ['D'],
      nameinitstring => 'Doe_J',
      namestring     => 'Doe, John',
      prefix         => undef,
      prefix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => 0 },
      suffix         => 'Jr',
      suffix_i       => ['J'] } ;



my $name3 =
    { firstname      => 'Johann~Gottfried',
      firstname_i    => ['J', 'G'],
      lastname       => 'Berlichingen zu~Hornberg',
      lastname_i     => ['B', 'z', 'H'],
      nameinitstring => 'v_Berlichingen_zu_Hornberg_JG',
      namestring     => 'von Berlichingen zu Hornberg, Johann Gottfried',
      prefix         => 'von',
      prefix_i       => ['v'],
      strip          => { firstname => 0, lastname => 0, prefix => 0, suffix => undef },
      suffix         => undef,
      suffix_i       => undef};

my $name4 =
    { firstname      => 'Johann~Gottfried',
      firstname_i    => ['J', 'G'],
      lastname       => 'Berlichingen zu~Hornberg',
      lastname_i     => ['B', 'z', 'H'],
      nameinitstring => 'Berlichingen_zu_Hornberg_JG',
      namestring     => 'von Berlichingen zu Hornberg, Johann Gottfried',
      prefix         => 'von',
      prefix_i       => ['v'],
      strip          => { firstname => 0, lastname => 0, prefix => 0, suffix => undef },
      suffix         => undef,
      suffix_i       => undef};


my $name5 =
   {  firstname      => undef,
      firstname_i    => undef,
      lastname       => 'Robert and Sons, Inc.',
      lastname_i     => ['R'],
      nameinitstring => '{Robert_and_Sons,_Inc.}',
      namestring     => 'Robert and Sons, Inc.',
      prefix         => undef,
      prefix_i       => undef,
      strip          => { firstname => undef, lastname => 1, prefix => undef, suffix => undef },
      suffix         => undef,
      suffix_i       => undef};


my $name6 =
   {  firstname      => 'ʿAbdallāh',
      firstname_i    => ['A'],
      lastname       => 'al-Ṣāliḥ',
      lastname_i     => ['Ṣ'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      namestring     => 'al-Ṣāliḥ, ʿAbdallāh',
      nameinitstring => 'al-Ṣāliḥ_A' } ;

my $name7 =
   {  firstname      => 'Jean Charles~Gabriel',
      firstname_i    => ['J', 'C', 'G'],
      lastname       => 'Vallée~Poussin',
      lastname_i     => ['V', 'P'],
      prefix         => 'de~la',
      prefix_i       => ['d', 'l'],
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => 0, suffix => undef },
      namestring     => 'de la Vallée Poussin, Jean Charles Gabriel',
      nameinitstring => 'dl_Vallée_Poussin_JCG' } ;

my $name8 =
   {  firstname      => 'Jean Charles Gabriel',
      firstname_i    => ['J'],
      lastname       => 'Vallée~Poussin',
      lastname_i     => ['V', 'P'],
      prefix         => 'de~la',
      prefix_i       => ['d', 'l'],
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 1, lastname => 0, prefix => 0, suffix => undef },
      namestring     => 'de la Vallée Poussin, Jean Charles Gabriel',
      nameinitstring => 'Vallée_Poussin_J' } ;

my $name9 =
   {  firstname      => 'Jean Charles Gabriel {de la}~Vallée',
      firstname_i    => ['J', 'C', 'G', 'd', 'V'],
      lastname       => 'Poussin',
      lastname_i     => ['P'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      namestring     => 'Poussin, Jean Charles Gabriel {de la} Vallée',
      nameinitstring => 'Poussin_JCGdV' } ;

my $name10 =
   {  firstname      => 'Jean Charles~Gabriel',
      firstname_i    => ['J', 'C', 'G'],
      lastname       => 'Vallée Poussin',
      lastname_i     => ['V'],
      prefix         => 'de~la',
      prefix_i       => ['d', 'l'],
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 1, prefix => 0, suffix => undef },
      namestring     => 'de la Vallée Poussin, Jean Charles Gabriel',
      nameinitstring => '{Vallée_Poussin}_JCG' } ;

my $name11 =
   {  firstname      => 'Jean Charles Gabriel',
      firstname_i    => ['J'],
      lastname       => 'Vallée Poussin',
      lastname_i     => ['V'],
      prefix         => 'de~la',
      prefix_i       => ['d', 'l'],
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 1, lastname => 1, prefix => 0, suffix => undef },
      namestring     => 'de la Vallée Poussin, Jean Charles Gabriel',
      nameinitstring => '{Vallée_Poussin}_J' } ;

my $name12 =
   {  firstname      => 'Jean Charles~Gabriel',
      firstname_i    => ['J', 'C', 'G'],
      lastname       => 'Poussin',
      lastname_i     => ['P'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      namestring     => 'Poussin, Jean Charles Gabriel',
      nameinitstring => 'Poussin_JCG' } ;

my $name13 =
   {  firstname      => 'Jean~Charles',
      firstname_i    => ['J', 'C'],
      lastname       => 'Poussin Lecoq',
      lastname_i     => ['P'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 1, prefix => undef, suffix => undef },
      namestring     => 'Poussin Lecoq, Jean Charles',
      nameinitstring => '{Poussin_Lecoq}_JC' } ;

my $name14 =
   {  firstname      => 'J.~C.~G.',
      firstname_i    => ['J', 'C', 'G'],
      lastname       => 'Vallée~Poussin',
      lastname_i     => ['V', 'P'],
      prefix         => 'de~la',
      prefix_i       => ['d', 'l'],
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => 0, suffix => undef },
      namestring     => 'de la Vallée Poussin, J. C. G.',
      nameinitstring => 'dl_Vallée_Poussin_JCG' } ;

# Note that the lastname initials are wrong because the prefix "El-" was not stripped
# This is because the default noinit regexp only strips lower-case prefices to protect
# hyphenated names
my $name15 =
   {  firstname      => 'E.~S.',
      firstname_i    => ['E', 'S'],
      lastname       => 'El-{M}allah',
      lastname_i     => ['E-M'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      namestring     => 'El-{M}allah, E. S.',
      nameinitstring => 'El-{M}allah_ES' } ;

my $name16 =
   {  firstname      => 'E.~S.',
      firstname_i    => ['E', 'S'],
      lastname       => '{K}ent-{B}oswell',
      lastname_i     => ['K-B'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      namestring     => '{K}ent-{B}oswell, E. S.',
      nameinitstring => '{K}ent-{B}oswell_ES' } ;

my $name17 =
   {  firstname      => 'A.~N.',
      firstname_i    => ['A', 'N'],
      lastname       => 'Other',
      lastname_i     => ['O'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => 0, lastname => 0, prefix => undef, suffix => undef },
      namestring     => 'Other, A. N.',
      nameinitstring => 'Other_AN' } ;

my $name18 =
   {  firstname      => undef,
      firstname_i    => undef,
      lastname       => 'British National Corpus',
      lastname_i     => ['B'],
      prefix         => undef,
      prefix_i       => undef,
      suffix         => undef,
      suffix_i       => undef,
      strip          => { firstname => undef, lastname => 1, prefix => undef, suffix => undef },
      namestring     => 'British National Corpus',
      nameinitstring => '{British_National_Corpus}' } ;

my $l1 = q|    \entry{L1}{book}{}
      \name{author}{1}{}{%
        {{hash=72287a68c1714cb1b9f4ab9e03a88b96}{Adler}{A\bibinitperiod}{Alfred}{A\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{72287a68c1714cb1b9f4ab9e03a88b96}
      \strng{fullhash}{72287a68c1714cb1b9f4ab9e03a88b96}
      \field{sortinit}{A}
      \field{sortinithash}{b685c7856330eaee22789815b49de9bb}
      \field{labelnamesource}{author}
    \endentry
|;

my $l2 = q|    \entry{L2}{book}{}
      \name{author}{1}{}{%
        {{hash=1c867a2b5ceb243bab70afb18702dc04}{Bull}{B\bibinitperiod}{Bertie\bibnamedelima B.}{B\bibinitperiod\bibinitdelim B\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{1c867a2b5ceb243bab70afb18702dc04}
      \strng{fullhash}{1c867a2b5ceb243bab70afb18702dc04}
      \field{sortinit}{B}
      \field{sortinithash}{4ecbea03efd0532989d3836d1a048c32}
      \field{labelnamesource}{author}
    \endentry
|;

my $l3 = q|    \entry{L3}{book}{}
      \name{author}{1}{}{%
        {{hash=cecd18116c43ee86e5a136b6e0362948}{Crop}{C\bibinitperiod}{C.\bibnamedelimi Z.}{C\bibinitperiod\bibinitdelim Z\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{cecd18116c43ee86e5a136b6e0362948}
      \strng{fullhash}{cecd18116c43ee86e5a136b6e0362948}
      \field{sortinit}{C}
      \field{sortinithash}{59f25d509f3381b07695554a9f35ecb2}
      \field{labelnamesource}{author}
    \endentry
|;

my $l4 = q|    \entry{L4}{book}{}
      \name{author}{1}{}{%
        {{hash=675883f3aca7c6069c0b154d47af4c86}{Decket}{D\bibinitperiod}{Derek\bibnamedelima D}{D\bibinitperiod\bibinitdelim D\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{675883f3aca7c6069c0b154d47af4c86}
      \strng{fullhash}{675883f3aca7c6069c0b154d47af4c86}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{labelnamesource}{author}
    \endentry
|;

my $l5 = q|    \entry{L5}{book}{}
      \name{author}{1}{}{%
        {{hash=c2d41bb75b01ec2339c1050981f9c2cc}{Eel}{E\bibinitperiod}{Egbert}{E\bibinitperiod}{von}{v\bibinitperiod}{}{}}%
      }
      \strng{namehash}{c2d41bb75b01ec2339c1050981f9c2cc}
      \strng{fullhash}{c2d41bb75b01ec2339c1050981f9c2cc}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l6 = q|    \entry{L6}{book}{}
      \name{author}{1}{}{%
        {{hash=68e9105aa98379a85ef6cd2e7ac29c00}{Frome}{F\bibinitperiod}{Francis}{F\bibinitperiod}{van\bibnamedelimb der\bibnamedelima valt}{v\bibinitperiod\bibinitdelim d\bibinitperiod\bibinitdelim v\bibinitperiod}{}{}}%
      }
      \strng{namehash}{68e9105aa98379a85ef6cd2e7ac29c00}
      \strng{fullhash}{68e9105aa98379a85ef6cd2e7ac29c00}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l7 = q|    \entry{L7}{book}{}
      \name{author}{1}{}{%
        {{hash=4dbef3c5464f951b537a49ba93676a9a}{Gloom}{G\bibinitperiod}{Gregory\bibnamedelima R.}{G\bibinitperiod\bibinitdelim R\bibinitperiod}{van}{v\bibinitperiod}{}{}}%
      }
      \strng{namehash}{4dbef3c5464f951b537a49ba93676a9a}
      \strng{fullhash}{4dbef3c5464f951b537a49ba93676a9a}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l8 = q|    \entry{L8}{book}{}
      \name{author}{1}{}{%
        {{hash=9fb4d242b62f047e4255282864eedb97}{Henkel}{H\bibinitperiod}{Henry\bibnamedelima F.}{H\bibinitperiod\bibinitdelim F\bibinitperiod}{van}{v\bibinitperiod}{}{}}%
      }
      \strng{namehash}{9fb4d242b62f047e4255282864eedb97}
      \strng{fullhash}{9fb4d242b62f047e4255282864eedb97}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l9 = q|    \entry{L9}{book}{}
      \name{author}{1}{}{%
        {{hash=1734924c4c55de5bb18d020c34a5249e}{{Iliad\bibnamedelimb Ipswich}}{I\bibinitperiod}{Ian}{I\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{1734924c4c55de5bb18d020c34a5249e}
      \strng{fullhash}{1734924c4c55de5bb18d020c34a5249e}
      \field{sortinit}{I}
      \field{sortinithash}{25e99d37ba90f7c4fb20baf4e310faf3}
      \field{labelnamesource}{author}
    \endentry
|;


my $l10 = q|    \entry{L10}{book}{}
      \name{author}{1}{}{%
        {{hash=758a11cc45860d7635b1f6091b2d95a9}{Jolly}{J\bibinitperiod}{James}{J\bibinitperiod}{}{}{III}{I\bibinitperiod}}%
      }
      \strng{namehash}{758a11cc45860d7635b1f6091b2d95a9}
      \strng{fullhash}{758a11cc45860d7635b1f6091b2d95a9}
      \field{sortinit}{J}
      \field{sortinithash}{ec3950a647c092421b9fcca6d819504a}
      \field{labelnamesource}{author}
    \endentry
|;


my $l10a = q|    \entry{L10a}{book}{}
      \name{author}{1}{}{%
        {{hash=5e60d697e6432558eab7dccf9890eb79}{Pimentel}{P\bibinitperiod}{Joseph\bibnamedelima J.}{J\bibinitperiod\bibinitdelim J\bibinitperiod}{}{}{Jr.}{J\bibinitperiod}}%
      }
      \strng{namehash}{5e60d697e6432558eab7dccf9890eb79}
      \strng{fullhash}{5e60d697e6432558eab7dccf9890eb79}
      \field{sortinit}{P}
      \field{sortinithash}{c0a4896d0e424f9ca4d7f14f2b3428e7}
      \field{labelnamesource}{author}
    \endentry
|;


my $l11 = q|    \entry{L11}{book}{}
      \name{author}{1}{}{%
        {{hash=ef4ab7eba5cd140b54ba4329e1dda90b}{Kluster}{K\bibinitperiod}{Kevin}{K\bibinitperiod}{van}{v\bibinitperiod}{Jr.}{J\bibinitperiod}}%
      }
      \strng{namehash}{ef4ab7eba5cd140b54ba4329e1dda90b}
      \strng{fullhash}{ef4ab7eba5cd140b54ba4329e1dda90b}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l12 = q|    \entry{L12}{book}{}
      \name{author}{1}{}{%
        {{hash=5bb094a9232384acc478f1aa54e8cf3c}{Vallée\bibnamedelima Poussin}{V\bibinitperiod\bibinitdelim P\bibinitperiod}{Charles\bibnamedelimb Louis\bibnamedelimb Xavier\bibnamedelima Joseph}{C\bibinitperiod\bibinitdelim L\bibinitperiod\bibinitdelim X\bibinitperiod\bibinitdelim J\bibinitperiod}{de\bibnamedelima la}{d\bibinitperiod\bibinitdelim l\bibinitperiod}{}{}}%
      }
      \strng{namehash}{5bb094a9232384acc478f1aa54e8cf3c}
      \strng{fullhash}{5bb094a9232384acc478f1aa54e8cf3c}
      \field{sortinit}{d}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{labelnamesource}{author}
    \endentry
|;

my $l13 = q|    \entry{L13}{book}{}
      \name{author}{1}{}{%
        {{hash=5e79da6869afaf0d38e01285b494d555}{Van\bibnamedelimb de\bibnamedelima Graaff}{V\bibinitperiod\bibinitdelim d\bibinitperiod\bibinitdelim G\bibinitperiod}{R.\bibnamedelimi J.}{R\bibinitperiod\bibinitdelim J\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{5e79da6869afaf0d38e01285b494d555}
      \strng{fullhash}{5e79da6869afaf0d38e01285b494d555}
      \field{sortinit}{V}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l14 = q|    \entry{L14}{book}{}
      \name{author}{1}{}{%
        {{hash=2319907d9a5d5dd46da77879bdb7e609}{St\bibnamedelima John-Mollusc}{S\bibinitperiod\bibinitdelim J\bibinithyphendelim M\bibinitperiod}{Oliver}{O\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{2319907d9a5d5dd46da77879bdb7e609}
      \strng{fullhash}{2319907d9a5d5dd46da77879bdb7e609}
      \field{sortinit}{S}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;

my $l15 = q|    \entry{L15}{book}{}
      \name{author}{1}{}{%
        {{hash=379b415d869a4751678a5eee23b07e48}{Gompel}{G\bibinitperiod}{Roger\bibnamedelima P.{\,}G.}{R\bibinitperiod\bibinitdelim P\bibinitperiod}{van}{v\bibinitperiod}{}{}}%
      }
      \strng{namehash}{379b415d869a4751678a5eee23b07e48}
      \strng{fullhash}{379b415d869a4751678a5eee23b07e48}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l16 = q|    \entry{L16}{book}{}
      \name{author}{1}{}{%
        {{hash=0a9532fa161f6305ec403c1c85951bdf}{Gompel}{G\bibinitperiod}{Roger\bibnamedelima {P.\,G.}}{R\bibinitperiod\bibinitdelim P\bibinitperiod}{van}{v\bibinitperiod}{}{}}%
      }
      \strng{namehash}{0a9532fa161f6305ec403c1c85951bdf}
      \strng{fullhash}{0a9532fa161f6305ec403c1c85951bdf}
      \field{sortinit}{v}
      \field{sortinithash}{d18f5ce25ce0b5ca7f924e3f6c04870e}
      \field{labelnamesource}{author}
    \endentry
|;

my $l17 = q|    \entry{L17}{book}{}
      \name{author}{1}{}{%
        {{hash=766d5329cf995fcc7c1cef19de2a2ae8}{Lovecraft}{L\bibinitperiod}{Bill\bibnamedelima H.{\,}P.}{B\bibinitperiod\bibinitdelim H\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{766d5329cf995fcc7c1cef19de2a2ae8}
      \strng{fullhash}{766d5329cf995fcc7c1cef19de2a2ae8}
      \field{sortinit}{L}
      \field{sortinithash}{872351f18d0f736066eda0bf18bfa4f7}
      \field{labelnamesource}{author}
    \endentry
|;

my $l18 = q|    \entry{L18}{book}{}
      \name{author}{1}{}{%
        {{hash=58620d2c7d6839bac23306c732c563fb}{Lovecraft}{L\bibinitperiod}{Bill\bibnamedelima {H.\,P.}}{B\bibinitperiod\bibinitdelim H\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{58620d2c7d6839bac23306c732c563fb}
      \strng{fullhash}{58620d2c7d6839bac23306c732c563fb}
      \field{sortinit}{L}
      \field{sortinithash}{872351f18d0f736066eda0bf18bfa4f7}
      \field{labelnamesource}{author}
    \endentry
|;

my $l19 = q|    \entry{L19}{book}{}
      \name{author}{1}{}{%
        {{hash=83caa52f21f97e572dd3267bdf62978a}{Mustermann}{M\bibinitperiod}{Klaus-Peter}{K\bibinithyphendelim P\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{83caa52f21f97e572dd3267bdf62978a}
      \strng{fullhash}{83caa52f21f97e572dd3267bdf62978a}
      \field{sortinit}{M}
      \field{sortinithash}{2684bec41e9697b92699b46491061da2}
      \field{labelnamesource}{author}
    \endentry
|;

my $l19a = q|    \entry{L19a}{book}{}
      \name{author}{1}{}{%
        {{hash=0963f6904ccfeaac2770c5882a587001}{Lam}{L\bibinitperiod}{Ho-Pun}{H\bibinithyphendelim P\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{0963f6904ccfeaac2770c5882a587001}
      \strng{fullhash}{0963f6904ccfeaac2770c5882a587001}
      \field{sortinit}{L}
      \field{sortinithash}{872351f18d0f736066eda0bf18bfa4f7}
      \field{labelnamesource}{author}
    \endentry
|;


my $l20 = q|    \entry{L20}{book}{}
      \name{author}{1}{}{%
        {{hash=fdaa0936724be89ef8bd16cf02e08c74}{Ford}{F\bibinitperiod}{{John\bibnamedelimb Henry}}{J\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{fdaa0936724be89ef8bd16cf02e08c74}
      \strng{fullhash}{fdaa0936724be89ef8bd16cf02e08c74}
      \field{sortinit}{F}
      \field{sortinithash}{c6a7d9913bbd7b20ea954441c0460b78}
      \field{labelnamesource}{author}
    \endentry
|;

my $l21 = q|    \entry{L21}{book}{}
      \name{author}{1}{}{%
        {{hash=4389a3c0dc7da74487b50808ba9436ad}{Smith}{S\bibinitperiod}{\v{S}omeone}{\v{S}\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{4389a3c0dc7da74487b50808ba9436ad}
      \strng{fullhash}{4389a3c0dc7da74487b50808ba9436ad}
      \field{sortinit}{S}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;

my $l22u = q|    \entry{L22}{book}{}
      \name{author}{1}{}{%
        {{hash=e58b861545799d0eaf883402a882126e}{Šmith}{Š\bibinitperiod}{Someone}{S\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{e58b861545799d0eaf883402a882126e}
      \strng{fullhash}{e58b861545799d0eaf883402a882126e}
      \field{sortinit}{Š}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;


my $l22 = q|    \entry{L22}{book}{}
      \name{author}{1}{}{%
        {{hash=e58b861545799d0eaf883402a882126e}{\v{S}mith}{\v{S}\bibinitperiod}{Someone}{S\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{e58b861545799d0eaf883402a882126e}
      \strng{fullhash}{e58b861545799d0eaf883402a882126e}
      \field{sortinit}{\v{S}}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;


my $l23 = q|    \entry{L23}{book}{}
      \name{author}{1}{}{%
        {{hash=4389a3c0dc7da74487b50808ba9436ad}{Smith}{S\bibinitperiod}{Šomeone}{Š\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{4389a3c0dc7da74487b50808ba9436ad}
      \strng{fullhash}{4389a3c0dc7da74487b50808ba9436ad}
      \field{sortinit}{S}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;

my $l24 = q|    \entry{L24}{book}{}
      \name{author}{1}{}{%
        {{hash=e58b861545799d0eaf883402a882126e}{Šmith}{Š\bibinitperiod}{Someone}{S\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{e58b861545799d0eaf883402a882126e}
      \strng{fullhash}{e58b861545799d0eaf883402a882126e}
      \field{sortinit}{Š}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;

my $l25 = q|    \entry{L25}{book}{}
      \name{author}{1}{}{%
        {{hash=7069367d4a4f37ffb0377e3830e98ed0}{{American\bibnamedelimb Psychological\bibnamedelimb Association,\bibnamedelimb Task\bibnamedelimb Force\bibnamedelimb on\bibnamedelimb the\bibnamedelimb Sexualization\bibnamedelimb of\bibnamedelimb Girls}}{A\bibinitperiod}{}{}{}{}{}{}}%
      }
      \strng{namehash}{7069367d4a4f37ffb0377e3830e98ed0}
      \strng{fullhash}{7069367d4a4f37ffb0377e3830e98ed0}
      \field{sortinit}{A}
      \field{sortinithash}{b685c7856330eaee22789815b49de9bb}
      \field{labelnamesource}{author}
    \endentry
|;

my $l26 = q|    \entry{L26}{book}{}
      \name{author}{1}{}{%
        {{hash=d176a8af5ce1c45cb06875c4433f2fe2}{{Sci-Art\bibnamedelimb Publishers}}{S\bibinitperiod}{}{}{}{}{}{}}%
      }
      \strng{namehash}{d176a8af5ce1c45cb06875c4433f2fe2}
      \strng{fullhash}{d176a8af5ce1c45cb06875c4433f2fe2}
      \field{sortinit}{S}
      \field{sortinithash}{fd1e7c5ab79596b13dbbb67f8d70fb5a}
      \field{labelnamesource}{author}
    \endentry
|;

# Malformed anyway but a decent test
my $l28 = q|    \entry{L28}{book}{}
      \field{sortinit}{0}
      \field{sortinithash}{990108227b3316c02842d895999a0165}
      \warn{\item Name "Deux et al.,, O." is malformed (consecutive commas): skipping name}
    \endentry
|;


my $l29 = q|    \entry{L29}{book}{}
      \name{author}{1}{}{%
        {{hash=59a5e43a502767d00e589eb29f863728}{{U.S.\bibnamedelimi Department\bibnamedelimb of\bibnamedelimb Health\bibnamedelimb and\bibnamedelimb Human\bibnamedelimb Services,\bibnamedelimb National\bibnamedelimb Institute\bibnamedelimb of\bibnamedelimb Mental\bibnamedelimb Health,\bibnamedelimb National\bibnamedelimb Heart,\bibnamedelimb Lung\bibnamedelimb and\bibnamedelimb Blood\bibnamedelimb Institute}}{U\bibinitperiod}{}{}{}{}{}{}}%
      }
      \strng{namehash}{59a5e43a502767d00e589eb29f863728}
      \strng{fullhash}{59a5e43a502767d00e589eb29f863728}
      \field{sortinit}{U}
      \field{sortinithash}{8145509bd2718876fc77d31fd2cde117}
      \field{labelnamesource}{author}
    \endentry
|;

my $l31 = q|    \entry{L31}{book}{}
      \name{author}{1}{}{%
        {{hash=29c3ff92fff79d09a8b44d2f775de0b1}{\~{Z}elly}{\~{Z}\bibinitperiod}{Arthur}{A\bibinitperiod}{}{}{}{}}%
      }
      \name{editor}{1}{}{%
        {{hash=29c3ff92fff79d09a8b44d2f775de0b1}{\~{Z}elly}{\~{Z}\bibinitperiod}{Arthur}{A\bibinitperiod}{}{}{}{}}%
      }
      \name{translator}{1}{}{%
        {{hash=29c3ff92fff79d09a8b44d2f775de0b1}{\~{Z}elly}{\~{Z}\bibinitperiod}{Arthur}{A\bibinitperiod}{}{}{}{}}%
      }
      \strng{namehash}{29c3ff92fff79d09a8b44d2f775de0b1}
      \strng{fullhash}{29c3ff92fff79d09a8b44d2f775de0b1}
      \field{sortinit}{\~{Z}}
      \field{sortinithash}{fdda4caaa6b5fa63e0c081dcb159543a}
      \field{labelnamesource}{author}
    \endentry
|;

is_deeply(Biber::Input::file::bibtex::parsename('John Doe', 'author'), $name1, 'parsename 1');
is_deeply(Biber::Input::file::bibtex::parsename('Doe, Jr, John', 'author'), $name2, 'parsename 2');
is_deeply(Biber::Input::file::bibtex::parsename('von Berlichingen zu Hornberg, Johann Gottfried', 'author', {useprefix => 1}), $name3, 'parsename 3') ;
is_deeply(Biber::Input::file::bibtex::parsename('von Berlichingen zu Hornberg, Johann Gottfried', 'author', {useprefix => 0}), $name4, 'parsename 4') ;
is_deeply(Biber::Input::file::bibtex::parsename('{Robert and Sons, Inc.}', 'author'), $name5, 'parsename 5') ;
is_deeply(Biber::Input::file::bibtex::parsename('al-Ṣāliḥ, ʿAbdallāh', 'author', undef, 1), $name6, 'parsename 6') ;
is_deeply(Biber::Input::file::bibtex::parsename('Jean Charles Gabriel de la Vallée Poussin', 'author', {useprefix => 1}, 1), $name7, 'parsename 7');
is_deeply(Biber::Input::file::bibtex::parsename('{Jean Charles Gabriel} de la Vallée Poussin', 'author', undef, 1), $name8, 'parsename 8');
is_deeply(Biber::Input::file::bibtex::parsename('Jean Charles Gabriel {de la} Vallée Poussin', 'author', undef, 1), $name9, 'parsename 9');
is_deeply(Biber::Input::file::bibtex::parsename('Jean Charles Gabriel de la {Vallée Poussin}', 'author', undef, 1), $name10, 'parsename 10');
is_deeply(Biber::Input::file::bibtex::parsename('{Jean Charles Gabriel} de la {Vallée Poussin}', 'author', undef, 1), $name11, 'parsename 11');
is_deeply(Biber::Input::file::bibtex::parsename('Jean Charles Gabriel Poussin', 'author'), $name12, 'parsename 12');
is_deeply(Biber::Input::file::bibtex::parsename('Jean Charles {Poussin Lecoq}', 'author'), $name13, 'parsename 13');
is_deeply(Biber::Input::file::bibtex::parsename('J. C. G. de la Vallée Poussin', 'author', {useprefix => 1}, 1), $name14, 'parsename 14');
is_deeply(Biber::Input::file::bibtex::parsename('E. S. El-{M}allah', 'author'), $name15, 'parsename 15');
is_deeply(Biber::Input::file::bibtex::parsename('E. S. {K}ent-{B}oswell', 'author'), $name16, 'parsename 16');
is_deeply(Biber::Input::file::bibtex::parsename('Other, A.~N.', 'author'), $name17, 'parsename 17');
is_deeply(Biber::Input::file::bibtex::parsename('{{{British National Corpus}}}', 'author'), $name18, 'parsename 18');


eq_or_diff( $out->get_output_entry('L1', $main), $l1, 'First Last') ;
eq_or_diff( $out->get_output_entry('L2', $main), $l2, 'First Initial. Last') ;
eq_or_diff( $out->get_output_entry('L3', $main), $l3, 'Initial. Initial. Last') ;
eq_or_diff( $out->get_output_entry('L4', $main), $l4, 'First Initial Last') ;
eq_or_diff( $out->get_output_entry('L5', $main), $l5, 'First prefix Last') ;
eq_or_diff( $out->get_output_entry('L6', $main), $l6, 'First prefix prefix Last') ;
eq_or_diff( $out->get_output_entry('L7', $main), $l7, 'First Initial. prefix Last') ;
eq_or_diff( $out->get_output_entry('L8', $main), $l8, 'First Initial prefix Last') ;
eq_or_diff( $out->get_output_entry('L9', $main), $l9, 'First {Last Last}') ;
eq_or_diff( $out->get_output_entry('L10', $main), $l10, 'Last, Suffix, First') ;
eq_or_diff( $out->get_output_entry('L10a', $main), $l10a, 'Last, Suffix, First Initial.') ;
eq_or_diff( $out->get_output_entry('L11', $main), $l11, 'prefix Last, Suffix, First') ;
eq_or_diff( $out->get_output_entry('L13', $main), $l13, 'Last Last Last, Initial. Initial.');
eq_or_diff( $out->get_output_entry('L14', $main), $l14, 'Last Last-Last, First');
eq_or_diff( $out->get_output_entry('L15', $main), $l15, 'First F.{\bibinitdelim }F. Last');
eq_or_diff( $out->get_output_entry('L16', $main), $l16, 'First {F.\bibinitdelim F.} Last');
eq_or_diff( $out->get_output_entry('L17', $main), $l17, 'Last, First {F.\bibinitdelim F.}');
eq_or_diff( $out->get_output_entry('L18', $main), $l18, 'Last, First F.{\bibinitdelim }F.');
eq_or_diff( $out->get_output_entry('L19', $main), $l19, 'Firstname with hyphen');
eq_or_diff( $out->get_output_entry('L19a', $main), $l19a, 'Short firstname with hyphen');
eq_or_diff( $out->get_output_entry('L20', $main), $l20, 'Protected dual first name');
eq_or_diff( encode_utf8(NFC($out->get_output_entry('L22', $main))), encode_utf8($l22u), 'LaTeX encoded unicode lastname - 1');
eq_or_diff( NFC($out->get_output_entry('L23', $main)), $l23, 'Unicode firstname');
eq_or_diff( NFC($out->get_output_entry('L24', $main)), $l24, 'Unicode lastname');
eq_or_diff( $out->get_output_entry('L25', $main), $l25, 'Single string name');
eq_or_diff( $out->get_output_entry('L26', $main), $l26, 'Hyphen at brace level <> 0');
eq_or_diff($section->bibentry('L27')->get_field('author')->count_names, 1, 'Bad name with 3 commas');
eq_or_diff( $out->get_output_entry('L28', $main), $l28, 'Bad name with consecutive commas');
eq_or_diff( $out->get_output_entry('L29', $main), $l29, 'Escaped name with 3 commas');

# Checking visibility
# Count does not include the "and others" as this "name" is delete in the output driver
eq_or_diff($bibentries->entry('V1')->get_field($bibentries->entry('V1')->get_labelname_info)->count_names, '2', 'Name count for "and others" - 1');
eq_or_diff($bibentries->entry('V1')->get_field($bibentries->entry('V1')->get_labelname_info)->get_visible_cite, '2', 'Visibility for "and others" - 1');
eq_or_diff($bibentries->entry('V2')->get_field($bibentries->entry('V2')->get_labelname_info)->get_visible_cite, '1', 'Visibility for "and others" - 2');

# A few tests depend set to non UTF-8 output
# Have to use a new biber object when trying to change encoding as this isn't
# dealt with in ->prepare
$biber->parse_ctrlfile('names.bcf');
$biber->set_output_obj(Biber::Output::bbl->new());

# Biber options
Biber::Config->setoption('output_encoding', 'latin1');
# If you change the encoding options, you have to re-read the T::B data from the datasource
# This won't happen unless you invalidate the T::B cache.
Biber::Input::file::bibtex->init_cache;

# Now generate the information
$biber->prepare;
$out = $biber->get_output_obj;
$section = $biber->sections->get_section(0);
$main = $biber->sortlists->get_list(0, 'nty', 'entry', 'nty');
$bibentries = $section->bibentries;

eq_or_diff(NFC($bibentries->entry('L21')->get_field($bibentries->entry('L21')->get_labelname_info)->nth_name(1)->get_firstname_i->[0]), 'Š', 'Terseinitials 1'); # Should be in NFD UTF-8
eq_or_diff( encode_utf8($out->get_output_entry('L12', $main)), encode_utf8($l12), 'First First First First prefix prefix Last Last') ;
eq_or_diff( $out->get_output_entry('L21', $main), $l21, 'LaTeX encoded unicode firstname');
eq_or_diff( $out->get_output_entry('L22', $main), $l22, 'LaTeX encoded unicode lastname - 2');
eq_or_diff( $out->get_output_entry('L31', $main), $l31, 'LaTeX encoded unicode lastname with tie char');

