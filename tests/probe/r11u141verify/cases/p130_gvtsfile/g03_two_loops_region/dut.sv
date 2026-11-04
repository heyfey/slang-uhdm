// § genvarIntTsRootFile130
// case g03_two_loops_region: the generate loop lives in an included file
module top(input logic [1:0] a, output logic [1:0] y);
`include "loop.svh"
endmodule
