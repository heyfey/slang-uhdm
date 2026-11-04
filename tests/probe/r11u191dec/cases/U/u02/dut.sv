// (r11u191) a sized hex default, a 64-bit LHS
package p;
   parameter logic [15:0] X = 16'h12;
endpackage
module m(output logic [63:0] a);
   import p::X;
   assign a = X;
endmodule
module top(output logic [63:0] o);
   m u(.a(o));
endmodule
