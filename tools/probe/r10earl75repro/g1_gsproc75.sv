// r10earl75 g1 — POSITION x HOME x ORIGIN grid for § genScopeProcOpFoldTs75.
//
// The law says: a fold of a wildcard-imported package parameter that an
// OPERATION inside a GENERATE SCOPE'S PROCESS reduces carries the parameter's
// own declaration typespec, exactly as the byte-identical statement written in
// the module body already does.  The module-body rows are therefore the
// POSITIVE CONTROL (they were already right at 94e673b and must not move), the
// gen-scope rows are the claim, and the module parameter / module localparam /
// gen-scope localparam / genvar / QUALIFIED-read rows are the NEGATIVE controls
// that must gain nothing.
//
// The Earlgrey head shape is row B_P1: a replication COUNT that is the whole
// Rhs of an assignment inside an `always_comb` written in a generate block.
package g75p;
  parameter int NB = 4;
  parameter bit [7:0] TB = 8'd3;
  parameter     UT = 5;
endpackage

module g75m import g75p::*; #(
  parameter int MP = 2
) (
  input  logic        req_i,
  input  logic [15:0] bus_i,
  output logic [15:0] o_i
);
  localparam int ML = 3;
  logic [15:0] alloc;

  // A module-level function, so that a BARE (unqualified) user-call ARGUMENT
  // can be measured in both homes: V-FIX v58 (b) says golden keeps the ref
  // there for a gen-scope-declared parameter, and this asks the same question
  // of an imported PACKAGE parameter.
  function automatic logic [15:0] mfn(input int a);
    return a[15:0];
  endfunction

  // ---------------------------------------------------------------- HOME A
  // MODULE BODY always_comb.  § procOpFold9 already stamps every P* row here;
  // they are the control that says the law is about the HOME and not about the
  // position.
  logic [15:0] a1, a2, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14;
  logic [47:0] a3;
  always_comb begin
    a1  = {NB{req_i}};                 // P1  replication count, whole Rhs
    a2  = {NB{req_i}} & alloc;         // P2  replication count under an op
    a3  = {NB, bus_i};                 // P3  concat MEMBER
    a4  = NB + 16'h1;                  // P4  arithmetic operand
    a5  = req_i ? NB : 16'h7;          // P5  ternary arm
    a6  = NB;                          // P6  whole Rhs, no operation
    a7  = bus_i[NB];                   // P7  bit-select INDEX
    a8  = bus_i[NB-1:0];               // P8  part-select BOUND
    a9  = bus_i[0 +: NB];              // P9  indexed part-select WIDTH
    a10 = $clog2(NB);                  // P10 sys-func ARGUMENT
    a11 = 16'h0;
    for (int k = 0; k < NB; k++)       // P11 for-loop CONDITION bound
      a11 = a11 + 16'h1;
    a12 = 16'h0;
    if (bus_i == NB) a12 = 16'h1;      // P12 if CONDITION operand
    a13 = 16'h0;
    case (bus_i)
      NB + 16'h0: a13 = 16'h2;         // P13 case-ITEM operand
      default:    a13 = 16'h3;
    endcase
    a14 = mfn(NB) & alloc;             // P14 bare user-call ARGUMENT
  end

  // ---------------------------------------------------------------- HOME B
  // gen-IF block always_comb — the r10earl74 R0 home.
  if (MP != 99) begin : gen_b
    logic [15:0] b1, b2, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14;
    logic [47:0] b3;
    always_comb begin
      b1  = {NB{req_i}};
      b2  = {NB{req_i}} & alloc;
      b3  = {NB, bus_i};
      b4  = NB + 16'h1;
      b5  = req_i ? NB : 16'h7;
      b6  = NB;
      b7  = bus_i[NB];
      b8  = bus_i[NB-1:0];
      b9  = bus_i[0 +: NB];
      b10 = $clog2(NB);
      b11 = 16'h0;
      for (int k = 0; k < NB; k++) b11 = b11 + 16'h1;
      b12 = 16'h0;
      if (bus_i == NB) b12 = 16'h1;
      b13 = 16'h0;
      case (bus_i)
        NB + 16'h0: b13 = 16'h2;
        default:    b13 = 16'h3;
      endcase
      b14 = mfn(NB) & alloc;
    end
  end

  // ---------------------------------------------------------------- HOME C
  // gen-FOR block always_comb, two iterations: does every iteration stamp?
  for (genvar i = 0; i < 2; i++) begin : gen_c
    localparam int GL = 2;
    logic [15:0] c1, c2, c5, c9;
    always_comb begin
      c1 = {NB{req_i}};                // the head shape, gen-for home
      c2 = {NB{req_i}} & alloc;
      c5 = req_i ? NB : 16'h7;
      c9 = bus_i[0 +: NB];
    end
    // ------------------------------------------------------------- HOME D
    // NESTED gen block: § genNestedScopePkgParamNoFold24 says the read does not
    // FOLD there at all (golden keeps a ref_obj bound to an enum_const), so the
    // law must gain nothing.  This is the fence, measured, not assumed.
    for (genvar j = 0; j < 2; j++) begin : gen_d
      logic [15:0] d1, d2;
      always_comb begin
        d1 = {NB{req_i}};
        d2 = {NB{req_i}} & alloc;
      end
    end
    // ------------------------------------------------------------- HOME E
    // NEGATIVE ORIGINS inside a gen scope's process.
    logic [15:0] e1, e2, e3, e4, e5, e6, e7;
    always_comb begin
      e1 = {g75p::NB{req_i}} & alloc;  // O2 the SAME parameter, QUALIFIED
      e2 = {TB{req_i}} & alloc;        // O3 package `bit [7:0]`
      e3 = {UT{req_i}} & alloc;        // O4 package IMPLICITLY typed
      e4 = {MP{req_i}} & alloc;        // O5 a MODULE parameter
      e5 = {ML{req_i}} & alloc;        // O6 a MODULE localparam
      e6 = {GL{req_i}} & alloc;        // O7 a GEN-SCOPE localparam
      e7 = {(i+1){req_i}} & alloc;     // O8 the GENVAR itself
    end
  end

  // ---------------------------------------------------------------- HOME F
  // gen-scope always_ff and gen-scope initial: `inGenScopeProc` is true for
  // BOTH, so both must answer the way golden answers.
  if (MP != 98) begin : gen_f
    logic [15:0] f1, f2;
    always_ff @(posedge req_i) f1 <= {NB{req_i}} & alloc;
    initial                    f2  = {NB{req_i}} & alloc;
  end

  // ---------------------------------------------------------------- HOME G
  // A gen-scope FUNCTION body: `currentTf` gates § tfOpFold9 there and
  // `inGenScopeProc` is NOT set, so the law must not reach it.
  if (MP != 97) begin : gen_g
    function automatic logic [15:0] gfn(logic r);
      return {NB{r}} & alloc;
    endfunction
    logic [15:0] g1;
    always_comb g1 = gfn(req_i);
  end

  assign o_i = a1 | a2 | a4 | a5 | a6 | a7 | a8 | a9 | a10 | a11 | a12 | a13 |
               a14 | a3[15:0] | alloc;
endmodule

module g75top;
  logic r; logic [15:0] bus, x, y, z;
  // three instances: does every ELAB body stamp, and does an override matter?
  g75m           u0(.req_i(r), .bus_i(bus), .o_i(x));
  g75m #(.MP(7)) u1(.req_i(r), .bus_i(bus), .o_i(y));
  g75m #(.MP(9)) u2(.req_i(r), .bus_i(bus), .o_i(z));
endmodule
