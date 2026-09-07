// r10earl117 arm p3_fence117 — THE FENCES and THE INDEX-FORM AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE USER-CALL FENCE, carried over from § patCaGenIdxNeverInUserCallArg112v
// and re-measured on THIS carrier (a bare bit-select, not a dotted path):
//   k1  f8(v[i])                    a USER call's argument
//   k2  $unsigned(v[i])             a SYSTEM call's argument
//   k3  f8($unsigned(v[i]))         system inside user
//   k4  $unsigned(f8(v[i]))         user inside system
//   k5  f8(f8(v[i]))                user inside user
//   k6  4'(v[i])                    a CAST
//   k7  v[i] ? 4'h1 : 4'h2          a ternary CONDITION inside the value
//
// THE INDEX-FORM AXIS, same carrier, same position:
//   e1  bare genvar `i`
//   e2  arithmetic `i+1`
//   e3  a GEN-SCOPE localparam `LB`
//   e4  a MODULE parameter `MP`
//   e5  a literal
//
// THE MUST-STAY FLOOR (earl110's § hpSelHalfOpParamFold110 cells):
//   h1  tl_h_i[i].a_source[IDW-1 -: STIDW] in a PLAIN cont_assign
//   h2  the SAME select half INSIDE a pattern member value
//   h3  a genvar in a part-select bound, plain cont_assign
package p3p117;
  typedef struct packed {
    logic [3:0] w;
    logic [3:0] x;
    logic [3:0] y;
    logic [3:0] z;
  } q_t;
  typedef struct packed {
    logic       a_valid;
    logic [7:0] a_source;
  } h_t;
  typedef struct packed {
    logic [3:0] p1;
    logic [3:0] p2;
  } pb_t;
  typedef struct packed {
    logic [1:0] r1;
    logic [1:0] r2;
  } h2_t;
endpackage

module p3_fence117 #(
    parameter int M     = 3,
    parameter int MP    = 1,
    parameter int IDW   = 8,
    parameter int STIDW = 2
) (
    input  logic [7:0]     pin,
    input  p3p117::h_t     tl_h_i [M],
    output logic [3:0]     q
);
  logic [7:0]   v;
  p3p117::q_t   ok [M];
  p3p117::q_t   oe [M];
  logic [1:0]   hs [M];
  logic [3:0]   hp [M];
  p3p117::pb_t  pb [M];

  assign v = pin;

  function automatic logic [3:0] f8(input logic [3:0] a);
    return a ^ 4'h5;
  endfunction

  for (genvar i = 0; i < M; i++) begin : gen_f
    localparam int LB = 1;

    // THE FENCE CELLS
    assign ok[i] = '{
      w: f8({3'b0, v[i]}),                      // k1  USER call argument
      x: $unsigned({3'b0, v[i]}),               // k2  SYSTEM call argument
      y: f8($unsigned({3'b0, v[i]})),           // k3  system in user
      z: $unsigned(f8({3'b0, v[i]}))            // k4  user in system
    };
    assign hp[i] = f8(f8({3'b0, v[i]}));        // k5  user in user (plain CA)

    // THE INDEX-FORM CELLS
    assign oe[i] = '{
      w: {3'b0, v[i]},                          // e1  bare genvar
      x: {3'b0, v[i+1]},                        // e2  arithmetic
      y: {3'b0, v[LB]},                         // e3  gen-scope localparam
      z: {3'b0, v[MP]}                          // e4  module parameter
    };

    // k6 CAST and k7 a ternary condition, both inside a pattern member value
    assign pb[i] = '{p1: 4'(v[i]), p2: (v[i] ? 4'h1 : 4'h2)};

    // THE MUST-STAY FLOOR
    // h1 earl110's own shape in a PLAIN cont_assign
    assign hs[i] = tl_h_i[i].a_source[IDW-1 -: STIDW];
  end

  // h2 the SAME select half INSIDE a pattern member value, and h3 a genvar in
  // a part-select bound — both in a second generate so the shapes do not share
  // a scope with the fence cells above.
  p3p117::h2_t h2o [M];
  logic [1:0] h3o [M];
  for (genvar g = 0; g < M; g++) begin : gen_h
    assign h2o[g] = '{r1: tl_h_i[g].a_source[IDW-1 -: STIDW], r2: 2'b00};
    assign h3o[g] = v[g+1:g];
  end

  assign q = {ok[0].w[0], oe[0].w[0], hs[0][0] ^ h2o[0].r1[0] ^ h3o[0][0],
              hp[0][0] ^ pb[0].p1[0]};
endmodule
