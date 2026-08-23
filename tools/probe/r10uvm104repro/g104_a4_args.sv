// r10uvm104 arm 4 — the FENCE: a macro WITH ARGUMENTS whose stringification
// pastes around a character.  Surelog substitutes the formals BEFORE its
// regex runs, so the pastes are consumed and NOTHING is rewritten; the model
// must bail (the definition text no longer describes the value).
`define PAIR(A,B) `"A``(``B``)`"
`define AA(V,I) `"aa(``V``,``I``)`"
package arg_pk;
  parameter string a_pair = `PAIR(int,bit);
  parameter string a_aa   = `AA(byte,shortint);
endpackage
module arg_top; endmodule
