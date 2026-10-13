// § nestedPosInstUdp307
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  inner u_in (a, y);
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  for (genvar k = 0; k < 2; k++) begin : g
    outer u1 (.a(a[k]), .y(y[k]));
  end
endmodule
