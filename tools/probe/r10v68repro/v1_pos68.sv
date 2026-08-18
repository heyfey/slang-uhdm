// r10v68 arm v1 — EVERY genvar-read POSITION an elaborated gen-scope
// cont_assign can put a genvar in, at distances 0/1/2, plus the procedural,
// range-bound, localparam-init, port-actual and call-argument positions.
// MEASUREMENT ONLY (verifier of r10earl68).
module v1_kid68 #(parameter int unsigned K = 0) (input logic [7:0] p, output logic [7:0] q);
  assign q = p ^ K[7:0];
endmodule

module v1_pos68 (input logic [7:0] din, output logic [7:0] dout);
  localparam int unsigned W = 8;
  logic [7:0]  a8;
  logic [63:0] wide;
  logic [7:0]  mem [0:15];
  logic [7:0]  r_bare, r_add, r_mul, r_neg, r_not, r_and, r_eq, r_tern,
               r_cat, r_rep, r_bidx, r_ipsb, r_ipsw, r_ps, r_cast,
               r_ucall, r_scall, r_ncall, r_lp, r_rng, r_proc, r_alw,
               r_nda, r_paren, r_pact0, r_pact1, r_pact2, r_memidx;
  logic [7:0] k0, k1, k2;

  function automatic logic [7:0] f68(input int unsigned x);
    return x[7:0] + 8'd1;
  endfunction

  // ---------------- distance 0 -------------------------------------------
  for (genvar i = 1; i < 3; i++) begin : g_p0
    assign r_bare  = i;                 // WHOLE Rhs (the law)
    assign r_add   = i + 1;             // operation operand, fully reducible
    assign r_mul   = i * 2;
    assign r_neg   = -i;
    assign r_not   = ~i;
    assign r_and   = i & 1;
    assign r_eq    = (i == 0);
    assign r_tern  = i ? din : ~din;    // ternary predicate, NOT reducible
    assign r_cat   = {i[0], 1'b0};      // concat
    assign r_rep   = {4{i[0]}};         // replication (count is a literal)
    assign r_bidx  = mem[i];            // bit/array-select INDEX (rgg14)
    assign r_ipsb  = wide[i +: 8];      // ips BASE
    assign r_ipsw  = wide[(i*8) +: 8];  // ips computed base
    assign r_ps    = wide[i+7 : i];     // part-select BOUNDS (both genvar)
    assign r_cast  = W'(i);             // cast
    assign r_ucall = f68(i);            // USER call arg
    assign r_scall = $clog2(i+2);       // SYSTEM call arg
    assign r_ncall = f68($clog2(i+2));  // NESTED call arg
    assign r_paren = (i);               // parenthesised bare genvar
    assign mem[i]  = din;               // LHS index
    localparam int unsigned Lp0 = i;    // localparam INIT
    assign r_lp    = Lp0;               // localparam read as whole Rhs
    logic [i:0] rng0;                   // RANGE BOUND
    assign rng0    = din[i:0];
    assign r_rng   = {7'b0, rng0[0]};
    logic [7:0] nda0 = i;               // NET-DECL-ASSIGN
    assign r_nda   = nda0;
    logic [7:0] pv0;
    always_comb pv0 = i;                // PROCEDURAL (always_comb)
    assign r_proc  = pv0;
    logic [7:0] av0;
    always @(*) av0 = i;                // PROCEDURAL (always @*)
    assign r_alw   = av0;
    v1_kid68 #(.K(i)) u_k0 (.p(din), .q(k0));            // PARAM actual
  end

  // ---------------- distance 1 and 2, port actuals ------------------------
  for (genvar i = 0; i < 2; i++) begin : g_p1
    if (i >= 0) begin : b1
      v1_kid68 u_k1 (.p({7'b0, i[0]}), .q(k1));          // port actual, expr
      assign r_pact0 = k1;
      if (i >= 0) begin : b2
        v1_kid68 u_k2 (.p(mem[i]), .q(k2));              // port actual, index
        assign r_pact1 = k2;
        assign r_memidx = mem[i];
        assign r_pact2 = i;                              // whole Rhs at dist 2
      end
    end
  end

  assign dout = r_bare ^ r_add ^ r_mul ^ r_neg ^ r_not ^ r_and ^ r_eq ^
                r_tern ^ r_cat ^ r_rep ^ r_bidx ^ r_ipsb ^ r_ipsw ^ r_ps ^
                r_cast ^ r_ucall ^ r_scall ^ r_ncall ^ r_lp ^ r_rng ^
                r_proc ^ r_alw ^ r_nda ^ r_paren ^ r_pact0 ^ r_pact1 ^
                r_pact2 ^ r_memidx ^ a8 ^ wide[7:0] ^ k0;
endmodule
