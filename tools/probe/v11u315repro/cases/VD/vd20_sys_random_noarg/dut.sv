// § genConnTernSysActual315
module child (input logic [31:0] clk, output logic o);
  assign o = clk[0];
endmodule
module top (output logic o);
  if (1) begin : g
    child c0 (.clk($random()), .o(o));
  end
endmodule
