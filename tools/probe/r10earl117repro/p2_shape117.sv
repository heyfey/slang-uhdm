// r10earl117 arm p2_shape117 — THE PATTERN-SHAPE AXIS and THE DEPTH AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The CARRIER is held fixed at the head's own — a bit-select on a module-scope
// packed vector, index a bare genvar — and the SHAPE that carries it moves:
//
//   s1  keyed member value, gen depth 1                    (the baseline)
//   s2  POSITIONAL element
//   s3  a pattern NESTED inside a pattern
//   s4  a `default:` key's value
//   s5  a pattern in an ALWAYS_COMB in the generate body
//   s6  a pattern in an INITIAL in the generate body
//   s7  a pattern in a cont_assign at generate DEPTH 2 (for in for)
//   s8  a pattern inside a GENERATE-IF nested in the for
//   s9  a pattern at generate DEPTH 0 (module body), index a module parameter
//   s10 a gen-scope pattern writing a MODULE-SCOPE whole-name target
package p2p117;
  typedef struct packed {
    logic       a;
    logic       b;
    logic [1:0] c;
  } t_t;
endpackage

module p2_shape117 #(
    parameter int M  = 3,
    parameter int MP = 1
) (
    input  logic [M-1:0] pin,
    output logic [M-1:0] q
);
  logic [M-1:0] v;
  p2p117::t_t   o1 [M];
  p2p117::t_t   o2 [M];
  p2p117::t_t   o4 [M];
  p2p117::t_t   o5 [M];
  p2p117::t_t   o6 [M];
  p2p117::t_t   o7 [M][2];
  p2p117::t_t   o8 [M];
  p2p117::t_t   o9;
  p2p117::t_t   o10;
  logic [1:0]   n3 [M];

  assign v = pin;

  for (genvar i = 0; i < M; i++) begin : gen_s
    // s1 KEYED member value
    assign o1[i] = '{a: v[i], b: 1'b0, c: 2'b01};
    // s2 POSITIONAL element
    assign o2[i] = '{v[i], 1'b0, 2'b01};
    // s3 a pattern NESTED inside a pattern
    assign n3[i] = '{v[i], 1'b1};
    // s4 a `default:` key
    assign o4[i] = '{default: v[i]};
    // s5 an ALWAYS_COMB in the generate body
    always_comb o5[i] = '{a: v[i], b: 1'b0, c: 2'b10};
    // s6 an INITIAL in the generate body
    initial o6[i] = '{a: v[i], b: 1'b1, c: 2'b11};
    // s7 generate DEPTH 2
    for (genvar j = 0; j < 2; j++) begin : gen_s2
      assign o7[i][j] = '{a: v[i], b: 1'b0, c: 2'b00};
    end
    // s8 a GENERATE-IF nested in the for
    if (M > 1) begin : gen_if
      assign o8[i] = '{a: v[i], b: 1'b1, c: 2'b01};
    end
    // s10 a gen-scope pattern whose target is a MODULE-SCOPE whole name
    if (i == 0) begin : gen_mod
      assign o10 = '{a: v[i], b: 1'b0, c: 2'b11};
    end
  end

  // s9 generate DEPTH 0 — the module body, index a MODULE PARAMETER
  assign o9 = '{a: v[MP], b: 1'b0, c: 2'b10};

  assign q = {o1[0].a ^ o2[1].a ^ n3[0][0],
              o4[0].a ^ o5[0].a ^ o6[0].a ^ o7[0][0].a,
              o8[0].a ^ o9.a ^ o10.a};
endmodule
