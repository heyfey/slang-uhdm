// § patFlatTernPickedLeafSpan250 (control: a chain ending at a parameter name abstains)
package p;
  localparam integer W = 11;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t dflt = '{a : W, b : 1};
  localparam s_t cfg = '{a: (W > 0) ? dflt.a : 0, b: dflt.b};
endpackage
module top import p::*; (output integer o);
  assign o = cfg.a + cfg.b;
endmodule
