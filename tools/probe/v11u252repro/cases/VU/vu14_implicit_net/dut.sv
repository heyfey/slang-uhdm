// § dupImportSameValueKeeps252
package p;
parameter A = 1;
endpackage
import p::*;
module sub(input logic a, output logic y); assign y = a ^ A; endmodule
module top(input logic a, output logic y);
  sub u(.a(a), .y(n1));
  assign y = n1;
endmodule
