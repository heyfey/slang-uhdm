// law pkgParamElabCaSharesDefFold183
package p;
   parameter logic [3:0][1:0] X = 8'hA5;
endpackage
module m(output int a);
   import p::*;
   assign a = X;
endmodule
module top(output int o, output int q);
   m u1(.a(o));
   m u2(.a(q));
endmodule
