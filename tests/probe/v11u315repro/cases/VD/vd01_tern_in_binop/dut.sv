// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, input logic b, input logic c, input logic s, output logic o);
  if (1) begin : g
    child c0 (.clk(a & (s ? b : c)), .o(o));
  end
endmodule
