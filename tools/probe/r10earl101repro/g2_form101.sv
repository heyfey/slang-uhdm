// r10earl101 g2_form101 -- IMPORT FORMS for a packed-vector port element.
// Axis: wildcard import / EXPLICIT single-symbol import / scoped use with NO
// import at all / a $unit-scope import.  writeImportedSymbols clones and
// re-names only for the EXPLICIT form (its `item->Item()` decompile is the
// symbol name; a wildcard carries "*" and matches no package typespec), so
// this arm is what separates a LAW-S per-declaration copy from an import
// clone.
package p2f101;
  typedef logic [15:0] w_t;
endpackage

// $unit-scope import: every module below can see w_t unqualified.
import p2f101::w_t;

module m2wild101
  import p2f101::*;
(input w_t [3:0] i_p, output w_t [3:0] o_p);
  assign o_p = i_p;
endmodule

module m2expl101
  import p2f101::w_t;
(input w_t [3:0] i_p, output w_t [3:0] o_p);
  assign o_p = i_p;
endmodule

module m2scope101 (            // NO import: the type is written pkg::-qualified
  input  p2f101::w_t [3:0] i_p,
  output p2f101::w_t [3:0] o_p);
  assign o_p = i_p;
endmodule

module m2unit101 (             // reaches w_t through the $unit import above
  input  w_t [3:0] i_p,
  output w_t [3:0] o_p);
  assign o_p = i_p;
endmodule

module g2_form101 (input logic clk);
  p2f101::w_t [3:0] a_i, a_o, b_i, b_o, c_i, c_o, d_i, d_o;
  m2wild101  u_wild  (.i_p(a_i), .o_p(a_o));
  m2expl101  u_expl  (.i_p(b_i), .o_p(b_o));
  m2scope101 u_scope (.i_p(c_i), .o_p(c_o));
  m2unit101  u_unit  (.i_p(d_i), .o_p(d_o));
endmodule
