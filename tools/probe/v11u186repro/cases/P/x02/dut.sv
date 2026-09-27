// § pkgParamElabCaSharesDefFold183 (two specializations of a parameterized module, a wildcard import)
package p;
   parameter logic [7:0] X = 8'b1010_0101;
endpackage
module m #(parameter int W = 1)(output logic [7:0] a, output logic [W-1:0] b);
   import p::*;
   assign a = X;
   assign b = '0;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2, output logic o3, output logic [3:0] o4);
   m #(.W(1)) u1(.a(o1), .b(o3));
   m #(.W(4)) u2(.a(o2), .b(o4));
endmodule
