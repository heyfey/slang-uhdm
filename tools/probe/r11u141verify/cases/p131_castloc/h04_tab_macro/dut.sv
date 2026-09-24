// § castTsPushLaidOut131
// case h04: a macro before the cast on the same line, the line indented with a TAB
`define ZERO 6'd0
module top(input logic [15:0] a, output logic [5:0] o);
	assign o = `ZERO + 6'(a);
endmodule
