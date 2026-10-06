// § shadowedImportTsRefOwner260 (an interface body's indexed part-select width)
package rp;
  localparam int OffD = 2;
endpackage
interface ifc import rp::*; (input logic [7:0] a);
  localparam int OffD = 2;
  logic [1:0] q;
  assign q = a[1 +: OffD];
endinterface
module top;
  logic [7:0] a;
  ifc u (.a(a));
endmodule
