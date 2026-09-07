// r10v112 arm v8 -- THE PATTERN KINDS THE GUARD DOES NOT COVER.
// MEASUREMENT ONLY.  slang has THREE assignment-pattern expression kinds;
// r10earl112 arms two of them (Structured, Simple).  This arm asks what golden
// does with the third (Replicated) and with the FLATTENED path
// (§ patFlatDidOrder27 returns before the guard is constructed), so the misses
// are named as residues rather than discovered later as surprises.
package pv8_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v8_repl112 #(parameter int M = 3) (
  input  pv8_112::h2d_t tl_h_i [M],
  output logic [7:0]    r1_o [4],
  output pv8_112::h2d_t r3_o
);
  for (genvar i = 0; i < M; i++) begin : gen_r
    logic [7:0]    r1 [4];
    pv8_112::h2d_t r2;

    // r1  a REPLICATED assignment pattern at the top of a gen-scope cont_assign
    assign r1 = '{4{tl_h_i[i].a_data}};   // unpacked target

    // r2  a REPLICATED pattern NESTED inside a structured one
    assign r2 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_opcode: 3'b0,
                   a_data:   {2{tl_h_i[i].a_valid, 3'b0}} };
  end

  assign r1_o = gen_r[0].r1;
  assign r3_o = gen_r[1].r2;
endmodule
