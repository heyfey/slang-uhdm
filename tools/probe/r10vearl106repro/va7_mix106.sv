// r10v106 va7_mix106 — THE PRISTINE-RIGHT -> PATCHED-WRONG WITNESS.
//
// In the ELABORATED view every cont_assign of a COMMA-LIST `assign` carries the
// span of the WHOLE statement, so two cont_assigns in one gen scope share
// `applyCaCastAdjust106`'s key `(gen-scope fullname, cont_assign span)`.  The
// record map is a `std::map` filled with `emplace`, so the FIRST record wins and
// BOTH cont_assigns are re-encoded at the FIRST Lhs's width.
//
// `m_mix` pairs a BINDING module-body Lhs with a NON-binding GEN-LOCAL Lhs in
// one comma list.  Golden leaves the gen-local one at size 64 with NO decompile
// (`bindVariable` fails, so `adjustSize` never runs) and the pristine binary
// already agrees with it field for field.  MEASUREMENT ONLY.
package pv7_106;
  parameter int unsigned P8 = 8;
endpackage

module va7_mix106 (output logic o);
  logic [7:0]  f8x, g8x;
  logic [3:0]  h4x;
  logic [15:0] h16x;

  // A: binding Lhs FIRST, gen-local SECOND — the gen-local inherits width 8
  //    and a decimal decompile it must not have.
  if (1) begin : m_mix
    logic [7:0] locz;
    assign f8x = pv7_106::P8'(6'h3F), locz = pv7_106::P8'(6'h3F);
  end

  // B: gen-local FIRST, binding Lhs SECOND — the record still keys on the
  //    shared span, so the gen-local is reached from the other side too.
  if (1) begin : m_mix2
    logic [7:0] locy;
    assign locy = pv7_106::P8'(6'h3F), g8x = pv7_106::P8'(6'h3F);
  end

  // C: two BINDING Lhs of DIFFERENT widths in one comma list — the second
  //    takes the first's width.
  if (1) begin : m_mix3
    assign h4x = pv7_106::P8'(6'h3F), h16x = pv7_106::P8'(6'h3F);
  end

  assign o = f8x[0] ^ g8x[0] ^ h4x[0] ^ h16x[0];
endmodule
