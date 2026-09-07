// r10uvm199 grid arm G — THE TYPED HALF OF THE DECLARED-TYPE GRID, the arms
// that MUST KEEP their typespec.  A ranged-untyped declaration, an explicitly
// signed untyped one, a typed int, a typed string and a typedef'd vector, all
// materialized twice through a FILE-scope wildcard import.
package gPkg;
  typedef logic [3:0] nib_t;
  parameter [5:0]     G_RNG  = 6'd12;   // RANGED-untyped
  parameter signed    G_SGN  = 'h5;     // UNTYPED + explicit signing
  parameter int       G_INT  = 7;       // TYPED int
  parameter string    G_STR  = "hello"; // TYPED string
  parameter nib_t     G_TNIB = 4'h5;    // TYPEDEF'd vector
endpackage
import gPkg::*;
module gTop;
  initial $display(G_STR);
endmodule
