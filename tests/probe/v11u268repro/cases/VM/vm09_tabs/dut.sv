// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top; int a;
	initial	$display("%s %0d",	`VS,	a + 1);
endmodule
