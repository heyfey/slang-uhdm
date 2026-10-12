// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [3:0] pad; logic [5:0] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 6'h2A, cfg: 2'b11 };
endpackage
module top(output logic [1:0] o);
  localparam logic [1:0] X = q2::IMPL.cfg;
  assign o = X;
endmodule
