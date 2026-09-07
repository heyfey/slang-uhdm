// r10earl115 arm p1 -- THE POSITION AXIS.
// MEASUREMENT ONLY.
//
// The law says a pattern-carried `hier_path` in an ELABORATED generate-scope
// continuous assign binds its FIRST path element to the root object and leaves
// EVERY element after it bare.  This arm varies the path LENGTH so "first",
// "middle" and "trailing" are all populated by real cells rather than by one
// two-element shape read three ways:
//
//   n1  2 components  -> first + trailing
//   n2  3 components  -> first + ONE middle + trailing
//   n3  4 components  -> first + TWO middles + trailing
//   n4  2 components with a SELECT on the trailing element
//   n5  3 components with a SELECT on the MIDDLE element
//
// Every cell is the head-reproducing carrier: a generate-for at depth 1, a
// KEYED pattern in a continuous assign whose target is declared in that
// generate block and whose type is a packed struct.
package p115p;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       f0;
    logic [3:0] f1;
  } lo_t;
  typedef struct packed {
    lo_t        lo;
    logic [7:0] hi;
  } mid_t;
  typedef struct packed {
    mid_t       md;
    logic [7:0] tp;
  } top_t;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module p1_pos115 #(parameter int M = 3) (
  input  logic        clk,
  input  p115p::h2d_t two_i  [M],
  input  p115p::mid_t three_i[M],
  input  p115p::top_t four_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  // n1  TWO components: first (bit_select) + trailing (ref_obj).
  for (genvar i = 0; i < M; i++) begin : gen_n1
    p115p::h2d_t n1_t;
    assign n1_t = '{ a_valid:  two_i[i].a_valid,
                     a_opcode: p115p::OpA,
                     a_data:   d_i };
  end

  // n2  THREE components: first + ONE middle + trailing.
  for (genvar i = 0; i < M; i++) begin : gen_n2
    p115p::h2d_t n2_t;
    assign n2_t = '{ a_valid:  three_i[i].lo.f0,
                     a_opcode: p115p::OpA,
                     a_data:   d_i };
  end

  // n3  FOUR components: first + TWO middles + trailing.
  for (genvar i = 0; i < M; i++) begin : gen_n3
    p115p::h2d_t n3_t;
    assign n3_t = '{ a_valid:  four_i[i].md.lo.f0,
                     a_opcode: p115p::OpA,
                     a_data:   d_i };
  end

  // n4  TWO components, the TRAILING one selected.
  for (genvar i = 0; i < M; i++) begin : gen_n4
    p115p::h2d_t n4_t;
    assign n4_t = '{ a_valid:  two_i[i].a_data[0],
                     a_opcode: p115p::OpA,
                     a_data:   d_i };
  end

  // n5  THREE components, the MIDDLE one carrying the path's only select.
  for (genvar i = 0; i < M; i++) begin : gen_n5
    p115p::h2d_t n5_t;
    assign n5_t = '{ a_valid:  three_i[i].lo.f1[2],
                     a_opcode: p115p::OpA,
                     a_data:   d_i };
  end

  assign v_o = two_i[0].a_valid;
endmodule
