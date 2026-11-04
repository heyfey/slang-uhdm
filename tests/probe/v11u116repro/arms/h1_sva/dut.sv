package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module dut import pk::*; (input logic clk, input logic [31:0] x);
  property pp; @(posedge clk) x == P_CAT |-> ##1 x != P_REP; endproperty
  assert property (pp);
  cover property (@(posedge clk) x == P_CAT);
endmodule
