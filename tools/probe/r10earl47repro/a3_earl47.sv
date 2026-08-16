// r10earl47 GRID ARM A3 — the DEPTH axis and the CONTEXT axis.
//
// A2 proved that a localparam declared ONE gen scope UP is substituted at the
// use site while the use's OWN scope's localparam is not, and that a MODULE
// parameter read TWO scopes down is NOT substituted although the same module
// parameter read ONE scope down (A1) is.  A3 nails that down: three nested gen
// scopes, a localparam at every level, and the same leaf read at distance 0, 1
// and 2 — and the same distance-1 read in a PROCESS, on a cont_assign LHS, in
// a variable-declaration INITIALIZER and through a GENVAR.
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module a3_earl47;
  localparam int MP = 8;

  logic [255:0] d;

  for (genvar x = 0; x < 2; x++) begin : gen_x
    localparam int LPX = 4 + x * 2;

    for (genvar y = 0; y < 2; y++) begin : gen_y
      localparam int LPY = 10 + y;

      logic [63:0] p_own, p_par, p_mod, p_proc, p_lhs;
      logic [63:0] p_ini = d[0 +: LPX];    // var INIT, distance 1

      assign p_own  = d[0 +: LPY];         // distance 0 (own scope)
      assign p_par  = d[0 +: LPX];         // distance 1 (parent gen scope)
      assign p_mod  = d[0 +: MP];          // distance 2 (the module)
      always_comb p_proc = d[0 +: LPX];    // distance 1, in a PROCESS
      assign p_lhs[LPX +: 4] = 4'hA;       // distance 1, on the LHS

      for (genvar z = 0; z < 2; z++) begin : gen_z
        logic [63:0] z_1up, z_2up, z_3up, z_gv;
        assign z_1up = d[0 +: LPY];        // distance 1
        assign z_2up = d[0 +: LPX];        // distance 2
        assign z_3up = d[0 +: MP];         // distance 3
        assign z_gv  = d[x +: 4];          // a GENVAR at distance 2
      end
    end
  end
endmodule
