// (r11u191) a negative int package parameter into a 64-bit LHS and a 4-bit LHS
package p;
   parameter int N = -3;
endpackage
module m(output logic [63:0] a, output logic [3:0] b);
   import p::*;
   assign a = N;
   assign b = N;
endmodule
module top(output logic [63:0] o, output logic [3:0] q);
   m u(.a(o), .b(q));
endmodule
