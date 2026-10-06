// § topNestedArrElemTopTwin269 (a module-local variable of the struct, not a port)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct packed { addr_t addr; mreg_t [1:0] cfg; } reg2hw_t;
endpackage
module sub(input logic d, output logic q); assign q = d; endmodule
module top(input logic d, output logic o);
  import p::*;
  reg2hw_t r;
  sub u0(.d(d), .q(r.cfg[0].en.q));
  assign o = r.cfg[1].en.q;
endmodule
