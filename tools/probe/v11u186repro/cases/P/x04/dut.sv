// § pkgParamElabCaSharesDefFold183 (a struct-typed and a signed package parameter)
package p;
   typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
   parameter s_t S = 8'h5a;
   parameter logic signed [7:0] N = -8'sd3;
endpackage
module m(output logic [7:0] a, output logic signed [7:0] b);
   import p::*;
   assign a = S;
   assign b = N;
endmodule
module top(output logic [7:0] o1, output logic signed [7:0] o2);
   m u(.a(o1), .b(o2));
endmodule
