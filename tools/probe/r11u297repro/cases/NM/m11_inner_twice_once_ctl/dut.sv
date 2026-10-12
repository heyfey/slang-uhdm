// § nestedDefPortsNeedShell297
module outer (input logic [1:0] a, output logic [1:0] b);
  module inner (input logic x, output logic y); assign y = x; endmodule
  inner u_i (.x(a[0]), .y(b[0]));
  inner u_j (.x(a[1]), .y(b[1]));
endmodule
module dut(input logic [1:0] a, output logic [1:0] b);
  outer u0 (.a(a), .b(b));
endmodule
