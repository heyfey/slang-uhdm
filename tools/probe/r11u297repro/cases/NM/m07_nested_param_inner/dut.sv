// § nestedDefPortsNeedShell297
module outer (input logic [3:0] a, output logic [3:0] b);
  module inner #(parameter int N = 2) (input logic [N-1:0] x, output logic [N-1:0] y);
    assign y = x;
  endmodule
  inner #(.N(4)) u_i (.x(a), .y(b));
endmodule
module dut(input logic [7:0] a, output logic [7:0] b);
  outer u0 (.a(a[3:0]), .b(b[3:0]));
  outer u1 (.a(a[7:4]), .b(b[7:4]));
endmodule
