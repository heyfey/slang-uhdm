// residue (no law landed): a package enum/alias cast outside a parameter declaration (exit 0 at pristine, NOT_EQUAL on the return fold), see README
package p;
  typedef enum { A, B, C } e_t;
  e_t v = e_t'(2);
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = v;
endmodule
