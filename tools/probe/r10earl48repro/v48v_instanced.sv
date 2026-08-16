// r10earl48 VERIFIER arm — the shapes the implementer's a1/a2/a3 never put on
// the page.  LHS is ALWAYS golden (Surelog).
//
//  w1  the EXACT prim_present shape inside an INSTANTIATED child module.
//      Every measured cell of this law lives in a module that is a TOP
//      (prim_present is never instantiated in Earlgrey_0_1, and all three
//      implementer arms are top modules).  If Surelog's flatten is a property
//      of the TOP elaboration path only, this row refutes the law.
//  w2  an else arm whose SECOND item is a MODULE INSTANCE (the implementer
//      measured a wire+assign in that position, a3 v5; an instance is a whole
//      sub-tree).
//  w3  an else arm whose first item's taken branch is a BARE STATEMENT
//      (unnamed).
//  w4  a promoted block holding an INSTANCE first and a for-generate second
//      (span carrier = the instance?), inside an INSTANTIATED module.
//  w8  a promoted block whose name COLLIDES with an existing sibling of the
//      scope the promotion lands in.
//  w9  first item is an if / else-IF chain (the taken block hangs off the
//      nested IfGenerate, not off the arm's ElseClause).

module v48v_leaf ();
  wire lz;
  assign lz = 1'b0;
endmodule

module w1_child #(parameter int P = 64) ();
  wire a, b;
  for (genvar k = 0; k < 2; k++) begin : w1_round
    wire [1:0] st;
    assign st = 2'b01;
    if (0) begin : w1_dec
      assign b = 1'b0;
    end else begin : w1_enc
      if (P == 64) begin : w1_d64
        assign a = st[0];
        assign b = st[1];
      end else begin : w1_d32
        assign a = 1'b0;
      end
      if (P == 64) begin : w1_k128
        assign b = 1'b1;
      end
    end
  end
endmodule

module w4_child ();
  if (0) begin : w4_t
    wire t;
  end else begin : w4_e
    if (1) begin : w4_c
      v48v_leaf u_in ();
      for (genvar i = 0; i < 2; i++) begin : w4_l
        wire w;
      end
    end
  end
endmodule

module v48v_instanced ();
  w1_child #(.P(64)) u_w1 ();
  w4_child           u_w4 ();
endmodule

module w2 ();
  wire c0;
  if (0) begin : w2_t
    wire t;
  end else begin : w2_e
    if (1) begin : w2_c
      wire c1;
      assign c1 = 1'b0;
    end
    v48v_leaf u_leaf ();
  end
endmodule

module w3 ();
  wire x, y;
  if (0) begin : w3_t
    wire t;
  end else begin : w3_e
    if (1) assign x = y;
  end
endmodule

module w8 ();
  if (1) begin : w8_c
    wire p;
    assign p = 1'b0;
  end
  if (0) begin : w8_t
    wire t;
  end else begin : w8_e
    if (1) begin : w8_c
      wire q;
      assign q = 1'b1;
    end
  end
endmodule

module w9 ();
  wire n1;
  if (0) begin : w9_t
    wire t;
  end else begin : w9_e
    if (0) begin : w9_a
      wire aa;
    end else if (1) begin : w9_b
      wire bb;
      assign bb = 1'b0;
    end
  end
endmodule
