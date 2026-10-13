// § genConnTernSysActual315
module child (input logic [2:0] clk, output logic o);
  assign o = clk[0];
endmodule
module top (input logic [3:0] v, output logic o);
  for (genvar i = 0; i < 1; i++) begin : g
    child c0 (.clk($countones(v)), .o(o));
  end
endmodule
