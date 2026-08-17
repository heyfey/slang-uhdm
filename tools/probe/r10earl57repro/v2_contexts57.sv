// r10earl57 v2 — THE SAME 14 CAST TARGETS, one CONTEXT per copy.
// v1 measured them at MODULE scope and every row already agreed.  This arm asks
// the question the corpus head forces: does the CONTEXT the cast is written in
// move golden's answer?  Contexts: IF-generate, FOR-generate body, a function
// body, an always_comb, and a nested gen scope.
module c57 #(
  parameter  int unsigned PLIT  = 8,
  parameter  int unsigned PDEP  = PLIT + 1,
  localparam int unsigned QLIT  = 5,
  localparam int unsigned QDEP  = (PLIT == 0) ? 1 : PLIT,
  parameter               PUNT  = 7
) (
  input  logic [31:0] sig,
  output logic [31:0] gi1, gi2, gi3, gi4, gi5,
  output logic [31:0] gf1, gf2,
  output logic [31:0] fn1, fn2,
  output logic [31:0] ac1, ac2,
  output logic [31:0] ns1, ns2
);
  localparam int unsigned BLIT = 6;
  localparam int unsigned BDEP = $clog2(PLIT + 1);

  // ---- IF-generate (the corpus shape: gen_normal_fifo) ----------------
  if (PLIT > 1) begin : gen_if57
    assign gi1 = PLIT'(sig);   // literal-default port param
    assign gi2 = PDEP'(sig);   // computed-default port param
    assign gi3 = QDEP'(sig);   // computed-default port LOCALPARAM  <-- DepthW
    assign gi4 = BDEP'(sig);   // computed-default BODY localparam
    assign gi5 = BLIT'(sig);   // literal-default body localparam
    // ---- a NESTED gen scope inside it ----
    if (PLIT > 2) begin : gen_inner57
      assign ns1 = QDEP'(sig);
      assign ns2 = BDEP'(sig);
    end
  end else begin : gen_else57
    assign gi1 = '0; assign gi2 = '0; assign gi3 = '0; assign gi4 = '0;
    assign gi5 = '0; assign ns1 = '0; assign ns2 = '0;
  end

  // ---- FOR-generate body ---------------------------------------------
  for (genvar gv = 0; gv < 1; gv++) begin : gen_for57
    assign gf1 = QDEP'(sig);
    assign gf2 = BDEP'(sig);
  end

  // ---- function body -------------------------------------------------
  function automatic logic [31:0] f57(logic [31:0] a);
    return QDEP'(a) + BDEP'(a);
  endfunction
  assign fn1 = f57(sig);
  assign fn2 = QDEP'(sig);

  // ---- procedural ----------------------------------------------------
  always_comb ac1 = QDEP'(sig);
  always_comb ac2 = BDEP'(sig);
endmodule

module top57c (
  input  logic [31:0] s,
  output logic [31:0] b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13
);
  c57 i_c (.sig(s), .gi1(b1), .gi2(b2), .gi3(b3), .gi4(b4), .gi5(b5),
           .gf1(b6), .gf2(b7), .fn1(b8), .fn2(b9), .ac1(b10), .ac2(b11),
           .ns1(b12), .ns2(b13));
endmodule
