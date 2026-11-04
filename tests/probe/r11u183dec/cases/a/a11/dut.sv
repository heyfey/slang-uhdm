package p;
   parameter logic [15:0] X = 16'h1234;
endpackage
module m(output logic [7:0] a);
   import p::*;
   assign a = X;
endmodule
module top(output logic [7:0] o);
   m u(.a(o));
endmodule
