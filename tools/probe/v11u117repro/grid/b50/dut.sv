// port default select, overridden in generate-loop instances
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module leaf #(parameter logic [1:0] C = q2::IMPL.cfg)(output logic [1:0] o); assign o = C; endmodule
module top(output logic [3:0] o); for (genvar g = 0; g < 2; g++) begin : gg leaf #(.C(g[1:0])) u(.o(o[g*2+:2])); end endmodule
