# -*- cperl -*-
use strict;
use warnings;
use utf8;
no warnings 'utf8' ;
use open qw/:std :utf8/;

use Test::More tests => 60;
use Test::Differences;
unified_diff;

use Biber;
use Biber::Entry::Name;
use Biber::Entry::Names;
use Biber::Utils;
use Biber::LaTeX::Recode;
use Log::Log4perl;
use IPC::Cmd qw( can_run );
use Cwd;
use Unicode::Normalize;
use Encode;

my $cwd = getcwd;

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

# NFD/NFC calls below as we are accessing internal functions which assume NFD and results strings
# which assume NFC.

# File locating
# Using File::Spec->canonpath() to normalise path separators so these tests work
# on Windows/non-Windows
# Absolute path
eq_or_diff(File::Spec->canonpath(locate_biber_file("$cwd/t/tdata/general1.bcf")), File::Spec->canonpath("$cwd/t/tdata/general1.bcf"), 'File location - 1');
# Relative path
eq_or_diff(File::Spec->canonpath(locate_biber_file('t/tdata/general1.bcf')), File::Spec->canonpath('t/tdata/general1.bcf'), 'File location - 2');
# Same place as control file
Biber::Config->set_ctrlfile_path('t/tdata/general1.bcf');
eq_or_diff(File::Spec->canonpath(locate_biber_file('t/tdata/examples.bib')), File::Spec->canonpath('t/tdata/examples.bib'), 'File location - 3');

# The \cM* is there because if cygwin picks up miktex kpsewhich, it will return a path
# with a Ctrl-M on the end
# Testing using a file guaranteed to be installed with any latex install
SKIP: {
  skip "No LaTeX installation", 1 unless can_run('kpsewhich');
  # using kpsewhich
  like(File::Spec->canonpath(locate_biber_file('plain.tex')), qr|plain.tex\cM*\z|, 'File location - 4');
    }

# In output_directory
Biber::Config->setoption('output_directory', 't/tdata');
eq_or_diff(File::Spec->canonpath(locate_biber_file('general1.bcf')), File::Spec->canonpath("t/tdata/general1.bcf"), 'File location - 5');

# String normalising
eq_or_diff(normalise_string('"a, b–c: d" ', 1),  'a bc d', 'normalise_string' );

Biber::Config->setoption('output_encoding', 'UTF-8');
eq_or_diff(NFC(normalise_string_underscore(latex_decode('\c Se\x{c}\"ok-\foo{a},  N\`i\~no
    $§+ :-)   '), 0)), 'Şecöka_Nìño', 'normalise_string_underscore 1' );

eq_or_diff(normalise_string_underscore('{Foo de Bar, Graf Ludwig}', 1), 'Foo_de_Bar_Graf_Ludwig', 'normalise_string_underscore 3');

# LaTeX decoding/encoding
eq_or_diff(NFC(latex_decode('Mu\d{h}ammad ibn M\=us\=a al-Khw\=arizm\=\i{} \r{a}')), 'Muḥammad ibn Mūsā al-Khwārizmı̄ å', 'latex decode 1');
eq_or_diff(latex_decode('\alpha'), '\alpha', 'latex decode 2'); # no greek decoding by default
eq_or_diff(latex_decode('\textless\textampersand'), '<&', 'latex decode 3'); # checking XML encoding bits
eq_or_diff(latex_encode(NFD('Muḥammad ibn Mūsā al-Khwārizmī')), 'Mu\d{h}ammad ibn M\={u}s\={a} al-Khw\={a}rizm\=\i{}', 'latex encode 1');
eq_or_diff(latex_encode(NFD('α')), 'α', 'latex encode 2'); # no greek encoding by default
eq_or_diff(NFC(latex_decode("{M{\\'a}t{\\'e}}")), '{Máté}', 'latex decode accent 1');
eq_or_diff(NFC(latex_decode("{M\\'{a}t\\'{e}}")), '{Máté}', 'latex decode accent 2');
eq_or_diff(NFC(latex_decode("{M\\'at\\'e}")), '{Máté}', 'latex decode accent 3');
eq_or_diff(NFC(latex_decode("R{\\'egis}")), 'R{égis}', 'latex decode accent 4');
eq_or_diff(NFC(latex_decode("\\textuppercase{\\'e}")), '\textuppercase{é}', 'latex decode accent 5');
eq_or_diff(NFC(latex_decode("\\DH{}and\\dj{}and\\'{c}, H.")), 'Ðandđandć, H.', 'latex reversing recoding test 1');
eq_or_diff(NFC(latex_decode("{\\DH{}and\\dj{}and\\'{c}, H.}")), '{Ðandđandć, H.}', 'latex reversing recoding test 2');
eq_or_diff(latex_encode(NFD('Ðandđandć, H.')), '\\DH{}and\\dj{}and\\\'{c}, H.', 'latex reversing recoding test 3');
eq_or_diff(latex_encode(NFD('{Ðandđandć, H.}')), '{\\DH{}and\\dj{}and\\\'{c}, H.}', 'latex reversing recoding test 4');

Biber::LaTeX::Recode->init_sets('full', 'full'); # Need to do this to reset
eq_or_diff(latex_decode('\alpha'), 'α', 'latex decode 4'); # greek decoding with "full"
eq_or_diff(NFC(latex_decode("\\'\\i")), 'ı́', 'latex decode 5'); # checking i/j with accents

eq_or_diff(NFC(latex_decode("{\\'\\i}")), 'ı́', 'latex decode 5a'); # checking i/j with accents
eq_or_diff(NFC(latex_decode("\\^{\\j}")), 'ȷ̂', 'latex decode 6'); # checking i/j with accents
eq_or_diff(NFC(latex_decode("\\u{\\i}")), 'ı̆', 'latex decode 7'); # checking i/j with accents
eq_or_diff(NFC(latex_decode("\\u\\i")), 'ı̆', 'latex decode 8'); # checking i/j with accents
eq_or_diff(latex_decode('\i'), 'ı', 'latex decode 9'); # checking dotless i
eq_or_diff(latex_decode('\j'), 'ȷ', 'latex decode 10'); # checking dotless j
eq_or_diff(latex_decode('\textdiv'), '÷', 'latex decode 11'); # checking multiple set for types
eq_or_diff(latex_decode('\textbackslash'), "\\", 'latex decode 12'); # checking multiple set for types
eq_or_diff(latex_decode('--'), '--', 'latex decode 13'); # Testing raw

eq_or_diff(latex_encode(NFD('α')), '{$\alpha$}', 'latex encode 3'); # greek encoding with "full"
eq_or_diff(latex_encode(NFD('µ')), '{$\mu$}', 'latex encode 4'); # Testing symbols
eq_or_diff(latex_encode(NFD('≄')), '{$\not\simeq$}', 'latex encode 5'); # Testing negated symbols
eq_or_diff(latex_encode(NFD('Þ')), '\TH{}', 'latex encode 6'); # Testing preferred
eq_or_diff(latex_encode('$'), '$', 'latex encode 7'); # Testing exclude
eq_or_diff(latex_encode(NFD('–')), '--', 'latex encode 8'); # Testing raw
eq_or_diff(latex_decode('a\-a'), 'a\-a', 'discretionary hyphens');
eq_or_diff(latex_encode(NFD('Åå')), '\r{A}\r{a}', 'latex encode 9');
eq_or_diff(latex_encode(NFD('a̍')), '\|{a}', 'latex encode 10');
eq_or_diff(latex_encode(NFD('ı̆')), '\u{\i{}}', 'latex encode 11');

my @arrayA = qw/ a b c d e f c /;
my @arrayB = qw/ c e /;
my @AminusB = reduce_array(\@arrayA, \@arrayB);
my @AminusBexpected = qw/ a b d f /;

is_deeply(\@AminusB, \@AminusBexpected, 'reduce_array') ;

eq_or_diff(remove_outer('{Some string}'), 'Some string', 'remove_outer') ;

eq_or_diff(normalise_string_hash('Ä.~{\c{C}}.~{\c S}.'), 'Äc:Cc:S', 'normalise_string_lite' ) ;

Biber::LaTeX::Recode->init_sets('base', 'full'); # Need to do this to reset
eq_or_diff(latex_decode('\textdiv'), '\textdiv', 'latex different encode/decode sets 1');
eq_or_diff(latex_encode(NFD('÷')), '{$\div$}', 'latex different encode/decode sets 2');

Biber::LaTeX::Recode->init_sets('null', 'full'); # Need to do this to reset
eq_or_diff(latex_decode('\i'), '\i', 'latex null decode 1');
eq_or_diff(latex_encode(NFD('ı')), '\i{}', 'latex null encode 2');

eq_or_diff(rangelen([[10,15]]), 6, 'Rangelen test 1');
eq_or_diff(rangelen([[10,15],[47, 53]]), 13, 'Rangelen test 2');
eq_or_diff(rangelen([[10,15],[47, undef]]), 7, 'Rangelen test 3');
eq_or_diff(rangelen([[10,15],[47, '']]), -1, 'Rangelen test 4');
eq_or_diff(rangelen([[10,15],['', 35]]), -1, 'Rangelen test 5');
eq_or_diff(rangelen([[10,15],['', undef]]), -1, 'Rangelen test 6');
eq_or_diff(rangelen([[10,15],['XX', 'XXiv'],['i',10]]), 21, 'Rangelen test 7');
# This is nasty - it's U+2165 U+2160, U+217B to test unicode decomp
eq_or_diff(rangelen([[10,15],['ⅥⅠ', 'ⅻ']]), 12, 'Rangelen test 8');
eq_or_diff(rangelen([['I-II', 'III-IV']]), -1, 'Rangelen test 9');
eq_or_diff(rangelen([[22,4],[123,7],[113,15]]), 11, 'Rangelen test 10');

