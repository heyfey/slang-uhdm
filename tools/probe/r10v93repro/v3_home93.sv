// v93 adversarial arm V3 — homes: gen-for, gen-if, 3-deep chain, bind, interface.
module v3_leaf #(parameter int W = 64) (input logic clk, output logic [63:0] o);
  localparam logic [W-1:0] L = W'(64'hFFFF_FFFF_FFFF_FFFF);
  assign o = L[63:0] ^ {64{clk}};
endmodule
module v3_mid #(parameter int W = 64) (input logic clk, output logic [63:0] o);
  localparam logic [W-1:0] LM = W'(64'hFFFF_FFFF_FFFF_FFFF);
  v3_leaf #(.W(W)) u (.clk(clk), .o(o));
endmodule
module v3_out #(parameter int W = 64) (input logic clk, output logic [63:0] o);
  localparam logic [W-1:0] LO = W'(64'hFFFF_FFFF_FFFF_FFFF);
  v3_mid #(.W(W)) u (.clk(clk), .o(o));
endmodule
module v3_bindee (input logic clk);
  localparam logic [63:0] LB = 64'(64'hFFFF_FFFF_FFFF_FFFF);
endmodule
module v3_top (input logic clk, output logic [63:0] o);
  logic [63:0] t0, t1, t2;
  genvar gi;
  generate
    for (gi = 0; gi < 3; gi++) begin : g_for
      localparam int GW = 64 + 32*gi;
      localparam logic [GW-1:0] LG = GW'(64'hFFFF_FFFF_FFFF_FFFF);
      localparam logic [63:0] LG64 = LG[63:0];
    end
    if (1) begin : g_if
      localparam logic [63:0]  LI64  = 64'(64'hFFFF_FFFF_FFFF_FFFF);
      localparam logic [95:0]  LI96  = 96'(64'hFFFF_FFFF_FFFF_FFFF);
      localparam logic [127:0] LI128 = 128'(64'hFFFF_FFFF_FFFF_FFFF);
    end
  endgenerate
  v3_out #(.W(64))  a64  (.clk(clk), .o(t0));
  v3_out #(.W(96))  a96  (.clk(clk), .o(t1));
  v3_out #(.W(128)) a128 (.clk(clk), .o(t2));
  v3_bindee u_be (.clk(clk));
  assign o = t0 ^ t1 ^ t2;
endmodule
