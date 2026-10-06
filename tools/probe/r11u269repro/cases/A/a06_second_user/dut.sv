// § topNestedArrElemTopTwin269
package p;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct packed {
    logic [3:0] other;
    mreg_t [1:0] cfg;
  } reg2hw_t;
endpackage
module sub(input logic d, output logic q);
  assign q = d;
endmodule
module regtop(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.cfg[0].en.q));
endmodule
module mp import p::*; (input mreg_t [1:0] cfgs_i, output logic o);
  assign o = cfgs_i[0].en.q;
endmodule
module top(input logic d, output logic o);
  p::reg2hw_t r;
  regtop u_reg(.d(d), .reg2hw(r));
  mp u_mp(.cfgs_i(r.cfg), .o(o));
endmodule
