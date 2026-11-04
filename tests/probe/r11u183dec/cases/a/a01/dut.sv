package p;
   parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module m(output int a);
   import p::*;
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
