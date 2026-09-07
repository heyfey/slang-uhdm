// r10earl112 arm g3 -- THE DEPTH and INDEX-FORM axes.  MEASUREMENT ONLY.
//
// earl110's law is gated on generate-nesting depth EXACTLY ONE.  This arm asks
// the same question of the pattern-carrier render: does the depth matter, and
// which INDEX FORMS take the value (a bare genvar, arithmetic on one, a
// gen-scope localparam, a MODULE parameter, a plain constant)?
package p112c;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module g3_depth112 #(parameter int M = 4, parameter int MP = 1) (
  input  p112c::h2d_t tl_h_i [M],
  output p112c::h2d_t o0_o,
  output p112c::h2d_t o1_o
);
  // d0  DEPTH 0 -- module body, no generate at all
  assign o0_o = '{ a_valid: tl_h_i[MP].a_valid, a_opcode: tl_h_i[MP].a_opcode,
                   a_data: tl_h_i[MP].a_data };

  // d1  DEPTH 1 -- the head's own depth, four index forms
  for (genvar i = 0; i < 2; i++) begin : gen_d1
    localparam int LB = 1;
    p112c::h2d_t e1, e2, e3, e4, e5;
    // e1 bare genvar
    assign e1 = '{ a_valid: tl_h_i[i].a_valid, a_opcode: tl_h_i[i].a_opcode,
                   a_data: tl_h_i[i].a_data };
    // e2 ARITHMETIC on the genvar
    assign e2 = '{ a_valid: tl_h_i[i+1].a_valid, a_opcode: tl_h_i[i+1].a_opcode,
                   a_data: tl_h_i[i+1].a_data };
    // e3 a GEN-SCOPE localparam
    assign e3 = '{ a_valid: tl_h_i[LB].a_valid, a_opcode: tl_h_i[LB].a_opcode,
                   a_data: tl_h_i[LB].a_data };
    // e4 a MODULE parameter
    assign e4 = '{ a_valid: tl_h_i[MP].a_valid, a_opcode: tl_h_i[MP].a_opcode,
                   a_data: tl_h_i[MP].a_data };
    // e5 a plain CONSTANT
    assign e5 = '{ a_valid: tl_h_i[2].a_valid, a_opcode: tl_h_i[2].a_opcode,
                   a_data: tl_h_i[2].a_data };
  end

  // d2  DEPTH 2 -- for inside for, and if inside for
  for (genvar j = 0; j < 2; j++) begin : gen_d2a
    for (genvar k = 0; k < 2; k++) begin : gen_d2b
      p112c::h2d_t f1;
      assign f1 = '{ a_valid: tl_h_i[j+k].a_valid,
                     a_opcode: tl_h_i[j+k].a_opcode,
                     a_data:  tl_h_i[j+k].a_data };
    end
  end
  for (genvar n = 0; n < 2; n++) begin : gen_d2c
    if (1) begin : gen_d2d
      p112c::h2d_t f2;
      assign f2 = '{ a_valid: tl_h_i[n].a_valid, a_opcode: tl_h_i[n].a_opcode,
                     a_data: tl_h_i[n].a_data };
    end
  end

  assign o1_o = gen_d1[0].e1;
endmodule
