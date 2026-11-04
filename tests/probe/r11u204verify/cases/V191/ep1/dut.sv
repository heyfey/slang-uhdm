// § enumDefOwnerNotInstance191: a module-local enum in a definition instantiated twice, and a package enum imported by two modules instantiated in a for-generate
package p;
  typedef enum logic [1:0] {R, G, B} col_t;
endpackage
module own;
  typedef enum {S0, S1, S2} st_t;
  st_t st;
endmodule
module ia; import p::*; col_t c; endmodule
module ib; import p::*; col_t d; endmodule
module top;
  own o1 (); own o2 ();
  for (genvar i = 0; i < 2; i++) begin : g
    ia a (); ib b ();
  end
endmodule
