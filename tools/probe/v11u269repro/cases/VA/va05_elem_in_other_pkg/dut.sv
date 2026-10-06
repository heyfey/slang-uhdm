// § topNestedArrElemTopTwin269
package e;
  typedef struct packed {
    struct packed { logic q; } en;
    logic [3:0] base;
  } mreg_t;
endpackage
package p;
  typedef struct packed {
    struct packed { logic q; } top_en;
    e::mreg_t [1:0] cfg;
  } reg2hw_t;
endpackage
module sub(input logic d, output logic q);
  assign q = d;
endmodule
module regtop(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.cfg[0].en.q));
endmodule
module top(input logic d, output p::reg2hw_t r);
  regtop u_reg(.d(d), .reg2hw(r));
endmodule
