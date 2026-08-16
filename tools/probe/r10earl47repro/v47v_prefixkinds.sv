// r10earl47 VERIFIER ARM v47v_prefixkinds (r10earl47 verifier) — the NON-SCOPE PREFIX COMPONENTS.
// The law's distance is `usePrefix.rfind('.')`, i.e. "drop the last component
// of the emission prefix".  That is a scope hop ONLY when the last component
// is a scope.  These rows put a NON-SCOPE component last (a function name, a
// task name, a named statement block, a variable name) and ask golden.
// LHS is ALWAYS golden (Surelog).
module v1_earl47v;
  localparam int W  = 64;
  localparam int MP = 8;
  logic [255:0] d;

  for (genvar x = 0; x < 2; x++) begin : gen_x
    localparam int LPX = 4 + x * 2;      // the gen-scope localparam

    // ---- V1a: a FUNCTION declared in the localparam's OWN scope.  The body's
    // emission prefix is <gen_x[i]>.<funcname>, so the one-hop test makes the
    // localparam "distance 1" although it is in the SAME scope.
    function automatic logic [63:0] f_fn(input logic [255:0] a);
      f_fn = a[0 +: LPX];
    endfunction

    // ---- V1b: a TASK, same shape.
    logic [63:0] t_out;
    task automatic t_tk(input logic [255:0] a);
      t_out = a[LPX +: 4];
    endtask

    // ---- V1c: a NAMED STATEMENT BLOCK inside a process in the OWN scope.
    logic [63:0] p_nb;
    always_comb begin : nb
      p_nb = d[0 +: LPX];
    end

    // ---- V1d: a variable DECLARATION INITIALIZER in the OWN scope
    // (b1's r_dini shape, re-measured here as a control).
    logic [63:0] r_dini = d[0 +: LPX];

    // ---- V1e: the plain OWN-scope cont_assign control (distance 0).
    logic [63:0] r_own;
    assign r_own = d[0 +: LPX];

    logic [63:0] r_fn, r_tkdrv;
    assign r_fn = f_fn(d);

    // ---- the DESCENDANT scope, with the same non-scope components ---------
    for (genvar y = 0; y < 2; y++) begin : gen_y
      // V1f: a function ONE scope down: prefix is <gen_x[i].gen_y[j]>.<fn>,
      // so the one-hop test sees gen_y, NOT gen_x -> must NOT substitute.
      function automatic logic [63:0] g_fn(input logic [255:0] a);
        g_fn = a[0 +: LPX];
      endfunction
      logic [63:0] n_fn;
      assign n_fn = g_fn(d);

      // V1g: a named block one scope down (prefix <...gen_y[j]>.<nb2>).
      logic [63:0] n_nb;
      always_comb begin : nb2
        n_nb = d[0 +: LPX];
      end

      // V1h: the plain distance-1 control that the law DOES claim.
      logic [63:0] n_ok;
      assign n_ok = d[0 +: LPX];

      // V1i: a declaration initializer one scope down (a3 p_ini shape).
      logic [63:0] n_ini = d[0 +: LPX];
    end
  end
endmodule
