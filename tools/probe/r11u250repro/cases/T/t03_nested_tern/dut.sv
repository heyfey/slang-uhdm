// § patFlatTernPickedLeafSpan250
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t d1 = '{a : 3, b : 4};
  localparam s_t d2 = '{a : 5, b : 6};
  localparam int SEL = 2;
  localparam s_t cfg = '{a: (SEL == 1) ? d1.a : (SEL == 2) ? d2.a : 0,
                         b: (SEL == 0) ? d1.b : 12};
endpackage
module top import p::*; (output integer o);
  assign o = cfg.a + cfg.b;
endmodule
