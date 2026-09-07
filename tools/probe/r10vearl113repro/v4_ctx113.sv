// r10vearl113 (VERIFIER) arm v4 -- THE CONTEXT AXIS.  MEASUREMENT ONLY.
// The corpus head lives in a SUBMODULE instantiated inside another module's
// generate block, so every cell here moves the same gen-local pattern through
// a hierarchy instead of keeping it in the top module:
//   e1  a submodule with the head shape, instantiated TWICE at module scope
//   e2  the same submodule instantiated INSIDE a generate block
//   e3  a module-scope target of a submodule written from that submodule's own
//       generate block, one hierarchy level down (the fence, one level down)
//   e4  a gen block inside a module whose parameter differs per instance
package pv4113;
  typedef enum logic [2:0] { YA = 3'h0, YB = 3'h4 } ye_e;
  typedef struct packed {
    logic       v;
    ye_e        o;
    logic [7:0] d;
  } ys_t;
endpackage

module v4_leaf113 #(parameter int N = 2) (
  input  pv4113::ys_t tl_i [2],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  // gen-local target, one hierarchy level down
  for (genvar i = 0; i < N; i++) begin : gen_leaf
    pv4113::ys_t e_loc;
    assign e_loc = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  end
  // e3  MODULE-BODY target of THIS module written from THIS module's gen block
  pv4113::ys_t e3_mod;
  if (N > 0) begin : gen_leaf_mod
    assign e3_mod = '{ v: tl_i[1].v, o: tl_i[1].o, d: d_i };
  end
  assign y_o = e3_mod.v;
endmodule

module v4_ctx113 (
  input  logic        clk,
  input  pv4113::ys_t tl_i [2],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  logic a_o, b_o, c_o;
  // e1  the same submodule twice at module scope
  v4_leaf113 #(.N(2)) u_a (.tl_i(tl_i), .d_i(d_i), .y_o(a_o));
  v4_leaf113 #(.N(2)) u_b (.tl_i(tl_i), .d_i(d_i), .y_o(b_o));
  // e2  the submodule inside a generate block
  for (genvar i = 0; i < 2; i++) begin : gen_inst
    logic w;
    // e4  a differing parameter per instance
    v4_leaf113 #(.N(i + 1)) u_c (.tl_i(tl_i), .d_i(d_i), .y_o(w));
  end
  assign c_o = gen_inst[0].w ^ gen_inst[1].w;
  assign y_o = a_o ^ b_o ^ c_o;
endmodule
