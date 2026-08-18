// r10earl67 arm 2 — the DECLARED-TYPE x RHS-SHAPE x HOME x POSITION grid for
// a ONE-HOP gen-scope localparam read as a BIT-SELECT INDEX, plus every
// NEIGHBOURING site the new call site could reach by accident: a port
// High_conn, a parameter override, a param_assign Rhs, a net/variable
// declaration initializer, an always_comb body, a function body and a
// function-call argument.
package a2pkg67;
  localparam int unsigned PKGQ = 1;
endpackage

module a2sub67 #(parameter int unsigned SP = 0) (
    input logic ci, input logic [7:0] cv, output logic co);
  assign co = ci ^ cv[SP];
endmodule

module a2_types67 (input logic [15:0] d, output logic [15:0] y);
  logic [15:0] w;
  assign w = d;

  // HOME A: a for-generate whose body declares the localparams, read one hop
  // down in a nested for-generate body.
  for (genvar g = 0; g < 3; g++) begin : gA
    localparam int unsigned  Ku  = g + 1;   // int unsigned, genvar expression
    localparam int           Ks  = g + 2;   // int, genvar expression
    localparam logic [3:0]   Kl  = g + 3;   // logic[3:0]
    localparam bit [3:0]     Kb  = g + 4;   // bit[3:0]
    localparam               Kn  = g + 5;   // untyped
    localparam integer       Ki  = g + 6;   // integer
    localparam int unsigned  Klit = 2;      // LITERAL init
    localparam int unsigned  Kdep = Ku + 1; // from another localparam
    for (genvar h = 0; h < 1; h++) begin : gB
      logic a_ku, a_ks, a_kl, a_kb, a_kn, a_ki, a_klit, a_kdep;
      assign a_ku   = w[Ku];
      assign a_ks   = w[Ks];
      assign a_kl   = w[Kl];
      assign a_kb   = w[Kb];
      assign a_kn   = w[Kn];
      assign a_ki   = w[Ki];
      assign a_klit = w[Klit];
      assign a_kdep = w[Kdep];
    end
    // HOME B: a generate-IF body one hop down
    if (g < 2) begin : gC
      logic c_ku;
      assign c_ku = w[Ku];
      // the NEIGHBOURING sites, all at distance 1
      logic [15:0] c_init = w[Ku];              // net-decl-assign / var init
      localparam int unsigned c_pa = Ku + 10;   // param_assign Rhs
      logic c_proc, c_fn, c_arg;
      always_comb c_proc = w[Ku];               // PROCESS
      function automatic logic f2(input logic [15:0] v);
        return v[Ku];                           // FUNCTION BODY
      endfunction
      assign c_fn  = f2(w);
      assign c_arg = |{w[Ku], f2(w[Ku] ? w : ~w)};   // call ARGUMENT
      a2sub67 #(.SP(Ku)) u_c (.ci(w[Ku]), .cv(w[7:0]), .co(y[g]));  // HC + override
      assign y[8+g] = c_pa[0] ^ c_init[0] ^ c_proc ^ c_fn ^ c_arg ^ c_ku;
    end
  end
  assign y[15:11] = '0;
endmodule
