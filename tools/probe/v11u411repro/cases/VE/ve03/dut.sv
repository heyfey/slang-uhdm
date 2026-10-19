// § pkgEnumCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  function automatic int f(int x);
    localparam e_t L = e_t'(2);
    return x + L;
  endfunction
endpackage
module top (output [31:0] o);
  assign o = p::f(1);
endmodule
