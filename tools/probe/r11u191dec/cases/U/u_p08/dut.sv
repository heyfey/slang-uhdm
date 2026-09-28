// law pkgParamFoldOwnTs183 (an explicit import, two readers)
package p;
   parameter logic [11:0] K = 100 + 23;
endpackage
module m(output int a, output int b);
   import p::K;
   assign a = K;
   assign b = K + 1;
endmodule
module top(output int o, output int q);
   m u(.a(o), .b(q));
endmodule
