
#swe_kal.txt | head -100 |c

# | #01 | uppslagsord, ev. följt av nummer (= xxx)                       |
# | #02 | ordklassbeteckning                                             |
# | #04 | ordförklaring                                                  |
# | #05 | stilkommentar                                                  |
# | #06 | sakupplysning                                                  |
# | #07 | satsexempel; löpnummer i 47                                    |
# | #08 | idiomexempel; löpnummer i 48                                   |
# | #09 | referens till bild eller annat uttryck                         |
# | #10 | syntaxmarkering, t ex "x & y"                                  |
# | #11 | sammansättningsexempel; löpnummer i 51                         |
# | #12 | ordböjning, hela ord eller inlett med "-" om 10 innehåller "~" |
# | #13 | stavningsvariant                                               |
# | #14 | uttal                                                          |
# | #15 | grammatikkommentar                                             |
# | #31 | övers. av #01                                                  |
# | #32 | övers. av #02                                                  |
# | #35 | övers. av #05                                                  |
# | #36 | övers. av #06                                                  |
# | #37 | övers. av #07                                                  |
# | #38 | övers. av #08                                                  |
# | #39 | övers. av #09                                                  |
# | #41 | övers. av #11                                                  |
# | #45 | övers. av #15                                                  |
# | #54 | övers. av #04                                                  |
# | #47 | löpnummer för exempel                                          |
# | #48 | löpnummer för idiom                                            |
# | #51 | löpnummer för sammansättning                                   |
# | #98 | löpnummer för olika uppslagsord                                |
# | #99 | löpnummer för uppslagsord (inkl varianter)                     |

use JSON::Fast;

#my $viggo = '../../lexinextra/dictionaries/swe_kal.txt';
my $viggo = 'swe_kal-red.txt';
# my @viggo1.push: | $viggo.IO.slurp.split(/^^[\h*\n]+/).map: {
#     my %h = do for .split(/\h*\n\h*/, :skip-empty) -> $r {
# 	my ($k, $v) = $r.split: /\h+/, 2;
# 	$k => $v }
#     };

my @viggo2.push: | $viggo.IO.slurp.split(/^^[\h*\n]+<?before ^^"#01">/).subst("/#45", "#45").map: {
    my %h = do for .split(/\h*\n\h*/, :skip-empty) -> $r {
	my ($k, $v) = $r.split: /\h+/, 2;
	#say $k unless $v;
	$k => $v }
    };

#say @viggo1.elems;
#say @viggo2.elems;

for @viggo2 { my @a = $_.keys.grep: * !~~ /^'#'/; say($_<#01>," == ", $_, @a) if @a }

#my %viggo = @
