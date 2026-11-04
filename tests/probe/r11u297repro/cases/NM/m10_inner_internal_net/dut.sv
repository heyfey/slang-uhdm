// § nestedDefPortsNeedShell297
module outer (input logic a, output logic b);
  module inner (input logic x, output logic y);
    logic t;
    assign t = ~x;
    always_comb y = t;
  endmodule
  inner u_i (.x(a), .y(b));
endmodule
module dut(input logic [1:0] a, output logic [1:0] b);
  outer u0 (.a(a[0]), .b(b[0]));
  outer u1 (.a(a[1]), .b(b[1]));
endmodule
