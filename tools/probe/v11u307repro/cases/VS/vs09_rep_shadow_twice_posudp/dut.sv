// § nestShadowFileScopeResolves307v
module inner (output logic o, input logic i); assign o = ~i; endmodule
module outer (input logic a, output logic y);
  module inner (output logic o, input logic i); assign o = ~i; endmodule
  inner u_in (y, a);
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (.a(a[0]), .y(y[0]));
  outer u2 (.a(a[1]), .y(y[1]));
endmodule
