// v11u69 v4 — A MODULE INSTANCE INSIDE A GENERATE BLOCK, and the leaf has its
// own generate block.  Two different overrides reach the leaf through the
// generate loop, so the per-instance clone rule is measured one level deeper
// than `g9_child`, and the leaf's gen-scope Lhs is a module PORT.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 41};
  localparam cfg_t B = '{n: 42};
endpackage

module leaf #(parameter p::cfg_t C = p::A)
  (input logic a_i, output logic [31:0] o_g, output logic [15:0] o_nar);
  if (1) begin : lk
    assign o_g = C.n;          // module PORT Lhs, 32 bits
    assign o_nar = C.n;        // module PORT Lhs, 16 bits -> adjustSize masks
  end
endmodule

module dut (input logic a_i,
            output logic [31:0] o0, o1,
            output logic [15:0] n0, n1);
  for (genvar k = 0; k < 2; k++) begin : gg
    if (k == 0) begin : c0
      leaf #(.C(p::A)) u (.a_i(a_i), .o_g(o0), .o_nar(n0));
    end else begin : c1
      leaf #(.C(p::B)) u (.a_i(a_i), .o_g(o1), .o_nar(n1));
    end
  end
endmodule
