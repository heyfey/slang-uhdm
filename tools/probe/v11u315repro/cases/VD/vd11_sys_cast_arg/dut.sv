// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [1:0] a, output logic o);
  if (1) begin : g
    child c0 (.clk($signed(1'(a))), .o(o));
  end
endmodule
