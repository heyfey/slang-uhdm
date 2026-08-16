// r10earl47 GRID ARM B1 — the DISCRIMINATOR arm: the SAME ips-width position,
// varied along every axis that is NOT the position.
//
//   * the use site's SCOPE: same gen scope / a NESTED gen scope (prim_keccak's
//     gen_others is nested inside gen_rho_y) / a gen scope under an `if`
//   * the use CONTEXT: a cont_assign RHS / a cont_assign LHS / a PROCESS
//     (always_comb) / a declaration initializer / an instance PORT connection
//   * the SYMBOL: a real gen localparam / a genvar / a module parameter
//
// Every row is the same shape at the leaf (`d[0 +: <sym>]` or `d[<sym> +: 4]`),
// so any row that differs from its neighbours isolates ONE axis.
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module b1_earl47;
  localparam int W  = 64;
  localparam int MP = 8;

  logic [255:0] d;
  logic [63:0]  m_out;

  // MODULE-scope control: the same leaf shape OUTSIDE any generate.
  assign m_out = d[0 +: MP];

  for (genvar x = 0; x < 3; x++) begin : gen_x
    localparam int LPA = 4 + x * 2;

    logic [63:0] r_same, r_proc, r_init, r_lhs, r_port;
    logic [63:0] r_nest, r_ifgen;

    // same gen scope, cont_assign RHS (the a1 baseline row)
    assign r_same = d[0 +: LPA];

    // a PROCESS in the same gen scope
    always_comb r_proc = d[0 +: LPA];

    // a DECLARATION initializer in the same gen scope
    logic [63:0] r_dini = d[0 +: LPA];

    // a cont_assign LHS
    assign r_lhs[LPA +: 4] = 4'hA;

    // an instance PORT connection
    b1_leaf u_leaf (.i(d[0 +: LPA]), .o(r_port));

    // a NESTED gen scope reading the PARENT gen scope's localparam —
    // prim_keccak's gen_others reading gen_rho_y's ShiftAmt, exactly.
    for (genvar y = 0; y < 2; y++) begin : gen_y
      assign r_nest = d[0 +: LPA];
    end

    // a gen scope under an `if` (prim_keccak's gen_others is one of these)
    if (x > 0) begin : gen_if
      assign r_ifgen = d[LPA +: 4];
    end

    // the genvar itself in the same two positions
    logic [63:0] r_gvw, r_gvb;
    assign r_gvw = d[0 +: (x + 1)];
    assign r_gvb = d[x +: 4];

    // unused reads so nothing is optimised away
    assign r_init = r_dini;
  end
endmodule

module b1_leaf (input logic [63:0] i, output logic [63:0] o);
  assign o = i;
endmodule
