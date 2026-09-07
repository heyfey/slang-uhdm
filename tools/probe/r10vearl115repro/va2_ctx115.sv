// r10vearl115 ADVERSARIAL ARM va2 -- THE CONTEXT AXIS.  MEASUREMENT ONLY.
//
// r10earl115's consumer walk declines the law below a module boundary crossed
// from inside a generate scope (`genAbove`), and it walks `interface_inst` the
// same way it walks `module_inst`.  These cells put BOTH under load with NO
// namesake anywhere in the hierarchy, which r10vearl113's `v4_ctx113` does not
// (its child carries r10earl113's own namesake shapes).
//
//   b1  a gen scope inside an INTERFACE                    -- law fires
//   b2  ONE child module, a gen-local pattern with NO namesake, instantiated
//       (i) at MODULE SCOPE (law fires) and (ii) INSIDE A GENERATE BLOCK
//       (fenced by `genAbove`).  If golden is BARE in the fenced copy the
//       fence is over-applied; if golden BINDS there the fence is right.
//   b3  a gen scope TWO levels deep (gen-for inside gen-for)  -- law fires
//   b4  a gen scope inside a module that is inside a module that is inside a
//       generate block (the fence must reach two levels down)
package v115c;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_op;
    logic [7:0] a_data;
  } h2d_t;
endpackage

interface vb_if115 #(parameter int M = 3) (input logic clk);
  v115c::h2d_t tl_h_i [M];
  logic [7:0]  d_i;
  // b1 -- a gen scope inside an interface.
  for (genvar i = 0; i < M; i++) begin : gen_b1
    v115c::h2d_t b1_t;
    assign b1_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
endinterface

module vb_child115 #(parameter int M = 3) (
  input  v115c::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  for (genvar i = 0; i < M; i++) begin : gen_b2
    v115c::h2d_t b2_t;
    assign b2_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
  assign y_o = gen_b2[0].b2_t.a_valid;
endmodule

module vb_mid115 #(parameter int M = 3) (
  input  v115c::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  // b4 -- one more module boundary below the generate block.
  vb_child115 #(.M(M)) u_deep (.tl_h_i(tl_h_i), .d_i(d_i), .y_o(y_o));
endmodule

module va2_ctx115 #(parameter int M = 3) (
  input  logic        clk,
  input  v115c::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  logic y_a, y_c, y_d;

  vb_if115 #(.M(M)) u_if (.clk(clk));

  // (i) child at MODULE SCOPE -- the law must fire inside it.
  vb_child115 #(.M(M)) u_a (.tl_h_i(tl_h_i), .d_i(d_i), .y_o(y_a));

  // (ii) the SAME child instantiated INSIDE a generate block -- fenced.
  for (genvar k = 0; k < 2; k++) begin : gen_inst
    logic y_g;
    vb_child115 #(.M(M)) u_c (.tl_h_i(tl_h_i), .d_i(d_i), .y_o(y_g));
    // b4 -- and one two modules deep below the same generate block.
    logic y_h;
    vb_mid115 #(.M(M)) u_m (.tl_h_i(tl_h_i), .d_i(d_i), .y_o(y_h));
  end

  // b3 -- TWO generate levels deep in THIS module (no module boundary).
  for (genvar i = 0; i < M; i++) begin : gen_b3
    for (genvar j = 0; j < 2; j++) begin : gen_b3i
      v115c::h2d_t b3_t;
      assign b3_t = '{ a_valid: tl_h_i[i].a_valid,
                       a_op:    tl_h_i[i].a_op,
                       a_data:  d_i };
    end
  end

  assign y_c = gen_inst[0].y_g;
  assign y_d = gen_inst[1].y_h;
  assign v_o = y_a ^ y_c ^ y_d ^ gen_b3[0].gen_b3i[0].b3_t.a_valid ^ u_if.gen_b1[0].b1_t.a_valid;
endmodule
