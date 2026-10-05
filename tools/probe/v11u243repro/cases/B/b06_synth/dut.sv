// § unitImpPaRhsOwnCopy243
// a synthesizable module reading $unit-imported package parameters with unsized and typed values
package p;
  parameter W = 'h8;
  parameter int unsigned K = 'h3;
  parameter logic [7:0] V = 'ha5;
  parameter F = '1;
endpackage
import p::*;
module top(input logic [W-1:0] a, output logic [W-1:0] o, output logic [7:0] q);
  assign o = a + K;
  assign q = V ^ {8{F[0]}};
endmodule
