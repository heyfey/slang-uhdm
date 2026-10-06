// § topNestedArrElemTopTwin269 (control: the qualified port type alone, no import anywhere)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct packed { addr_t addr; mreg_t [1:0] cfg; } reg2hw_t;
endpackage
module sub(input logic d, output logic q); assign q = d; endmodule
module regtop(input logic d, output p::reg2hw_t reg2hw);
  sub u0(.d(d), .q(reg2hw.cfg[0].en.q));
endmodule
module top(input logic d, output p::reg2hw_t r);
  regtop u_reg(.d(d), .reg2hw(r));
endmodule
