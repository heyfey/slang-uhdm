// r10earl48 GRID ARM A2 — the EDGES of the plain-else collapse that A1 found.
//
// A1's verdict: a TAKEN PLAIN-ELSE arm whose members are only if-generate
// blocks is spliced out; its FIRST instantiated if-generate child takes its
// place (first-member span) and the arm's REMAINING children are DROPPED.
// A2 pushes on every clause of that sentence that A1 left unmeasured:
//
//  u1  named else arm, gen-only, the surviving child is UNNAMED
//  u2  UNNAMED else arm, gen-only, one named child          (A1 t_e5 re-read)
//  u3  UNNAMED else arm, gen-only, TWO named children       (ordering)
//  u4  named else arm whose only gen child is NOT taken     (nothing survives)
//  u5  named else arm, first child NOT taken, second taken  (which survives?)
//  u6  named else arm + a LOCALPARAM beside the gen child   (content guard)
//  u7  named else arm + a MODULE INSTANCE beside the child  (content guard)
//  u8  named else arm whose only child is a CASE-generate
//  u9  named else arm whose only child is an EMPTY if-generate block
//  u10 named else arm of an if that is itself an ELSE-IF arm's body
//  u11 the same else-arm shape inside an INTERFACE (collapseIfLeaf9 overlap)
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module a2_leaf (output wire z);
  assign z = 1'b0;
endmodule

interface a2_if48;
  wire w;
  if (0) begin : u11_if
    wire p1; assign p1 = 1'b0;
  end else begin : u11
    if (1) begin : u11_c1
      wire p2; assign p2 = 1'b0;
    end
    if (1) begin : u11_c2
      wire p3; assign p3 = 1'b0;
    end
  end
endinterface

module a2_earl48 (output wire o);

  // ---- u1: surviving child is UNNAMED -----------------------------------
  if (0) begin : u1_if
    wire a1; assign a1 = 1'b0;
  end else begin : u1
    if (1) begin
      wire a2; assign a2 = 1'b0;
    end
  end

  // ---- u2: UNNAMED else arm, one named child ----------------------------
  if (0) begin : u2_if
    wire b1; assign b1 = 1'b0;
  end else begin
    if (1) begin : u2_c
      wire b2; assign b2 = 1'b0;
    end
  end

  // ---- u3: UNNAMED else arm, TWO named children -------------------------
  if (0) begin : u3_if
    wire c1; assign c1 = 1'b0;
  end else begin
    if (1) begin : u3_c1
      wire c2; assign c2 = 1'b0;
    end
    if (1) begin : u3_c2
      wire c3; assign c3 = 1'b0;
    end
  end

  // ---- u4: the only gen child is NOT taken ------------------------------
  if (0) begin : u4_if
    wire d1; assign d1 = 1'b0;
  end else begin : u4
    if (0) begin : u4_c
      wire d2; assign d2 = 1'b0;
    end
  end

  // ---- u5: first child NOT taken, second taken --------------------------
  if (0) begin : u5_if
    wire e1; assign e1 = 1'b0;
  end else begin : u5
    if (0) begin : u5_c1
      wire e2; assign e2 = 1'b0;
    end
    if (1) begin : u5_c2
      wire e3; assign e3 = 1'b0;
    end
  end

  // ---- u6: a LOCALPARAM beside the gen child ----------------------------
  if (0) begin : u6_if
    wire f1; assign f1 = 1'b0;
  end else begin : u6
    localparam int F = 3;
    if (1) begin : u6_c
      wire f2; assign f2 = 1'b0;
    end
  end

  // ---- u7: a MODULE INSTANCE beside the gen child -----------------------
  if (0) begin : u7_if
    wire g1; assign g1 = 1'b0;
  end else begin : u7
    a2_leaf u_leaf (.z());
    if (1) begin : u7_c
      wire g2; assign g2 = 1'b0;
    end
  end

  // ---- u8: the only child is a CASE-generate ----------------------------
  if (0) begin : u8_if
    wire h1; assign h1 = 1'b0;
  end else begin : u8
    case (1)
      1: begin : u8_c
        wire h2; assign h2 = 1'b0;
      end
      default: begin : u8_d
        wire h3; assign h3 = 1'b0;
      end
    endcase
  end

  // ---- u9: the only child is an EMPTY if-generate block -----------------
  if (0) begin : u9_if
    wire i1; assign i1 = 1'b0;
  end else begin : u9
    if (1) begin : u9_c
    end
  end

  // ---- u10: else arm nested under an ELSE-IF arm ------------------------
  if (0) begin : u10_if
    wire j1; assign j1 = 1'b0;
  end else if (1) begin : u10_ei
    if (0) begin : u10_if2
      wire j2; assign j2 = 1'b0;
    end else begin : u10
      if (1) begin : u10_c
        wire j3; assign j3 = 1'b0;
      end
    end
  end

  a2_if48 u_if48 ();
  assign o = 1'b0;
endmodule
