// r10vearl116 ADVERSARIAL arm va2_rep116 — REPLICATED / TYPE-KEYED / NESTED
// PATTERNS, under BOTH Lhs shapes, in BOTH scopes.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE ATTACK.  r10earl116 widened `flattenPatternCaRhs`'s reach: it used to run
// ONLY when `reemitting` had produced a flattened operand list, and now runs on
// the TAGGED list too (`patStruct9`, not `patFlat9`).  Inside it,
//     if (ops.size() != ap.memberSetters.size()) return;
// is the only thing standing between the new call and a MISALIGNED index join
// between UHDM operands and slang's memberSetters.  A REPLICATED pattern, a
// TYPE-KEYED pattern and a `default:`-only pattern each make slang's
// `memberSetters` a DIFFERENT length from the emitted operand vector, so they
// are the shapes that probe that guard.  q3_mix116 covers `default:` and a
// nested pattern; it covers NEITHER replication NOR a type key, and neither
// under a select Lhs.
//
//   r1  whole-name Lhs, REPLICATED pattern  '{2{...}}
//   r2  SELECT Lhs,     REPLICATED pattern
//   r3  whole-name Lhs, TYPE-KEYED pattern
//   r4  SELECT Lhs,     TYPE-KEYED pattern
//   r5  whole-name Lhs, `default:`-ONLY pattern (memberSetters empty)
//   r6  SELECT Lhs,     `default:`-ONLY pattern
//   r7  whole-name Lhs, member key + `default:` MIXED
//   r8  SELECT Lhs,     member key + `default:` MIXED
//   r9  SELECT Lhs,     NESTED keyed pattern as a member value
//   r10 MODULE-SCOPE select Lhs, keyed (the site this law does not gate)
package v2p116;
  typedef struct packed {
    logic [3:0] g0;
    logic [3:0] g1;
  } gsub_t;
  typedef struct packed {
    logic [3:0] m0;
    logic [3:0] m1;
  } rep_t;
  typedef logic [3:0] nib_t;
  typedef logic [7:0] byt_t;
  typedef struct packed {
    nib_t k_d;
    byt_t k_b;
  } key_t;
  typedef struct packed {
    logic  n_v;
    gsub_t n_lo;
  } nest_t;
endpackage

module va2_rep116 #(
    parameter int M = 3
) (
    input  logic       clk,
    input  logic [3:0] a_i,
    input  logic [3:0] b_i,
    input  logic       v_i,
    output logic       v_o
);
  import v2p116::nib_t;
  import v2p116::byt_t;
  v2p116::rep_t  rarr[M];
  v2p116::key_t  karr[M];
  v2p116::key_t  darr[M];
  v2p116::key_t  xarr[M];
  v2p116::nest_t narr[M];
  v2p116::key_t  marr[M];

  // r1  whole-name Lhs, REPLICATED pattern.
  for (genvar i = 0; i < M; i++) begin : gen_r1
    v2p116::rep_t t;
    assign t = '{2{a_i}};
  end

  // r2  SELECT Lhs, REPLICATED pattern.
  for (genvar i = 0; i < M; i++) begin : gen_r2
    assign rarr[i] = '{2{b_i}};
  end

  // r3  whole-name Lhs, TYPE-KEYED pattern.
  for (genvar i = 0; i < M; i++) begin : gen_r3
    v2p116::key_t t;
    assign t = '{nib_t: a_i, byt_t: {4'h0, a_i}};
  end

  // r4  SELECT Lhs, TYPE-KEYED pattern.
  for (genvar i = 0; i < M; i++) begin : gen_r4
    assign karr[i] = '{nib_t: b_i, byt_t: {4'h1, b_i}};
  end

  // r5  whole-name Lhs, `default:`-ONLY pattern (slang memberSetters EMPTY).
  for (genvar i = 0; i < M; i++) begin : gen_r5
    v2p116::key_t t;
    assign t = '{default: 1'b0};
  end

  // r6  SELECT Lhs, `default:`-ONLY pattern.
  for (genvar i = 0; i < M; i++) begin : gen_r6
    assign darr[i] = '{default: 1'b1};
  end

  // r7  whole-name Lhs, member key + `default:` MIXED.
  for (genvar i = 0; i < M; i++) begin : gen_r7
    v2p116::key_t t;
    assign t = '{k_d: a_i, default: 1'b0};
  end

  // r8  SELECT Lhs, member key + `default:` MIXED.
  for (genvar i = 0; i < M; i++) begin : gen_r8
    assign xarr[i] = '{k_d: b_i, default: 1'b1};
  end

  // r9  SELECT Lhs, NESTED keyed pattern as a member value.
  for (genvar i = 0; i < M; i++) begin : gen_r9
    assign narr[i] = '{n_v: v_i, n_lo: '{g0: a_i, g1: b_i}};
  end

  // r10 MODULE-SCOPE select Lhs, keyed -- outside the gen-scope arm entirely.
  assign marr[0] = '{k_d: a_i, k_b: {4'h2, a_i}};

  assign v_o = rarr[0].m0[0] ^ karr[0].k_d[0] ^ darr[0].k_d[0] ^ xarr[0].k_d[0]
             ^ narr[0].n_v ^ marr[0].k_d[0];
endmodule
