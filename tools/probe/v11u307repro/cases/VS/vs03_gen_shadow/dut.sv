// § nestShadowFileScopeResolves307v
module inner (input logic i, output logic o); assign o = ~i; endmodule
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  if (1) begin : g
    inner u_in (.i(a), .o(y));
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
