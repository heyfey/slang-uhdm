// residue S3 of r11u137 (N0057, the struct member enum copy of a package import clone): fence re-derivation
// case f03: a variable (not a parameter) of B's struct
package ea3;
  typedef enum logic {Off = 1'b0, On = 1'b1} sw_e;
endpackage
package eb3;
  import ea3::*;
  typedef struct packed { sw_e s; logic t; } r_t;
endpackage
module top(input logic [1:0] i, output logic o);
  eb3::r_t v;
  assign v = i;
  assign o = v.s;
endmodule
