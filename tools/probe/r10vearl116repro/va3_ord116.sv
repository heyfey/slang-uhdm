// r10vearl116 ADVERSARIAL arm va3_ord116 — THE INDEX JOIN, OUT OF ORDER.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE ATTACK.  r10earl116 moved `flattenPatternCaRhs` from `patFlat9` to the
// WIDER `patStruct9`, so it now runs on a TAGGED operand list, which it never
// saw before.  Inside it the Root_value binding is a POSITIONAL INDEX JOIN
// between UHDM's operand vector and slang's `memberSetters`:
//
//     for (size_t i = 0; i < ops.size(); i++) {
//         opi116 = ops[i]; if tagged_pattern -> opi116 = ->Pattern();
//         if (opi116->UhdmType() != uhdmhier_path) continue;
//         b = stripImplicitConv(*ap.memberSetters[i].expr);   // <-- ops[i] vs
//         ...  hp114->Root_value(nit->second);                //     setters[i]
//
// Before the patch that join only ever ran over a list `reemitting` had just
// REBUILT, so the two orders were the same by construction.  Now it runs over
// the list `emitExpr` produced with the tagged wrappers left on.  If slang
// orders `memberSetters` by SOURCE and the emitted operands by DECLARATION
// (or vice versa), a pattern whose keys are written OUT OF DECLARATION ORDER
// binds `hier_path::Root_value` — a field `hier_path::Compare` READS — to the
// WRONG member's root object.  That is a silent, judged, patch-introduced
// mis-binding, and no arm in r10earl116repro writes a key out of order.
//
//   w1  SELECT Lhs, keys in DECLARATION order   (control)
//   w2  SELECT Lhs, keys REVERSED               (the attack)
//   w3  SELECT Lhs, keys ROTATED, mixed roots   (two DIFFERENT root arrays, so
//                                                a mis-join changes the NAME)
//   w4  MEMBER Lhs, keys REVERSED
//   w5  whole-name Lhs, keys REVERSED           (the still-flattened control)
//   w6  SELECT Lhs, keys reversed, SINGLE gen instance (1 vs 3 multiplicity)
package v3p116;
  typedef struct packed {
    logic       s_a;
    logic [3:0] s_b;
    logic [7:0] s_c;
  } t3_t;
  typedef struct packed {
    logic  o_v;
    t3_t   o_lo;
  } o3_t;
endpackage

module va3_ord116 #(
    parameter int M = 3
) (
    input  logic         clk,
    input  v3p116::t3_t  src_i [M],
    input  v3p116::t3_t  alt_i [M],
    output logic         v_o
);
  v3p116::t3_t oarr[M];   // w1
  v3p116::t3_t rarr[M];   // w2
  v3p116::t3_t marr[M];   // w3
  v3p116::t3_t sarr[1];   // w6

  // w1  CONTROL -- SELECT Lhs, keys in DECLARATION order.
  for (genvar i = 0; i < M; i++) begin : gen_w1
    assign oarr[i] = '{s_a: src_i[i].s_a, s_b: src_i[i].s_b, s_c: src_i[i].s_c};
  end

  // w2  THE ATTACK -- SELECT Lhs, keys written in REVERSE declaration order.
  for (genvar i = 0; i < M; i++) begin : gen_w2
    assign rarr[i] = '{s_c: src_i[i].s_c, s_b: src_i[i].s_b, s_a: src_i[i].s_a};
  end

  // w3  SELECT Lhs, keys ROTATED and drawn from TWO DIFFERENT root arrays, so a
  //     mis-join binds Root_value to a root with a DIFFERENT NAME.
  for (genvar i = 0; i < M; i++) begin : gen_w3
    assign marr[i] = '{s_b: alt_i[i].s_b, s_c: src_i[i].s_c, s_a: alt_i[i].s_a};
  end

  // w4  MEMBER Lhs, keys REVERSED.
  for (genvar i = 0; i < M; i++) begin : gen_w4
    v3p116::o3_t w4t;
    assign w4t.o_lo = '{s_c: src_i[i].s_c, s_b: alt_i[i].s_b, s_a: src_i[i].s_a};
  end

  // w5  CONTROL -- whole-name Lhs, keys REVERSED (this one STAYS FLAT).
  for (genvar i = 0; i < M; i++) begin : gen_w5
    v3p116::t3_t w5t;
    assign w5t = '{s_c: src_i[i].s_c, s_b: src_i[i].s_b, s_a: src_i[i].s_a};
  end

  // w6  SELECT Lhs, keys reversed, a SINGLE generate instance.
  for (genvar i = 0; i < 1; i++) begin : gen_w6
    assign sarr[i] = '{s_c: alt_i[0].s_c, s_b: alt_i[0].s_b, s_a: alt_i[0].s_a};
  end

  assign v_o = oarr[0].s_a ^ rarr[0].s_a ^ marr[0].s_a ^ sarr[0].s_a;
endmodule
