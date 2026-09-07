// r10v190 arm 3 — THE BOUND SHAPES AT THE GATE'S EDGE, and MULTIPLICITY.
// The copier reproduces exactly three node kinds (constant / ref_obj /
// operation-without-attributes).  Anything else must make the gate ABSTAIN and
// share byte-for-byte as before the pass.  This arm puts the refused shapes
// next to the accepted ones, and repeats the head's OWN shape 1, 2 and 3 times
// (one typedef feeding one, two and three enums) — the BuildUVMPkg multiplicity
// that a shared vector makes invisible.
package pv3_190;
  parameter integer W1 = 14;
  parameter integer W2 = 6;
  parameter type    TP = logic;

  // --- accepted shapes
  typedef bit [W1-1 : 0]      t_op1;
  typedef enum t_op1 { s1_a = 0, s1_b = 1 } e_op1;          // x1

  typedef bit [W1-1 : 0]      t_op2;                        // SAME shape, x2
  typedef enum t_op2 { s2_a = 0, s2_b = 1 } e_op2_first;
  typedef enum t_op2 { s3_a = 0, s3_b = 1 } e_op2_second;

  typedef bit [W2 : 0]        t_op3;                        // x3
  typedef enum t_op3 { s4_a = 0, s4_b = 1 } e_op3_a;
  typedef enum t_op3 { s5_a = 0, s5_b = 1 } e_op3_b;
  typedef enum t_op3 { s6_a = 0, s6_b = 1 } e_op3_c;

  // --- shapes the copier's gate must REFUSE (share, unchanged)
  typedef bit [$clog2(W1)-1 : 0] t_sys;                     // system func call
  typedef enum t_sys { s7_a = 0, s7_b = 1 } e_sys;

  typedef bit [$bits(int)-1 : 0] t_bits;
  typedef enum t_bits { s8_a = 0, s8_b = 1 } e_bits;

  // --- a bound whose operands are BOTH parameters (two refs in one op)
  typedef bit [W1-W2 : 0] t_2ref;
  typedef enum t_2ref { s9_a = 0, s9_b = 1 } e_2dim;

  // --- a bound over a parameter of a PARAMETERIZED type
  typedef bit [W1-W2 : W2-W2] t_zero;
  typedef enum t_zero { sA_a = 0, sA_b = 1 } e_zero;

  // --- a signed base and a base with no range at all (gate abstains)
  typedef bit signed [W2-1 : 0] t_sgn;
  typedef enum t_sgn { sB_a = 0, sB_b = 1 } e_sgn;
  typedef bit t_norange;
  typedef enum t_norange { sC_a = 0, sC_b = 1 } e_norange;
endpackage

module v190_3_shapes;
  pv3_190::e_op1        v1;
  pv3_190::e_op2_first  v2;
  pv3_190::e_op2_second v3;
  pv3_190::e_op3_a      v4;
  pv3_190::e_op3_b      v5;
  pv3_190::e_op3_c      v6;
  pv3_190::e_sys        v7;
  pv3_190::e_bits       v8;
  pv3_190::e_2dim       v9;
  pv3_190::e_zero       vA;
  pv3_190::e_sgn        vB;
  pv3_190::e_norange    vC;
  initial begin
    v1 = pv3_190::s1_b; v2 = pv3_190::s2_b; v3 = pv3_190::s3_b;
    v4 = pv3_190::s4_b; v5 = pv3_190::s5_b; v6 = pv3_190::s6_b;
    v7 = pv3_190::s7_b; v8 = pv3_190::s8_b; v9 = pv3_190::s9_a;
    vA = pv3_190::sA_b; vB = pv3_190::sB_b; vC = pv3_190::sC_b;
  end
endmodule
