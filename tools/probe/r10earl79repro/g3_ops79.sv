module sink3 #(
  parameter int unsigned N = 4,
  parameter int unsigned M = 2
) (
  input logic clk
);
  localparam int LM = N * 2;
  localparam int LA = N + 1;
  localparam int LL = 6;

  logic [7:0] c_add_ii  [(N*2)+1];
  logic [7:0] c_add_lp  [LM+1];
  logic [7:0] c_add_la  [LA+1];
  logic [7:0] c_add_ll  [LL+1];
  logic [7:0] c_add_lit [1+2];
  logic [7:0] c_nest    [(N+1)*2];
  logic [7:0] c_nest2   [N*2+1];
  logic [7:0] c_umin    [-(0-N)];
  logic [7:0] c_paren_b [(N)];
  logic [7:0] c_cast    [int'(N*2)];
  logic [7:0] c_ucast   [unsigned'(N*2)];
  logic [7:0] c_tern    [(N>2)?4:2];
  logic [7:0] c_clog_e  [$clog2(N*4)];
  logic [7:0] c_xor     [N^1];
  logic [7:0] c_sized   [N+8'd2];
  logic [7:0] c_shl_ip  [(N*2)<<1];
endmodule

module top3;
  logic clk;
  sink3 #(.N(3), .M(1)) u_a (.clk(clk));
  sink3 #(.N(5), .M(2)) u_b (.clk(clk));
endmodule
