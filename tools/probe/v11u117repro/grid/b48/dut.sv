// localparam live only in the SECOND parameterization of the module
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module leaf #(parameter bit P = 0)(output logic [1:0] o);
  if (P) begin : g localparam logic [1:0] X = q2::IMPL.cfg; assign o = X; end
  else begin : h assign o = 2'b00; end
endmodule
module top(output logic [3:0] o); leaf #(.P(0)) a(.o(o[1:0])); leaf #(.P(1)) b(.o(o[3:2])); endmodule
