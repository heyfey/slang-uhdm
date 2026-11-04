// § pkgParamElabCaSharesDefFold183 (instances in a generate loop, an interface reading the parameter)
package p;
   parameter logic [3:0] X = 4'hc;
endpackage
interface bus_if(output logic [3:0] w);
   import p::*;
   assign w = X;
endinterface
module m(output logic [3:0] a);
   import p::X;
   assign a = X;
endmodule
module top(output logic [3:0] o [2], output logic [3:0] q);
   for (genvar i = 0; i < 2; i++) begin : g
     m u(.a(o[i]));
   end
   bus_if b(.w(q));
endmodule
