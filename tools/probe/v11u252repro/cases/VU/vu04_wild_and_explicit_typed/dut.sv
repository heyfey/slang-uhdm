// § dupImportSameValueKeeps252
package p;
parameter int A = 3;
parameter int B = 4'hc;
parameter int C = A + B;
endpackage
import p::*;
import p::A;
module top(output logic [7:0] o);
  assign o = A + C;
endmodule
