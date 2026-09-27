// § importNetTsToInitEnd183 (the package in an included header, imported by two modules)
`include "pkg.svh"
module m(output logic [3:0] o);
  import p::*;
  assign o = a + b[3:0];
endmodule
module top(output logic [3:0] o1, o2);
  import p::a;
  m u(.o(o1));
  assign o2 = a;
endmodule
