package Biber::LaTeX::Recode::Data;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT    = qw[ %ACCENTS           %ACCENTS_R
                     %WORDMACROS        %WORDMACROS_R
                     %DIACRITICS        %DIACRITICS_R
                     %WORDMACROSEXTRA   %WORDMACROSEXTRA_R
                     %DIACRITICSEXTRA   %DIACRITICSEXTRA_R
                     %PUNCTUATION       %PUNCTUATION_R
                     %NEGATEDSYMBOLS    %NEGATEDSYMBOLS_R
                     %SUPERSCRIPTS      %SUPERSCRIPTS_R
                     %SYMBOLS           %SYMBOLS_R
                     %CMDSUPERSCRIPTS   %CMDSUPERSCRIPTS_R
                     %DINGS             %DINGS_R
                     %GREEK             %GREEK_R
                                        %ENCODE_EXCLUDE_R
                     $ACCENTS_RE        $ACCENTS_RE_R
                     $DIAC_RE_BASE      $DIAC_RE_BASE_R
                     $DIAC_RE_EXTRA     $DIAC_RE_EXTRA_R
                     $NEG_SYMB_RE       $NEG_SYMB_RE_R
                     $SUPER_RE          $SUPER_RE_R
                     $SUPERCMD_RE       $SUPERCMD_RE_R
                                        $DINGS_RE_R
                  ];

our %ACCENTS = (
    chr(0x60) => "\x{300}", #`
    chr(0x27) => "\x{301}", #'
    chr(0x5e) => "\x{302}", #^
    chr(0x7e) => "\x{303}", #~
    chr(0x3d) => "\x{304}", #=
    chr(0x2e) => "\x{307}", #.
    chr(0x22) => "\x{308}", #"
);

our %ACCENTS_R = reverse %ACCENTS;

our %WORDMACROS = (
    textquotedbl         => "\x{0022}",
    texthash             => "\x{0023}",
    textdollar           => "\x{0024}",
    textpercent          => "\x{0025}",
    textampersand        => "\x{0026}",
    textquotesingle      => "\x{0027}",
    textasteriskcentered => "\x{002A}",
    textless             => "\x{003C}",
    textequals           => "\x{003D}",
    textgreater          => "\x{003E}",
    textbackslash        => "\x{005C}",
    textasciicircum      => "\x{005E}",
    textunderscore       => "\x{005F}",
    textasciigrave       => "\x{0060}",
    textg                => "\x{0067}",
    textbraceleft        => "\x{007B}",
    textbar              => "\x{007C}",
    textbraceright       => "\x{007D}",
    textasciitilde       => "\x{007E}",
    nobreakspace         => "\x{00A0}",
    textexclamdown       => "\x{00A1}",
    textcent             => "\x{00A2}",
    pounds               => "\x{00A3}",
    textsterling         => "\x{00A3}",
    textcurrency         => "\x{00A4}",
    textyen              => "\x{00A5}",
    textbrokenbar        => "\x{00A6}",
    S                    => "\x{00A7}",
    textsection          => "\x{00A7}",
    textasciidieresis    => "\x{00A8}",
    copyright            => "\x{00A9}",
    textcopyright        => "\x{00A9}",
    textordfeminine      => "\x{00AA}",
    guillemotleft        => "\x{00AB}",
    lnot                 => "\x{00AC}",
    textlogicalnot       => "\x{00AC}",
    textminus            => "\x{2212}",
    textregistered       => "\x{00AE}",
    textasciimacron      => "\x{00AF}",
    textdegree           => "\x{00B0}",
    pm                   => "\x{00B1}",
    textpm               => "\x{00B1}",
    texttwosuperior      => "\x{00B2}",
    textthreesuperior    => "\x{00B3}",
    textasciiacute       => "\x{00B4}",
    mu                   => "\x{00B5}",
    textmu               => "\x{00B5}",
    P                    => "\x{00B6}",
    textparagraph        => "\x{00B6}",
    textperiodcentered   => "\x{00B7}",
    textcentereddot      => "\x{00B7}",
    textasciicedilla     => "\x{00B8}",
    textonesuperior      => "\x{00B9}",
    textordmasculine     => "\x{00BA}",
    guillemotright       => "\x{00BB}",
    textonequarter       => "\x{00BC}",
    textonehalf          => "\x{00BD}",
    textthreequarters    => "\x{00BE}",
    textquestiondown     => "\x{00BF}",
    AA                   => "\x{00C5}",
    AE                   => "\x{00C6}",
    DH                   => "\x{00D0}",
    times                => "\x{00D7}",
    texttimes            => "\x{00D7}",
    O                    => "\x{00D8}",
    TH                   => "\x{00DE}",
    Thorn                => "\x{00DE}",
    ss                   => "\x{00DF}",
    aa                   => "\x{00E5}",
    ae                   => "\x{00E6}",
    dh                   => "\x{00F0}",
    div                  => "\x{00F7}",
    textdiv              => "\x{00F7}",
    o                    => "\x{00F8}",
    th                   => "\x{00FE}",
    textthorn            => "\x{00FE}",
    textthornvari        => "\x{00FE}",
    textthornvarii       => "\x{00FE}",
    textthornvariii      => "\x{00FE}",
    textthornvariv       => "\x{00FE}",
    DJ                   => "\x{0110}",
    dj                   => "\x{0111}",
    textcrd              => "\x{0111}",
    textHbar             => "\x{0126}",
    textcrh              => "\x{0127}",
    texthbar             => "\x{0127}",
    i                    => "\x{0131}",
    IJ                   => "\x{0132}",
    ij                   => "\x{0133}",
    textkra              => "\x{0138}",
    L                    => "\x{0141}",
    l                    => "\x{0142}",
    textbarl             => "\x{0142}",
    NG                   => "\x{014A}",
    ng                   => "\x{014B}",
    OE                   => "\x{0152}",
    oe                   => "\x{0153}"
);

our %WORDMACROS_R = reverse %WORDMACROS;

our %WORDMACROSEXTRA = (
    textTbar            => "\x{0166}",
    textTstroke         => "\x{0166}",
    texttbar            => "\x{0167}",
    texttstroke         => "\x{0167}",
    textcrb             => "\x{0180}",
    textBhook           => "\x{0181}",
    textOopen           => "\x{0186}",
    textChook           => "\x{0187}",
    textchook           => "\x{0188}",
    texthtc             => "\x{0188}",
    textDafrican        => "\x{0189}",
    textDhook           => "\x{018A}",
    textEreversed       => "\x{018E}",
    textEopen           => "\x{0190}",
    textFhook           => "\x{0191}",
    textflorin          => "\x{0192}",
    textGammaafrican    => "\x{0194}",
    texthvlig           => "\x{0195}",
    hv                  => "\x{0195}",
    textIotaafrican     => "\x{0196}",
    textKhook           => "\x{0198}",
    textkhook           => "\x{0199}",
    texthtk             => "\x{0199}",
    textcrlambda        => "\x{019B}",
    textNhookleft       => "\x{019D}",
    OHORN               => "\x{01A0}",
    ohorn               => "\x{01A1}",
    textPhook           => "\x{01A4}",
    textphook           => "\x{01A5}",
    texthtp             => "\x{01A5}",
    textEsh             => "\x{01A9}",
    ESH                 => "\x{01A9}",
    textlooptoprevesh   => "\x{01AA}",
    textpalhookbelow    => "\x{01AB}",
    textThook           => "\x{01AC}",
    textthook           => "\x{01AD}",
    texthtt             => "\x{01AD}",
    textTretroflexhook  => "\x{01AE}",
    UHORN               => "\x{01AF}",
    uhorn               => "\x{01B0}",
    textVhook           => "\x{01B2}",
    textYhook           => "\x{01B3}",
    textyhook           => "\x{01B4}",
    textEzh             => "\x{01B7}",
    texteturned         => "\x{01DD}",
    textturna           => "\x{0250}",
    textscripta         => "\x{0251}",
    textturnscripta     => "\x{0252}",
    textbhook           => "\x{0253}",
    texthtb             => "\x{0253}",
    textoopen           => "\x{0254}",
    textopeno           => "\x{0254}",
    textctc             => "\x{0255}",
    textdtail           => "\x{0256}",
    textrtaild          => "\x{0256}",
    textdhook           => "\x{0257}",
    texthtd             => "\x{0257}",
    textreve            => "\x{0258}",
    textschwa           => "\x{0259}",
    textrhookschwa      => "\x{025A}",
    texteopen           => "\x{025B}",
    textepsilon         => "\x{025B}",
    textrevepsilon      => "\x{025C}",
    textrhookrevepsilon => "\x{025D}",
    textcloserevepsilon => "\x{025E}",
    textbardotlessj     => "\x{025F}",
    texthtg             => "\x{0260}",
    textscriptg         => "\x{0261}",
    textscg             => "\x{0262}",
    textgammalatinsmall => "\x{0263}",
    textgamma           => "\x{0263}",
    textramshorns       => "\x{0264}",
    textturnh           => "\x{0265}",
    texthth             => "\x{0266}",
    texththeng          => "\x{0267}",
    textbari            => "\x{0268}",
    textiotalatin       => "\x{0269}",
    textiota            => "\x{0269}",
    textsci             => "\x{026A}",
    textltilde          => "\x{026B}",
    textbeltl           => "\x{026C}",
    textrtaill          => "\x{026D}",
    textlyoghlig        => "\x{026E}",
    textturnm           => "\x{026F}",
    textturnmrleg       => "\x{0270}",
    textltailm          => "\x{0271}",
    textltailn          => "\x{0272}",
    textnhookleft       => "\x{0272}",
    textrtailn          => "\x{0273}",
    textscn             => "\x{0274}",
    textbaro            => "\x{0275}",
    textscoelig         => "\x{0276}",
    textcloseomega      => "\x{0277}",
    textphi             => "\x{0278}",
    textturnr           => "\x{0279}",
    textturnlonglegr    => "\x{027A}",
    textturnrrtail      => "\x{027B}",
    textlonglegr        => "\x{027C}",
    textrtailr          => "\x{027D}",
    textfishhookr       => "\x{027E}",
    textlhti            => "\x{027F}",    # ??
    textscr             => "\x{0280}",
    textinvscr          => "\x{0281}",
    textrtails          => "\x{0282}",
    textesh             => "\x{0283}",
    texthtbardotlessj   => "\x{0284}",
    textraisevibyi      => "\x{0285}",    # ??
    textctesh           => "\x{0286}",
    textturnt           => "\x{0287}",
    textrtailt          => "\x{0288}",
    texttretroflexhook  => "\x{0288}",
    textbaru            => "\x{0289}",
    textupsilon         => "\x{028A}",
    textscriptv         => "\x{028B}",
    textvhook           => "\x{028B}",
    textturnv           => "\x{028C}",
    textturnw           => "\x{028D}",
    textturny           => "\x{028E}",
    textscy             => "\x{028F}",
    textrtailz          => "\x{0290}",
    textctz             => "\x{0291}",
    textezh             => "\x{0292}",
    textyogh            => "\x{0292}",
    textctyogh          => "\x{0293}",
    textglotstop        => "\x{0294}",
    textrevglotstop     => "\x{0295}",
    textinvglotstop     => "\x{0296}",
    textstretchc        => "\x{0297}",
    textbullseye        => "\x{0298}",
    textscb             => "\x{0299}",
    textcloseepsilon    => "\x{029A}",
    texthtscg           => "\x{029B}",
    textsch             => "\x{029C}",
    textctj             => "\x{029D}",
    textturnk           => "\x{029E}",
    textscl             => "\x{029F}",
    texthtq             => "\x{02A0}",
    textbarglotstop     => "\x{02A1}",
    textbarrevglotstop  => "\x{02A2}",
    textdzlig           => "\x{02A3}",
    textdyoghlig        => "\x{02A4}",
    textdctzlig         => "\x{02A5}",
    texttslig           => "\x{02A6}",
    textteshlig         => "\x{02A7}",
    texttesh            => "\x{02A7}",
    texttctclig         => "\x{02A8}",
    hamza               => "\x{02BE}",
    ain                 => "\x{02BF}",
    ayn                 => "\x{02BF}",
    textprimstress      => "\x{02C8}",
    textlengthmark      => "\x{02D0}"
);

our %WORDMACROSEXTDA_R = reverse %WORDMACROSEXTRA;

our %DIACRITICS = (
    r => "\x{030A}",
    H => "\x{030B}",
    u => "\x{0306}",
    v => "\x{030C}",
    G => "\x{030F}",
    M => "\x{0322}",
    d => "\x{0323}",
    c => "\x{0327}",
    k => "\x{0328}",
    b => "\x{0331}",
    B => "\x{0335}",
    t => "\x{0311}",
);

our %DIACRITICS_R = reverse %DIACRITICS;

our %DIACRITICSEXTRA = (
    textvbaraccent        => "\x{030D}",
    textdoublevbaraccent  => "\x{030E}",
    textdotbreve          => "\x{0310}",
    textturncommaabove    => "\x{0312}",
    textcommaabove        => "\x{0313}",
    textrevcommaabove     => "\x{0314}",
    textcommaabover       => "\x{0315}",
    textsubgrave          => "\x{0316}",
    textsubacute          => "\x{0317}",
    textadvancing         => "\x{0318}",
    textretracting        => "\x{0319}",
    textlangleabove       => "\x{031A}",
    textrighthorn         => "\x{031B}",
    textsublhalfring      => "\x{031C}",
    textraising           => "\x{031D}",
    textlowering          => "\x{031E}",
    textsubplus           => "\x{031F}",
    textsubbar            => "\x{0320}",
    textsubminus          => "\x{0320}",
    textpalhookbelow      => "\x{0321}",
    textsubumlaut         => "\x{0324}",
    textsubring           => "\x{0325}",
    textcommabelow        => "\x{0326}",
    textsyllabic          => "\x{0329}",
    textsubbridge         => "\x{032A}",
    textsubw              => "\x{032B}",
    textsubwedge          => "\x{032C}",
    textsubcircnum        => "\x{032D}",
    textsubbreve          => "\x{032E}",
    textundertie          => "\x{032E}",
    textsubarch           => "\x{032F}",
    textsubtilde          => "\x{0330}",
    subdoublebar          => "\x{0333}",
    textsuperimposetilde  => "\x{0334}",
    textlstrokethru       => "\x{0336}",
    textsstrikethru       => "\x{0337}",
    textlstrikethru       => "\x{0338}",
    textsubrhalfring      => "\x{0339}",
    textinvsubbridge      => "\x{033A}",
    textsubsquare         => "\x{033B}",
    textseagull           => "\x{033C}",
    textovercross         => "\x{033D}",
    overbridge            => "\x{0346}",
    subdoublebar          => "\x{0347}",    ## ??
    subdoublevert         => "\x{0348}",
    subcorner             => "\x{0349}",
    crtilde               => "\x{034A}",
    textoverw             => "\x{034A}",
    dottedtilde           => "\x{034B}",
    doubletilde           => "\x{034C}",
    spreadlips            => "\x{034D}",
    whistle               => "\x{034E}",
    textrightarrowhead    => "\x{0350}",
    textlefthalfring      => "\x{0351}",
    sublptr               => "\x{0354}",
    subrptr               => "\x{0355}",
    textrightuparrowhead  => "\x{0356}",
    textrighthalfring     => "\x{0357}",
    textdoublebreve       => "\x{035D}",
    textdoublemacron      => "\x{035E}",
    textdoublemacronbelow => "\x{035F}",
    textdoubletilde       => "\x{0360}",
    texttoptiebar         => "\x{0361}",
    sliding               => "\x{0362}"
);

our %DIACRITICSEXTRA_R = reverse %DIACRITICSEXTRA;

our %PUNCTUATION = (
    textendash         => "\x{2013}",
    textemdash         => "\x{2014}",
    textquoteleft      => "\x{2018}",
    textquoteright     => "\x{2019}",
    quotesinglbase     => "\x{201A}",
    textquotedblleft   => "\x{201C}",
    textquotedblright  => "\x{201D}",
    quotedblbase       => "\x{201E}",
    dag                => "\x{2020}",
    ddag               => "\x{2021}",
    textbullet         => "\x{2022}",
    dots               => "\x{2026}",
    textperthousand    => "\x{2030}",
    textpertenthousand => "\x{2031}",
    guilsinglleft      => "\x{2039}",
    guilsinglright     => "\x{203A}",
    textreferencemark  => "\x{203B}",
    textinterrobang    => "\x{203D}",
    textoverline       => "\x{203E}",
    langle             => "\x{27E8}",
    rangle             => "\x{27E9}"
);

our %PUNCTUATION_R = reverse %PUNCTUATION;

# \not\xxx
our %NEGATEDSYMBOLS = (
    asymp       => "\x{226D}",
    lesssim     => "\x{2274}",
    gtrsim      => "\x{2275}",
    subset      => "\x{2284}",
    supset      => "\x{2285}",
    ni          => "\x{220C}",
    simeq       => "\x{2244}",
    approx      => "\x{2249}",
    equiv       => "\x{2262}",
    preccurlyeq => "\x{22E0}",
    succcurlyeq => "\x{22E1}",
    sqsubseteq  => "\x{22E2}",
    sqsupseteq  => "\x{22E3}",
);

our %NEGATEDSYMBOLS_R = reverse %NEGATEDSYMBOLS;

# \textsuperscript{x}
our %SUPERSCRIPTS = (
    0   => "\x{2070}",
    i   => "\x{2071}",
    4   => "\x{2074}",
    5   => "\x{2075}",
    6   => "\x{2076}",
    7   => "\x{2077}",
    8   => "\x{2078}",
    9   => "\x{2079}",
    '+' => "\x{207A}",
    '-' => "\x{207B}",
    '=' => "\x{207C}",
    '(' => "\x{207D}",
    ')' => "\x{207E}",
    n   => "\x{207F}",
    SM  => "\x{2120}",
    h   => "\x{02b0}",
    j   => "\x{02b2}",
    r   => "\x{02b3}",
    w   => "\x{02b7}",
    y   => "\x{02b8}"
);

our %SUPERSCRIPTS_R = reverse %SUPERSCRIPTS;

# \textsuperscript{\xxx}
our %CMDSUPERSCRIPTS = (
    texthth        => "\x{02b1}",
    textturnr      => "\x{02b4}",
    textturnrrtail => "\x{02b5}",
    textinvscr     => "\x{02b6}"
);

our %CMDSUPERSCRIPTS_R = reverse %CMDSUPERSCRIPTS;

our %SYMBOLS = (
    textcolonmonetary => "\x{20A1}",
    textlira          => "\x{20A4}",
    textnaira         => "\x{20A6}",
    textwon           => "\x{20A9}",
    textdong          => "\x{20AB}",
    euro              => "\x{20AC}",
    texteuro          => "\x{20AC}",
    textnumero        => "\x{2116}",
    texttrademark     => "\x{2122}",
    leftarrow         => "\x{2190}",
    uparrow           => "\x{2191}",
    rightarrow        => "\x{2192}",
    downarrow         => "\x{2193}",
    leftrightarrow    => "\x{2194}",
    updownarrow       => "\x{2195}",
    leadsto           => "\x{219D}",
    rightleftharpoons => "\x{21CC}",
    Rightarrow        => "\x{21D2}",
    Leftrightarrow    => "\x{21D4}",
    forall            => "\x{2200}",
    complement        => "\x{2201}",
    partial           => "\x{2202}",
    exists            => "\x{2203}",
    nexists           => "\x{2204}",
    set               => "\x{2205}",
    Delta             => "\x{2206}",
    nabla             => "\x{2207}",
    in                => "\x{2208}",
    notin             => "\x{2209}",
    ni                => "\x{220B}",
    prod              => "\x{220F}",
    coprod            => "\x{2210}",
    sum               => "\x{2211}",
    mp                => "\x{2213}",
    dotplus           => "\x{2214}",
    setminus          => "\x{2216}",
    ast               => "\x{2217}",
    circ              => "\x{2218}",
    bullet            => "\x{2219}",
    surd              => "\x{221A}",
    propto            => "\x{221D}",
    infty             => "\x{221E}",
    angle             => "\x{2220}",
    measuredangle     => "\x{2221}",
    sphericalangle    => "\x{2222}",
    mid               => "\x{2223}",
    nmid              => "\x{2224}",
    parallel          => "\x{2225}",
    nparallel         => "\x{2226}",
    wedge             => "\x{2227}",
    vee               => "\x{2228}",
    cap               => "\x{2229}",
    cup               => "\x{222A}",
    int               => "\x{222B}",
    iint              => "\x{222C}",
    iiint             => "\x{222D}",
    oint              => "\x{222E}",
    therefore         => "\x{2234}",
    because           => "\x{2235}",
    sim               => "\x{223C}",
    backsim           => "\x{223D}",
    wr                => "\x{2240}",
    nsim              => "\x{2241}",
    simeq             => "\x{2243}",
    cong              => "\x{2245}",
    ncong             => "\x{2247}",
    approx            => "\x{2248}",
    approxeq          => "\x{224A}",
    asymp             => "\x{224D}",
    Bumpeq            => "\x{224E}",
    bumpeq            => "\x{224F}",
    doteq             => "\x{2250}",
    doteqdot          => "\x{2251}",
    fallingdotseq     => "\x{2252}",
    risingdotseq      => "\x{2253}",
    eqcirc            => "\x{2256}",
    circeq            => "\x{2257}",
    triangleq         => "\x{225C}",
    neq               => "\x{2260}",
    equiv             => "\x{2261}",
    leq               => "\x{2264}",
    geq               => "\x{2265}",
    leqq              => "\x{2266}",
    geqq              => "\x{2267}",
    lneqq             => "\x{2268}",
    gneqq             => "\x{2269}",
    ll                => "\x{226A}",
    gg                => "\x{226B}",
    between           => "\x{226C}",
    nless             => "\x{226E}",
    ngtr              => "\x{226F}",
    nleq              => "\x{2270}",
    ngeq              => "\x{2271}",
    lesssim           => "\x{2272}",
    gtrsim            => "\x{2273}",
    lessgtr           => "\x{2276}",
    gtrless           => "\x{2277}",
    prec              => "\x{227A}",
    succ              => "\x{227B}",
    preccurlyeq       => "\x{227C}",
    succcurlyeq       => "\x{227D}",
    precsim           => "\x{227E}",
    succsim           => "\x{227F}",
    nprec             => "\x{2280}",
    nsucc             => "\x{2281}",
    subset            => "\x{2282}",
    supset            => "\x{2283}",
    subseteq          => "\x{2286}",
    supseteq          => "\x{2287}",
    nsubseteq         => "\x{2288}",
    nsupseteq         => "\x{2289}",
    subsetneq         => "\x{228A}",
    supsetneq         => "\x{228B}",
    uplus             => "\x{228E}",
    sqsubset          => "\x{228F}",
    sqsupset          => "\x{2290}",
    sqsubseteq        => "\x{2291}",
    sqsupseteq        => "\x{2292}",
    sqcap             => "\x{2293}",
    sqcup             => "\x{2294}",
    oplus             => "\x{2295}",
    ominus            => "\x{2296}",
    otimes            => "\x{2297}",
    oslash            => "\x{2298}",
    odot              => "\x{2299}",
    circledcirc       => "\x{229A}",
    circledast        => "\x{229B}",
    circleddash       => "\x{229D}",
    boxplus           => "\x{229E}",
    boxminus          => "\x{229F}",
    boxtimes          => "\x{22A0}",
    boxdot            => "\x{22A1}",
    vdash             => "\x{22A2}",
    dashv             => "\x{22A3}",
    top               => "\x{22A4}",
    bot               => "\x{22A5}",
    Vdash             => "\x{22A9}",
    Vvdash            => "\x{22AA}",
    nVdash            => "\x{22AE}",
    lhd               => "\x{22B2}",
    rhd               => "\x{22B3}",
    unlhd             => "\x{22B4}",
    unrhd             => "\x{22B5}",
    multimap          => "\x{22B8}",
    intercal          => "\x{22BA}",
    veebar            => "\x{22BB}",
    barwedge          => "\x{22BC}",
    bigwedge          => "\x{22C0}",
    bigvee            => "\x{22C1}",
    bigcap            => "\x{22C2}",
    bigcup            => "\x{22C3}",
    diamond           => "\x{22C4}",
    cdot              => "\x{22C5}",
    star              => "\x{22C6}",
    divideontimes     => "\x{22C7}",
    bowtie            => "\x{22C8}",
    ltimes            => "\x{22C9}",
    rtimes            => "\x{22CA}",
    leftthreetimes    => "\x{22CB}",
    rightthreetimes   => "\x{22CC}",
    backsimeq         => "\x{22CD}",
    curlyvee          => "\x{22CE}",
    curlywedge        => "\x{22CF}",
    Subset            => "\x{22D0}",
    Supset            => "\x{22D1}",
    Cap               => "\x{22D2}",
    Cup               => "\x{22D3}",
    pitchfork         => "\x{22D4}",
    lessdot           => "\x{22D6}",
    gtrdot            => "\x{22D7}",
    lll               => "\x{22D8}",
    ggg               => "\x{22D9}",
    lesseqgtr         => "\x{22DA}",
    gtreqless         => "\x{22DB}",
    curlyeqprec       => "\x{22DE}",
    curlyeqsucc       => "\x{22DF}",
    lnsim             => "\x{22E6}",
    gnsim             => "\x{22E7}",
    precnsim          => "\x{22E8}",
    succnsim          => "\x{22E9}",
    ntriangleleft     => "\x{22EA}",
    ntriangleright    => "\x{22EB}",
    ntrianglelefteq   => "\x{22EC}",
    ntrianglerighteq  => "\x{22ED}",
    vdots             => "\x{22EE}",
    cdots             => "\x{22EF}",
    ddots             => "\x{22F1}",
    lceil             => "\x{2308}",
    rceil             => "\x{2309}",
    lfloor            => "\x{230A}",
    rfloor            => "\x{230B}",
    Box               => "\x{25A1}",
    spadesuit         => "\x{2660}",
    heartsuit         => "\x{2661}",
    diamondsuit       => "\x{2662}",
    clubsuit          => "\x{2663}",
    flat              => "\x{266D}",
    natural           => "\x{266E}",
    sharp             => "\x{266F}",
    tone5             => "\x{02E5}",
    tone4             => "\x{02E6}",
    tone3             => "\x{02E7}",
    tone2             => "\x{02E8}",
    tone1             => "\x{02E9}"
);

our %SYMBOLS_R = reverse %SYMBOLS;

our %DINGS = (
    '21' => "\x{2701}",
    '22' => "\x{2702}",
    '23' => "\x{2703}",
    '24' => "\x{2704}",
    '25' => "\x{260E}",
    '26' => "\x{2706}",
    '27' => "\x{2707}",
    '28' => "\x{2708}",
    '29' => "\x{2709}",
    '2A' => "\x{261B}",
    '2B' => "\x{261E}",
    '2C' => "\x{270C}",
    '2D' => "\x{270D}",
    '2E' => "\x{270E}",
    '2F' => "\x{270F}",
    '30' => "\x{2710}",
    '31' => "\x{2711}",
    '32' => "\x{2712}",
    '33' => "\x{2713}",
    '34' => "\x{2714}",
    '35' => "\x{2715}",
    '36' => "\x{2716}",
    '37' => "\x{2717}",
    '38' => "\x{2718}",
    '39' => "\x{2719}",
    '3A' => "\x{271A}",
    '3B' => "\x{271B}",
    '3C' => "\x{271C}",
    '3D' => "\x{271D}",
    '3E' => "\x{271E}",
    '3F' => "\x{271F}",
    '40' => "\x{2720}",
    '41' => "\x{2721}",
    '42' => "\x{2722}",
    '43' => "\x{2723}",
    '44' => "\x{2724}",
    '45' => "\x{2725}",
    '46' => "\x{2726}",
    '47' => "\x{2727}",
    '48' => "\x{2605}",
    '49' => "\x{2729}",
    '4A' => "\x{272A}",
    '4B' => "\x{272B}",
    '4C' => "\x{272C}",
    '4D' => "\x{272D}",
    '4E' => "\x{272E}",
    '4F' => "\x{272F}",
    '50' => "\x{2730}",
    '51' => "\x{2731}",
    '52' => "\x{2732}",
    '53' => "\x{2733}",
    '54' => "\x{2734}",
    '55' => "\x{2735}",
    '56' => "\x{2736}",
    '57' => "\x{2737}",
    '58' => "\x{2738}",
    '59' => "\x{2739}",
    '5A' => "\x{273A}",
    '5B' => "\x{273B}",
    '5C' => "\x{273C}",
    '5D' => "\x{273D}",
    '5E' => "\x{273E}",
    '5F' => "\x{273F}",
    '60' => "\x{2740}",
    '61' => "\x{2741}",
    '62' => "\x{2742}",
    '63' => "\x{2743}",
    '64' => "\x{2744}",
    '65' => "\x{2745}",
    '66' => "\x{2746}",
    '67' => "\x{2747}",
    '68' => "\x{2748}",
    '69' => "\x{2749}",
    '6A' => "\x{274A}",
    '6B' => "\x{274B}",
    '6C' => "\x{25CF}",
    '6D' => "\x{274D}",
    '6E' => "\x{25A0}",
    '6F' => "\x{274F}",
    '70' => "\x{2750}",
    '71' => "\x{2751}",
    '72' => "\x{2752}",
    '73' => "\x{25B2}",
    '74' => "\x{25BC}",
    '75' => "\x{25C6}",
    '76' => "\x{2756}",
    '77' => "\x{25D7}",
    '78' => "\x{2758}",
    '79' => "\x{2759}",
    '7A' => "\x{275A}",
    '7B' => "\x{275B}",
    '7C' => "\x{275C}",
    '7D' => "\x{275D}",
    '7E' => "\x{275E}",
    'A1' => "\x{2761}",
    'A2' => "\x{2762}",
    'A3' => "\x{2763}",
    'A4' => "\x{2764}",
    'A5' => "\x{2765}",
    'A6' => "\x{2766}",
    'A7' => "\x{2767}",
    'A9' => "\x{2666}",
    'AA' => "\x{2665}",
    'AC' => "\x{2460}",
    'AD' => "\x{2461}",
    'AE' => "\x{2462}",
    'AF' => "\x{2463}",
    'B0' => "\x{2464}",
    'B1' => "\x{2465}",
    'B2' => "\x{2466}",
    'B3' => "\x{2467}",
    'B4' => "\x{2468}",
    'B5' => "\x{2469}",
    'B6' => "\x{2776}",
    'B7' => "\x{2777}",
    'B8' => "\x{2778}",
    'B9' => "\x{2779}",
    'BA' => "\x{277A}",
    'BB' => "\x{277B}",
    'BC' => "\x{277C}",
    'BD' => "\x{277D}",
    'BE' => "\x{277E}",
    'BF' => "\x{277F}",
    'C0' => "\x{2780}",
    'C1' => "\x{2781}",
    'C2' => "\x{2782}",
    'C3' => "\x{2783}",
    'C4' => "\x{2784}",
    'C5' => "\x{2785}",
    'C6' => "\x{2786}",
    'C7' => "\x{2787}",
    'C8' => "\x{2788}",
    'C9' => "\x{2789}",
    'CA' => "\x{278A}",
    'CB' => "\x{278B}",
    'CC' => "\x{278C}",
    'CD' => "\x{278D}",
    'CE' => "\x{278E}",
    'CF' => "\x{278F}",
    'D0' => "\x{2790}",
    'D1' => "\x{2791}",
    'D2' => "\x{2792}",
    'D3' => "\x{2793}",
    'D4' => "\x{2794}",
    'D6' => "\x{2194}",
    'D7' => "\x{2195}",
    'D8' => "\x{2798}",
    'D9' => "\x{2799}",
    'DA' => "\x{279A}",
    'DB' => "\x{279B}",
    'DC' => "\x{279C}",
    'DD' => "\x{279D}",
    'DE' => "\x{279E}",
    'DF' => "\x{279F}",
    'E0' => "\x{27A0}",
    'E1' => "\x{27A1}",
    'E2' => "\x{27A2}",
    'E3' => "\x{27A3}",
    'E4' => "\x{27A4}",
    'E5' => "\x{27A5}",
    'E6' => "\x{27A6}",
    'E7' => "\x{27A7}",
    'E8' => "\x{27A8}",
    'E9' => "\x{27A9}",
    'EA' => "\x{27AA}",
    'EB' => "\x{27AB}",
    'EC' => "\x{27AC}",
    'ED' => "\x{27AD}",
    'EE' => "\x{27AE}",
    'EF' => "\x{27AF}",
    'F1' => "\x{27B1}",
    'F2' => "\x{27B2}",
    'F3' => "\x{27B3}",
    'F4' => "\x{27B4}",
    'F5' => "\x{27B5}",
    'F6' => "\x{27B6}",
    'F7' => "\x{27B7}",
    'F8' => "\x{27B8}",
    'F9' => "\x{27B9}",
    'FA' => "\x{27BA}",
    'FB' => "\x{27BB}",
    'FC' => "\x{27BC}",
    'FD' => "\x{27BD}",
    'FE' => "\x{27BE}"
);

our %DINGS_R = reverse %DINGS;

our %GREEK = (
    alpha      => "\x{3b1}",
    beta       => "\x{3b2}",
    gamma      => "\x{3b3}",
    delta      => "\x{3b4}",
    varepsilon => "\x{3b5}",
    zeta       => "\x{3b6}",
    eta        => "\x{3b7}",
    vartheta   => "\x{3b8}",
    iota       => "\x{3b9}",
    kappa      => "\x{3ba}",
    lambda     => "\x{3bb}",
    mu         => "\x{3bc}",
    nu         => "\x{3bd}",
    xi         => "\x{3be}",
    omicron    => "\x{3bf}",
    pi         => "\x{3c0}",
    varrho     => "\x{3c1}",
    varsigma   => "\x{3c2}",
    sigma      => "\x{3c3}",
    tau        => "\x{3c4}",
    upsilon    => "\x{3c5}",
    varphi     => "\x{3c6}",
    chi        => "\x{3c7}",
    psi        => "\x{3c8}",
    omega      => "\x{3c9}",
    Alpha      => "\x{391}",
    Beta       => "\x{392}",
    Gamma      => "\x{393}",
    Delta      => "\x{394}",
    Epsilon    => "\x{395}",
    Zeta       => "\x{396}",
    Eta        => "\x{397}",
    Theta      => "\x{398}",
    Iota       => "\x{399}",
    Kappa      => "\x{39a}",
    Lambda     => "\x{39b}",
    Mu         => "\x{39c}",
    Nu         => "\x{39d}",
    Xi         => "\x{39e}",
    Omicron    => "\x{39f}",
    Pi         => "\x{3a0}",
    Rho        => "\x{3a1}",
    Sigma      => "\x{3a3}",
    Tau        => "\x{3a4}",
    Upsilon    => "\x{3a5}",
    Phi        => "\x{3a6}",
    Chi        => "\x{3a7}",
    Psi        => "\x{3a8}",
    Omega      => "\x{3a9}"
);

our %GREEK_R = reverse %GREEK;

# Things we don't want to change when encoding as this would break LaTeX
our %ENCODE_EXCLUDE_R = (
                         chr(0x22)	=> 1, # \textquotedbl
                         chr(0x23)	=> 1, # \texthash
                         chr(0x24)	=> 1, # \textdollar
                         chr(0x25)	=> 1, # \textpercent
                         chr(0x26)	=> 1, # \textampersand
                         chr(0x27)	=> 1, # \textquotesingle
                         chr(0x2a)	=> 1, # \textasteriskcentered
                         chr(0x3c)	=> 1, # \textless
                         chr(0x3d)	=> 1, # \textequals
                         chr(0x3e)	=> 1, # \textgreater
                         chr(0x5c)	=> 1, # \textbackslash
                         chr(0x5e)	=> 1, # \textasciicircum
                         chr(0x5f)  => 1, # \textunderscore
                         chr(0x60)	=> 1, # \textasciigrave
                         chr(0x67)	=> 1, # \textg
                         chr(0x7b)	=> 1, # \textbraceleft
                         chr(0x7c)	=> 1, # \textbar
                         chr(0x7d)	=> 1, # \textbraceright
                         chr(0x7e)	=> 1, # \textasciitilde
                         chr(0xa0)	=> 1, # \nobreakspace
                         chr(0xa3)	=> 1, # \textsterling
                         chr(0xb1)	=> 1, # \pm
                         chr(0xb5)	=> 1, # \mu
                         chr(0xb6)	=> 1, # \P
                        );

our $ACCENTS_RE = qr{[\^\.`'"~=]};
our $ACCENTS_RE_R = qr{[\x{300}-\x{304}\x{307}\x{308}]};

our $DIAC_RE_BASE  = join('|', keys %DIACRITICS);
$DIAC_RE_BASE = qr{$DIAC_RE_BASE};
our $DIAC_RE_BASE_R  = join('|', keys %DIACRITICS_R);
$DIAC_RE_BASE_R = qr{$DIAC_RE_BASE_R};

our $DIAC_RE_EXTRA = join('|', sort {length $b <=> length $a} keys %DIACRITICSEXTRA);
$DIAC_RE_EXTRA = qr{$DIAC_RE_EXTRA|$DIAC_RE_BASE};
our $DIAC_RE_EXTRA_R = join('|', sort {length $b <=> length $a} keys %DIACRITICSEXTRA_R);
$DIAC_RE_EXTRA_R = qr{$DIAC_RE_EXTRA_R|$DIAC_RE_BASE_R};

our $NEG_SYMB_RE = join('|', sort keys %NEGATEDSYMBOLS);
$NEG_SYMB_RE    = qr{$NEG_SYMB_RE};
our $NEG_SYMB_RE_R = join('|', sort keys %NEGATEDSYMBOLS_R);
$NEG_SYMB_RE_R    = qr{$NEG_SYMB_RE_R};

our $SUPER_RE;
my @_ss   = keys %SUPERSCRIPTS;
$SUPER_RE = join('|', map { /[\+\-\)\(]/ ? '\\' . $_ : $_ } @_ss);
$SUPER_RE = qr{$SUPER_RE};
our $SUPER_RE_R;
my @_ss_r   = keys %SUPERSCRIPTS_R;
$SUPER_RE_R = join('|', map { /[\+\-\)\(]/ ? '\\' . $_ : $_ } @_ss_r);
$SUPER_RE_R = qr{$SUPER_RE_R};

our $SUPERCMD_RE = join('|', keys %CMDSUPERSCRIPTS);
$SUPERCMD_RE    = qr{$SUPERCMD_RE};
our $SUPERCMD_RE_R = join('|', keys %CMDSUPERSCRIPTS_R);
$SUPERCMD_RE_R    = qr{$SUPERCMD_RE_R};

our $DINGS_RE_R = join('|', keys %DINGS_R);
$DINGS_RE_R    = qr{$DINGS_RE_R};


=head1 AUTHOR

François Charette, C<< <firmicus at gmx.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-latex-decode at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=LaTeX-Decode>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 NOTICE

This module is currently distributed with biber, but it is not unlikely that it
will eventually make its way to CPAN.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 François Charette, all rights reserved.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

1;

# vim: set tabstop=4 shiftwidth=4 expandtab: