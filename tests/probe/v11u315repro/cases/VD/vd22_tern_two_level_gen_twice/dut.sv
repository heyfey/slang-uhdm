// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module mid (input logic a, input logic b, input logic s, output logic o);
  for (genvar i = 0; i < 1; i++) begin : g
    if (1) begin : h
      child c0 (.clk(s ? a : b), .o(o));
    end
  end
endmodule
module top (input logic a, input logic b, input logic s, output logic o1, output logic o2);
  mid m1 (.a(a), .b(b), .s(s), .o(o1));
  mid m2 (.a(b), .b(a), .s(s), .o(o2));
endmodule
