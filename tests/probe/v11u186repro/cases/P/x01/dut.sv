// § pkgParamElabCaSharesDefFold183 (two instances of one module read a package parameter)
package p;
   parameter logic [15:0] X = 16'h12;
endpackage
module m(output logic [15:0] a);
   import p::X;
   assign a = X;
endmodule
module top(output logic [15:0] o1, output logic [15:0] o2);
   m u1(.a(o1));
   m u2(.a(o2));
endmodule
