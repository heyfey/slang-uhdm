// r10earl43 — THE GRID for the Earlgrey head at top_earlgrey.sv:290:28.
//
// The head is a PORT CONNECTION (vpiHighConn), NOT a parameter override:
//   .boot_addr_i (ADDR_SPACE_ROM)     // ADDR_SPACE_ROM = tl_main_pkg localparam
// Golden folds the actual to a typed constant; we keep a ref_obj.
//
// Every cell is ONE instance with ONE input port, so the grid row key is the
// INSTANCE NAME and a row survives span drift.  LHS is ALWAYS golden.
//
// AXES
//   * what the actual IS        (imported pkg localparam / scoped pkg param /
//                                module-own localparam / module-own parameter /
//                                pkg `parameter` / untyped localparam /
//                                int-typed / expression / literal / net)
//   * the FORMAL's type         (typed logic[31:0] / implicit 1-bit / typedef)
//   * instance DEPTH            (top-level child vs a child of a child)
//   * named vs POSITIONAL connection
//   * a parameter OVERRIDE with the same imported name (the brief's framing —
//     kept as a cell precisely so the refutation is measured, not asserted)

package p43;
  localparam logic [31:0] PK_LOGIC32 = 32'h 00008000;   // the head's exact shape
  localparam int          PK_INT     = 7;
  localparam              PK_UNTYPED = 5;
  parameter  logic [15:0] PK_PARAM16 = 16'h 00ff;
  typedef logic [31:0]    word43_t;
  localparam word43_t     PK_TDEF    = 32'h 0bad_c0de;
endpackage

module leaf43 (input logic [31:0] p_i, output logic [31:0] z_o);
  assign z_o = p_i;
endmodule

module leafu43 (input p_i, output z_o);          // IMPLICIT 1-bit formal
  assign z_o = p_i;
endmodule

module leaft43 (input p43::word43_t p_i, output logic [31:0] z_o);
  assign z_o = p_i;
endmodule

module leafp43 #(parameter logic [31:0] PW = 32'h 0) (output logic [31:0] z_o);
  assign z_o = PW;
endmodule

// depth carrier: its own child sees the SAME imported name one level down
module mid43 (output logic [31:0] z_o);
  import p43::*;
  leaf43 u_deep (.p_i (PK_LOGIC32), .z_o (z_o));
endmodule

module top43 (input logic [31:0] n_net, output logic [31:0] o0, o1, o2, o3,
              output logic [31:0] o4, o5, o6, o7, o8, o9, o10, o11, o12, o13,
              output logic o14);
  import p43::*;

  localparam logic [31:0] MOD_LP  = 32'h dead_beef;
  parameter  logic [31:0] MOD_P   = 32'h 1234_5678;
  localparam              MOD_UNT = 9;

  // C1  imported pkg localparam, typed formal            <-- THE HEAD'S SHAPE
  leaf43  u_c1  (.p_i (PK_LOGIC32), .z_o (o0));
  // C2  the SAME pkg localparam written SCOPED
  leaf43  u_c2  (.p_i (p43::PK_LOGIC32), .z_o (o1));
  // C3  the module's OWN localparam
  leaf43  u_c3  (.p_i (MOD_LP), .z_o (o2));
  // C4  the module's OWN parameter
  leaf43  u_c4  (.p_i (MOD_P), .z_o (o3));
  // C5  imported pkg localparam of INT type
  leaf43  u_c5  (.p_i (PK_INT), .z_o (o4));
  // C6  imported pkg UNTYPED localparam
  leaf43  u_c6  (.p_i (PK_UNTYPED), .z_o (o5));
  // C7  EXPRESSION of imported pkg params
  leaf43  u_c7  (.p_i (PK_LOGIC32 + 1), .z_o (o6));
  // C8  LITERAL control (already a constant on both sides)
  leaf43  u_c8  (.p_i (32'h 00008000), .z_o (o7));
  // C9  NET control (must stay a ref_obj on both sides)
  leaf43  u_c9  (.p_i (n_net), .z_o (o8));
  // C10 imported pkg `parameter` (not localparam)
  leaf43  u_c10 (.p_i (PK_PARAM16), .z_o (o9));
  // C11 imported pkg localparam of a TYPEDEF'd type, TYPEDEF'd formal
  leaft43 u_c11 (.p_i (PK_TDEF), .z_o (o10));
  // C12 the module's OWN UNTYPED localparam
  leaf43  u_c12 (.p_i (MOD_UNT), .z_o (o11));
  // C13 POSITIONAL connection of the imported pkg localparam
  leaf43  u_c13 (PK_LOGIC32, o12);
  // C14 DEPTH: the same imported name one instance level down
  mid43   u_c14 (.z_o (o13));
  // C15 IMPLICIT 1-bit formal fed the 32-bit imported pkg localparam
  leafu43 u_c15 (.p_i (PK_LOGIC32), .z_o (o14));
  // C16 the BRIEF'S FRAMING: a parameter OVERRIDE whose value is the imported
  //     pkg localparam.  Not the head's shape; measured so the refutation is
  //     a measurement.
  leafp43 #(.PW (PK_LOGIC32)) u_c16 (.z_o ());
endmodule
