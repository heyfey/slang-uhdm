// r10v87 arm va11 — the colliding formal is a BODY parameter and the module has
// NO PARAMETER PORT LIST, so § modDefImportShape's `defImpElabShape9` is FALSE
// and the DEF-view topView flip never runs.  The ELAB stamp must still fire.
package pb11;
  localparam int BA = 131;
  localparam int BB = 132;
endpackage

module bleaf (output logic [7:0] o);
  import pb11::*;
  parameter int BA = 1;          // body parameter, overridable
  localparam int BC = 3;
  assign o = BA[7:0] + BB[7:0] + BC[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  bleaf #(.BA(7)) u_ov (.o(o1));
  bleaf           u_no (.o(o2));
endmodule
