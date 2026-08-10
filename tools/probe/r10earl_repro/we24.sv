// we24.sv — pass-24 residue: the frontier law A uncovered.  bis24 after law A
// stops at ibex_counter.sv:68:15, the RANGE bound of a GEN-SCOPE local:
//     if (CounterWidth < 64) begin : g_counter_narrow
//       logic [63:CounterWidth] unused_counter_load;
// where `parameter int CounterWidth = 32` is OVERRIDDEN to 40 by
// ibex_cs_registers' mcounters_variable_i.  Golden folds that bound to
// `constant {ct=9 sz=64 dec=40}`; we fold it at sz=32.  Same 64-at-override
// shape § dimFoldOverriddenParam23 measured for an UNPACKED dim, now on a
// PACKED range — so this file crosses OVERRIDE x (gen scope | module body) x
// (typed | untyped) x (parameter | localparam).
module ie24 #(
  parameter int          W_T = 32,   // typed, OVERRIDDEN below
  parameter              W_U = 32,   // untyped, OVERRIDDEN below
  parameter int          W_D = 32    // typed, DEFAULT (never overridden)
) (
  input  logic [63:0] d,
  output logic        o
);
  localparam int W_L = 24;

  // R1 (the corpus shape): gen-scope local, range bound = OVERRIDDEN typed param
  if (W_T < 64) begin : g_n
    logic [63:W_T] v_t;
    assign v_t = d[63:W_T];
  end
  // R2: gen-scope local, bound = OVERRIDDEN UNTYPED param
  if (W_U < 64) begin : g_u
    logic [63:W_U] v_u;
    assign v_u = d[63:W_U];
  end
  // R3: gen-scope local, bound = DEFAULT (un-overridden) typed param
  if (W_D < 64) begin : g_d
    logic [63:W_D] v_d;
    assign v_d = d[63:W_D];
  end
  // R4: gen-scope local, bound = module LOCALPARAM
  if (W_L < 64) begin : g_l
    logic [63:W_L] v_l;
    assign v_l = d[63:W_L];
  end
  // R5 / R6 / R7: the same three bounds on MODULE-BODY vars (no gen scope)
  logic [63:W_T] m_t;
  logic [63:W_U] m_u;
  logic [63:W_L] m_l;
  assign m_t = d[63:W_T];
  assign m_u = d[63:W_U];
  assign m_l = d[63:W_L];
  // R8: NESTED gen scope, bound = OVERRIDDEN typed param
  if (W_T < 64) begin : g_o
    logic [3:0] q;
    for (genvar i = 0; i < 1; i++) begin : g_i
      logic [63:W_T] v_n;
      assign v_n = d[63:W_T];
      assign q[i] = |v_n;
    end
  end
  assign o = 1'b0;
endmodule

module we24 (
  input  logic [63:0] d,
  output logic        a, b
);
  ie24 #(.W_T(40), .W_U(40)) u_c (.d(d), .o(a));   // OVERRIDE both
  ie24                       u_dflt (.d(d), .o(b)); // all defaults
endmodule
