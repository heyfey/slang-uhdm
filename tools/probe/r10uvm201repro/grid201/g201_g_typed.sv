// r10uvm201 grid arm G — the NEGATIVE control: the TYPED / RANGED / SIGNED /
// TYPEDEF'd / decimal-based / unbased-unsized forms whose Rhs constants must
// be byte-for-byte unchanged.  The typedef lives INSIDE the package: a
// compilation-unit typedef referenced from a package is illegal SV and our
// binary correctly rejects the file, which would have left this control arm
// producing no database at all.
package p201g;
  typedef logic [3:0] nib201_t;
  parameter [5:0]  G_RNG  = 6'd12;
  parameter signed G_SGN  = 'h5;
  parameter int    G_INT  = 7;
  parameter string G_STR  = "hello";
  parameter nib201_t G_TNIB = 4'h5;
  parameter G_UDB = 'd13;
  parameter G_UNB = '0;
endpackage
import p201g::*;
module m201g;
endmodule
