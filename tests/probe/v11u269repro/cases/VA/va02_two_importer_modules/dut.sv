// § topNestedArrElemTopTwin269
package p;
  typedef struct packed {
    struct packed { logic q; } en;
    logic [3:0] base;
  } mreg_t;
  typedef struct packed {
    struct packed { logic q; } top_en;
    mreg_t [1:0] cfg;
  } reg2hw_t;
endpackage
module sub(input logic d, output logic q);
  assign q = d;
endmodule
module ra(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.cfg[0].en.q));
endmodule
module rb(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u1(.d(d), .q(reg2hw.cfg[1].en.q));
endmodule
module top(input logic d, output p::reg2hw_t r, output p::reg2hw_t s);
  ra u_a(.d(d), .reg2hw(r));
  rb u_b(.d(d), .reg2hw(s));
endmodule
