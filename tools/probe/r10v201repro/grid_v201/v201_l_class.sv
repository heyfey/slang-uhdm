// v201 arm L — the `other` view: a CLASS in a package carrying param_assigns,
// imported into a module.
package p201vl;
  parameter L_A = 13;
  parameter L_B = L_A;
  class c201vl #(parameter L_P = 4);
    parameter L_IN = L_A;
  endclass
endpackage
import p201vl::*;
module m201vl;
  c201vl #(5) h;
endmodule
