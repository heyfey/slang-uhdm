// § genConnTernSysActual315
`define SG(x) $signed(x)
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, output logic o);
  if (1) begin : g
    child c0 (.clk(`SG(a)), .o(o));
  end
endmodule
