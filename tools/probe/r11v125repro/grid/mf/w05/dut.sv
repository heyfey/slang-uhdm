// § macroTokenFileFollowsLine125
`include "a.svh"
module top(input logic [3:0] a, output logic [3:0] o1, o2);
`include "b.svh"
endmodule
