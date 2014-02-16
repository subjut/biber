package Biber::LaTeX::Recode;
use v5.16;
use strict;
use warnings;
use base qw(Exporter);
use Biber::Config;
use Encode;
use IPC::Cmd qw( can_run );
use IPC::Run3; # This works with PAR::Packer and Windows. IPC::Run doesn't
use Unicode::Normalize;
use List::AllUtils qw (first);
use Log::Log4perl qw(:no_extra_logdie_message);
use XML::LibXML::Simple;
use Carp;

our @EXPORT  = qw(latex_encode latex_decode);

my $logger = Log::Log4perl::get_logger('main');

=encoding utf-8

=head1 NAME

Biber::LaTeX::Recode - Encode/Decode chars to/from UTF-8/lacros in LaTeX

=head1 SYNOPSIS

    use Biber::LaTeX:Recode

    my $string       = 'Muḥammad ibn Mūsā al-Khwārizmī';
    my $latex_string = latex_encode($string);
        # => 'Mu\d{h}ammad ibn M\=us\=a al-Khw\=arizm\={\i}'

    my $string = 'Mu\d{h}ammad ibn M\=us\=a al-Khw\=arizm\={\i}';
    my $utf8_string   = latex_decode($string);
        # => 'Muḥammad ibn Mūsā al-Khwārizmī'

=head1 DESCRIPTION

Allows conversion between Unicode chars and LaTeX macros.

=head1 GLOBAL OPTIONS

Possible values for the encoding/decoding set to use are 'null', 'base' and 'full'; default
value is 'base'.

null  => No conversion

base  => Most common macros and diacritics (sufficient for Western languages
         and common symbols)

full  => Also converts punctuation, larger range of diacritics and macros
         (e.g. for IPA, Latin Extended Additional, etc.), symbols, Greek letters,
         dingbats, negated symbols, and superscript characters and symbols ...

=cut

use vars qw( $remap_d $remap_e $set_d $set_e );

=head2 init_sets(<decode set>, <encode_set>)

  Initialise recoding sets. We can't do this on loading the module as we don't have the config
  information to do this yet

=cut

sub init_sets {
  shift; # class method
  ($set_d, $set_e) = @_;
  no autovivification;

  # Reset these, mostly for tests which call init_sets more than once
  $remap_d = {};
  $remap_e = {};

  my $mapdata;
  # User-defined recode data file
  if (my $rdata = Biber::Config->getoption('recodedata')) {
    my $err;
    if ( can_run('kpsewhich') ) {
      run3 [ 'kpsewhich', $rdata ], \undef, \$mapdata, \$err, { return_if_system_error => 1};
      if ($? == -1) {
        biber_error("Error running kpsewhich to look for output_safechars data file: $err");
      }

      chomp $mapdata;
      $mapdata =~ s/\cM\z//xms; # kpsewhich in cygwin sometimes returns ^M at the end
      $mapdata = undef unless $mapdata; # sanitise just in case it's an empty string
    }
    else {
      biber_error("Can't run kpsewhich to look for output_safechars data file: $err");
    }
    $logger->info("Using user-defined recode data file '$mapdata'");
  }
  else {
    # we assume that the data file is in the same dir as the module
    (my $vol, my $data_path, undef) = File::Spec->splitpath( $INC{'Biber/LaTeX/Recode.pm'} );

    # Deal with the strange world of Par::Packer paths, see similar code in Biber.pm

    if ($data_path =~ m|/par\-| and $data_path !~ m|/inc|) { # a mangled PAR @INC path
      $mapdata = File::Spec->catpath($vol, "$data_path/inc/lib/Biber/LaTeX/recode_data.xml");
    }
    else {
      $mapdata = File::Spec->catpath($vol, $data_path, 'recode_data.xml');
    }
  }

  # Read driver config file
  my $parser = XML::LibXML->new();
  my $xml = File::Slurp::read_file($mapdata) or biber_error("Can't read file $mapdata");
  my $recodexml = $parser->parse_string(decode('UTF-8', $xml));
  my $xpc = XML::LibXML::XPathContext->new($recodexml);

  my @types = qw(accents letters diacritics punctuation symbols negatedsymbols superscripts cmdsuperscripts dings greek);

  # Have to have separate loops for decode/recode or you can't have independent decode/recode
  # sets

  # Construct decode set
  foreach my $type (@types) {
    foreach my $maps ($xpc->findnodes("/texmap/maps[\@type='$type']")) {
      my @set = split(/\s*,\s*/, $maps->getAttribute('set'));
      next unless first {$set_d eq $_} @set;
      foreach my $map ($maps->findnodes('map')) {
        my $from = $map->findnodes('from')->shift();
        my $to = $map->findnodes('to')->shift();
        $remap_d->{$type}{map}{NFD($from->textContent())} = NFD($to->textContent());
      }
    }
  }

  # Construct encode set
  foreach my $type (@types) {
    foreach my $maps ($xpc->findnodes("/texmap/maps[\@type='$type']")) {
      my @set = split(/\s*,\s*/, $maps->getAttribute('set'));
      next unless first {$set_e eq $_} @set;
      foreach my $map ($maps->findnodes('map')) {
        my $from = $map->findnodes('from')->shift();
        my $to = $map->findnodes('to')->shift();
        $remap_e->{$type}{map}{NFD($to->textContent())} = NFD($from->textContent());
      }
      # There are some duplicates in the data to handle preferred encodings.
      foreach my $map ($maps->findnodes('map[from[@preferred]]')) {
        my $from = $map->findnodes('from')->shift();
        my $to = $map->findnodes('to')->shift();
        $remap_e->{$type}{map}{NFD($to->textContent())} = NFD($from->textContent());
      }
    }
    # Things we don't want to change when encoding as this would break LaTeX
    foreach my $e ($xpc->findnodes('/texmap/encode_exclude/char')) {
      delete($remap_e->{$type}{map}{NFD($e->textContent())});
    }
  }

  # Populate the decode regexps
  foreach my $type (@types) {
    next unless exists $remap_d->{$type};
    if ($type eq 'accents') {
      $remap_d->{$type}{re} = '[' . join('', sort keys %{$remap_d->{$type}{map}}) . ']';
      $remap_d->{$type}{re} = qr/$remap_d->{$type}{re}/;
    }
    elsif ($type eq 'superscripts') {
      $remap_d->{$type}{re} = join('|', map { /[\+\-\)\(]/ ? '\\' . $_ : $_ } sort keys %{$remap_d->{$type}{map}});
      $remap_d->{$type}{re} = qr|$remap_d->{$type}{re}|;
    }
    else {
      $remap_d->{$type}{re} = join('|', sort keys %{$remap_d->{$type}{map}});
      $remap_d->{$type}{re} = qr|$remap_d->{$type}{re}|;
    }
  }

  # Populate the encode regexps
  foreach my $type (@types) {
    next unless exists $remap_e->{$type};
    if ($type eq 'accents') {
      $remap_e->{$type}{re} = '[' . join('', sort keys %{$remap_e->{$type}{map}}) . ']';
      $remap_e->{$type}{re} = qr/$remap_e->{$type}{re}/;
    }
    elsif ($type eq 'superscripts') {
      $remap_e->{$type}{re} = join('|', map { /[\+\-\)\(]/ ? '\\' . $_ : $_ } sort keys %{$remap_e->{$type}{map}});
      $remap_e->{$type}{re} = qr|$remap_e->{$type}{re}|;
    }
    else {
      $remap_e->{$type}{re} = join('|', sort keys %{$remap_e->{$type}{map}});
      $remap_e->{$type}{re} = qr|$remap_e->{$type}{re}|;
    }
  }
}

=head2 latex_decode($text, @options)

Converts LaTeX macros in the $text to Unicode characters.

The function accepts a number of options:

    * normalize => $bool (default 1)
        whether the output string should be normalized with Unicode::Normalize

    * normalization => <normalization form> (default 'NFD')
        and if yes, the normalization form to use (see the Unicode::Normalize documentation)

    * strip_outer_braces => $bool (default 0)
        whether the outer curly braces around letters+combining marks should be
        stripped off. By default "fut{\\'e}" becomes fut{é}, to prevent something
        like '\\textuppercase{\\'e}' from becoming '\\textuppercaseé'. Setting this option to
        TRUE can be useful for instance when converting BibTeX files.

=cut

sub latex_decode {
    my $text      = shift;
    # Optimisation - if there are no macros, no point doing anything
    return $text unless $text =~ m/\\/;

    # Optimisation - if virtual null set was specified, do nothing
    return $text if $set_d eq 'null';

    $logger->trace("String before latex_decode() -> '$text'");

    my %opts      = @_;
    my $norm      = exists $opts{normalize} ? $opts{normalize} : 1;
    my $norm_form = exists $opts{normalization} ? $opts{normalization} : 'NFD';
    my $strip_outer_braces =
      exists $opts{strip_outer_braces} ? $opts{strip_outer_braces} : 0;

    # Deal with raw TeX \char macros.
    $text =~ s/\\char"(\p{ASCII_Hex_Digit}+)/"chr(0x$1)"/gee; # hex chars
    $text =~ s/\\char'(\d+)/"chr(0$1)"/gee;  # octal chars
    $text =~ s/\\char(\d+)/"chr($1)"/gee;    # decimal chars

    # Some tricky cases
    my $d_re = $remap_d->{diacritics}{re} || '';
    my $a_re = $remap_d->{accents}{re} || '';
    # Change dotless i/j to normal i/j when applying accents
    $text =~ s/(\\(?:$d_re|$a_re)){\\(i|j)}/$1$2/g;     # \={\i}    -> \=i
    $text =~ s/(\\(?:$d_re|$a_re))\\(i|j)/$1$2/g;       # \=\i      -> \=i

    $text =~ s/(\\[a-zA-Z]+)\\(\s+)/$1\{\}$2/g;    # \foo\ bar -> \foo{} bar
    $text =~ s/([^{]\\\w)([;,.:%])/$1\{\}$2/g;     #} Aaaa\o,  -> Aaaa\o{},


    foreach my $type (sort keys %$remap_d) {
      my $map = $remap_d->{$type}{map};
      my $re = $remap_d->{$type}{re};
      if ($type eq 'negatedsymbols') {
        $text =~ s/\\not\\($re)/$map->{$1}/ge if $re;
      }
      elsif ($type eq 'superscripts') {
        $text =~ s/\\textsuperscript{($re)}/$map->{$1}/ge if $re;
      }
      elsif ($type eq 'cmdsuperscripts') {
        $text =~ s/\\textsuperscript{\\($re)}/$map->{$1}/ge if $re;
      }
      elsif ($type eq 'dings') {
        $text =~ s/\\ding{([2-9AF][0-9A-F])}/$map->{$1}/ge;
      }
      elsif ($type eq 'letters') {
        $text =~ s/\\($re)(?: \{\}|\s+|\b)/$map->{$1}/gxe;
      }
    }

    foreach my $type (sort keys %$remap_d) {
      my $map = $remap_d->{$type}{map};
      my $re = $remap_d->{$type}{re};

      if (first {$type eq $_} ('punctuation', 'symbols', 'greek')) {
        ## remove {} around macros that print one character
        ## by default we skip that, as it would break constructions like \foo{\i}
        if ($strip_outer_braces) {
          $text =~ s/\{\\($re)\} / $map->{$1}/gxe;
        }
        $text =~ s/\\($re)(?: \{\}|\s+|\b)/$map->{$1}/gxe;
      }
      if ($type eq 'accents') {
        $text =~ s/\\($re)\s*\{(\p{L}\p{M}*)\}/$2 . $map->{$1}/ge;
        $text =~ s/\\($re)\s*(\p{L}\p{M}*)/$2 . $map->{$1}/ge;
      }
      if ($type eq 'diacritics') {
        $text =~ s/\\($re)\s*\{(\p{L}\p{M}*)\}/$2 . $map->{$1}/ge;
        $text =~ s/\\($re)\s+(\p{L}\p{M}*)/$2 . $map->{$1}/ge;
      }
    }

    ## remove {} around letter+combining mark(s)
    ## by default we skip that, as it would destroy constructions like \foo{\`e}
    if ($strip_outer_braces) {
        $text =~ s/{(\PM\pM+)}/$1/g;
    }

    $logger->trace("String in latex_decode() now -> '$text'");

    if ($norm) {
      return Unicode::Normalize::normalize( $norm_form, $text );
    }
    else {
        return $text;
    }
}

=head2 latex_encode($text, @options)

Converts UTF-8 to LaTeX

=cut

sub latex_encode {
  my $text = shift;

  # Optimisation - if virtual null set was specified, do nothing
  return $text if $set_e eq 'null';

  foreach my $type (sort keys %$remap_e) {
    my $map = $remap_e->{$type}{map};
    my $re = $remap_e->{$type}{re};
      if ($type eq 'negatedsymbols') {
        $text =~ s/($re)/"{\$\\not\\" . $map->{$1} . '$}'/ge;
      }
    elsif ($type eq 'superscripts') {
      $text =~ s/($re)/'\textsuperscript{' . $map->{$1} . '}'/ge;
    }
    elsif ($type eq 'cmdsuperscripts') {
      $text =~ s/($re)/"\\textsuperscript{\\" . $map->{$1} . "}"/ge;
    }
    elsif ($type eq 'dings') {
      $text =~ s/($re)/'\ding{' . $map->{$1} . '}'/ge;
    }
  }

  foreach my $type (sort keys %$remap_e) {
    my $map = $remap_e->{$type}{map};
    my $re = $remap_e->{$type}{re};
    if ($type eq 'accents') {
      # Accents
      # special case such as "i\x{304}" -> '\={\i}' -> "i" needs the dot removing for accents
      $text =~ s/i($re)/"\\" . $map->{$1} . '{\i}'/ge;

      $text =~ s/\{(\p{L}\p{M}*)\}($re)/"\\" . $map->{$2} . "{$1}"/ge;
      $text =~ s/(\p{L}\p{M}*)($re)/"\\" . $map->{$2} . "{$1}"/ge;

    }
    if ($type eq 'diacritics') {
      # Diacritics
      $text =~ s{
                  (\P{M})($re)($re)($re)
              }{
                "\\" . $map->{$4} . "{\\" . $map->{$3} . "{\\" . $map->{$2} . _get_diac_last_r($1,$2) . '}}'
              }gex;
      $text =~ s{
                  (\P{M})($re)($re)
              }{
                "\\" . $map->{$3} . "{\\" . $map->{$2} . _get_diac_last_r($1,$2) . '}'
              }gex;
      $text =~ s{
                  (\P{M})($re)
              }{
                "\\" . $map->{$2} . _get_diac_last_r($1,$2)
              }gex;
    }
  }

  foreach my $type (sort keys %$remap_e) {
    my $map = $remap_e->{$type}{map};
    my $re = $remap_e->{$type}{re};
    if ($type eq 'letters') {
      # General macros (excluding special encoding excludes)
      $text =~ s/($re)/"{\\" . $map->{$1} . '}'/ge;
    }
    if (first {$type eq $_}  ('punctuation', 'symbols', 'greek')) {
      # Math mode macros (excluding special encoding excludes)
      $text =~ s/($re)/"{\$\\" . $map->{$1} . '$}'/ge;
    }
  }

  return $text;
}


# Helper subroutines

sub _get_diac_last_r {
    my ($a,$b) = @_;
    my $re = $remap_e->{accents}{re};

    if ( $b =~ /$re/) {
        return ($a eq 'i') or ($a eq 'j') ? "{\\$a}" : $a;
    }
    else {
        return "{$a}"
    }
}

1;

__END__

=head1 AUTHOR

François Charette, C<< <firmicus at ankabut.net> >>
Philip Kime C<< <philip at kime.org.uk> >>

=head1 BUGS

Please report any bugs or feature requests on our Github tracker at
L<https://github.com/plk/biber/issues>.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2013 François Charette and Philip Kime, all rights reserved.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut
