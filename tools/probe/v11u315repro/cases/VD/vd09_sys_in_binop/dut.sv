// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, input logic b, output logic o);
  if (1) begin : g
    child c0 (.clk(b ^ $signed(a)), .o(o));
  end
endmodule
