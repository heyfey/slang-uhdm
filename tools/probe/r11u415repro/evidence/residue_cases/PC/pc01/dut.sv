// residue (no law landed): a package enum/alias cast outside a parameter declaration (exit 0 at pristine, NOT_EQUAL on the return fold), see README
package p;
  typedef enum { A, B, C } e_t;
  function automatic e_t f();
    return e_t'(1);
  endfunction
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = f();
endmodule
