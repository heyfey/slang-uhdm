// § genConnTernSysActual315
module child (input logic [1:0] clk, output logic o);
  assign o = clk[0];
endmodule
module top (input logic a, input logic b, output logic o);
  if (1) begin : g
    child c0 (.clk($unsigned({a, b})), .o(o));
  end
endmodule
