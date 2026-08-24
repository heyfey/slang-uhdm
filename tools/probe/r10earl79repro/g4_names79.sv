package pk4;
  parameter int unsigned PM = 4 * 2;
  parameter int unsigned PP = 8;
endpackage

module sink4 import pk4::*; #(
  parameter int unsigned N = 4
) (
  input logic clk
);
  logic [7:0] q_qpm  [pk4::PM+1];
  logic [7:0] q_qpp  [pk4::PP+1];
  logic [7:0] q_upm  [PM+1];
  logic [7:0] q_upp  [PP+1];
  logic [7:0] q_bits [$bits(int)+N];
  logic [7:0] q_clg2 [$clog2(N)+1];
  logic [7:0] q_fn   [f4(N)];
  logic [7:0] q_sub1 [N-1];
  function automatic int f4(int x); return x + 1; endfunction
endmodule

module top4;
  logic clk;
  sink4 #(.N(3)) u_a (.clk(clk));
  sink4 #(.N(5)) u_b (.clk(clk));
endmodule
