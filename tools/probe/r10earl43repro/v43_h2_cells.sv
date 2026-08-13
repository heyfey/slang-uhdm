// r10earl43 VERIFIER hunt H2 — EMPTY-PRODUCT / OVER-FIRE cells the pass's own
// two probes do not carry.
//
//  h_untp   package UNTYPED `parameter` (a1 has an untyped LOCALPARAM and a
//           TYPED parameter, never the untyped parameter): does its
//           pkgParamObj entry have a Typespec at all?  If not, the arm mints a
//           ref_typespec with NO vpiActual -> an EMPTY PRODUCT CELL.
//  h_time   package TIME-typed parameter (another shape whose Rhs is a
//           constant but whose typespec is not logic_typespec).
//  h_mac    the reference written through a MACRO that expands to the BARE
//           name (rawText walks back to the macro BODY).
//  h_macs   the reference written through a MACRO that expands to the SCOPED
//           name — the `::` text gate must still hold.
//  h_gen    the connection inside a GENERATE block (def view).
//  h_twice  the SAME package parameter connected TWICE in one module: the arm
//           mints a fresh constant each time but SHARES the param_assign
//           vpiParent pointer.
//  u_pm     a PARAMETERIZED enclosing module: `prefix` (which becomes the
//           ref_typespec's vpiFullName) is the paramod's name, not `work@mod`.
`define H2_BARE   H2_PLAIN
`define H2_SCOPED ph2::H2_PLAIN

package ph2;
  localparam logic [31:0] H2_PLAIN  = 32'h 00008000;
  parameter               H2_UNTP   = 11;          // UNTYPED `parameter`
  localparam time         H2_TIME   = 5ns;
endpackage

module leafh2 (input logic [31:0] p_i, output logic [31:0] z_o);
  assign z_o = p_i;
endmodule
module leafht2 (input time p_i, output logic [31:0] z_o);
  assign z_o = 32'h0;
endmodule

// PARAMETERIZED enclosing module: gets BOTH a `work@midh2` def and a paramod
// def in allModules.
module midh2 #(parameter int MW = 8) (output logic [31:0] z_o);
  import ph2::*;
  leafh2 u_pm (.p_i (H2_PLAIN), .z_o (z_o));
endmodule

module toph2 (output logic [31:0] o0, o1, o2, o3, o4, o5, o6, o7);
  import ph2::*;

  leafh2  u_untp  (.p_i (H2_UNTP),      .z_o (o0));
  leafht2 u_time  (.p_i (H2_TIME),      .z_o (o1));
  leafh2  u_mac   (.p_i (`H2_BARE),     .z_o (o2));
  leafh2  u_macs  (.p_i (`H2_SCOPED),   .z_o (o3));
  leafh2  u_twice1(.p_i (H2_PLAIN),     .z_o (o4));
  leafh2  u_twice2(.p_i (H2_PLAIN),     .z_o (o5));
  midh2 #(.MW (16)) u_pmod (.z_o (o6));

  generate
    if (1) begin : g_blk
      leafh2 u_gen (.p_i (H2_PLAIN), .z_o (o7));
    end
  endgenerate
endmodule
