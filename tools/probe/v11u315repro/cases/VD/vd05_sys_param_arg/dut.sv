// § genConnTernSysActual315
module child (input logic [3:0] clk, output logic o);
  assign o = clk[0];
endmodule
module top #(parameter int W = 8) (output logic o);
  if (1) begin : g
    child c0 (.clk($clog2(W)), .o(o));
  end
endmodule
