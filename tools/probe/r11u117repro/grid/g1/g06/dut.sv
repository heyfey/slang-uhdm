// typedef'd 2-D member selected whole: q2::IMPL.UnitTypes
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] UnitTypes; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, UnitTypes: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o);
  localparam logic [11:0] V = q2::IMPL.UnitTypes;
  assign o = V;
endmodule
