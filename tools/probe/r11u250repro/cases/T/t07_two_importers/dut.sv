// § patFlatTernPickedLeafSpan250
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t dflt = '{a : 1, b : 2};
  localparam s_t ovr = '{default : "inv"};
  localparam s_t cfg = '{a: (ovr.a == "inv") ? dflt.a : ovr.a, b: (ovr.b == "inv") ? dflt.b : ovr.b};
endpackage
module sub import p::*; (output integer o);
  assign o = cfg.a;
endmodule
module top import p::*; (output integer o, output integer q);
  sub u(.o(o));
  assign q = cfg.b;
endmodule
