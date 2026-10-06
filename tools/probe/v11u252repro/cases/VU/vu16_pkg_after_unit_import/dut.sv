// § dupImportSameValueKeeps252
package p;
parameter A = 3;
endpackage
import p::*;
package r;
parameter RB = A + 1;
endpackage
module top import r::*; (output logic [7:0] o);
  assign o = RB + A;
endmodule
