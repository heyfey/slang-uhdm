// § includeInfoEmptyRedefineLine125
`define E 1
`define E 1
`include "d.svh"
`include "d.svh"
module top(output o);
assign o = 0;
endmodule
