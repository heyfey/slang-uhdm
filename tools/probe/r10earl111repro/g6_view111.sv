// r10earl111 arm g6 -- THE DEF/ELAB VIEW AXIS.  One module instantiated TWICE
// with different overrides, so the database carries the DEFINITION copy and two
// ELABORATED copies of every select.  The census keys on the span, so the two
// views land in the SAME key with different multiplicities: if the law stamped
// only one view the count would split and the multiset join would say so.
package pk6111;
  typedef struct packed { logic [31:0] src; logic v; } h_t;
endpackage

module s6111 #(parameter int M = 2)
              (input pk6111::h_t h_i, output logic [63:0] o);
  localparam int unsigned W = 2;
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    assign r[1:0] = h_i.src[0 +: W];
  end
  assign o = r;
endmodule

module g6_view111;
  pk6111::h_t s;
  logic [63:0] o1, o2;
  s6111 #(.M(2)) u1 (.h_i(s), .o(o1));
  s6111 #(.M(3)) u2 (.h_i(s), .o(o2));
endmodule
