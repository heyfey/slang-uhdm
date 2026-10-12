// § nestedDefPortsNeedShell297
module outer #(parameter int W = 1) (input logic [W-1:0] a, output logic [W-1:0] b);
  module inner (input logic x, output logic y); assign y = ~x; endmodule
  inner u_i (.x(a[0]), .y(b[0]));
  if (W > 1) begin : g
    assign b[W-1:1] = a[W-1:1];
  end
endmodule
module dut(input logic [5:0] a, output logic [5:0] b);
  outer #(.W(1)) u0 (.a(a[0]), .b(b[0]));
  outer #(.W(2)) u1 (.a(a[2:1]), .b(b[2:1]));
  outer #(.W(3)) u2 (.a(a[5:3]), .b(b[5:3]));
endmodule
