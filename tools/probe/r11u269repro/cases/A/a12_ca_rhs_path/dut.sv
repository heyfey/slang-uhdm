// § topNestedArrElemTopTwin269 (the member path read on a continuous assignment's right side)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct packed { addr_t addr; mreg_t [1:0] cfg; } reg2hw_t;
endpackage
module regtop(input p::reg2hw_t reg2hw, output logic [3:0] o, output logic e);
  import p::*;
  assign o = reg2hw.cfg[1].base.q;
  assign e = reg2hw.cfg[0].en.q;
endmodule
module top(input p::reg2hw_t r, output logic [3:0] o, output logic e);
  regtop u_reg(.reg2hw(r), .o(o), .e(e));
endmodule
