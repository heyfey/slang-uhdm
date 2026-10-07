// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = -3;
  parameter logic [3:0] B = ~4'h1;
endpackage
interface ifc; import pk::*; logic [3:0] s; assign s = B; int t; assign t = A; endinterface
module dut(output logic [3:0] o); ifc u(); assign o = u.s; endmodule
