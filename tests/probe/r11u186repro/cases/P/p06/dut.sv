// § pkgParamFoldOwnTs183 (a bare decimal default)
package p;
   parameter logic [7:0] Y = 5;
endpackage
module m(output int a);
   import p::*;
   assign a = Y;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
