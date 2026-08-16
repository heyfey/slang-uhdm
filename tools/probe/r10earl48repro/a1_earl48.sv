// r10earl48 GRID ARM A1 — WHICH if-generate levels does golden's ELABORATED
// view keep, and which does it splice out?
//
// The head (Earlgrey prim_present.sv:91-95) shows golden emitting
//   gen_round[0].gen_d64            (gen_scope_array parented at gen_round[0])
// where we emit
//   gen_round[0].gen_enc.gen_d64
// AND golden emitting NOTHING at all for gen_enc's SECOND generate child
// (gen_k128, whose cont_assign is simply absent from golden's elab view).
//
// prim_present's shape, exactly:
//   for (genvar k...) begin : gen_round        <- loop
//     logic ...; assign ...;                   <- non-generate content
//     if (Decrypt) begin : gen_dec  ...        <- NOT taken
//     end else begin : gen_enc                 <- TAKEN **ELSE** arm,
//       if (DataWidth==64) begin : gen_d64 ... <-   whose members are
//       end else begin : gen_d32 ... end       <-   ONLY generate constructs
//       if (KeyWidth==128) begin : gen_k128 .. <-   (two of them)
//       end else if ... end
//     end
//   end
//
// The candidate discriminators, each given its own row.  LHS is ALWAYS golden
// (Surelog).  RHS is ALWAYS ours.
//
// t_then   THEN arm, gen-only, 1 gen child            (the genblk_order shape)
// t_t2     THEN arm, gen-only, 2 gen children
// t_e1     ELSE arm, gen-only, 1 gen child
// t_e2     ELSE arm, gen-only, 2 gen children         (prim_present's shape)
// t_e3     ELSE arm, gen child PLUS a wire+assign     (content guard)
// t_e4     ELSE-IF arm, gen-only, 1 gen child
// t_e5     UNNAMED else arm, gen-only, 1 gen child
// t_e6     ELSE arm, gen-only, single child is a FOR loop
// t_e7     ELSE arm whose only child is another ELSE arm (recursion)
// t_l      the EXACT prim_present shape, inside a for-generate
module a1_earl48 (output wire o);

  // ---- t_then: THEN arm, gen-only, one gen child ------------------------
  if (1) begin : t_then
    if (1) begin : t_then_c
      wire a1; assign a1 = 1'b0;
    end
  end

  // ---- t_t2: THEN arm, gen-only, TWO gen children -----------------------
  if (1) begin : t_t2
    if (1) begin : t_t2_c1
      wire a2; assign a2 = 1'b0;
    end
    if (1) begin : t_t2_c2
      wire a3; assign a3 = 1'b0;
    end
  end else begin : t_t2_else
    wire a4; assign a4 = 1'b0;
  end

  // ---- t_e1: ELSE arm, gen-only, ONE gen child --------------------------
  if (0) begin : t_e1_if
    wire b1; assign b1 = 1'b0;
  end else begin : t_e1
    if (1) begin : t_e1_c
      wire b2; assign b2 = 1'b0;
    end
  end

  // ---- t_e2: ELSE arm, gen-only, TWO gen children (prim_present) --------
  if (0) begin : t_e2_if
    wire c1; assign c1 = 1'b0;
  end else begin : t_e2
    if (1) begin : t_e2_c1
      wire c2; assign c2 = 1'b0;
    end
    if (1) begin : t_e2_c2
      wire c3; assign c3 = 1'b0;
    end
  end

  // ---- t_e3: ELSE arm with NON-generate content beside a gen child ------
  if (0) begin : t_e3_if
    wire d1; assign d1 = 1'b0;
  end else begin : t_e3
    wire d2; assign d2 = 1'b0;
    if (1) begin : t_e3_c
      wire d3; assign d3 = 1'b0;
    end
  end

  // ---- t_e4: ELSE-IF arm, gen-only, one gen child -----------------------
  if (0) begin : t_e4_if
    wire e1; assign e1 = 1'b0;
  end else if (1) begin : t_e4
    if (1) begin : t_e4_c
      wire e2; assign e2 = 1'b0;
    end
  end

  // ---- t_e5: UNNAMED else arm, gen-only, one gen child ------------------
  if (0) begin : t_e5_if
    wire f1; assign f1 = 1'b0;
  end else begin
    if (1) begin : t_e5_c
      wire f2; assign f2 = 1'b0;
    end
  end

  // ---- t_e6: ELSE arm whose only child is a FOR loop --------------------
  if (0) begin : t_e6_if
    wire g1; assign g1 = 1'b0;
  end else begin : t_e6
    for (genvar i = 0; i < 2; i++) begin : t_e6_l
      wire g2; assign g2 = 1'b0;
    end
  end

  // ---- t_e7: ELSE arm whose only child is another ELSE arm --------------
  if (0) begin : t_e7_if
    wire h1; assign h1 = 1'b0;
  end else begin : t_e7
    if (0) begin : t_e7_if2
      wire h2; assign h2 = 1'b0;
    end else begin : t_e7_e
      if (1) begin : t_e7_c
        wire h3; assign h3 = 1'b0;
      end
    end
  end

  // ---- t_l: the EXACT prim_present shape, inside a for-generate ---------
  for (genvar k = 0; k < 2; k++) begin : t_l
    wire i1;
    assign i1 = 1'b0;
    if (0) begin : t_l_dec
      wire i2; assign i2 = 1'b0;
    end else begin : t_l_enc
      if (1) begin : t_l_d64
        wire i3; assign i3 = 1'b0;
        wire i4; assign i4 = 1'b0;
      end else begin : t_l_d32
        wire i5; assign i5 = 1'b0;
      end
      if (1) begin : t_l_k128
        wire i6; assign i6 = 1'b0;
      end
    end
  end

  assign o = 1'b0;
endmodule
