package Biber::Constants;
use strict;
use warnings;
use Encode::Alias;
use Readonly;

use base 'Exporter';

our @EXPORT = qw{
  %CONFIG_DEFAULT_BIBER
  %CONFIG_DEFAULT_BIBLATEX
  %CONFIG_SCOPE_BIBLATEX
  %STRUCTURE_DATATYPES
  $BIBER_CONF_NAME
  $BIBLATEX_VERSION
  $BIBER_SORT_FINAL
  $BIBER_SORT_NULL
  $BIBER_SORT_FIRSTPASSDONE
  %BIBER_DATAFILE_REFS
  %NUMERICALMONTH
  %DISPLAYMODES
  $DISPLAYMODE_DEFAULT
  } ;

# Version of biblatex which this release works with. Matched against version
# passed in control file
Readonly::Scalar our $BIBLATEX_VERSION => '1.1';

# Global flags needed for sorting
our $BIBER_SORT_FINAL = 0;
our $BIBER_SORT_NULL  = 0;
our $BIBER_SORT_FIRSTPASSDONE = 0;

# the name of the Biber configuration file, which should be
# either returned by kpsewhich or located at "$HOME/.$BIBER_CONF_NAME"
our $BIBER_CONF_NAME = 'biber.conf';

Readonly::Scalar our $DISPLAYMODE_DEFAULT => 'uniform';

## Biber CONFIGURATION DEFAULTS

# Locale - first try environment ...
my $locale;
if ($ENV{LC_COLLATE}) {
  $locale = $ENV{LC_COLLATE};
}
elsif ($ENV{LANG}) {
  $locale = $ENV{LANG};
}
elsif ($ENV{LC_ALL}) {
  $locale = $ENV{LC_ALL};
}

# ... if nothing, set a default
unless ($locale) {
  if ( $^O =~ /Win/) {
    $locale = 'English_United States.1252';
  }
  else {
    $locale = 'en_US.UTF-8';
  }
}

# datatypes for structure validation
our %STRUCTURE_DATATYPES = (
                            integer => qr/\A\d+\z/xms
);

# In general, these defaults are for two reasons:
# * If there is no .bcf to set these options (-a and -d flags for example)
# * New features which are not implemented in .bcf by biblatex yet and so we have
#   provide defaults in case they are missing.

our %CONFIG_DEFAULT_BIBER = (
  allentries         => 0,
  bblencoding        => 'UTF-8',
  bibdata            =>  undef,
  bibdatatype        => 'bibtex',
  bibencoding        => 'UTF-8',
  collate            => 1,
  collate_options    => { level => 4 },
  debug              => 0,
  displaymode        => $DISPLAYMODE_DEFAULT, # eventually, shall be moved to biblatex options
  mincrossrefs       => 2,
  nolog              => 0,
  nosortdiacritics   => qr/[\x{2bf}\x{2018}]/,
  nosortprefix       => qr/\p{L}{2}\p{Pd}/,
  quiet              => 0,
  sortcase           => 1,
  sortlocale         => $locale,
  sortupper          => 1,
  trace              => 0,
  wraplines          => 0,
  validate_control   => 0,
  validate_structure => 0
  );

# default global options for biblatex
# in practice these will be obtained from the control file,
# but we need this as a fallback, just in case,
# or when using the command-line options "-a -d <datafile>"
# without a bcf file
our %CONFIG_DEFAULT_BIBLATEX =
  (
   alphaothers     => '\textbf{+}',
   controlversion  => undef,
   debug           => '0',
   labelalpha      => '0',
   labelname       => ['shortauthor', 'author', 'shorteditor', 'editor', 'translator'],
   labelnumber     => '0',
   labelyear       => [ 'year' ],
   maxitems        => '3',
   maxnames        => '3',
   minitems        => '1',
   minnames        => '1',
   singletitle     => '0',
   sortalphaothers => '+',
   sortlos         => '1',
   terseinits      => '0',
   uniquename      => '0',
   useauthor       => '1',
   useeditor       => '1',
   useprefix       => '0',
   usetranslator   => '0',
   # Now the defaults for special .bcf sections information
   inheritance     => {
                   defaults => {
                                inherit_all     => 'yes',
                                override_target => 'no',
                                type_pair => []
                               },
                   inherit => [
                               {
                                type_pair => [
                                               {
                                                source => 'proceedings',
                                                target => 'inproceedings'
                                               },
                                               {
                                                source => 'collection',
                                                target => 'incollection',
                                               },
                                               {
                                                source => 'book',
                                                target => 'inbook',
                                               }
                                              ],
                                field => [
                                           {
                                            source => 'title',
                                            target => 'booktitle',
                                            override_target => 'yes',
                                           },
                                           {
                                            source => 'subtitle',
                                            target => 'booksubtitle',
                                            override_target => 'yes',
                                           },
                                           {
                                            source => 'titleaddon',
                                            target => 'booktitleaddon',
                                            override_target => 'yes',
                                           },
                                          ]
                               },
                               {
                                type_pair => [
                                               {
                                                source => 'book',
                                                target => 'inbook',
                                               }
                                              ],
                                field => [
                                           {
                                            source => 'author',
                                            target => 'bookauthor',
                                            override_target => 'yes',
                                           },
                                          ]
                               },
                              ]
                  },
   presort => 'mm',
   sorting_label   =>  [
                [
                 {final          => undef,
                  sort_direction => undef},
                 {
                  'presort'    => {}},
                ],
                [
                 {final          => 1,
                  sort_direction => undef},
                 {
                  'sortkey'    => {}}
                ],
                [
                 {final          => undef,
                  sort_direction => undef},
                 {
                  'sortname'   => {}},
                 {
                  'author'     => {}},
                 {
                  'editor'     => {}},
                 {
                  'translator' => {}},
                 {
                  'sorttitle'  => {}},
                 {
                  'title'      => {}}
                ],
                [
                 {final          => undef,
                  sort_direction => undef},
                 {
                  'sortyear'   => {}},
                 {
                  'year'       => {}}
                ],
                [
                 {final          => undef,
                  sort_direction => undef},
                 {
                  'sorttitle'  => {}},
                 {
                  'title'      => {}}
                ],
                [
                 {final          => undef,
                  sort_direction => undef},
                 {
                  'volume'     => {}},
                 {
                  '0000'       => {}}
                ]
               ],
   structure => {
  aliases     => {
                   alias => [
                     {
                       name => { content => "conference" },
                       realname => { content => "inproceedings" },
                       type => "entrytype",
                     },
                     {
                       name => { content => "electronic" },
                       realname => { content => "online" },
                       type => "entrytype",
                     },
                     {
                       field    => [{ content => "mathesis", name => "type" }],
                       name     => { content => "mastersthesis" },
                       realname => { content => "thesis" },
                       type     => "entrytype",
                     },
                     {
                       field    => [{ content => "phdthesis", name => "type" }],
                       name     => { content => "phdthesis" },
                       realname => { content => "thesis" },
                       type     => "entrytype",
                     },
                     {
                       field    => [{ content => "techreport", name => "type" }],
                       name     => { content => "techreport" },
                       realname => { content => "report" },
                       type     => "entrytype",
                     },
                     {
                       name => { content => "www" },
                       realname => { content => "online" },
                       type => "entrytype",
                     },
                     {
                       name => { content => "address" },
                       realname => { content => "location" },
                       type => "field",
                     },
                     {
                       name => { content => "annote" },
                       realname => { content => "annotation" },
                       type => "field",
                     },
                     {
                       name => { content => "archiveprefix" },
                       realname => { content => "eprinttype" },
                       type => "field",
                     },
                     {
                       name => { content => "journal" },
                       realname => { content => "journaltitle" },
                       type => "field",
                     },
                     {
                       name => { content => "key" },
                       realname => { content => "sortkey" },
                       type => "field",
                     },
                     {
                       name => { content => "pdf" },
                       realname => { content => "file" },
                       type => "field",
                     },
                     {
                       name => { content => "primaryclass" },
                       realname => { content => "eprintclass" },
                       type => "field",
                     },
                     {
                       name => { content => "school" },
                       realname => { content => "institution" },
                       type => "field",
                     },
                   ],
                 },
  constraints => [
                   {
                     constraint => [
                                     {
                                       antecedent => { field => [{ content => "date" }], quant => "all" },
                                       consequent => { field => [{ content => "month" }], quant => "none" },
                                       type => "conditional",
                                     },
                                     {
                                       datatype => "integer",
                                       field    => [{ content => "month" }],
                                       rangemax => 12,
                                       rangemin => 1,
                                       type     => "data",
                                     },
                                     {
                                       datatype => "datespec",
                                       field => [
                                         { content => "date" },
                                         { content => "origdate" },
                                         { content => "eventdate" },
                                         { content => "urldate" },
                                       ],
                                       type => "data",
                                     },
                                   ],
                     entrytype  => [{ content => "ALL" }],
                   },
                   {
                     constraint => [
                                     {
                                       fieldxor => [
                                         {
                                           field => [
                                             { coerce => "true", content => "date" },
                                             { content => "year" },
                                           ],
                                         },
                                       ],
                                       type => "mandatory",
                                     },
                                   ],
                     entrytype  => [
                                     { content => "article" },
                                     { content => "book" },
                                     { content => "inbook" },
                                     { content => "bookinbook" },
                                     { content => "suppbook" },
                                     { content => "booklet" },
                                     { content => "collection" },
                                     { content => "incollection" },
                                     { content => "suppcollection" },
                                     { content => "manual" },
                                     { content => "misc" },
                                     { content => "online" },
                                     { content => "patent" },
                                     { content => "periodical" },
                                     { content => "suppperiodical" },
                                     { content => "proceedings" },
                                     { content => "inproceedings" },
                                     { content => "reference" },
                                     { content => "inreference" },
                                     { content => "report" },
                                     { content => "set" },
                                     { content => "thesis" },
                                     { content => "unpublished" },
                                   ],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "entryset" }, { content => "crossref" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "set" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "journaltitle" },
                                                  { content => "title" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "article" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "author" }, { content => "title" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "book" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "title" },
                                                  { content => "booktitle" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [
                                     { content => "inbook" },
                                     { content => "bookinbook" },
                                     { content => "suppbook" },
                                   ],
                   },
                   {
                     constraint => [
                                     {
                                       field   => [{ content => "title" }],
                                       fieldor => [
                                                    { field => [{ content => "author" }, { content => "editor" }] },
                                                  ],
                                       type    => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "booklet" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "editor" }, { content => "title" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "collection" }, { content => "reference" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "editor" },
                                                  { content => "title" },
                                                  { content => "booktitle" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [
                                     { content => "incollection" },
                                     { content => "suppcollection" },
                                     { content => "inreference" },
                                   ],
                   },
                   {
                     constraint => [{ field => [{ content => "title" }], type => "mandatory" }],
                     entrytype  => [{ content => "manual" }],
                   },
                   {
                     constraint => [{ field => [{ content => "title" }], type => "mandatory" }],
                     entrytype  => [{ content => "misc" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "title" }, { content => "url" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "online" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "title" },
                                                  { content => "number" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "patent" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "editor" }, { content => "title" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "periodical" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "editor" }, { content => "title" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "proceedings" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "editor" },
                                                  { content => "title" },
                                                  { content => "booktitle" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "inproceedings" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "title" },
                                                  { content => "type" },
                                                  { content => "institution" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "report" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [
                                                  { content => "author" },
                                                  { content => "title" },
                                                  { content => "type" },
                                                  { content => "institution" },
                                                ],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "thesis" }],
                   },
                   {
                     constraint => [
                                     {
                                       field => [{ content => "author" }, { content => "title" }],
                                       type  => "mandatory",
                                     },
                                   ],
                     entrytype  => [{ content => "unpublished" }],
                   },
                 ],
  entryfields => [
                   {
                     entrytype => [{ content => "ALL" }],
                     field => [
                       { content => "abstract" },
                       { content => "annotation" },
                       { content => "authortype" },
                       { content => "bookpagination" },
                       { content => "crossref" },
                       { content => "entryset" },
                       { content => "entrysubtype" },
                       { content => "execute" },
                       { content => "file" },
                       { content => "gender" },
                       { content => "hyphenation" },
                       { content => "indextitle" },
                       { content => "indexsorttitle" },
                       { content => "isan" },
                       { content => "ismn" },
                       { content => "iswc" },
                       { content => "keywords" },
                       { content => "label" },
                       { content => "library" },
                       { content => "lista" },
                       { content => "listb" },
                       { content => "listc" },
                       { content => "listd" },
                       { content => "liste" },
                       { content => "listf" },
                       { content => "nameaddon" },
                       { content => "options" },
                       { content => "origdate" },
                       { content => "origlocation" },
                       { content => "origpublisher" },
                       { content => "origtitle" },
                       { content => "pagination" },
                       { content => "presort" },
                       { content => "related" },
                       { content => "relatedtype" },
                       { content => "reprinttitle" },
                       { content => "shortauthor" },
                       { content => "shorteditor" },
                       { content => "shorthand" },
                       { content => "shorthandintro" },
                       { content => "shortjournal" },
                       { content => "shortseries" },
                       { content => "shorttitle" },
                       { content => "sortkey" },
                       { content => "sortname" },
                       { content => "sorttitle" },
                       { content => "sortyear" },
                       { content => "usera" },
                       { content => "userb" },
                       { content => "userc" },
                       { content => "userd" },
                       { content => "usere" },
                       { content => "userf" },
                       { content => "verba" },
                       { content => "verbb" },
                       { content => "verbc" },
                       { content => "xref" },
                     ],
                   },
                   {
                     entrytype => [{ content => "set" }],
                     field => [{ content => "ALL" }],
                   },
                   {
                     entrytype => [{ content => "article" }],
                     field => [
                       { content => "author" },
                       { content => "journaltitle" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "annotator" },
                       { content => "commentator" },
                       { content => "doi" },
                       { content => "editor" },
                       { content => "editora" },
                       { content => "editorb" },
                       { content => "editorc" },
                       { content => "editoratype" },
                       { content => "editorbtype" },
                       { content => "editorctype" },
                       { content => "eid" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "issn" },
                       { content => "issue" },
                       { content => "issuetitle" },
                       { content => "issuesubtitle" },
                       { content => "journalsubtitle" },
                       { content => "language" },
                       { content => "month" },
                       { content => "note" },
                       { content => "number" },
                       { content => "origlanguage" },
                       { content => "pages" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "translator" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "version" },
                       { content => "volume" },
                     ],
                   },
                   {
                     entrytype => [{ content => "book" }],
                     field => [
                       { content => "author" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "afterword" },
                       { content => "annotator" },
                       { content => "chapter" },
                       { content => "commentator" },
                       { content => "doi" },
                       { content => "edition" },
                       { content => "editor" },
                       { content => "editora" },
                       { content => "editorb" },
                       { content => "editorc" },
                       { content => "editoratype" },
                       { content => "editorbtype" },
                       { content => "editorctype" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "foreword" },
                       { content => "introduction" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "maintitle" },
                       { content => "maintitleaddon" },
                       { content => "mainsubtitle" },
                       { content => "note" },
                       { content => "number" },
                       { content => "origlanguage" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "part" },
                       { content => "publisher" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "translator" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "volume" },
                       { content => "volumes" },
                     ],
                   },
                   {
                     entrytype => [
                       { content => "inbook" },
                       { content => "bookinbook" },
                       { content => "suppbook" },
                     ],
                     field => [
                       { content => "author" },
                       { content => "title" },
                       { content => "booktitle" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "afterword" },
                       { content => "annotator" },
                       { content => "bookauthor" },
                       { content => "booksubtitle" },
                       { content => "booktitleaddon" },
                       { content => "chapter" },
                       { content => "commentator" },
                       { content => "doi" },
                       { content => "edition" },
                       { content => "editor" },
                       { content => "editora" },
                       { content => "editorb" },
                       { content => "editorc" },
                       { content => "editoratype" },
                       { content => "editorbtype" },
                       { content => "editorctype" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "foreword" },
                       { content => "introduction" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "mainsubtitle" },
                       { content => "maintitle" },
                       { content => "maintitleaddon" },
                       { content => "note" },
                       { content => "number" },
                       { content => "origlanguage" },
                       { content => "part" },
                       { content => "publisher" },
                       { content => "pages" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "translator" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "volume" },
                       { content => "volumes" },
                     ],
                   },
                   {
                     entrytype => [{ content => "booklet" }],
                     field => [
                       { content => "author" },
                       { content => "editor" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "chapter" },
                       { content => "doi" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "howpublished" },
                       { content => "language" },
                       { content => "location" },
                       { content => "note" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "type" },
                       { content => "url" },
                       { content => "urldate" },
                     ],
                   },
                   {
                     entrytype => [{ content => "collection" }, { content => "reference" }],
                     field => [
                       { content => "editor" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "afterword" },
                       { content => "annotator" },
                       { content => "chapter" },
                       { content => "commentator" },
                       { content => "doi" },
                       { content => "edition" },
                       { content => "editora" },
                       { content => "editorb" },
                       { content => "editorc" },
                       { content => "editoratype" },
                       { content => "editorbtype" },
                       { content => "editorctype" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "foreword" },
                       { content => "introduction" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "mainsubtitle" },
                       { content => "maintitle" },
                       { content => "maintitleaddon" },
                       { content => "note" },
                       { content => "number" },
                       { content => "origlanguage" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "part" },
                       { content => "publisher" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "translator" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "volume" },
                       { content => "volumes" },
                     ],
                   },
                   {
                     entrytype => [
                       { content => "incollection" },
                       { content => "suppcollection" },
                       { content => "inreference" },
                     ],
                     field => [
                       { content => "author" },
                       { content => "editor" },
                       { content => "title" },
                       { content => "booktitle" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "afterword" },
                       { content => "annotator" },
                       { content => "booksubtitle" },
                       { content => "booktitleaddon" },
                       { content => "chapter" },
                       { content => "commentator" },
                       { content => "doi" },
                       { content => "edition" },
                       { content => "editora" },
                       { content => "editorb" },
                       { content => "editorc" },
                       { content => "editoratype" },
                       { content => "editorbtype" },
                       { content => "editorctype" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "foreword" },
                       { content => "introduction" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "mainsubtitle" },
                       { content => "maintitle" },
                       { content => "maintitleaddon" },
                       { content => "note" },
                       { content => "number" },
                       { content => "origlanguage" },
                       { content => "pages" },
                       { content => "part" },
                       { content => "publisher" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "translator" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "volume" },
                       { content => "volumes" },
                     ],
                   },
                   {
                     entrytype => [{ content => "manual" }],
                     field => [
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "author" },
                       { content => "chapter" },
                       { content => "doi" },
                       { content => "edition" },
                       { content => "editor" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "note" },
                       { content => "number" },
                       { content => "organization" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "publisher" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "type" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "version" },
                     ],
                   },
                   {
                     entrytype => [{ content => "misc" }],
                     field => [
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "author" },
                       { content => "doi" },
                       { content => "editor" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "howpublished" },
                       { content => "language" },
                       { content => "location" },
                       { content => "month" },
                       { content => "note" },
                       { content => "organization" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "type" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "version" },
                     ],
                   },
                   {
                     entrytype => [{ content => "online" }],
                     field => [
                       { content => "title" },
                       { content => "url" },
                       { content => "addendum" },
                       { content => "author" },
                       { content => "editor" },
                       { content => "language" },
                       { content => "month" },
                       { content => "note" },
                       { content => "organization" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "urldate" },
                       { content => "version" },
                       { content => "year" },
                     ],
                   },
                   {
                     entrytype => [{ content => "patent" }],
                     field => [
                       { content => "author" },
                       { content => "title" },
                       { content => "number" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "doi" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "holder" },
                       { content => "location" },
                       { content => "month" },
                       { content => "note" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "type" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "version" },
                     ],
                   },
                   {
                     entrytype => [{ content => "periodical" }],
                     field => [
                       { content => "editor" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "doi" },
                       { content => "editora" },
                       { content => "editorb" },
                       { content => "editorc" },
                       { content => "editoratype" },
                       { content => "editorbtype" },
                       { content => "editorctype" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "issn" },
                       { content => "issue" },
                       { content => "issuesubtitle" },
                       { content => "issuetitle" },
                       { content => "language" },
                       { content => "month" },
                       { content => "note" },
                       { content => "number" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "volume" },
                     ],
                   },
                   {
                     entrytype => [{ content => "proceedings" }],
                     field => [
                       { content => "editor" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "chapter" },
                       { content => "doi" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "eventdate" },
                       { content => "eventtitle" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "mainsubtitle" },
                       { content => "maintitle" },
                       { content => "maintitleaddon" },
                       { content => "month" },
                       { content => "note" },
                       { content => "number" },
                       { content => "organization" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "part" },
                       { content => "publisher" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "venue" },
                       { content => "volume" },
                       { content => "volumes" },
                     ],
                   },
                   {
                     entrytype => [{ content => "inproceedings" }],
                     field => [
                       { content => "author" },
                       { content => "editor" },
                       { content => "title" },
                       { content => "booktitle" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "booksubtitle" },
                       { content => "booktitleaddon" },
                       { content => "chapter" },
                       { content => "doi" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "eventdate" },
                       { content => "eventtitle" },
                       { content => "isbn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "mainsubtitle" },
                       { content => "maintitle" },
                       { content => "maintitleaddon" },
                       { content => "month" },
                       { content => "note" },
                       { content => "number" },
                       { content => "organization" },
                       { content => "pages" },
                       { content => "part" },
                       { content => "publisher" },
                       { content => "pubstate" },
                       { content => "series" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "venue" },
                       { content => "volume" },
                       { content => "volumes" },
                     ],
                   },
                   {
                     entrytype => [{ content => "report" }],
                     field => [
                       { content => "author" },
                       { content => "title" },
                       { content => "type" },
                       { content => "institution" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "chapter" },
                       { content => "doi" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "isrn" },
                       { content => "language" },
                       { content => "location" },
                       { content => "month" },
                       { content => "note" },
                       { content => "number" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "url" },
                       { content => "urldate" },
                       { content => "version" },
                     ],
                   },
                   {
                     entrytype => [{ content => "thesis" }],
                     field => [
                       { content => "author" },
                       { content => "title" },
                       { content => "type" },
                       { content => "institution" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "chapter" },
                       { content => "doi" },
                       { content => "eprint" },
                       { content => "eprintclass" },
                       { content => "eprinttype" },
                       { content => "language" },
                       { content => "location" },
                       { content => "month" },
                       { content => "note" },
                       { content => "pages" },
                       { content => "pagetotal" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "url" },
                       { content => "urldate" },
                     ],
                   },
                   {
                     entrytype => [{ content => "unpublished" }],
                     field => [
                       { content => "author" },
                       { content => "title" },
                       { content => "year" },
                       { content => "date" },
                       { content => "addendum" },
                       { content => "howpublished" },
                       { content => "language" },
                       { content => "location" },
                       { content => "month" },
                       { content => "note" },
                       { content => "pubstate" },
                       { content => "subtitle" },
                       { content => "titleaddon" },
                       { content => "url" },
                       { content => "urldate" },
                     ],
                   },
                 ],
  entrytypes  => {
                   entrytype => [
                     { content => "article" },
                     { content => "artwork" },
                     { content => "audio" },
                     { content => "book" },
                     { content => "bookinbook" },
                     { content => "booklet" },
                     { content => "collection" },
                     { content => "commentary" },
                     { content => "customa" },
                     { content => "customb" },
                     { content => "customc" },
                     { content => "customd" },
                     { content => "custome" },
                     { content => "customf" },
                     { content => "inbook" },
                     { content => "incollection" },
                     { content => "inproceedings" },
                     { content => "inreference" },
                     { content => "image" },
                     { content => "jurisdiction" },
                     { content => "legal" },
                     { content => "legislation" },
                     { content => "letter" },
                     { content => "manual" },
                     { content => "misc" },
                     { content => "movie" },
                     { content => "music" },
                     { content => "online" },
                     { content => "patent" },
                     { content => "performance" },
                     { content => "periodical" },
                     { content => "proceedings" },
                     { content => "reference" },
                     { content => "report" },
                     { content => "review" },
                     { content => "set" },
                     { content => "software" },
                     { content => "standard" },
                     { content => "suppbook" },
                     { content => "suppcollection" },
                     { content => "thesis" },
                     { content => "unpublished" },
                     { content => "video" },
                   ],
                 },
  fields      => {
                   field => [
                     { content => "abstract", datatype => "literal", fieldtype => "field" },
                     { content => "addendum", datatype => "literal", fieldtype => "field" },
                     { content => "afterword", datatype => "name", fieldtype => "list" },
                     { content => "annotation", datatype => "literal", fieldtype => "field" },
                     { content => "annotator", datatype => "name", fieldtype => "list" },
                     { content => "author", datatype => "name", fieldtype => "list" },
                     { content => "authortype", datatype => "key", fieldtype => "field" },
                     { content => "bookauthor", datatype => "name", fieldtype => "list" },
                     { content => "bookpagination", datatype => "key", fieldtype => "field" },
                     { content => "booksubtitle", datatype => "literal", fieldtype => "field" },
                     { content => "booktitle", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "booktitleaddon",
                       datatype  => "literal",
                       fieldtype => "field",
                     },
                     { content => "chapter", datatype => "literal", fieldtype => "field" },
                     { content => "commentator", datatype => "name", fieldtype => "list" },
                     { content => "crossref", datatype => "literal", fieldtype => "field" },
                     {
                       content     => "date",
                       datatype    => "date",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     { content => "day", datatype => "literal", fieldtype => "field" },
                     { content => "doi", datatype => "verbatim", fieldtype => "field" },
                     { content => "edition", datatype => "literal", fieldtype => "field" },
                     { content => "editor", datatype => "name", fieldtype => "list" },
                     { content => "editora", datatype => "name", fieldtype => "list" },
                     { content => "editoratype", datatype => "key", fieldtype => "field" },
                     { content => "editorb", datatype => "name", fieldtype => "list" },
                     { content => "editorbtype", datatype => "key", fieldtype => "field" },
                     { content => "editorc", datatype => "name", fieldtype => "list" },
                     { content => "editorctype", datatype => "key", fieldtype => "field" },
                     { content => "editortype", datatype => "key", fieldtype => "field" },
                     { content => "eid", datatype => "literal", fieldtype => "field" },
                     { content => "endday", datatype => "literal", fieldtype => "field" },
                     { content => "endmonth", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "endyear",
                       datatype  => "literal",
                       fieldtype => "field",
                       nullok    => "true",
                     },
                     { content => "entryset", datatype => "literal", fieldtype => "field", skip_output => "true"},
                     { content => "entrysubtype", datatype => "literal", fieldtype => "field" },
                     { content => "eprint", datatype => "verbatim", fieldtype => "field" },
                     { content => "eprintclass", datatype => "literal", fieldtype => "field" },
                     { content => "eprinttype", datatype => "literal", fieldtype => "field" },
                     {
                       content     => "eventdate",
                       datatype    => "literal",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     { content => "eventday", datatype => "literal", fieldtype => "field" },
                     { content => "eventendday", datatype => "literal", fieldtype => "field" },
                     { content => "eventendmonth", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "eventendyear",
                       datatype  => "literal",
                       fieldtype => "field",
                       nullok    => "true",
                     },
                     { content => "eventmonth", datatype => "literal", fieldtype => "field" },
                     { content => "eventtitle", datatype => "literal", fieldtype => "field" },
                     { content => "eventyear", datatype => "literal", fieldtype => "field" },
                     { content => "execute", datatype => "literal", fieldtype => "field" },
                     { content => "file", datatype => "verbatim", fieldtype => "field" },
                     { content => "foreword", datatype => "name", fieldtype => "list" },
                     { content => "gender", datatype => "literal", fieldtype => "field" },
                     { content => "holder", datatype => "name", fieldtype => "list" },
                     { content => "howpublished", datatype => "literal", fieldtype => "field" },
                     { content => "hyphenation", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "indexsorttitle",
                       datatype  => "literal",
                       fieldtype => "field",
                     },
                     { content => "indextitle", datatype => "literal", fieldtype => "field" },
                     { content => "institution", datatype => "literal", fieldtype => "list" },
                     { content => "introduction", datatype => "name", fieldtype => "list" },
                     { content => "isan", datatype => "literal", fieldtype => "field" },
                     { content => "isbn", datatype => "literal", fieldtype => "field" },
                     { content => "ismn", datatype => "literal", fieldtype => "field" },
                     { content => "isrn", datatype => "literal", fieldtype => "field" },
                     { content => "issn", datatype => "literal", fieldtype => "field" },
                     { content => "issue", datatype => "literal", fieldtype => "field" },
                     { content => "issuesubtitle", datatype => "literal", fieldtype => "field" },
                     { content => "issuetitle", datatype => "literal", fieldtype => "field" },
                     { content => "iswc", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "journalsubtitle",
                       datatype  => "literal",
                       fieldtype => "field",
                     },
                     { content => "journaltitle", datatype => "literal", fieldtype => "field" },
                     { content => "keywords", datatype => "literal", fieldtype => "field" },
                     { content => "label", datatype => "literal", fieldtype => "field" },
                     { content => "language", datatype => "key", fieldtype => "list" },
                     { content => "library", datatype => "literal", fieldtype => "field" },
                     { content => "lista", datatype => "literal", fieldtype => "list" },
                     { content => "listb", datatype => "literal", fieldtype => "list" },
                     { content => "listc", datatype => "literal", fieldtype => "list" },
                     { content => "listd", datatype => "literal", fieldtype => "list" },
                     { content => "liste", datatype => "literal", fieldtype => "list" },
                     { content => "listf", datatype => "literal", fieldtype => "list" },
                     { content => "location", datatype => "literal", fieldtype => "list" },
                     { content => "mainsubtitle", datatype => "literal", fieldtype => "field" },
                     { content => "maintitle", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "maintitleaddon",
                       datatype  => "literal",
                       fieldtype => "field",
                     },
                     { content => "month", datatype => "integer", fieldtype => "field" },
                     { content => "namea", datatype => "name", fieldtype => "list" },
                     { content => "nameaddon", datatype => "literal", fieldtype => "field" },
                     { content => "nameatype", datatype => "key", fieldtype => "field" },
                     { content => "nameb", datatype => "name", fieldtype => "list" },
                     { content => "namebtype", datatype => "key", fieldtype => "field" },
                     { content => "namec", datatype => "name", fieldtype => "list" },
                     { content => "namectype", datatype => "key", fieldtype => "field" },
                     { content => "note", datatype => "literal", fieldtype => "field" },
                     { content => "number", datatype => "literal", fieldtype => "field" },
                     { content => "options", datatype => "literal", fieldtype => "field" },
                     { content => "organization", datatype => "literal", fieldtype => "list" },
                     {
                       content     => "origdate",
                       datatype    => "date",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     { content => "origday", datatype => "literal", fieldtype => "field" },
                     { content => "origendday", datatype => "literal", fieldtype => "field" },
                     { content => "origendmonth", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "origendyear",
                       datatype  => "literal",
                       fieldtype => "field",
                       nullok    => "true",
                     },
                     { content => "origlanguage", datatype => "key", fieldtype => "field" },
                     { content => "origlocation", datatype => "literal", fieldtype => "list" },
                     { content => "origmonth", datatype => "literal", fieldtype => "field" },
                     { content => "origpublisher", datatype => "literal", fieldtype => "list" },
                     { content => "origtitle", datatype => "literal", fieldtype => "field" },
                     { content => "origyear", datatype => "literal", fieldtype => "field" },
                     { content => "pages", datatype => "range", fieldtype => "field" },
                     { content => "pagetotal", datatype => "literal", fieldtype => "field" },
                     { content => "pagination", datatype => "key", fieldtype => "field" },
                     { content => "part", datatype => "literal", fieldtype => "field" },
                     {
                       content     => "presort",
                       datatype    => "literal",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     { content => "publisher", datatype => "literal", fieldtype => "list" },
                     { content => "pubstate", datatype => "key", fieldtype => "field" },
                     { content => "related", datatype => "literal", fieldtype => "field" },
                     { content => "relatedtype", datatype => "literal", fieldtype => "field" },
                     { content => "reprinttitle", datatype => "literal", fieldtype => "field" },
                     { content => "series", datatype => "literal", fieldtype => "field" },
                     { content => "shortauthor", datatype => "name", fieldtype => "list" },
                     { content => "shorteditor", datatype => "name", fieldtype => "list" },
                     { content => "shorthand", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "shorthandintro",
                       datatype  => "literal",
                       fieldtype => "field",
                     },
                     { content => "shortjournal", datatype => "literal", fieldtype => "field" },
                     { content => "shortseries", datatype => "literal", fieldtype => "field" },
                     { content => "shorttitle", datatype => "literal", fieldtype => "field" },
                     {
                       content     => "sortkey",
                       datatype    => "literal",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     {
                       content     => "sortname",
                       datatype    => "literal",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     {
                       content     => "sorttitle",
                       datatype    => "literal",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     {
                       content     => "sortyear",
                       datatype    => "literal",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     { content => "subtitle", datatype => "literal", fieldtype => "field" },
                     { content => "title", datatype => "literal", fieldtype => "field" },
                     { content => "titleaddon", datatype => "literal", fieldtype => "field" },
                     { content => "translator", datatype => "name", fieldtype => "list" },
                     { content => "type", datatype => "key", fieldtype => "field" },
                     { content => "url", datatype => "verbatim", fieldtype => "field" },
                     {
                       content     => "urldate",
                       datatype    => "date",
                       fieldtype   => "field",
                       skip_output => "true",
                     },
                     { content => "usera", datatype => "literal", fieldtype => "field" },
                     { content => "userb", datatype => "literal", fieldtype => "field" },
                     { content => "userc", datatype => "literal", fieldtype => "field" },
                     { content => "userd", datatype => "literal", fieldtype => "field" },
                     { content => "usere", datatype => "literal", fieldtype => "field" },
                     { content => "userf", datatype => "literal", fieldtype => "field" },
                     { content => "urlday", datatype => "literal", fieldtype => "field" },
                     { content => "urlendday", datatype => "literal", fieldtype => "field" },
                     { content => "urlendmonth", datatype => "literal", fieldtype => "field" },
                     {
                       content   => "urlendyear",
                       datatype  => "literal",
                       fieldtype => "field",
                       nullok    => "true",
                     },
                     { content => "urlmonth", datatype => "literal", fieldtype => "field" },
                     { content => "urlyear", datatype => "literal", fieldtype => "field" },
                     { content => "venue", datatype => "literal", fieldtype => "field" },
                     { content => "verba", datatype => "verbatim", fieldtype => "field" },
                     { content => "verbb", datatype => "verbatim", fieldtype => "field" },
                     { content => "verbc", datatype => "verbatim", fieldtype => "field" },
                     { content => "version", datatype => "literal", fieldtype => "field" },
                     { content => "volume", datatype => "literal", fieldtype => "field" },
                     { content => "volumes", datatype => "literal", fieldtype => "field" },
                     { content => "xref", datatype => "literal", fieldtype => "field" },
                     { content => "year", datatype => "literal", fieldtype => "field" },
                   ],
                 },
}
  );
$CONFIG_DEFAULT_BIBLATEX{sorting_final} = $CONFIG_DEFAULT_BIBLATEX{sorting_label};

# Set up some encoding aliases to map \inputen{c,x} encoding names to Encode
# It seems that inputen{c,x} has a different idea of nextstep than Encode
# so we push it to MacRoman
define_alias( 'ansinew'        => 'cp1252'); # inputenc alias for cp1252
define_alias( 'applemac'       => 'MacRoman');
define_alias( 'applemacce'     => 'MacCentralEurRoman');
define_alias( 'next'           => 'MacRoman');
define_alias( 'x-mac-roman'    => 'MacRoman');
define_alias( 'x-mac-centeuro' => 'MacCentralEurRoman');
define_alias( 'x-mac-cyrillic' => 'MacCyrillic');
define_alias( 'x-nextstep'     => 'MacRoman');
define_alias( 'x-ascii'        => 'ascii'); # Encode doesn't resolve this one by default
define_alias( 'lutf8'          => 'UTF-8'); # Luatex
define_alias( 'utf8x'          => 'UTF-8'); # UCS (old)

# Defines the scope of each of the BibLaTeX configuration options
our %CONFIG_SCOPE_BIBLATEX = (
  alphaothers       => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  controlversion    => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  debug             => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  dataonly          => {GLOBAL => 0, PER_TYPE => 0, PER_ENTRY => 1},
  inheritance       => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  labelalpha        => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  labelname         => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  labelnumber       => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  labelyear         => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  maxitems          => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  minitems          => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  maxnames          => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  minnames          => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  presort           => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 1},
  singletitle       => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  skipbib           => {GLOBAL => 0, PER_TYPE => 1, PER_ENTRY => 1},
  skiplab           => {GLOBAL => 0, PER_TYPE => 1, PER_ENTRY => 1},
  skiplos           => {GLOBAL => 0, PER_TYPE => 1, PER_ENTRY => 1},
  sortalphaothers   => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  sortexclusion     => {GLOBAL => 0, PER_TYPE => 1, PER_ENTRY => 0},
  sorting           => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  sorting_label     => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  sorting_final     => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  sortlos           => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  structure         => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  terseinits        => {GLOBAL => 1, PER_TYPE => 0, PER_ENTRY => 0},
  uniquename        => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 0},
  useauthor         => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 1},
  useeditor         => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 1},
  useprefix         => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 1},
  usetranslator     => {GLOBAL => 1, PER_TYPE => 1, PER_ENTRY => 1},
);

Readonly::Hash our %NUMERICALMONTH => (
  'January' => 1,
  'February' => 2,
  'March' => 3,
  'April' => 4,
  'May' => 5,
  'June' => 6,
  'July' => 7,
  'August' => 8,
  'September' => 9,
  'October' => 10,
  'November' => 11,
  'December' => 12,
  'january' => 1,
  'february' => 2,
  'march' => 3,
  'april' => 4,
  'may' => 5,
  'june' => 6,
  'july' => 7,
  'august' => 8,
  'september' => 9,
  'october' => 10,
  'november' => 11,
  'december' => 12,
  'jan' => 1,
  'feb' => 2,
  'mar' => 3,
  'apr' => 4,
  'may' => 5,
  'jun' => 6,
  'jul' => 7,
  'aug' => 8,
  'sep' => 9,
  'oct' => 10,
  'nov' => 11,
  'dec' => 12
  );


Readonly::Hash our %DISPLAYMODES => {
  uniform => [ qw/uniform romanized translated original/ ],
  translated => [ qw/translated uniform romanized original/ ],
  romanized => [ qw/romanized uniform translated original/ ],
  original => [ qw/original romanized uniform translated/ ]
  } ;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Biber::Constants - global constants for biber

=head1 AUTHOR

François Charette, C<< <firmicus at gmx.net> >>
Philip Kime C<< <philip at kime.org.uk> >>

=head1 BUGS

Please report any bugs or feature requests on our sourceforge tracker at
L<https://sourceforge.net/tracker2/?func=browse&group_id=228270>.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2011 François Charette and Philip Kime, all rights reserved.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# vim: set tabstop=2 shiftwidth=2 expandtab:
