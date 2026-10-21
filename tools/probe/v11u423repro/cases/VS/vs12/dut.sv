// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h7;
endpackage
interface ifc(input logic [3:0] a);
  import p::*;
  logic [3:0] b;
  assign b = a & H;
endinterface
module top(input logic [3:0] a);
  ifc u(.a(a));
endmodule
