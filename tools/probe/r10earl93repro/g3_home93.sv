// r10earl93 g3 -- THE HOME GRID.  ONE cast text, many homes: a gen-for scope,
// a gen-if scope, a 3-deep instance chain, and three instantiations of ONE
// span at three different widths.  MEASUREMENT ONLY.
module g3_leaf #(parameter int unsigned W = 64) (output logic [W-1:0] o);
  localparam logic [W-1:0] L_leaf = W'(64'hFFFFFFFFFFFFFFFF);
  assign o = L_leaf;
endmodule
module g3_mid #(parameter int unsigned W = 64) (output logic [W-1:0] o);
  localparam logic [W-1:0] L_mid = W'(64'd1);
  g3_leaf #(.W(W)) u (.o(o));
endmodule
module g3_top3 #(parameter int unsigned W = 64) (output logic [W-1:0] o);
  localparam logic [W-1:0] L_top3 = W'(64'd2);
  g3_mid #(.W(W)) u (.o(o));
endmodule
module g3;
  logic [63:0] a; logic [95:0] b; logic [127:0] c;
  // THREE instantiations of ONE span, three widths.
  g3_top3 #(.W(64))  ua (.o(a));
  g3_top3 #(.W(96))  ub (.o(b));
  g3_top3 #(.W(128)) uc (.o(c));
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gf
      localparam logic [63:0] L_genfor = 64'(64'd1) + gi;
      localparam logic [95:0] L_genfor96 = 96'(64'hFFFFFFFFFFFFFFFF);
      wire [63:0] wf; assign wf = 64'(64'd3);
    end
    if (1) begin : gif
      localparam logic [63:0] L_genif = 64'(64'd1);
      localparam logic [95:0] L_genif96 = 96'(64'hFFFFFFFFFFFFFFFF);
      wire [63:0] wg; assign wg = 64'(64'd3);
    end
  endgenerate
endmodule
