// § pkgParamElabCaSharesDefFold183 (the package in an included header; the reader in a second module too)
`include "pkg.svh"
module m(output logic [7:0] a);
   import p::X;
   assign a = X;
endmodule
module n(output logic [7:0] a);
   assign a = p::X;
endmodule
module top(output logic [7:0] o1, o2);
   m u(.a(o1));
   n v(.a(o2));
endmodule
