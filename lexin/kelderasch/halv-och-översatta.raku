use JSON::Fast;

#my @över  = $*IN.slurp.split("--\n").map:{ my @p = .split: "\n", :skip-empty };
my @ösättn = $*IN.slurp.split("--\n", :skip-empty).map:{ my @p = .split: "\n", :skip-empty; @p };

my %översättn;
my %pos;
for @ösättn {
    %översättn.push: $_[0] => $_[1];
    %pos{$_[0]}{$_[1]}.append: $_[2];
};

#say to-json %översättn;
#say to-json %pos;
#exit;


my @oöversatta-singel;
my @oöversatta-multi;
my @halvöversatta;

for %översättn -> $par {
    say  %pos{$par.key}{$par.value} ;
    my $SE = &SE( %pos{$par.key}{$par.value} );
    say $SE;
    
    given ($par.value) {
	when Str  { say join("\t", $par.key, $_.raku ,  $SE ?? 'SE' !! "oöversatt") }
	when *.grep: / <alpha> /  { say join("\t", $par.key, $_.raku , "ÖVERSATT") }
	when Array    { say join("\t", $par.key, $_.raku , "Array") }
	default      { say join("\t", $par.key, $_.raku , "OJ!") }
    }		
}

multi SE (Str $se) { so $se ~~ /"#02 se "/ }
multi SE (@se)     { so @se.grep: &SE(*) }

