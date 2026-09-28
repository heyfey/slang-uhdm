// law pkgParamElabCaSharesDefFold183 (a module port width read through the import)
package p;
   parameter logic [15:0] W = 16'h4;
endpackage
module m import p::*; (output logic [W-1:0] a);
   assign a = W;
endmodule
module top(output logic [3:0] o);
   m u(.a(o));
endmodule
