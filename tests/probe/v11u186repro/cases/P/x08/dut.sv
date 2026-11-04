// § pkgParamElabCaSharesDefFold183 (a binary literal read, a bit-select read, a package parameter in a generate scope)
package p;
   parameter logic [3:0] X = 4'b1010;
endpackage
module m(output logic [3:0] a, output logic b, output logic [3:0] c);
   import p::*;
   assign a = X;
   assign b = X[1];
   if (1) begin : g
     assign c = X;
   end
endmodule
module top(output logic [3:0] o1, output logic o2, output logic [3:0] o3);
   m u(.a(o1), .b(o2), .c(o3));
endmodule
