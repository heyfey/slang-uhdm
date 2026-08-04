// r10rggen7 t9: WHERE inside an elaborated gen-scope process does a module
// parameter fold?  t8 showed a BARE reference as an assignment Rhs folds.
// This file puts the same parameter in five positions of one gen-scope
// process: bare Rhs, inside a binary operation, as a select bound, in an
// if condition, and as a for-loop bound.
module t9 #(
  parameter bit [3:0] IV = 4'h5,
  parameter int       N  = 3
)(
  input  logic        clk,
  output logic [3:0]  o_bare,
  output logic [3:0]  o_expr,
  output logic [15:0] o_sel,
  output logic [3:0]  o_cond,
  output logic [3:0]  o_loop
);
  logic [15:0] src;
  assign src = 16'hbeef;

  generate if (N > 0) begin : g_p
    always_ff @(posedge clk) begin
      o_bare <= IV;
      o_expr <= IV + 4'h1;
      o_sel  <= src[N +: 4];
      if (IV == 4'h5)
        o_cond <= 4'h1;
      for (int i = 0; i < N; i++)
        o_loop <= o_loop + IV;
    end
  end endgenerate
endmodule

module t9_top;
  logic clk;
  logic [3:0] a, b, d, e;
  logic [15:0] c;
  t9 #(.IV(4'ha), .N(2)) u_t9 (.clk(clk), .o_bare(a), .o_expr(b), .o_sel(c),
                               .o_cond(d), .o_loop(e));
endmodule
