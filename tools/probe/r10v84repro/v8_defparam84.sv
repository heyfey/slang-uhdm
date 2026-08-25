// r10v84 arm v8 — DEFPARAM and the remaining producers.
//  p1 a parameter overridden by DEFPARAM (neither `isOverriddenParam` nor
//     `adjustCopiedParamConst64` was written for that producer)
//  p2 the same module NOT defparam'd — the control
//  p3 a localparam whose value is 0 and one at the top of the vector
module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module dpm84 #(parameter int DP = 3) ();
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  sinkv84 #(.W(8)) u_dp (.a(reg2hw.addr.q[DP +: 8]));
endmodule

module dpar84;
  dpm84 u_ov ();     // p1 — defparam'd below
  dpm84 u_pl ();     // p2 — control
  defparam u_ov.DP = 5;
endmodule
