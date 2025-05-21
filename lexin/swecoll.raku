subset Å   of Str where * ∈ <å Å>; 
subset Ä   of Str where * ∈ <ä Ä>; 
subset nÅÄ of Str where * ∉ <ä Ä å Å>; 

multi swe (Å $a, Ä $b) { note 111; Less }
multi swe (Ä $a, Å $b) { note 222; More }
multi swe ($a, nÅÄ $b) { note 333; $a.lc coll $b.lc }
multi swe (nÅÄ $a, $b) { note 444; $a.lc coll $b.lc }

multi sub lexsort-swe {()}
multi sub lexsort-swe ($item) { ($item,) }
multi sub lexsort-swe (@data) is export {
    return sort { coll-swe($^a,$^b) }, @data
}

sub coll-swe(Str $a, Str $b -->Order) is export {
	if $a eq $b { return Same }

	note $a.comb Z $b.comb;
	for $a.comb Z $b.comb {
	    note swe( $_[0], $_[1] );
	    #given ($_[0] coll $_[1]) {
	    given swe( $_[0], $_[1] ) {
		when Less { return Less }
		when More { return More }}
	}

	return $a.chars <=> $b.chars
}



       #my @in = ($a, $b)».lc; 
            #my $swe = <å ä>.Set; 
            #say @in ~~ $swe; 


        #    given ($a, $b)».lc {
        #        when * ⊂ $swe and{ say "swe: "  }
        #        default { say "coll"  }
        #    }
      #}
say ["ä", "å", " --> 222"];
say swe "ä", "å"; # 222
say "ä" coll "å"; 
say "ä" cmp "å"; 
say "ä" unicmp "å"; 

say ["ö", "o"], " --> 333";
say swe "ö", "o"; # 333
say "ö" coll "o"; 
say "ö" cmp "o"; 
say "ö" unicmp "o"; 

say ["ö", "p"], " --> 333";
say swe "ö", "p"; # 333
say "ö" coll "p"; 
say "ö" cmp "p"; 
say "ö" unicmp "p"; 

#`(

say swe "m", "O"; # 333

say swe "ä", "O"; # 333

say swe "Å", "a"; # 333

say swe "å", "Ä"; # 111

say swe "m", "Ä"; # 444


say lexsort-swe <ara åra öra ora måne ära man>; 
)
say $*COLLATION;
$*COLLATION.set(:quaternary(False));
say $*COLLATION;
$*COLLATION.set(Country => 'SE', Language => 'swe');
say $*COLLATION;

say <ara åra öra ora måne ära ARA man>.sort: { swe( $^a, $^b ) }
