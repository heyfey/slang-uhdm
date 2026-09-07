// r10earl112 arm g2 -- THE CARRIER axis.  Which assignment-pattern CARRIER
// values the genvar, and which does not.  MEASUREMENT ONLY.
//
// The corpus head sits in a pattern that is the RHS of a gen-scope
// CONTINUOUS ASSIGN.  Every other place a pattern can sit is measured here on
// ONE golden, so the gate is chosen from the grid and not from the one cell.
package p112b;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    h2d_t       inner;
    logic [3:0] tag;
  } outer_t;
endpackage

module sink112b (input p112b::h2d_t p);
endmodule

module g2_carrier112 #(parameter int M = 3) (
  input  p112b::h2d_t   tl_h_i [M],
  output p112b::h2d_t   o1_o,
  output p112b::h2d_t   o2_o,
  output p112b::outer_t o3_o,
  output logic [7:0]    o4_o
);
  for (genvar i = 0; i < M; i++) begin : gen_c
    p112b::h2d_t   d1_ca;      // c1 cont_assign  RHS pattern   (the head)
    p112b::h2d_t   d2_ac;      // c2 always_comb  pattern
    p112b::h2d_t   d3_ini;     // c3 initial      pattern
    p112b::outer_t d4_nest;    // c4 NESTED pattern
    p112b::h2d_t   d6_dflt;    // c6 pattern with a `default` key
    logic [7:0]    d7_val;     // c7 the genvar as a MEMBER VALUE, not an index

    // c1  the head carrier
    assign d1_ca = '{ a_valid: tl_h_i[i].a_valid, a_opcode: tl_h_i[i].a_opcode,
                      a_data: tl_h_i[i].a_data };

    // c2  a PROCEDURAL pattern (always_comb)
    always_comb d2_ac = '{ a_valid: tl_h_i[i].a_valid,
                           a_opcode: tl_h_i[i].a_opcode,
                           a_data: tl_h_i[i].a_data };

    // c3  a PROCEDURAL pattern (initial)
    initial d3_ini = '{ a_valid: tl_h_i[i].a_valid,
                        a_opcode: tl_h_i[i].a_opcode,
                        a_data: tl_h_i[i].a_data };

    // c4  a NESTED pattern -- the inner one is the cell
    assign d4_nest = '{ inner: '{ a_valid: tl_h_i[i].a_valid,
                                  a_opcode: tl_h_i[i].a_opcode,
                                  a_data: tl_h_i[i].a_data },
                        tag: 4'h3 };

    // c5  a pattern handed to a child instance as a PORT ACTUAL
    sink112b u_s (.p('{ a_valid: tl_h_i[i].a_valid,
                        a_opcode: tl_h_i[i].a_opcode,
                        a_data: tl_h_i[i].a_data }));

    // c6  a `default` key beside a named member
    assign d6_dflt = '{ a_data: tl_h_i[i].a_data, default: '0 };

    // c7  the GENVAR ITSELF as a member value (no select at all)
    assign d7_val = { 4'h0, 4'(i) };

    // c8  a genvar-indexed path in a pattern operand that is an OPERATION.
    //     ITS OWN per-instance target: an arm cell whose target is driven by
    //     every unrolling at once has NO elaborated golden objects at all, and
    //     then the key's multiset cannot match on either binary -- the arm
    //     scores noise instead of the law.
    logic [7:0] d8_op;
    assign d8_op = '{ 0: tl_h_i[i].a_valid & tl_h_i[i].a_opcode[0],
                      default: 1'b0 };

    // c9  a genvar index on the MEMBER as well as on the base -- two bracket
    //     groups, both of which this law renders
    logic [7:0] d9_two;
    assign d9_two = '{ 0: tl_h_i[i].a_data[i], default: 1'b0 };
  end

  assign o4_o = gen_c[0].d8_op;

  assign o1_o = '{ a_valid: tl_h_i[0].a_valid, a_opcode: tl_h_i[0].a_opcode,
                   a_data: tl_h_i[0].a_data };
  assign o2_o = gen_c[1].d1_ca;
  assign o3_o = gen_c[2].d4_nest;
endmodule
