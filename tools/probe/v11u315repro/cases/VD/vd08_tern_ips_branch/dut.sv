// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [3:0] v, input logic [1:0] s, input logic t, output logic o);
  if (1) begin : g
    child c0 (.clk(t ? v[s +: 1] : v[0]), .o(o));
  end
endmodule
