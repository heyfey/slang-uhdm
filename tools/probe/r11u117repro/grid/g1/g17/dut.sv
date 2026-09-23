// typedef'd 2-D member, INSTANCE parameter port default reads it (sgp_leaf default)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] UnitTypes; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, UnitTypes: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11 };
endpackage
module leaf #(parameter q2::row_t UT = q2::IMPL.UnitTypes[1]) (output logic [5:0] o);
  assign o = UT;
endmodule
module top(output logic [5:0] o);
  leaf u (.o(o));
endmodule
