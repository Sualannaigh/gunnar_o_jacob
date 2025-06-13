use HTTP::UserAgent;
use JSON::Fast; # <sorted-keys>;
use URI::Encode;

class  Lexin::API::Klient { ... }
module Lexin::Språk { ... }


#| Ex: "$ echo babblar | raku XXX";
#| Ex: "$ cat <FIL M RADVISA SV ORD> | raku XXX"
multi sub MAIN() {
    say to-json Lexin::API::Klient.new(:lang("swe_swe")).uppslag($*IN.lines), :sorted-keys;
}

#| Ex: "$ raku XXX babblar tonsill [ ... ]";
multi sub MAIN(
    :$raw = False,
    *@ord,
) {
    my @resultat = Lexin::API::Klient.new(:raw($raw), :lang("swe_swe")).uppslag(@ord);
    if $raw { say @resultat }
    else    { say to-json @resultat, :sorted-keys }
}

#| Ex: "$ echo babblar | raku XXX  --status";
#| Ex: "$ cat <FIL M RADVISA SV ORD> | raku XXX --status"
multi sub MAIN(
    Bool :$status!,         #= matar bara ut Corrections, Status och Wordbase
    Str :$lang = 'swe>swe', #= KÄLLSPRÅK>MÅLSPRÅL, ex "swe>fin"
    
) {
    my @svar = Lexin::API::Klient.new(| Lexin::Språk::lang($lang)).uppslag($*IN.lines);
    say to-json @svar.map: { [ .[0], .[1].pairs.grep( *.key ∈ <Corrections Status Variant Wordbase> ).Hash ] }, :sorted-keys;
}


multi sub MAIN(
    Bool :$raw = False,  #= Om True matas "originaljson" från servern ut
    Str  :$lang!,        #= KÄLLSPRÅK>MÅLSPRÅL, ex "swe>fin"
    *@ord,               #= ett eller flera källspråksord, ex. "babblar cyklade"
) {
    my @resultat = Lexin::API::Klient.new( :raw($raw), | Lexin::Språk::lang($lang)).uppslag(@ord);
    if $raw { say @resultat }
    else    { say to-json @resultat, :sorted-keys }
}


subset FromTo of Str where * ~~ 'from' | 'to' | 'both';

class Lexin::API::Klient {
    has Str    $tjänst           = 'http://lexin.nada.kth.se/lexin/';
    has FromTo $.riktn           = 'to';
    has Str    $.lang is required;
    has        $ua               = HTTP::UserAgent.new( timeout => 10, agent => 'Lexin-API-klient/0.8' );
    has Bool   $.raw             = False; #= Om True matas jsonformatet från API:et ut
    
    method uppslag (*@ord --> Seq) {
	gather for @ord.hyper -> $ord {
	    my $res = $ua.get( self.url($ord.trim.&uri_encode) );

	    if    ! $!raw and $res.is-success { take [ $ord.trim, from-json $res.content ] }
	    elsif   $!raw and $res.is-success { take [ $ord.trim,           $res.content ] }
	    else                              { note $res.status-line }
	}
    }

    method url (Str $ord --> Str) {
	sprintf( "%sservice?searchinfo=%s,%s,%s&output=JSON",
	           #                    #  #  #
	           $tjänst,             $!riktn,
	                                   #  #
	                                   $!lang,
                                              #
	                                      $ord);
    }
}

module Lexin::Språk {
    my @språkpar = <
       	  swe_alb swe_amh swe_ara swe_azj swe_bos swe_eng swe_fin
	  swe_gre swe_hrv swe_kmr swe_per swe_pus swe_rom swe_rus
	  swe_sdh swe_som swe_spa swe_srp swe_srp_cyrillic
	  swe_tha swe_tir swe_tur swe_ukr
    >; #  swe_swe

    our @språk =  @språkpar.map({ | .split: '_', 2 }).unique;
    
    our @språkpar-med-riktning = @språk
                                  .grep( * ne 'swe')
				  .map({ | ('swe>' ~ $_, $_ ~ '>swe')})
				  .unique
				  .Array;

    our proto sub lang (Str --> Hash) {*}

    multi sub lang ($ where * ~~ 'swe' | 'swe>swe' ) {
	%(lang => 'swe_swe', riktn => 'to');
    }

    multi sub lang (Str $lang-riktn where * ∈  @språkpar-med-riktning) {
	my (Str $l1, Str $l2) = $lang-riktn.split: '>';

	my $riktn = 'to';
	my $språk = $l1 ~ '_' ~ $l2;
	{ $riktn = 'from'; $språk = $l2 ~ '_' ~ $l1 } if $l2 ~~ 'swe';

	%(lang => $språk, riktn => $riktn);
    }
}
