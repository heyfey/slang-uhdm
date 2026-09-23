// witness: typedef'd 2-D array member, concat of six 2-bit literals; package pattern read as pkg::IMPL.member
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] UnitTypes; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, UnitTypes: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11 };
endpackage
module top(output logic [5:0] o);
  localparam q2::row_t UT = q2::IMPL.UnitTypes[0];
  assign o = UT;
endmodule
