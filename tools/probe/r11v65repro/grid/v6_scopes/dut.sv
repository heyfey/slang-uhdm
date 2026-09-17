// v6 - SCOPES: a package net cell (packages hold variables, not nets), a
// typedef declared in one package and re-typedef'd in a module, a typedef
// imported into a package and used there, and a nested-child chain.
package pkA;
  typedef logic [1:0] av_t;
  typedef logic [1:0] aa_t [4];
  aa_t pkgnet;                // a PACKAGE-scope declaration
  av_t pkgv [2];
endpackage
package pkB;
  import pkA::*;
  typedef aa_t bb_t;          // re-typedef of an IMPORTED unpacked typedef
  bb_t bnet;
endpackage
module leaf (output logic [1:0] o);
  import pkA::aa_t;
  typedef aa_t loc_t;         // LOCAL re-typedef of an imported unpacked alias
  loc_t ln;
  aa_t  la [2];               // imported unpacked typedef + declarator dim
  assign o = ln[0] | la[0][0];
endmodule
module dut (output logic [1:0] o);
  logic [1:0] lo;
  leaf u (.o(lo));
  assign o = lo | pkA::pkgnet[0] | pkB::bnet[0];
endmodule
