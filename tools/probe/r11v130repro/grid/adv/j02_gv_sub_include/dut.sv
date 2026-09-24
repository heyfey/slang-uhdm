// § genvarIntTsRootFile130
module sub(output logic [3:0] o);
`include "loop.svh"
endmodule
module top(output logic [3:0] o);
  sub u(.o(o));
endmodule
