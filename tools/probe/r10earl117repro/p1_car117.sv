// r10earl117 arm p1_car117 — THE CARRIER AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// ONE for-generate at depth 1, ONE keyed assignment pattern, the SAME genvar
// `i` in every index, and the CARRIER of that index varied one member at a
// time.  Every cell is a continuous assign inside the generate body, which is
// the only position the law's gate (a) admits.
//
//   c1  bit-select on a MODULE-SCOPE PACKED VECTOR   <- the corpus head
//   c2  bit-select on a GEN-LOCAL packed vector
//   c3  element index of an unpacked array of structs, dotted (earl112's own
//       carrier — already golden's before this pass, and it must stay so)
//   c4  element of an unpacked array, then a bit of it
//   c5  a 2-D packed select, the genvar in the FIRST and in the SECOND bracket
//   c6  a PART-SELECT's two bounds
//   c7  an INDEXED PART-SELECT's base
//   c8  bit-select on a PORT input vector
//   c9  the pattern's own Lhs select index  (pattern depth 0 — must stay)
//   c10 a bit-select in the SAME gen scope in a PLAIN cont_assign (control)
package p1p117;
  typedef struct packed {
    logic       f_v;
    logic [2:0] f_o;
  } s_t;
  typedef struct packed {
    logic       g_a;
    logic       g_b;
    logic [1:0] g_c;
    logic [1:0] g_d;
    logic [1:0] g_e;
    logic       g_f;
    logic       g_g;
  } w_t;
endpackage

module p1_car117 #(
    parameter int M = 3
) (
    input  logic [M-1:0]  pin,
    input  p1p117::s_t    sin,
    output logic [M-1:0]  q
);
  logic [M:0]            v;        // module-scope packed vector (one bit wide
                                   // enough for the c6 part-select bounds)
  logic [M-1:0]          ua [M];   // unpacked array of packed vectors
  logic [M-1:0][M-1:0]   m2;       // 2-D packed
  p1p117::s_t            sarr [M]; // unpacked array of packed structs
  p1p117::w_t            wout [M];
  logic [M-1:0]          plain;

  assign v  = {1'b0, pin};
  assign m2 = {M{pin}};
  for (genvar k = 0; k < M; k++) begin : gen_fill
    assign sarr[k] = sin;
    assign ua[k]   = pin;
  end

  for (genvar i = 0; i < M; i++) begin : gen_body
    logic [M-1:0] gv;                    // gen-LOCAL packed vector
    assign gv = pin;

    // c1..c8 all live in ONE keyed pattern so the pattern shape is held fixed
    // and only the carrier moves.  c9 is this assignment's own Lhs index.
    assign wout[i] = '{
      g_a: v[i],                         // c1  MODULE-SCOPE PACKED VECTOR
      g_b: gv[i],                        // c2  GEN-LOCAL packed vector
      g_c: {sarr[i].f_v, ua[i][0]},      // c3 dotted element / c4 unpacked elem
      g_d: {m2[i][0], m2[0][i]},         // c5  2-D, both brackets
      g_e: v[i+1:i],                     // c6  PART-SELECT bounds
      g_f: |v[i +: 1],                   // c7  INDEXED PART-SELECT base
      g_g: pin[i]                        // c8  PORT input vector
    };
    // c10: the CONTROL — the same bit-selects, same scope, PLAIN cont_assign.
    assign plain[i] = v[i] & gv[i] & pin[i];
  end

  assign q = plain ^ {wout[0].g_a, wout[1].g_b, wout[2].g_f};
endmodule
