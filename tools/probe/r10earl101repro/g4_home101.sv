// r10earl101 g4_home101 -- HOMES for a packed-vector port of a package scalar
// typedef.  Axis: the TOP module itself / a submodule / a module instantiated
// from a GEN SCOPE / an INTERFACE / THREE INSTANTIATIONS of ONE span.
//
// The three instantiations are the arm that proves the law's memo key: the
// DEF-view listing is written ONCE and the three elaborated instances are
// written separately, so a memo keyed on the listing object alone hands the
// same object to all four and a memo keyed on (listing object, VIEW) hands the
// def entry one and the three elaborated ports another.
package p4h101;
  typedef logic [7:0] h_t;
endpackage

interface if4h101
  import p4h101::*;
(input h_t [1:0] i_ifp);
  h_t [1:0] i_var;
  assign i_var = i_ifp;
  modport mp (input i_ifp);
endinterface

module m4leaf101
  import p4h101::*;
(input h_t [1:0] i_p, output h_t [1:0] o_p);
  assign o_p = i_p;
endmodule

module m4mid101
  import p4h101::*;
(input h_t [1:0] i_p, output h_t [1:0] o_p);
  m4leaf101 u_leaf (.i_p(i_p), .o_p(o_p));   // a SUBMODULE of a submodule
endmodule

module m4gen101
  import p4h101::*;
(input h_t [1:0] i_p, output h_t [1:0] o_p);
  h_t [1:0] chain [0:2];
  assign chain[0] = i_p;
  for (genvar g = 0; g < 2; g++) begin : gblk
    m4leaf101 u_g (.i_p(chain[g]), .o_p(chain[g+1]));   // inside a GEN SCOPE
  end
  assign o_p = chain[2];
endmodule

module g4_home101
  import p4h101::*;
(
  input  h_t [1:0] i_top,        // the TOP module's own packed-vector port
  output h_t [1:0] o_top
);
  h_t [1:0] a1, a2, a3, b1, b2, b3, gi, go;
  m4leaf101 u_i1 (.i_p(a1), .o_p(b1));   // THREE instantiations of ONE span
  m4leaf101 u_i2 (.i_p(a2), .o_p(b2));
  m4leaf101 u_i3 (.i_p(a3), .o_p(b3));
  m4mid101  u_mid (.i_p(i_top), .o_p(o_top));
  m4gen101 u_gen (.i_p(gi), .o_p(go));
  if4h101 u_if (.i_ifp(gi));
endmodule
