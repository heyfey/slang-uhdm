// § topNestedArrElemTopTwin269
package p;
  typedef struct packed {
    logic q;
    logic [2:0] f;
  } mreg_t;
  typedef union packed {
    struct packed { logic [11:0] x; } s;
    mreg_t [2:0] cfg;
  } reg2hw_u;
endpackage
module regtop import p::*; (input logic d, output reg2hw_u u);
  assign u.cfg[1].q = d;
  assign u.cfg[0] = '0;
  assign u.cfg[2] = '0;
endmodule
module top(input logic d, output p::reg2hw_u u);
  regtop r(.d(d), .u(u));
endmodule
