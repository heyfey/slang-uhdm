// r10rgg15 grid g4 — the same fill in a module BODY parameter, in a GEN SCOPE,
// and through a parameter HOP; plus a typedef'd target.  MEASUREMENT ONLY.
typedef bit [7:0] g4_bt;
module g4_sub #(parameter int W = 4)();
  localparam bit [W-1:0] L_body  = '0;
  localparam bit [W-1:0] L_bodyo = '1;
  localparam bit [7:0]   L_b8    = '0;
  localparam g4_bt       L_td    = '0;
  localparam int         L_int   = '0;
  if (1) begin : g
    localparam bit [W-1:0] L_gen  = '0;
    localparam bit [7:0]   L_gen8 = '0;
  end
endmodule

module g4_hop #(parameter bit [7:0] H = '0)();
  g4_sub2 #(.K(H)) u ();
endmodule
module g4_sub2 #(parameter bit [3:0] K = 4'h5)();
endmodule

module g4_top;
  g4_sub          u_d ();
  g4_sub #(.W(2)) u_2 ();
  g4_hop          u_h ();
endmodule
