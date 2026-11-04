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
module regtop import p::*; (input logic d, input mreg_t m, output reg2hw_t reg2hw, output logic o);
  assign reg2hw = '0;
  assign o = m.en.q ^ d;
endmodule
module top(input logic d, input p::mreg_t m, output p::reg2hw_t r, output logic o);
  regtop u_reg(.d(d), .m(m), .reg2hw(r), .o(o));
endmodule
