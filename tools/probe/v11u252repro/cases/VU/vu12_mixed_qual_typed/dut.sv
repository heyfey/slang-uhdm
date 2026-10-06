// § dupImportSameValueKeeps252
package p;
parameter int A = 6;
parameter int B = 2;
endpackage
import p::*;
module sub #(parameter X = p::A) (output logic [7:0] o);
  assign o = X + B;
endmodule
module top(output logic [7:0] o);
  sub #(.X(A + B)) u(o);
endmodule
