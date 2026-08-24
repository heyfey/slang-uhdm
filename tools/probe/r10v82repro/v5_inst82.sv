// v82 adversarial arm V5 — 1..3 INSTANCES of one definition, mixing an
// overridden and a DEFAULT instance (the § boundOverriddenParamWidth24 /
// we24 2x2 that a per-instance rule can break), with the bound in the module
// body, in a gen-for, in a gen-if and in a nested gen scope.
// MEASUREMENT ONLY.
typedef struct packed { logic [3:0] a; } mv5_t;

module ch_v5_82 #(parameter int W_T = 8, parameter W_U = 8)
  (input logic clk, output logic o);
  logic [63:W_T] n_t;
  logic [63:W_U] n_u;
  mv5_t [W_T:0]  v_t;
  logic acc;
  genvar gj;
  generate
    for (gj = 0; gj < 2; gj++) begin : g5f
      logic [63:W_T] n_gt;
      mv5_t [W_T:0]  v_gt;
      if (gj == 0) begin : g5n
        logic [63:W_T] n_nt;
        mv5_t [W_T:0]  v_nt;
      end
    end
    if (W_T > 0) begin : g5i
      logic [63:W_T] n_it;
      mv5_t [W_T:0]  v_it;
    end
  endgenerate
  always_comb acc = clk ^ n_t[63] ^ n_u[63] ^ v_t[0].a[0]
                    ^ g5f[0].n_gt[63] ^ g5f[0].g5n.n_nt[63] ^ g5i.n_it[63];
  assign o = acc;
endmodule

module top_v5_82 (input logic clk, output logic o1, o2, o3);
  localparam int EXPR_LPV = 20 + 20;
  ch_v5_82                                  ia (.clk(clk), .o(o1)); // DEFAULT
  ch_v5_82 #(.W_T(40), .W_U(40))            ib (.clk(clk), .o(o2)); // literal
  ch_v5_82 #(.W_T(EXPR_LPV), .W_U(EXPR_LPV)) ic (.clk(clk), .o(o3)); // name->expr
endmodule
