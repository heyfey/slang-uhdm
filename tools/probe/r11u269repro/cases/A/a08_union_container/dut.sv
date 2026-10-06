// § topNestedArrElemTopTwin269 (a packed union holding the struct-typed member and the array)
package p;
  typedef struct packed { logic [7:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [6:0] q; } base;
  } mreg_t;
  typedef struct packed { addr_t addr; mreg_t [1:0] cfg; } a_t;
  typedef union packed { a_t a; logic [23:0] raw; } reg2hw_t;
endpackage
module sub(input logic d, output logic q); assign q = d; endmodule
module regtop(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.a.cfg[0].en.q));
endmodule
module top(input logic d, output p::reg2hw_t r);
  regtop u_reg(.d(d), .reg2hw(r));
endmodule
