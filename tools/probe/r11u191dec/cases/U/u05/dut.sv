// (r11u191) a binary default and a based unsized default, a 16-bit LHS
package p;
   parameter logic [3:0] B = 4'b1010;
   parameter logic [9:0] H = 'h3F;
endpackage
module m(output logic [15:0] a, output logic [15:0] b);
   import p::*;
   assign a = B;
   assign b = H;
endmodule
module top(output logic [15:0] o, output logic [15:0] q);
   m u(.a(o), .b(q));
endmodule
