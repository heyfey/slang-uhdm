// § psBoundBareRefByBase145
package p;
  parameter int H = 7;
  parameter int L = 4;
endpackage
module dut import p::*; (input logic [31:0] a, output logic [3:0] o);
  assign o = a[H:L];
endmodule
