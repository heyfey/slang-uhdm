// § rawEndLineModel295
package p;
	logic	[7:0]	v	=	8'h3;
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
