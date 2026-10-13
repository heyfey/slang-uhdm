// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, input logic b, input logic c, output logic o);
  function automatic logic f(input logic x);
    return ~x;
  endfunction
  if (1) begin : g
    child c0 (.clk(f(a) ? b : c), .o(o));
  end
endmodule
