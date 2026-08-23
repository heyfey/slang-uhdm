// b08v: Verilog-2001 spelling, generate, defparam, ANSI and non-ANSI headers.
module b08v_child (clk);
  input clk;
  parameter VP = 'h1a;
  parameter VD = 'd7;
  parameter VB = 'b1010;
  localparam VL = 'h2b;
  reg [7:0] r;
  always @(posedge clk) r <= VP + VD + VB + VL;
endmodule
module b08v_ansi #(parameter AP = 'hCC) (input clk);
  localparam AL = 'o17;
  always @(posedge clk) $display(AP, AL);
endmodule
module b08v_top (clk);
  input clk;
  b08v_child c0 (clk);
  b08v_child #('hFF) c1 (clk);
  b08v_child c2 (clk);
  b08v_ansi  a0 (clk);
  defparam c2.VP = 'hEE;
  genvar g;
  generate
    for (g = 0; g < 2; g = g + 1) begin : gb
      localparam GL = 'h33;
      b08v_child #(.VP(GL)) cg (clk);
    end
  endgenerate
endmodule
