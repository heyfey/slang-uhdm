// v104 arm V2 - THE ATTACK: a macro WITH ARGUMENTS whose paste window touches
// a formal, invoked with argument text that COINCIDES with the formal name.
// The definition text then aligns byte-for-byte with the expanded value, so
// the implementer's "the alignment bails" fence is not exercised.
`define PAIR(A,B) `"A``(``B``)`"
`define AA(V,I) `"aa(``V``,``I``)`"
`define SEP(a,b) `"a``-``b`"
package v2_pk;
  parameter string z_pair_coin = `PAIR(A,B);
  parameter string z_pair_real = `PAIR(int,bit);
  parameter string z_aa_coin   = `AA(V,I);
  parameter string z_sep_coin  = `SEP(a,b);
  parameter string z_sep_real  = `SEP(xx,yy);
endpackage
module v2_top; endmodule
