// § nestShadowFileScopeResolves307v
primitive inner (output o, input i);
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive
module outer (input logic a, output logic y);
  module inner (output logic o, input logic i); assign o = ~i; endmodule
  inner u_in (y, a);
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
