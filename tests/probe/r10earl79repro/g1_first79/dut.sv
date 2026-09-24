module sink79 #(
  parameter int unsigned N = 4
) (
  input logic clk
);
  logic [7:0] v_plus  [N+1];
  logic [7:0] v_minus [N-1];
  logic [7:0] v_mul   [N*2];
  logic [7:0] v_div   [N/2];
  logic [7:0] v_shl   [N<<1];
  logic [7:0] v_clog  [$clog2(N)];
  logic [7:0] v_bare  [N];
  logic [7:0] v_lit   [7];
endmodule

module top79;
  logic clk;
  sink79 #(.N(3)) u_a (.clk(clk));
  sink79 #(.N(5)) u_b (.clk(clk));
endmodule
