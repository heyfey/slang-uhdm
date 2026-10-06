// § dupImportSameValueKeeps252
package p;
parameter real R = 2.5;
parameter string S = "ab";
parameter real R2 = R * 2;
endpackage
import p::*;
module top(output logic [7:0] o);
  real r;
  initial r = R2;
  assign o = 8'(S.len());
endmodule
