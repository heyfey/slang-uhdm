// (r11u191 unsized/sized package parameter folded in an elaborated continuous assignment) a sized hex default, an 8-bit LHS
package p;
   parameter logic [15:0] X = 16'h12;
endpackage
module m(output logic [7:0] a);
   import p::X;
   assign a = X;
endmodule
module top(output logic [7:0] o);
   m u(.a(o));
endmodule
