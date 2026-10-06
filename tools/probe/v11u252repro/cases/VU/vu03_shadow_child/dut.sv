// § dupImportSameValueKeeps252
package p;
parameter A = 5;
parameter B = A * 3;
endpackage
import p::*;
module child #(parameter A = 7) (output logic [7:0] o);
  assign o = A + B;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
  child c1(o1);
  child #(.A(9)) c2(o2);
endmodule
