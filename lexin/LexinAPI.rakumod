use HTTP::Request:from<Perl5>;
use LWP::UserAgent:from<Perl5>;
use JSON::Fast; # <sorted-keys>;

class  Lexin::API::Klient { ... }
module Lexin::Språk { ... }

proto sub MAIN(|) is export {*}

#! bara swe_swe-uppslag (dvs. lang = swe_swe)
#| Ex: "$ echo babblar | raku LexinAPI.rakumod";
#| Ex: "$ cat <FIL M RADVISA SV ORD> | raku LexinAPI.rakumod"
multi sub MAIN() {
    say to-json Lexin::API::Klient.new(:lang("swe_swe")).uppslag($*IN.lines), :sorted-keys;
}

#! bara swe_swe-uppslag (dvs. lang = swe_swe)
#| Ex: "$ echo babblar | raku LexinAPI.rakumod" --raw;
multi sub MAIN(
    Bool :$raw!, #= matar ut inkommande rå json
) {
    for Lexin::API::Klient.new(:lang("swe_swe"), :$raw).uppslag($*IN.lines) {
	say $_[0];
	say '-----';
	say $_[1];
	say '=====';
    }
}

#| Ex: "$ raku LexinAPI.rakumod --lang='swe>fin' babbla cyklade"
multi sub MAIN(
    Str :$lang!, #= KÄLLSPRÅK>MÅLSPRÅL, ex "swe>fin"
    *@ord,       #= ett eller flera källspråksord, ex. "babblar cyklade"
) {
    say to-json Lexin::API::Klient.new(| Lexin::Språk::lang($lang)).uppslag(@ord), :sorted-keys;
#    say $ord;
#    say Lexin::Språk::lang($lang);
}

multi sub MAIN( Bool :$zzz! ) {
    say Lexin::Språk::zzz();
}

multi sub MAIN(
    Bool :$json-rader!, #= mata ut resultatet som separata jsonrader (istf jsonarray)
) {
    Lexin::API::Klient.new(:lang("swe_swe")).uppslag($*IN.lines).map: { say to-json( $_, :sorted-keys, :!pretty ) };
}


subset FromTo of Str where * ~~ 'from' | 'to' | 'both';

class Lexin::API::Klient {
    has Str    $tjänst           = 'http://lexin.nada.kth.se/lexin/';
    has FromTo $.riktn           = 'to';
    has Str    $.lang is required;
    has        $ua               = LWP::UserAgent.new( agent => 'Lexin-API-klient/0.1 ' );
    has Bool   $.raw             = False; #= Om True matas jsonformatet från API:et ut

    method uppslag (*@ord --> Seq) {
	# <-- Seq
	gather for @ord.hyper -> $ord {
	    my $req = HTTP::Request.new( GET => self.url($ord.trim) );
 	    $req.content('query=libwww-perl&mode=dist');
	
	    my $res = $ua.request($req);
	    if    ! $!raw and $res.is_success { take [ $ord.trim, from-json $res.content ] }
	    elsif   $!raw and $res.is_success { take [ $ord.trim,           $res.content ] }
	    else                              { note $res.status_line }
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
	  swe_sdh swe_som swe_spa swe_srp swe_srp_cyrillic swe_swe
	  swe_tha swe_tir swe_tur
    >;

    our @språk =  @språkpar.map({ | .split: '_', 2 }).unique;
    
    our @språkpar-med-riktning = @språk
				  .map({ | ('swe>' ~ $_, $_ ~ '>swe')})
				  .unique
				  .Array.unshift: 'swe';

    our proto sub lang (Str --> Hash) {*}
    our multi sub lang ($ where * ~~ 'swe'|'swe>swe') {
	%(lang => 'swe_swe', riktn => 'to');
    }
    our multi sub lang (Str $lang-riktn where * ∈  @språkpar-med-riktning) {
	my (Str $l1, Str $l2) = $lang-riktn.split: '>';

	my $riktn = 'to';
	my $språk = $l1 ~ '_' ~ $l2;
	{ $riktn = 'from'; $språk = $l2 ~ '_' ~ $l1 } if $l2 ~~ 'swe';

	%(lang => $språk, riktn => $riktn);
}
	
    
    our sub zzz () {
	lang('swe>fin');
#	@språk;
#	@språkpar-med-riktning;
#	@språkpar.map({ | .split: '_', 2 }).grep( * !~~ 'swe' ).map({ | ('swe>' ~ $_, $_ ~ '>swe')}).Array.push: 'swe', 'swe>swe';
# 	(gather  for <a b c d e A> {
# 		take $_ => 'A';
# 		take 'A' => $_ }).map( {$_.key ~ 2 ~ $_.value} ).unique;
    }
}


