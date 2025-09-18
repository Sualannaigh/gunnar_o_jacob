use JSON::Fast;

my @översätttningspar = $*IN.slurp.split("--\n").map:{ my @p = .split: "\n", :skip-empty };

my %översätttningspar.push:  @översätttningspar.map: { .[0] => .[1] }

for %översätttningspar -> $par {
    given ($par.value) {
	when Str  { say join("\t", $par.key, $_.raku , "oöversatt") }
	#when Array Positional and *.grep: { /'#031 ' .*? \w / } { say $_, "   ÖVERSATT" }
	when *.grep: / <alpha> /  { say join("\t", $par.key, $_.raku , "ÖVERSATT") }
	when Array    { say join("\t", $par.key, $_.raku , "Array") }
	default      { say join("\t", $par.key, $_.raku , "OJ!") }
    }		
}


						       
