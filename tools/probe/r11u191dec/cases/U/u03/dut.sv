// (r11u191) an unsized decimal default, a 4-bit LHS
package p;
   parameter logic [7:0] Y = 5;
endpackage
module m(output logic [3:0] a);
   import p::*;
   assign a = Y;
endmodule
module top(output logic [3:0] o);
   m u(.a(o));
endmodule
