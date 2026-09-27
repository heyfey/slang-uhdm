// § pkgParamElabCaSharesDefFold183 (a struct-typed package parameter)
package p;
   typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
   parameter s_t S = 8'h5a;
endpackage
module m(output logic [7:0] a);
   import p::*;
   assign a = S;
endmodule
module top(output logic [7:0] o1);
   m u(.a(o1));
endmodule
