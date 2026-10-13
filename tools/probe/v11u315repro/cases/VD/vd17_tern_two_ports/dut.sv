// § genConnTernSysActual315
module child2 (input logic x, input logic y, output logic o);
  assign o = x & y;
endmodule
module top (input logic a, input logic b, input logic s, output logic o);
  if (1) begin : g
    child2 c0 (.x(s ? a : b), .y($signed(b)), .o(o));
  end
endmodule
