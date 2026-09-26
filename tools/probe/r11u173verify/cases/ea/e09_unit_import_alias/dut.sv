// § enumAliasClone161 — a $unit alias of a package enum reached through a $unit wildcard import
package pp;
  typedef enum logic [1:0] { R, G, B } c_e;
endpackage
import pp::*;
typedef c_e my_c;
module top(output logic [1:0] o);
  my_c v;
  assign v = G;
  assign o = v;
endmodule
