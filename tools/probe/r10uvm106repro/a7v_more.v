// a7v: Verilog-2001 spelling of the same shape
module a7v_child (clk);
  input clk;
  parameter V_P = 'h1a;
  parameter V_D = 'd7;
  localparam V_L = 'b1010;
  reg [V_P-1:0] r;
  always @(posedge clk) r <= V_L + V_D;
endmodule
module a7v_top (clk);
  input clk;
  a7v_child c0 (clk);
  a7v_child #('hFF) c1 (clk);
endmodule
