// r10earl106 g1_home106 — THE HOME AXIS for one fixed cast `W'(6'h3F)`.
// Which scope + which Lhs shape gets the decompile/size adjust.
// MEASUREMENT ONLY.
package pg1_106;
  parameter int unsigned W8 = 8;
endpackage

interface if1_106;
  logic [7:0] iv;
  if (1) begin : gen_if
    assign iv = pg1_106::W8'(6'h3F);   // interface home: bindVariable stops
  end
endinterface

module ch1_106 (output logic [7:0] o);
  logic [7:0] cv;
  if (1) begin : gen_if
    assign cv = pg1_106::W8'(6'h3F);   // child instance, gen-IF, module Lhs
  end
  assign o = cv;
endmodule

module g1_home106 (output logic [7:0] o1, output logic [7:0] o2);
  logic [7:0] m_mod;      // module-body target
  logic [7:0] m_mod2;
  logic [7:0] m_mod3;
  logic [7:0] m_mod4;
  logic [7:0] m_mod5;
  logic [7:0] m_sel;      // select target
  logic [3:0] m_nar;      // narrower target
  logic [15:0] m_wid;     // wider target

  // A: module body (the control — already right)
  assign m_mod = pg1_106::W8'(6'h3F);

  // B: gen-IF scope, module-body Lhs  (THE HEAD SHAPE)
  if (1) begin : gen_b
    assign m_mod2 = pg1_106::W8'(6'h3F);
  end

  // C: gen-IF scope, GEN-LOCAL Lhs
  if (1) begin : gen_c
    logic [7:0] loc_c;
    assign loc_c = pg1_106::W8'(6'h3F);
  end

  // D: gen-IF scope, BIT-SELECT Lhs
  if (1) begin : gen_d
    assign m_sel[3] = pg1_106::W8'(6'h3F);
  end

  // E: gen-IF scope, PART-SELECT Lhs
  if (1) begin : gen_e
    assign m_sel[7:4] = pg1_106::W8'(6'h3F);
  end

  // F: gen-FOR scope, module-body Lhs
  for (genvar i = 0; i < 1; i++) begin : gen_f
    assign m_mod3 = pg1_106::W8'(6'h3F);
  end

  // G: NESTED gen (IF inside FOR), module-body Lhs
  for (genvar j = 0; j < 1; j++) begin : gen_g
    if (1) begin : gen_gi
      assign m_mod4 = pg1_106::W8'(6'h3F);
    end
  end

  // H: gen-IF, NARROWER module Lhs (adjust must truncate)
  if (1) begin : gen_h
    assign m_nar = pg1_106::W8'(6'h3F);
  end

  // I: gen-IF, WIDER module Lhs (adjust must widen)
  if (1) begin : gen_i
    assign m_wid = pg1_106::W8'(6'h3F);
  end

  // J: gen-else branch taken
  if (0) begin : gen_j0
    assign m_mod5 = pg1_106::W8'(6'h3F);
  end else begin : gen_j1
    assign m_mod5 = pg1_106::W8'(6'h3F);
  end

  ch1_106 u_ch (.o(o1));
  if1_106 u_if ();
  assign o2 = m_mod;
endmodule
