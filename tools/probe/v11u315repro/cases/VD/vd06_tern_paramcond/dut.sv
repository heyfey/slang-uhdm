// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top #(parameter bit P = 1) (input logic a, input logic b, output logic o);
  if (1) begin : g
    child c0 (.clk(P ? a : b), .o(o));
  end
endmodule
