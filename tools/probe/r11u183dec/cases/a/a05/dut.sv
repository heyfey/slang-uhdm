package p;
   parameter logic [7:0] X = 8'hab;
endpackage
module top(output int a);
   import p::*;
   int b;
   always_comb b = X;
   assign a = b;
endmodule
