// § enumImpDefOwner180v (verifier: interface importer beside two module importers, the last module uninstantiated)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
interface bif;
  import p::*;
  e_t v;
endinterface
module bmod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign o = x[1];
endmodule
module top(input logic [1:0] x, output logic o);
  bif i();
  bmod b(.x(x), .o(o));
endmodule
module zz_unused(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign o = x[0];
endmodule
