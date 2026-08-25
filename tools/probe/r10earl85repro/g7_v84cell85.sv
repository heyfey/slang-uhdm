// r10v84 arm v7 — MORE PRODUCERS AND CONTEXTS.
//  d1 a parameter overridden by DEFPARAM (a producer neither `isOverriddenParam`
//     nor `adjustCopiedParamConst64` was written for)
//  d2 a NESTED module definition's instantiation
//  d3 the same read reached through TWO instantiation levels
//  d4 a parameter whose param_assign Rhs is an OPERATION our emitter left
//     unfolded (the R0-family shape)
module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module dp84 #(parameter int DP = 3) ();
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  sinkv84 #(.W(8)) u_dp (.a(reg2hw.addr.q[DP +: 8]));
endmodule

module lvl2_84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int L2 = 2;
  sinkv84 #(.W(8)) u_l2 (.a(reg2hw.addr.q[L2 +: 8]));
endmodule

module more84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;

  localparam int Base = 1;
  localparam int Op   = ~(('h1 << 3) - 1'b1) & 32'h7;   // an operation initialiser
  localparam int Add  = Base + 1;

  dp84   u_dpi ();
  lvl2_84 u_two ();

  sinkv84 #(.W(8)) u_op  (.a(reg2hw.addr.q[Op  +: 8]));
  sinkv84 #(.W(8)) u_add (.a(reg2hw.addr.q[Add +: 8]));
endmodule

// defparam on the dp84 instance
module dpwrap84;
  more84 u_more ();
endmodule
