// § nestedDeepInstStub307
module outer (input logic [1:0] a, output logic [1:0] y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  for (genvar k = 0; k < 2; k++) begin : g
    inner u_in (.i(a[k]), .o(y[k]));
  end
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (.a(a), .y(y));
endmodule
