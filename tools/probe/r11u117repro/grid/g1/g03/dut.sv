// literal member value, module localparam select (pass-113 a30)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] UnitTypes; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, UnitTypes: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [5:0] o);
  localparam q2::row_t UT = q2::IMPL.UnitTypes[0];
  assign o = UT;
endmodule
