// instance override written directly: #(.UT(q2::IMPL.UnitTypes[0]))
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] UnitTypes; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, UnitTypes: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11 };
endpackage
module sgp_leaf #(parameter q2::row_t UT = '0) (input logic [2:0] a, output logic [2:0] o);
  for (genvar f = 0; f < 3; f++) begin : g
    if (UT[f] == 2'b01) begin : keep
      assign o[f] = a[f];
    end else begin : inv
      assign o[f] = ~a[f];
    end
  end
endmodule
module top(input logic [2:0] a, output logic [2:0] o);
  sgp_leaf #(.UT(q2::IMPL.UnitTypes[0])) u (.a(a), .o(o));
endmodule
