// interface localparam holds the qualified select (instantiated)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
interface ifc;
  localparam logic [11:0] V = q2::IMPL.m;
  logic [11:0] w;
endinterface
module top(output logic [11:0] o);
  ifc u();
  assign o = u.w;
endmodule
