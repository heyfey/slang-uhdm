// r10earl90 g4 — THE HOME / OVERRIDE / PRODUCER GRID for the ips WIDTH.
// Homes: a plain module instantiation, a for-generate, an if-generate, an
// UNNAMED begin/end generate, a THREE-DEEP generate chain, an interface
// instantiated in a generate scope, and a `bind` instantiation (fence f).
// Producers: a module localparam, a NON-overridable module `parameter` left at
// its default, THE SAME `parameter` OVERRIDDEN at two instantiations, a
// gen-scope localparam, and a localparam whose initializer is a BARE REFERENCE
// to another signed one (`valueRange`'s inherited-sign consequence).
package pq90;
  localparam int          Q_SGN = 4;
  localparam int unsigned Q_UNS = 4;
endpackage

module snk4_90 (input logic [3:0] a_i);
endmodule
module snk2_90 (input logic [1:0] a_i);
endmodule

interface if90 ();
  logic [31:0] w;
endinterface

module mid90 #(parameter int MW = 4) (input logic [31:0] s_i);
  // MW is a MODULE PARAMETER: default at u_m3, OVERRIDDEN at u_m1 / u_m2.
  for (genvar g = 0; g < 1; g++) begin : gm
    snk4_90 u_ov (.a_i(s_i[g*4 +: MW]));
  end
endmodule

module bnd90 (input logic [3:0] a);
endmodule

module bindee90;
  logic [31:0] sig;
  localparam int Bd90 = 4;
  for (genvar g = 0; g < 1; g++) begin : gb
    snk4_90 u_in (.a_i(sig[g*4 +: Bd90]));
  end
endmodule

module g4_homes90;
  localparam int P4  = 4;
  localparam int P4R = P4;          // initializer is a BARE REFERENCE
  localparam int unsigned P4U = 4;
  localparam int P4RU = P4U;        // bare reference to an UNSIGNED one
  localparam int unsigned U4R  = P4;            // UNSIGNED decl <- SIGNED bare ref
  localparam int unsigned U4RU = P4U;           // UNSIGNED decl <- UNSIGNED bare ref
  localparam int unsigned U4Q  = pq90::Q_SGN;   // UNSIGNED decl <- QUALIFIED signed
  localparam int unsigned U4QU = pq90::Q_UNS;   // UNSIGNED decl <- QUALIFIED unsigned
  localparam int          S4Q  = pq90::Q_UNS;   // SIGNED decl   <- QUALIFIED unsigned
  localparam int          E1   = P4U*1;         // EXPRESSION initializer, signed decl
  localparam int unsigned E2   = P4*1;          // EXPRESSION initializer, unsigned decl
  localparam int          E3   = $clog2(16);    // $clog2, signed decl
  localparam int unsigned E4   = $clog2(16);    // $clog2, unsigned decl
  localparam int          E5   = int'(P4U);     // written CAST, signed decl
  localparam int          C2   = P4R;           // TWO-DEEP bare-reference chain
  logic [31:0] sig;

  // (1) PLAIN module home — the genvarConnFold arm is NOT armed.
  snk4_90 h01 (.a_i(sig[0 +: P4]));

  // (2) FOR-generate (the head's home).
  for (genvar g = 0; g < 2; g++) begin : gfor
    snk4_90 h02 (.a_i(sig[g*4 +: P4]));
    snk4_90 h03 (.a_i(sig[g*4 +: P4R]));    // inherited sign
    snk4_90 h04 (.a_i(sig[g*4 +: P4RU]));   // inherited UNSIGNED
    localparam int GP4 = 4;                 // a GEN-SCOPE localparam
    snk4_90 h05 (.a_i(sig[g*4 +: GP4]));
    snk4_90 h10 (.a_i(sig[g*4 +: U4R]));
    snk4_90 h11 (.a_i(sig[g*4 +: U4RU]));
    snk4_90 h12 (.a_i(sig[g*4 +: U4Q]));
    snk4_90 h13 (.a_i(sig[g*4 +: U4QU]));
    snk4_90 h14 (.a_i(sig[g*4 +: S4Q]));
    snk4_90 h15 (.a_i(sig[g*4 +: E1]));
    snk4_90 h16 (.a_i(sig[g*4 +: E2]));
    snk4_90 h17 (.a_i(sig[g*4 +: E3]));
    snk4_90 h18 (.a_i(sig[g*4 +: E4]));
    snk4_90 h19 (.a_i(sig[g*4 +: E5]));
    snk4_90 h20 (.a_i(sig[g*4 +: C2]));
  end

  // (3) IF-generate.
  if (1) begin : gif
    snk4_90 h06 (.a_i(sig[0 +: P4]));
  end

  // (4) UNNAMED begin/end generate.
  if (1) begin
    snk4_90 h07 (.a_i(sig[4 +: P4]));
  end

  // (5) THREE-DEEP generate chain.
  for (genvar a = 0; a < 1; a++) begin : gd1
    for (genvar b = 0; b < 1; b++) begin : gd2
      if (1) begin : gd3
        snk4_90 h08 (.a_i(sig[(a+b)*4 +: P4]));
      end
    end
  end

  // (6) an INTERFACE instantiated in a gen scope, and a select off it.
  for (genvar c = 0; c < 1; c++) begin : gifc
    if90 u_if ();
    snk4_90 h09 (.a_i(u_if.w[c*4 +: P4]));
  end

  // (7) THREE INSTANCES of one module: two OVERRIDDEN, one at the default.
  mid90 #(.MW(2)) u_m1 (.s_i(sig));
  mid90 #(.MW(2)) u_m2 (.s_i(sig));
  mid90           u_m3 (.s_i(sig));

  // (8) the bind target.
  bindee90 u_be ();
endmodule

// (9) THE BIND INSTANTIATION — fence f: Surelog's Reduce::Yes recompile has no
// Value for a parameter of the bind TARGET, so golden keeps the ref_obj.
bind bindee90 bnd90 u_bind (.a(sig[0 +: Bd90]));
