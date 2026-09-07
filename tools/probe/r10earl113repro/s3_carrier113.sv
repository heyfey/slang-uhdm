// r10earl113 arm s3 -- THE CARRIER AXIS.  MEASUREMENT ONLY.
//
// The same keyed struct pattern, same first-operand shape, carried by a
// continuous assign, an always_comb, an initial, a variable initializer and a
// localparam -- at MODULE scope and at generate depth 1.  Surelog sizes a
// pattern's FIRST operand only where `CompileHelper::expandPatternAssignment`
// runs (`UhdmWriter::writeCont_assign`, UhdmWriter.cpp:2178, and
// `NetlistElaboration`'s param path); the generate unrolling's
// `cont_assign::DeepClone` flatten never calls it.  A procedural assignment
// goes through neither, so the carrier is an axis this law's gate must be
// measured against and not assumed.
package r113;
  typedef enum logic [2:0] { RA = 3'h0, RB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module s3_carrier113 #(parameter int M = 3) (
  input  logic        clk,
  input  r113::h2d_t  tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  // ---- MODULE SCOPE ----------------------------------------------------
  r113::h2d_t c1_mod;
  assign c1_mod = '{ a_valid: tl_h_i[0].a_valid, a_opcode: r113::RA,
                     a_data:  d_i };                              // cont_assign

  r113::h2d_t c2_mod;
  always_comb c2_mod = '{ a_valid: tl_h_i[0].a_valid, a_opcode: r113::RA,
                          a_data:  d_i };                         // always_comb

  r113::h2d_t c3_mod;
  initial c3_mod = '{ a_valid: 1'b1, a_opcode: r113::RA,
                      a_data:  8'hAA };                           // initial

  r113::h2d_t c4_mod = '{ a_valid: 1'b1, a_opcode: r113::RA,
                          a_data:  8'hAA };                       // var init

  localparam r113::h2d_t C5_MOD = '{ a_valid: 1'b1, a_opcode: r113::RA,
                                     a_data:  8'hAA };            // localparam

  // ---- GENERATE DEPTH 1 ------------------------------------------------
  for (genvar i = 0; i < M; i++) begin : gen_c
    r113::h2d_t c1_gen;
    assign c1_gen = '{ a_valid: tl_h_i[i].a_valid, a_opcode: r113::RA,
                       a_data:  d_i };                            // cont_assign

    r113::h2d_t c2_gen;
    always_comb c2_gen = '{ a_valid: tl_h_i[i].a_valid, a_opcode: r113::RA,
                            a_data:  d_i };                       // always_comb

    r113::h2d_t c3_gen;
    initial c3_gen = '{ a_valid: 1'b1, a_opcode: r113::RA,
                        a_data:  8'hAA };                         // initial

    r113::h2d_t c4_gen = '{ a_valid: 1'b1, a_opcode: r113::RA,
                            a_data:  8'hAA };                     // var init

    localparam r113::h2d_t C5_GEN = '{ a_valid: 1'b1, a_opcode: r113::RA,
                                       a_data:  8'hAA };          // localparam
  end

  assign v_o = c1_mod.a_valid ^ C5_MOD.a_valid ^ c2_mod.a_valid;
endmodule
