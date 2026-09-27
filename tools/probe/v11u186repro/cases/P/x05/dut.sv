// § pkgParamElabCaSharesDefFold183 (a signed package parameter with a negative value)
package p;
   parameter logic signed [7:0] N = -8'sd3;
endpackage
module m(output logic signed [7:0] b);
   import p::*;
   assign b = N;
endmodule
module top(output logic signed [7:0] o2);
   m u(.b(o2));
endmodule
