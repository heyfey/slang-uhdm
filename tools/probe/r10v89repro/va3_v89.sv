// r10v89 va3 — HOMES.  GOLDEN = Surelog.  The head's leaf shape (`localparam
// int X = <expr>`, which reaches the REDUCED arm) and its `int unsigned` twin,
// placed in every home the brief names: module body, gen-for, gen-if, nested
// generate, an INTERFACE (declared and instantiated), a PORT's unpacked
// dimension (sized by a header localparam and by an overridden parameter), a
// THREE-DEEP instance chain, and a parameterised module with TWO
// instantiations that differ.
interface iv89 #(parameter int DW = 3) ();
  localparam int          I_S = DW + 1;
  localparam int unsigned I_U = DW + 1;
  logic [3:0] if_s  [I_S];
  logic [3:0] if_u  [I_U];
  wire  [3:0] if_ns [I_S];
endinterface

// a PORT's unpacked dimension sized by a HEADER LOCALPARAM (not overridable)
// and by the OVERRIDDEN parameter itself.
module portv89 #(parameter int DEPTH = 4,
                 localparam int          PD  = DEPTH + 1,
                 localparam int unsigned PDU = DEPTH + 1)
  (input  logic [3:0] pl_s [PD],
   input  logic [3:0] pl_u [PDU],
   output logic [3:0] po_s [PD],
   inout  wire  [3:0] pb_s [PD],
   input  logic [3:0] pd_s [DEPTH]);
  logic [3:0] pbody_s [PD];
  logic [3:0] pbody_u [PDU];
endmodule

// the BOTTOM of the three-deep chain
module leafv89 #(parameter int DEPTH = 4) ();
  localparam int          L_S = DEPTH + 1;
  localparam int unsigned L_U = DEPTH + 1;
  logic [3:0] lf_s [L_S];
  logic [3:0] lf_u [L_U];
endmodule

module midv89 #(parameter int MD = 4) ();
  localparam int M_S = MD + 1;
  logic [3:0] md_s [M_S];
  leafv89              u_a ();
  leafv89 #(.DEPTH(5)) u_b ();
  leafv89 #(.DEPTH(MD)) u_c ();
endmodule

module va3_89;
  localparam int          T_S = 3 + 1;
  localparam int unsigned T_U = 3 + 1;

  // ---- module body -----------------------------------------------------
  logic [3:0] b_s [T_S];
  logic [3:0] b_u [T_U];

  // ---- gen-for, gen-if, and a NESTED generate --------------------------
  for (genvar gi = 0; gi < 2; gi++) begin : gf
    localparam int          F_S = gi + 4;
    localparam int unsigned F_U = gi + 4;
    logic [3:0] f_s   [F_S];
    logic [3:0] f_u   [F_U];
    logic [3:0] f_out [T_S];
    if (gi == 0) begin : gn
      localparam int N_S = gi + 5;
      logic [3:0] n_s [N_S];
      logic [3:0] n_out [T_S];
    end
  end
  if (1) begin : gi1
    localparam int          H_S = 3 + 1;
    localparam int unsigned H_U = 3 + 1;
    logic [3:0] h_s   [H_S];
    logic [3:0] h_u   [H_U];
    logic [3:0] h_out [T_S];
  end
  else begin : gi0
    logic [3:0] h_dead [T_S];
  end

  // ---- an INTERFACE, twice, with different parameters ------------------
  iv89            u_if1 ();
  iv89 #(.DW(5))  u_if2 ();

  // ---- a PORTED child, twice -------------------------------------------
  logic [3:0] w_pl_s [5];
  logic [3:0] w_pl_u [5];
  logic [3:0] w_po_s [5];
  wire  [3:0] w_pb_s [5];
  logic [3:0] w_pd_s [4];
  portv89 u_p1 (.pl_s(w_pl_s), .pl_u(w_pl_u), .po_s(w_po_s), .pb_s(w_pb_s),
                .pd_s(w_pd_s));

  // ---- a THREE-DEEP chain, two sibling parents -------------------------
  midv89             u_m1 ();
  midv89 #(.MD(6))   u_m2 ();
endmodule
