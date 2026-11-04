package p;
   parameter logic [15:0] X = 1234;
endpackage
module m(output int a);
   import p::*;
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
