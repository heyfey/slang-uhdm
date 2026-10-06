// § topNestedArrElemTopTwin269 (two definitions with the port type, a path in each)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct packed { addr_t addr; mreg_t [1:0] cfg; } reg2hw_t;
endpackage
module sub(input logic d, output logic q); assign q = d; endmodule
module rega(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.cfg[0].en.q));
endmodule
module regb(input p::reg2hw_t reg2hw, output logic o);
  import p::*;
  sub u1(.d(reg2hw.cfg[1].en.q), .q(o));
endmodule
module top(input logic d, output logic o);
  p::reg2hw_t r;
  rega ua(.d(d), .reg2hw(r));
  regb ub(.reg2hw(r), .o(o));
endmodule
