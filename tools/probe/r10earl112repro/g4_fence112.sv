// r10earl112 arm g4 -- THE MUST-STAY FLOOR.  MEASUREMENT ONLY.
//
// earl110's § hpSelHalfOpParamFold110 deliberately SPELLS a genvar in the
// select half it folds (`tl_h_i[i].a_source[8 - 1-:2]`), THREE LINES from this
// pass's head.  This arm holds those cells beside the head's own, so an AWAY
// on earl110's floor is visible in the same census run:
//   h1  earl110's exact corpus shape, in a PLAIN cont_assign  -- MUST STAY
//   h2  the same select half INSIDE a pattern member value    -- the new face
//   h3  a genvar in a part-select `[l:r]` bound               -- MUST STAY
//   h4  a bit-select on the MEMBER (not the base)             -- MUST STAY
//   h5  a pattern with NO genvar anywhere                     -- MUST STAY
//   h6  the ROOT is an unpacked VARIABLE array, not a net -- the corpus's own
//       shape (golden's hier_path there carries a Typespec; the net-rooted one
//       does not), so the typespec face is measured rather than assumed.
package p112d;
  typedef struct packed {
    logic       a_valid;
    logic [7:0] a_source;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module g4_fence112 #(parameter int M = 3) (
  input  p112d::h2d_t tl_h_i [M],
  output logic [7:0]  q1_o,
  output logic [7:0]  q3_o,
  output logic [7:0]  q4_o,
  output p112d::h2d_t q5_o
);
  localparam int unsigned IDW   = 8;
  localparam int unsigned STIDW = 2;

  // h6's root: an unpacked array VARIABLE (not a net)
  p112d::h2d_t tl_v [M];
  always_comb tl_v = tl_h_i;

  for (genvar i = 0; i < M; i++) begin : gen_f
    p112d::h2d_t r2, r6;

    // h1  earl110's shape, PLAIN cont_assign: golden spells `i` and folds the
    //     parameter halves.  MUST STAY BYTE-IDENTICAL.
    assign q1_o = tl_h_i[i].a_source[IDW-1 -: STIDW];

    // h2  the SAME select half inside a PATTERN member value
    assign r2 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_source: {6'b0, tl_h_i[i].a_source[IDW-1 -: STIDW]},
                   a_data:   tl_h_i[i].a_data };

    // h3  a genvar in a plain part-select bound, plain cont_assign: MUST STAY
    assign q3_o = { 6'b0, tl_h_i[i].a_source[i+1 : i] };

    // h4  a bit-select on the MEMBER, plain cont_assign: MUST STAY
    assign q4_o = { 7'b0, tl_h_i[i].a_source[i] };

    // h5  a pattern with NO genvar: MUST STAY
    assign q5_o = '{ a_valid: 1'b1, a_source: 8'h5, a_data: 8'ha };

    // h6  the VARIABLE-rooted twin of the head
    assign r6 = '{ a_valid:  tl_v[i].a_valid,
                   a_source: tl_v[i].a_source,
                   a_data:   tl_v[i].a_data };
  end
endmodule
