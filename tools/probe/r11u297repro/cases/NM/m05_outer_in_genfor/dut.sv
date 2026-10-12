// § nestedDefPortsNeedShell297
module outer(input logic [1:0] a, output logic [1:0] b);
  module inner(input logic x, output logic y); assign y = x; endmodule
  inner u_i [1:0] (.x(a), .y(b));
endmodule
module dut(input logic [3:0] a, output logic [3:0] b);
  for (genvar k = 0; k < 2; k++) begin : g
    outer u_o (.a(a[2*k+:2]), .b(b[2*k+:2]));
  end
endmodule
