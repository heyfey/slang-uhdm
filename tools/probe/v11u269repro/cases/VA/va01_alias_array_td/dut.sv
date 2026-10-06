// § topNestedArrElemTopTwin269
package p;
  typedef struct packed {
    struct packed { logic q; } en;
    logic [3:0] base;
  } mreg_t;
  typedef mreg_t [1:0] mregs_t;
  typedef struct packed {
    struct packed { logic q; } top_en;
    mregs_t cfg;
  } reg2hw_t;
  function automatic logic g(mregs_t m);
    return m[0].en.q;
  endfunction
endpackage
module sub(input logic d, output logic q);
  assign q = d;
endmodule
module regtop(input logic d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.cfg[0].en.q));
endmodule
module top(input logic d, output p::reg2hw_t r);
  regtop u_reg(.d(d), .reg2hw(r));
endmodule
