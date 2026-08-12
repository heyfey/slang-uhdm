// r10earl33 arm 1 — THE GENERATE-CONTEXT AXIS of § fcArgPkgParamValueFolds32.
//
// r10earl32's verifier F4 named two cells (v4_more.sv 30:19 / 35:19) where a
// QUALIFIED package-parameter call argument written inside a generate body
// keeps the ref on our side and FOLDS in golden.  This arm holds the
// parameter, the call and the spelling fixed and moves ONLY the generate
// container, so the container is the only thing the cells can be measuring.
//
// The three abstentions that MUST survive are cells here, not assertions:
//   k5  BARE read in the same gen CA           (the gen no-fold laws own it)
//   k11 BARE read in a def-view gen PROCESS    (§ defGenProcWildcardPkgParamNoFold19)
//   k13 BARE read in a NESTED gen scope        (§ genNestedScopePkgParamNoFold24)
package p33;
  localparam logic [11:0] P    = 12'h380;
  localparam logic [11:0] Q    = 12'h123;
  localparam int          PI   = 7;
  // k17/k18's parameter: an ESCAPED name that CONTAINS `::`.  A bare read of
  // it is ONE IdentifierName token, but `rawText(...).find("::")` reads it as
  // QUALIFIED — the r10earl32 F1 spelling, and the reason
  // § genScopeBareArgKeepsRef33's gate is a SYNTAX KIND and not a text match.
  localparam logic [11:0] \x::y = 12'h456;
  function automatic logic [31:0] pfn(logic [11:0] v); return {v, 20'h0}; endfunction
endpackage

module k33sub (input logic [11:0] i_i, output logic [31:0] o);
  assign o = {i_i, 20'h0};
endmodule

module k33 (output logic [31:0] y);
  import p33::*;
  function automatic logic [31:0] mf(logic [11:0] v);  return {v, 20'h0}; endfunction
  function automatic logic [11:0] id(logic [11:0] v);  return v;          endfunction
  function automatic logic [31:0] mi(int v);           return v;          endfunction

  logic [31:0] r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14;

  // k1  FOR-generate body, CONT-ASSIGN, QUALIFIED  <- the F4 head
  // k5  the BARE sibling in the SAME cont-assign   <- must stay a ref
  for (genvar gi = 0; gi < 2; gi++) begin : gfor
    logic [31:0] w;
    assign w = mf(p33::P) + mf(P);
  end
  assign r1 = gfor[0].w;
  assign r5 = gfor[1].w;

  // k2  IF-generate body, cont-assign, qualified
  if (1) begin : gif
    logic [31:0] w;
    assign w = mf(p33::P);
  end
  assign r2 = gif.w;

  // k3  the ELSE branch of an if-generate
  if (0) begin : gth
    logic [31:0] w;
    assign w = mf(p33::Q);
  end else begin : gel
    logic [31:0] w;
    assign w = mf(p33::Q);
  end
  assign r3 = gel.w;

  // k4  NESTED generate (for inside if), cont-assign, qualified
  if (1) begin : gout
    for (genvar gj = 0; gj < 2; gj++) begin : gin
      logic [31:0] w;
      assign w = mf(p33::P);
    end
  end
  assign r4 = gout.gin[0].w;

  // k6  the argument is an OPERATION over the parameter (leaf position)
  // k7  a NESTED call
  // k8  a QUALIFIED PACKAGE function called with a qualified argument
  for (genvar gk = 0; gk < 2; gk++) begin : gops
    logic [31:0] w6, w7, w8;
    assign w6 = mf(p33::P + 12'h1);
    assign w7 = mf(id(p33::P));
    assign w8 = p33::pfn(p33::P);
  end
  assign r6 = gops[0].w6;
  assign r7 = gops[0].w7;
  assign r8 = gops[0].w8;

  // k9  a SYS-func call argument in a gen cont-assign
  for (genvar gl = 0; gl < 2; gl++) begin : gsys
    logic [31:0] w;
    assign w = $clog2(p33::PI) + mi(p33::PI);
  end
  assign r9 = gsys[0].w;

  // k10 an INSTANCE PORT ACTUAL that is a call, inside a generate block
  for (genvar gm = 0; gm < 2; gm++) begin : gport
    logic [31:0] w;
    k33sub u_s (.i_i(id(p33::P)), .o(w));
  end
  assign r10 = gport[0].w;

  // k11 / k12  a def-view gen-block PROCESS: BARE and QUALIFIED in the SAME
  // always_comb (a3_ctx g3/g4's pair, re-measured at this position)
  if (1) begin : gproc
    logic [31:0] wb, wq;
    always_comb begin
      wb = mf(P);
      wq = mf(p33::P);
    end
  end
  assign r11 = gproc.wb;
  assign r12 = gproc.wq;

  // k13 / k14  a NESTED gen scope's process: BARE and QUALIFIED
  if (1) begin : gnout
    for (genvar gn = 0; gn < 2; gn++) begin : gnin
      logic [31:0] wb, wq;
      always_comb begin
        wb = mf(P);
        wq = mf(p33::P);
      end
    end
  end
  assign r13 = gnout.gnin[0].wb;
  assign r14 = gnout.gnin[0].wq;

  // k17 / k18  THE ESCAPED-IDENTIFIER CELL the syntax-kind gate exists for: a
  // BARE read of a parameter whose NAME contains `::`, inside an elaborated
  // generate cont-assign (k17) and inside a generate process (k18).  Under a
  // `rawText(...).find("::")` test both read as QUALIFIED; under the syntax
  // kind both read as BARE, which is what they are.
  logic [31:0] r17, r18;
  for (genvar go = 0; go < 2; go++) begin : gesc
    logic [31:0] wc, wp;
    assign wc = mf(\x::y );
    always_comb wp = mf(\x::y );
  end
  assign r17 = gesc[0].wc;
  assign r18 = gesc[0].wp;

  assign y = r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6 ^ r7 ^ r8 ^ r9 ^ r10 ^ r11 ^ r12 ^
             r13 ^ r14 ^ r17 ^ r18;
endmodule

// k15 — the same for-generate inside a module that is NEVER INSTANTIATED
// (def listing only, no elaborated twin).
module k33never (output logic [31:0] y);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  logic [31:0] q;
  for (genvar gi = 0; gi < 2; gi++) begin : gnv
    logic [31:0] w;
    assign w = mf(p33::P);
  end
  assign q = gnv[0].w;
  assign y = q;
endmodule

// k16 — the NEGATIVE CONTROL: the same call written OUTSIDE any generate, in
// the module body.  § fcArgPkgParamValueFolds32 already owns this cell and it
// must be byte-identical before and after.
module k33flat (output logic [31:0] y);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  assign y = mf(p33::P);
endmodule

module k33top;
  logic [31:0] a, b;
  k33     u1 (.y(a));
  k33flat u2 (.y(b));
endmodule
