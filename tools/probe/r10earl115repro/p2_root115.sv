// r10earl115 arm p2 -- THE ROOT-KIND AXIS and THE DEPTH AXIS, on the ELEMENT
// BINDING field.  MEASUREMENT ONLY.
//
// r10earl114 measured the ROOT-KIND axis for the path's TYPESPEC edge; this arm
// repeats it for the per-element `Actual_group`, because the two fields are
// written by different code (`compileSelectExpression` vs UHDM's
// `hier_path::DeepClone` + `ElaboratorListener::leaveRef_obj`) and nothing says
// they must agree.
//
//   r1  PORT unpacked array of a typedef'd packed struct (the corpus root)
//   r2  MODULE-BODY unpacked array of the same struct
//   r3  a `wire`-declared array (an `array_net`, no typespec of its own)
//   d1..d3  the same leaf at generate depth 1, depth 2 and in a generate-IF.
//
// TWO CELLS WERE CUT AFTER BEING RUN, not guessed away: an UNDOTTED MODULE-BODY
// struct read from inside a generate scope (`mod_one.a_valid`) and a GEN-LOCAL
// struct root (`r5_src.a_valid`) both draw
// `[ERR:UH0725] Unresolved hierarchical reference` from Surelog's elaborator,
// so their golden is an error message rather than a measurement.  r10earl114's
// arm t1 cells r4/r5/r9/r10 already carry the gen-local half of that fence and
// the wide boundary re-scores them here.
package p115r;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module p2_root115 #(parameter int M = 3) (
  input  logic        clk,
  input  p115r::h2d_t port_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  p115r::h2d_t mod_arr [M];
  wire  p115r::h2d_t wire_arr [M];
  // r1  PORT unpacked array root.
  for (genvar i = 0; i < M; i++) begin : gen_r1
    p115r::h2d_t r1_t;
    assign r1_t = '{ a_valid:  port_i[i].a_valid,
                     a_opcode: p115r::OpA,
                     a_data:   d_i };
  end

  // r2  MODULE-BODY unpacked array root.
  for (genvar i = 0; i < M; i++) begin : gen_r2
    p115r::h2d_t r2_t;
    assign r2_t = '{ a_valid:  mod_arr[i].a_valid,
                     a_opcode: p115r::OpA,
                     a_data:   d_i };
  end

  // r3  `wire`-declared array root (an array_net).
  for (genvar i = 0; i < M; i++) begin : gen_r3
    p115r::h2d_t r3_t;
    assign r3_t = '{ a_valid:  wire_arr[i].a_valid,
                     a_opcode: p115r::OpA,
                     a_data:   d_i };
  end

  // d1  depth 1 (the control), d2 depth 2, d3 a generate-IF.
  for (genvar i = 0; i < M; i++) begin : gen_d1
    p115r::h2d_t d1_t;
    assign d1_t = '{ a_valid:  port_i[i].a_valid,
                     a_opcode: port_i[i].a_opcode,
                     a_data:   d_i };
  end

  for (genvar i = 0; i < M; i++) begin : gen_d2a
    for (genvar j = 0; j < 2; j++) begin : gen_d2b
      p115r::h2d_t d2_t;
      assign d2_t = '{ a_valid:  port_i[i].a_valid,
                       a_opcode: port_i[i].a_opcode,
                       a_data:   d_i };
    end
  end

  if (M > 1) begin : gen_d3
    p115r::h2d_t d3_t;
    assign d3_t = '{ a_valid:  port_i[0].a_valid,
                     a_opcode: port_i[0].a_opcode,
                     a_data:   d_i };
  end

  assign v_o = port_i[0].a_valid;
endmodule
