// § nestedDeepInstStub307
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  if (1) begin : g
    inner u_in (.i(a), .o(y));
  end
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (.a(a[0]), .y(y[0]));
  outer u2 (.a(a[1]), .y(y[1]));
endmodule
