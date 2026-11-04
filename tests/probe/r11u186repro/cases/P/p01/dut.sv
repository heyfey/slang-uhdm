// § pkgParamElabCaSharesDefFold183
package p;
   parameter logic [15:0] X = 16'h12;
endpackage
module m(output int a);
   import p::X;
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
