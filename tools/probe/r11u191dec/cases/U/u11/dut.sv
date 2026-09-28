// (r11u191) a binary default wider than the LHS (truncated) and an octal default
package p;
   parameter logic [7:0] B = 8'b1100_0101;
   parameter logic [8:0] O = 9'o17;
endpackage
module m(output logic [3:0] a, output int b);
   import p::*;
   assign a = B;
   assign b = O;
endmodule
module top(output logic [3:0] o, output int q);
   m u(.a(o), .b(q));
endmodule
