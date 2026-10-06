// § topNestedArrElemTopTwin269 (an unpacked struct holding an unpacked array of the struct)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct { addr_t addr; mreg_t cfg [2]; } reg2hw_t;
endpackage
module top(input logic d, output logic o);
  import p::*;
  reg2hw_t r;
  assign r.cfg[0].en.q = d;
  assign o = r.cfg[0].en.q;
endmodule
