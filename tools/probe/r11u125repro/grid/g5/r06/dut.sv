// § includeInfoEmptyRedefineLine125
`define E
`undef E
`define E
`include "d.svh"
module top(output o);
assign o = 0;
endmodule
