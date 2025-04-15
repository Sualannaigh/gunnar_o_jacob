use HTTP::UserAgent;

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


my $ua = HTTP::UserAgent.new;
$ua.timeout = 10;

my $response = $ua.get($url);

if $response.is-success {
    say $response.content;
} else {
    die $response.status-line;
}

