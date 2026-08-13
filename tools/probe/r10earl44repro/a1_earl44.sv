// r10earl44 — THE GRID for the Earlgrey head at top_earlgrey.sv:628:26.
//
// The head is a DEF-view PORT CONNECTION whose actual is written SCOPED:
//   .lc_pinmux_strap_i(pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT)
// where LC_PINMUX_STRAP_REQ_DEFAULT is a package `parameter` of a PACKED
// STRUCT type (its Rhs is an assignment pattern, i.e. an OPERATION, so it is
// NOT in pkgParamConst and § defConnPkgParamFold43 cannot reach it even if the
// `::` were stripped).
//
// Golden:  ref_obj vpiName = pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT
//                  NO vpiFullName,  vpiActual -> the package `parameter`
//                  span = 628:26-628:38, i.e. the QUALIFIER ONLY (up to but
//                  not including the final identifier)
// Ours:    ref_obj vpiName = LC_PINMUX_STRAP_REQ_DEFAULT (bare)
//                  vpiFullName = work@top_earlgrey.u_pinmux.<port>.<name>
//                  no vpiActual, span = the WHOLE written name
//
// Every cell is ONE instance with ONE input port, so the grid row key is the
// INSTANCE NAME and a row survives span drift.  LHS is ALWAYS golden.
//
// AXES
//   * WRITTEN FORM        scoped `pkg::P`  vs  BARE `P` (§ 43's cell — MUST
//                         NOT MOVE) vs scoped-with-WHITESPACE `p44 :: P`
//   * the PARAMETER's shape   scalar (folds in § 43) / packed struct / unpacked
//                         array / enum-typed / string / real / typedef'd /
//                         `parameter` vs `localparam` / untyped
//   * the FORMAL's type   typed / implicit 1-bit (forces an implicit conv)
//   * IMPORTED vs NOT     the same scoped write with and without `import p44::*`
//   * named vs POSITIONAL
//   * instance DEPTH      a child of a child
//   * NOT-A-PARAMETER     scoped enum CONSTANT, scoped package VARIABLE,
//                         scoped expression, scoped member access, scoped index
//   * def vs elab view    (both sections are printed by grid44.py)

package p44;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st44_t;
  typedef enum logic [1:0] { EN_A = 2'd0, EN_B = 2'd1 } en44_t;
  typedef logic [31:0] word44_t;
  localparam logic [31:0] PK_LOGIC32   = 32'h 00008000;
  localparam int          PK_INT       = 7;
  localparam              PK_UNTYPED   = 5;
  parameter  logic [15:0] PK_PARAM16   = 16'h 00ff;
  localparam word44_t     PK_TDEF      = 32'h 0bad_c0de;
  localparam st44_t       PK_STRUCT    = '{a: 8'h aa, b: 8'h bb};
  parameter  st44_t       PK_STRUCTP   = '{a: 8'h 11, b: 8'h 22}; // Earlgrey's kind
  localparam int          PK_ARR [0:1] = '{3, 4};
  localparam string       PK_STR       = "zz";
  localparam real         PK_REAL      = 1.5;
  localparam en44_t       PK_ENUM      = EN_B;
  logic [31:0]            PK_VAR;                                 // a package VARIABLE
endpackage

module leaf44  (input logic [31:0] p_i, output logic [31:0] z_o);
  assign z_o = p_i;
endmodule
module leafu44 (input p_i, output z_o);              // IMPLICIT 1-bit formal
  assign z_o = p_i;
endmodule
module leaft44 (input p44::word44_t p_i, output logic [31:0] z_o);
  assign z_o = p_i;
endmodule
module leafst44 (input p44::st44_t p_i, output logic [15:0] z_o);
  assign z_o = p_i;
endmodule
module leafar44 (input int p_i [0:1], output logic [31:0] z_o);
  assign z_o = p_i[0];
endmodule
module leafstr44 (input string p_i);
endmodule
module leafre44 (input real p_i);
endmodule
module leafen44 (input p44::en44_t p_i, output logic [1:0] z_o);
  assign z_o = p_i;
endmodule

// DEPTH carrier: the same SCOPED write one instance level down
module mid44 (output logic [15:0] z_o);
  leafst44 u_deep (.p_i (p44::PK_STRUCT), .z_o (z_o));
endmodule

// The same scoped writes with NO import in scope at all.
module noimp44 (output logic [31:0] z0, output logic [15:0] z1);
  leaf44   u_ni1 (.p_i (p44::PK_LOGIC32), .z_o (z0));
  leafst44 u_ni2 (.p_i (p44::PK_STRUCT),  .z_o (z1));
endmodule

module top44 (input logic [31:0] n_net,
              output logic [31:0] o0, o1, o2, o3, o4, o5, o6, o7, o8,
              output logic [15:0] s0, s1, s2, s3,
              output logic [31:0] a0, output logic [1:0] e0, e1,
              output logic o14, output logic [31:0] d0, d1);
  import p44::*;

  localparam logic [31:0] MOD_LP = 32'h dead_beef;

  // ---- SCOPED, scalar shapes (§ 43 folds these when written BARE) ----------
  leaf44   u_q1  (.p_i (p44::PK_LOGIC32), .z_o (o0));   // the R1 scalar cell
  leaf44   u_q3  (.p_i (p44::PK_INT),     .z_o (o1));
  leaf44   u_q4  (.p_i (p44::PK_UNTYPED), .z_o (o2));
  leaf44   u_q5  (.p_i (p44::PK_PARAM16), .z_o (o3));   // pkg `parameter`
  leaft44  u_q6  (.p_i (p44::PK_TDEF),    .z_o (o4));   // typedef'd type

  // ---- SCOPED, AGGREGATE shapes (THE HEAD) --------------------------------
  leafst44 u_q7  (.p_i (p44::PK_STRUCT),  .z_o (s0));   // packed struct localparam
  leafst44 u_q8  (.p_i (p44::PK_STRUCTP), .z_o (s1));   // packed struct `parameter`
  leafar44 u_q9  (.p_i (p44::PK_ARR),     .z_o (o5));   // unpacked array

  // ---- SCOPED, non-integral / enum ----------------------------------------
  leafstr44 u_q10 (.p_i (p44::PK_STR));
  leafre44  u_q11 (.p_i (p44::PK_REAL));
  leafen44  u_q12 (.p_i (p44::PK_ENUM),   .z_o (e0));   // enum-TYPED param (R2)
  leafen44  u_q13 (.p_i (p44::EN_B),      .z_o (e1));   // scoped ENUM CONSTANT

  // ---- SCOPED, NOT a simple reference -------------------------------------
  leaf44   u_q14 (.p_i (p44::PK_LOGIC32 + 1), .z_o (o6));  // expression
  leaf44   u_q18 (.p_i (p44::PK_STRUCT.a),    .z_o (o7));  // member access
  leaf44   u_q19 (.p_i (p44::PK_ARR[0]),      .z_o (o8));  // index (§ 41 family)
  leaf44   u_q21 (.p_i (p44::PK_VAR),         .z_o (a0));  // package VARIABLE

  // ---- SCOPED x FORMAL / SPELLING / POSITION / DEPTH ----------------------
  leafu44  u_q15 (.p_i (p44::PK_LOGIC32), .z_o (o14));     // implicit 1-bit formal
  leaf44   u_q16 (p44::PK_LOGIC32, d0);                    // POSITIONAL
  leaf44   u_q17 (.p_i (p44 :: PK_LOGIC32), .z_o (d1));    // WHITESPACE spelling
  mid44    u_q20 (.z_o (s2));                              // DEPTH
  noimp44  u_q22 (.z0 (), .z1 (s3));                       // NO import in scope

  // ---- BARE controls: § 43 owns these and they MUST NOT MOVE --------------
  leaf44   u_b1  (.p_i (PK_LOGIC32), .z_o ());   // § 43 folds: const+ts+parent
  leafst44 u_b2  (.p_i (PK_STRUCT),  .z_o ());   // aggregate bare -> ref_obj
  leaf44   u_b3  (.p_i (MOD_LP),     .z_o ());   // module's OWN -> ref_obj
  leaf44   u_b4  (.p_i (n_net),      .z_o ());   // net control
endmodule
