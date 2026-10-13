// § nestShadowFileScopeResolves307v
module outer (input logic a, b, output logic y);
  module inner (input logic i, j, output logic o); assign o = i & j; endmodule
  inner u_in (y, a, b);
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (a, b, y);
endmodule
module inner (input logic i, j, output logic o); assign o = i & j; endmodule
