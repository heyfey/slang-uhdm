// v58 VERIFIER arm V1 — MULTI-INSTANCE, DIFFERENT VALUES.  The mis-bind test:
// two elaborated copies of the same module whose d1 gen-scope localparam has
// DIFFERENT values.  A location+name (or a ps-only) lookup hands both copies
// the SAME constant; a path lookup must not.
module v1_leaf #(parameter int unsigned D = 4)
  (input logic clk, input logic [63:0] v,
   output logic [63:0] o1, output logic [63:0] o2, output logic [63:0] o3);
  if (D > 1) begin : gp
    localparam int unsigned W = D + 1;      // 5 / 9 / 13
    if (D > 2) begin : gc
      logic [63:0] r1, r2;
      logic [63:0] st [0:63];
      always_ff @(posedge clk) r1 <= v[W-2:0];             // part_select left bound, op
      always_comb r2 = v[0 +: (W-1)];                      // ips width, op
      always_ff @(posedge clk) st[v[W-2:0]] <= v;          // the prim_fifo_sync shape
      assign o1 = r1;
      assign o2 = r2;
      assign o3 = st[0];
    end
  end
endmodule

module v1_earl58 (input logic clk, input logic [63:0] v,
                  output logic [63:0] a1,a2,a3,b1,b2,b3,c1,c2,c3);
  v1_leaf #(.D(4))  ua (.clk(clk), .v(v), .o1(a1), .o2(a2), .o3(a3));
  v1_leaf #(.D(8))  ub (.clk(clk), .v(v), .o1(b1), .o2(b2), .o3(b3));
  v1_leaf #(.D(12)) uc (.clk(clk), .v(v), .o1(c1), .o2(c2), .o3(c3));
endmodule
