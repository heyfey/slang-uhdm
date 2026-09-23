// target shape: generate-loop localparam reads q2::IMPL.UnitTypes[grp], instance override
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
module top(input logic [5:0] a_i, output logic [5:0] o_o);
  for (genvar grp = 0; grp < 2; grp++) begin : gen_grps
    localparam q2::row_t UT = q2::IMPL.UnitTypes[grp];
    sgp_leaf #(.UT(UT)) u (.a(a_i[grp*3+:3]), .o(o_o[grp*3+:3]));
  end
endmodule
