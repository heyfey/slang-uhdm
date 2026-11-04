// § implicitPortPaLastIface419
package pk;
  parameter Q = 3;
endpackage
interface ifc
  import pk::*;
#(
  int N = 2
);
  localparam int L = N * Q;
  logic [N-1:0] x;
endinterface
module dut(ifc p);
endmodule
module top;
  ifc #(.N(4)) u();
  dut d(u);
endmodule
