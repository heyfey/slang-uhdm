// port default select; one instance overrides, one keeps default
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module leaf #(parameter logic [1:0] C = q2::IMPL.cfg)(output logic [1:0] o); assign o = C; endmodule
module top(output logic [3:0] o); leaf #(.C(2'b01)) u(.o(o[1:0])); leaf v(.o(o[3:2])); endmodule
