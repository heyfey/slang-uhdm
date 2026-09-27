package p;
   parameter logic [15:0] X = 16'h1234;
endpackage
module m import p::*; #(parameter logic [15:0] P = X) (output int a);
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
