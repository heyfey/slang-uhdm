// § dupImportSameValueKeeps252
package p;
parameter A = 3;
parameter B = 4'hc;
parameter C = A + B;
endpackage
import p::*;
import p::A;
module top(output logic [7:0] o);
  assign o = A + C;
endmodule
