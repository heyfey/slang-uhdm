// § nestedDefPortsNeedShell297
module outer(input logic [1:0] a, output logic [1:0] y);
  module inner(input logic [1:0] i, output logic [1:0] o);
    assign o = {i[0], i[1]};
  endmodule
  inner u_in(.i(a), .o(y));
endmodule
module dut(input logic [5:0] a, output logic [5:0] y);
  for (genvar k = 0; k < 3; k++) begin : g
    outer u(.a(a[2*k+:2]), .y(y[2*k+:2]));
  end
endmodule
