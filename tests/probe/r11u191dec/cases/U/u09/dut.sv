// (r11u191) one definition, two instances with different LHS widths (the in-place resize of a shared constant)
package p;
   parameter logic [15:0] X = 16'h12;
endpackage
module m #(parameter int W = 8) (output logic [W-1:0] a);
   import p::X;
   assign a = X;
endmodule
module top(output logic [7:0] o, output logic [31:0] q);
   m #(.W(8)) u1(.a(o));
   m #(.W(32)) u2(.a(q));
endmodule
