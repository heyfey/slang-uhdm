package p;
   parameter int X = 5;
endpackage
module m(output int a);
   import p::*;
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
