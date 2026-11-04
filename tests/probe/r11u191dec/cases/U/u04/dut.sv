// (r11u191) an unsized decimal default, a 12-bit LHS, a parameter typed int
package p;
   parameter int Y = 5;
endpackage
module m(output logic [11:0] a);
   import p::*;
   assign a = Y;
endmodule
module top(output logic [11:0] o);
   m u(.a(o));
endmodule
