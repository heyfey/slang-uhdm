// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h1F;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule
module top(output logic [7:0] y, output logic [15:0] z);
  import p::*;
  sub u(.i(H), .o(y));
  assign z = {H, 8'h0};
endmodule
