// § pkgParamFoldOwnTs183 (a computed default, a multi-dimensional packed type)
package p;
   parameter bit [3:0][1:0] Z = 2 * 3;
endpackage
module m(output int a);
   import p::*;
   assign a = Z;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
