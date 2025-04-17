use HTTP::UserAgent;
use JSON::Fast; # <sorted-keys>;
use URI::Encode;
class  Lexin::API::Klient { ... }
#module Lexin::Språk { ... }

#`(
my $tjänst          = 'http://lexin.nada.kth.se/lexin/';
my $riktn           = 'to';
my $lang            = "swe_swe";
my $ord             = 'babbladde';
my $url = sprintf( "%sservice?searchinfo=%s,%s,%s&output=JSON",
	            #                    #  #  #
	            #                    #  #  #
	            $tjänst,             $riktn,
	                                    #  #
	                                    $lang,
                                               #
	                                       $ord);


my $ua = HTTP::UserAgent.new
$ua.timeout = 10;

my $response = $ua.get($url);

if $response.is-success {
    say $response.content;
} else {
    die $response.status-line;
}
)

#| Ex: "$ echo babblar | raku XXX";
#| Ex: "$ cat <FIL M RADVISA SV ORD> | raku XXX"
multi sub MAIN() {
    say to-json Lexin::API::Klient.new(:lang("swe_swe")).uppslag($*IN.lines), :sorted-keys;
}

#| Ex: "$ echo babblar | raku XXX  --status";
#| Ex: "$ cat <FIL M RADVISA SV ORD> | raku XXX --status"
multi sub MAIN(
    Bool :$status!,   #= matar bara ut Corrections, Status och Wordbase
) {
    my @svar = Lexin::API::Klient.new(:lang("swe_swe")).uppslag($*IN.lines);
    say to-json @svar.map: { [ .[0], .[1].pairs.grep( *.key ∈ <Corrections Status Wordbase> ).Hash ] }, :sorted-keys;
}


multi sub MAIN(
    Str :$lang!, #= KÄLLSPRÅK>MÅLSPRÅL, ex "swe>fin"
    *@ord,       #= ett eller flera källspråksord, ex. "babblar cyklade"
) {
    say to-json Lexin::API::Klient.new(| Lexin::Språk::lang($lang)).uppslag(@ord), :sorted-keys;
#    say $ord;
#    say Lexin::Språk::lang($lang);
}


subset FromTo of Str where * ~~ 'from' | 'to' | 'both';

class Lexin::API::Klient {
    has Str    $tjänst           = 'http://lexin.nada.kth.se/lexin/';
    has FromTo $.riktn           = 'to';
    has Str    $.lang is required;
    #has        $ua               = LWP::UserAgent.new( agent => 'Lexin-API-klient/0.1 ' );
    has Bool   $.raw             = False; #= Om True matas jsonformatet från API:et ut

    method uppslag (*@ord --> Seq) {
	# <-- Seq

	my $ua = HTTP::UserAgent.new( timeout => 10 );
	
	gather for @ord.hyper -> $ord {
	    #my $req = HTTP::Request.new( GET => self.url($ord.trim) );
 	    #$req.content('query=libwww-perl&mode=dist');
	    #my $res = $ua.request($req);

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
