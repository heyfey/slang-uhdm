package p;
   parameter logic [15:0] X = 16'b1010;
   parameter logic [15:0] Y = 16'd77;
endpackage
module m(output int a, output int b);
   import p::*;
   assign a = X;
   assign b = Y;
endmodule
module top(output int o, output int q);
   m u(.a(o), .b(q));
endmodule
