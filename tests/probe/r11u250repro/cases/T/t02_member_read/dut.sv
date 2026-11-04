// § patFlatTernPickedLeafSpan250
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t dflt = '{a : 7, b : 9};
  localparam s_t cfg = '{a: dflt.a, b: dflt.b};
endpackage
module top import p::*; (output integer o);
  assign o = cfg.a + cfg.b;
endmodule
