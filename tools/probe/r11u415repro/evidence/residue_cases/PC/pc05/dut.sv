// residue (no law landed): a package enum/alias cast outside a parameter declaration (exit 0 at pristine, NOT_EQUAL on the return fold), see README
package p;
  typedef enum { A, B, C } e_t;
endpackage
module top (output [31:0] o);
  import p::*;
  e_t v;
  assign v = e_t'(1);
  assign o = v;
endmodule
