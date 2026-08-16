// r10earl48 GRID ARM A3 — the FIRST-ITEM clause, and the empty-scope control.
//
// A2 showed the else-arm collapse is decided by the arm's FIRST generate ITEM
// and that the remaining items are never visited (u3/u5/u11).  A3 measures the
// clauses that decision still leaves open:
//
//  v1  a standalone EMPTY named if-generate block   (the u9 baseline: does an
//      empty gen scope survive at all when nothing is collapsed?)
//  v2  else arm whose first item is an if/ELSE pair (which branch's name?)
//  v3  else arm whose FIRST item is a FOR-generate, second an if-generate
//  v4  else arm whose FIRST item is an if-generate, second a FOR-generate
//  v5  else arm with non-generate content AFTER the gen child (guard order)
//  v6  else arm whose first item is a CASE-generate
//  v7  else arm whose first item is a named if-generate holding ONLY a
//      localparam (non-empty, but no net/assign)
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module a3_earl48 (output wire o);

  // ---- v1: standalone EMPTY named if-generate ---------------------------
  if (1) begin : v1_c
  end

  // ---- v2: first item is an if/ELSE pair --------------------------------
  if (0) begin : v2_if
    wire a1; assign a1 = 1'b0;
  end else begin : v2
    if (0) begin : v2_t
      wire a2; assign a2 = 1'b0;
    end else begin : v2_e
      wire a3; assign a3 = 1'b0;
    end
  end

  // ---- v3: FIRST item is a FOR-generate ---------------------------------
  if (0) begin : v3_if
    wire b1; assign b1 = 1'b0;
  end else begin : v3
    for (genvar i = 0; i < 2; i++) begin : v3_l
      wire b2; assign b2 = 1'b0;
    end
    if (1) begin : v3_c
      wire b3; assign b3 = 1'b0;
    end
  end

  // ---- v4: FIRST item is an if-generate, second a FOR-generate ----------
  if (0) begin : v4_if
    wire c1; assign c1 = 1'b0;
  end else begin : v4
    if (1) begin : v4_c
      wire c2; assign c2 = 1'b0;
    end
    for (genvar i = 0; i < 2; i++) begin : v4_l
      wire c3; assign c3 = 1'b0;
    end
  end

  // ---- v5: non-generate content AFTER the gen child ---------------------
  if (0) begin : v5_if
    wire d1; assign d1 = 1'b0;
  end else begin : v5
    if (1) begin : v5_c
      wire d2; assign d2 = 1'b0;
    end
    wire d3; assign d3 = 1'b0;
  end

  // ---- v6: first item is a CASE-generate --------------------------------
  if (0) begin : v6_if
    wire e1; assign e1 = 1'b0;
  end else begin : v6
    case (1)
      1: begin : v6_c
        wire e2; assign e2 = 1'b0;
      end
      default: begin : v6_d
        wire e3; assign e3 = 1'b0;
      end
    endcase
    if (1) begin : v6_c2
      wire e4; assign e4 = 1'b0;
    end
  end

  // ---- v7: first item holds ONLY a localparam ---------------------------
  if (0) begin : v7_if
    wire f1; assign f1 = 1'b0;
  end else begin : v7
    if (1) begin : v7_c
      localparam int F7 = 5;
    end
  end

  assign o = 1'b0;
endmodule
