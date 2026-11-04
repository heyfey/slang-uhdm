// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top #(parameter bit P = 0) (input logic a, input logic b, input logic s, output logic o);
  if (P) begin : g
    child c0 (.clk(s ? a : b), .o(o));
  end else begin : h
    assign o = a;
  end
endmodule
