
say "ä" coll "b";
say "b" coll "ä";

#say multi sub infix:<coll> ('b', 'ä') { Less }
say multi sub infix:<coll> ('ä', 'b') { More }

say "ä" coll "b";
say "b" coll "ä";



