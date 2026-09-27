// § pkgParamElabCaSharesDefFold183
package p;
   parameter logic [7:0] X = 8'd200;
endpackage
module m(output int a);
   assign a = p::X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
