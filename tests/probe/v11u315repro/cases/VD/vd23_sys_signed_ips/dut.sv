// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [3:0] v, input logic [1:0] s, output logic o);
  if (1) begin : g
    child c0 (.clk($signed(v[s +: 1])), .o(o));
  end
endmodule
